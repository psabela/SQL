select 
       SFRSTCR_PIDM ,
       SFRSTCR_CRN                                       REGIST_CRN,
       SSBSECT_SSTS_CODE                              CLASS_ACTV_INACTV_CANC,
--      SFRSTCR_LEVL_CODE                              REGIST_COURSE_LEVEL,
       SFRSTCR_TERM_CODE                              REGIST_TERM_CODE,
       SFRSTCR_CREDIT_HR                              REGIST_CREDIT_HR,
       SFRSTCR_BILL_HR                                REGIST_BILL_HR,
       SFRSTCR_RSTS_CODE                              REGIST_STATUS, 
       SFRSTCR_ADD_DATE                                REGIST_ADD_DATE, 
       to_char(SFRSTCR_ADD_DATE , 'HH24') as REGIST_ADD_HOUR24,
       SFRSTCR_RSTS_DATE                              REGIST_STATUS_DATE,
       to_char(SFRSTCR_RSTS_DATE , 'HH24') as REGIST_STATUS_HOUR24,
       
      (SELECT SFBETRM_ADD_DATE FROM sfbetrm WHERE SFBETRM_PIDM = SFRSTCR_PIDM AND SFBETRM_TERM_CODE = SFRSTCR_TERM_CODE)   REGISTRATION_DATE,
--       SSBSECT_CRSE_NUMB                              SECTION_COURSE_NO, 
--       SSBSECT_SEQ_NUMB                               SECTION_SEQ_NO,
--       SSBSECT_TUIW_IND                               SECTION_WAIVER, 
--       SSBSECT_CAMP_CODE                              SECTION_CAMPUS_CODE, 
       SSBSECT_PTRM_START_DATE                        SECTION_PTRM_START_DATE, 
       SSBSECT_PTRM_END_DATE                          SECTION_PTRM_END_DATE,  
       SSBSECT_PTRM_CODE                              SECTION_PTRM_CODE, 
       CAMPUS.ZONE,
       --REFUND CALCULATION
       CASE WHEN SFRSTCR_RSTS_CODE not like 'R%' THEN
         CASE WHEN SUBSTR(SFRSTCR_TERM_CODE,-2,2) IN ('01','03') AND CAMPUS.ZONE = 'Campus' 
                   THEN /*ON-CAMPUS/Fall/Spring*/
                        CASE 
                          WHEN SFRSTCR_RSTS_DATE < SSBSECT_PTRM_START_DATE THEN 100
                          WHEN SFRSTCR_RSTS_DATE BETWEEN SSBSECT_PTRM_START_DATE AND SSBSECT_PTRM_START_DATE + 7 THEN 90
                          WHEN SFRSTCR_RSTS_DATE BETWEEN SSBSECT_PTRM_START_DATE + (1*7) + 1 AND SSBSECT_PTRM_START_DATE + (2*7) THEN 60
                          WHEN SFRSTCR_RSTS_DATE BETWEEN SSBSECT_PTRM_START_DATE + (2*7) + 1 AND SSBSECT_PTRM_START_DATE + (3*7) THEN 40
                          WHEN SFRSTCR_RSTS_DATE BETWEEN SSBSECT_PTRM_START_DATE + (3*7) + 1 AND SSBSECT_PTRM_START_DATE + (4*7) THEN 25
                          ELSE 0 END
                   WHEN SUBSTR(SFRSTCR_TERM_CODE,-2,2) IN ('02') AND CAMPUS.ZONE = 'Campus' 
                   THEN /*ON-CAMPUS/Summer*/
                        CASE 
                         WHEN SFRSTCR_RSTS_DATE < SSBSECT_PTRM_START_DATE THEN 100
                         WHEN SFRSTCR_RSTS_DATE BETWEEN SSBSECT_PTRM_START_DATE AND SSBSECT_PTRM_START_DATE + 7 THEN  85
                              --(SELECT SFRRFCR_TUIT_REFUND FROM  SFRRFCR WHERE SFRRFCR_TERM_CODE = SFRSTCR_TERM_CODE AND SFRRFCR_PTRM_CODE = SSBSECT_PTRM_CODE AND SFRRFCR_RSTS_CODE = SFRSTCR_RSTS_CODE)
                        ELSE 0 END
                   WHEN CAMPUS.ZONE = 'Off-Campus' 
                   THEN /*Off-Campus*/  
                        CASE 
                        WHEN SFRSTCR_RSTS_DATE < SSBSECT_PTRM_START_DATE THEN 100
                        WHEN SFRSTCR_RSTS_DATE < class_schd.MEETING_3 THEN 90
                        WHEN SFRSTCR_RSTS_DATE < class_schd.MEETING_5 THEN 50
                        ELSE 0 END                   
                   WHEN CAMPUS.ZONE = 'Online' 
                   THEN /*Online*/ 
                         CASE 
                        WHEN SFRSTCR_RSTS_DATE < SSBSECT_PTRM_START_DATE THEN 100
                        WHEN SFRSTCR_RSTS_DATE BETWEEN SSBSECT_PTRM_START_DATE AND SSBSECT_PTRM_START_DATE + 7 THEN 90
                        WHEN SFRSTCR_RSTS_DATE BETWEEN SSBSECT_PTRM_START_DATE + (1*7) + 1 AND SSBSECT_PTRM_START_DATE + (2*7) THEN 90
                        WHEN SFRSTCR_RSTS_DATE BETWEEN SSBSECT_PTRM_START_DATE + (2*7) + 1 AND SSBSECT_PTRM_START_DATE + (3*7) THEN 50
                        WHEN SFRSTCR_RSTS_DATE BETWEEN SSBSECT_PTRM_START_DATE + (3*7) + 1 AND SSBSECT_PTRM_START_DATE + (4*7) THEN 50
                        ELSE 0 END
                   WHEN  CAMPUS.ZONE != 'Campus'  AND SCBCRSE_DEPT_CODE IN ('EMSE','NGO')
                   THEN /*EMSE + NGO*/ 
                        CASE 
                        WHEN SFRSTCR_RSTS_DATE < SSBSECT_PTRM_START_DATE THEN 100
                        WHEN SFRSTCR_RSTS_DATE < class_schd.MEETING_3 THEN 90
                        WHEN SFRSTCR_RSTS_DATE < class_schd.MEETING_6 THEN 50 
                        ELSE 0 END
                   END
      END AS REFUND_TUI_PERCENT
FROM
      sfrstcr,
      ssbsect,
      SCBCRSE,
      (select stvcamp_code,stvcamp_desc, stvcamp_dicd_code, case stvcamp_dicd_code
            when 'OE' then 'Online'
            when '02' then 'Off-Campus'
            when '03' then 'Off-Campus'
            else 'Campus' end as "ZONE" from stvcamp) campus,
      (SELECT  
         TERM, 
          CRN, 
          SCHEDULE_DESC,
          MEETINGS,
          START_DATE AS MEETING1,  
          START_DATE + MEETING_2 AS MEETING_2,
          START_DATE + MEETING_2 + MEETING_3 AS MEETING_3,
          START_DATE + MEETING_2 + MEETING_3 + MEETING_4 AS MEETING_4,
          START_DATE + MEETING_2 + MEETING_3 + MEETING_4 + MEETING_5 AS MEETING_5,
          START_DATE + MEETING_2 + MEETING_3 + MEETING_4 + MEETING_5 + MEETING_6 AS MEETING_6
        FROM (select 
              schedule.TERM,
              schedule.CRN,
              schedule.START_DATE,
              schedule.SCHEDULE_DESC,
              schedule.MEETINGS,
              CASE substr(schedule.days,1,1)
              WHEN 'U' THEN INSTR('UMTWRFSU',substr(schedule.days,2,1),2)-1
              WHEN 'M' THEN INSTR('MTWRFSUM',substr(schedule.days,2,1),2)-1
              WHEN 'T' THEN INSTR('TWRFSUMT',substr(schedule.days,2,1),2)-1
              WHEN 'W' THEN INSTR('WRFSUMTW',substr(schedule.days,2,1),2)-1
              WHEN 'R' THEN INSTR('RFSUMTWR',substr(schedule.days,2,1),2)-1
              WHEN 'F' THEN INSTR('FSUMTWRF',substr(schedule.days,2,1),2)-1
              WHEN 'S' THEN INSTR('SUMTWRFS',substr(schedule.days,2,1),2)-1
              END AS MEETING_2,  
              CASE substr(schedule.days,2,1)
              WHEN 'U' THEN INSTR('UMTWRFSU',substr(schedule.days,3,1),2)-1
              WHEN 'M' THEN INSTR('MTWRFSUM',substr(schedule.days,3,1),2)-1
              WHEN 'T' THEN  INSTR('TWRFSUMT',substr(schedule.days,3,1),2)-1
              WHEN 'W' THEN INSTR('WRFSUMTW',substr(schedule.days,3,1),2)-1
              WHEN 'R' THEN  INSTR('RFSUMTWR',substr(schedule.days,3,1),2)-1
              WHEN 'F' THEN INSTR('FSUMTWRF',substr(schedule.days,3,1),2)-1
              WHEN 'S' THEN INSTR('SUMTWRFS',substr(schedule.days,3,1),2)-1
              END AS MEETING_3,  
              CASE substr(schedule.days,3,1)
              WHEN 'U' THEN INSTR('UMTWRFSU',substr(schedule.days,4,1),2)-1
              WHEN 'M' THEN INSTR('MTWRFSUM',substr(schedule.days,4,1),2)-1
              WHEN 'T' THEN  INSTR('TWRFSUMT',substr(schedule.days,4,1),2)-1
              WHEN 'W' THEN INSTR('WRFSUMTW',substr(schedule.days,4,1),2)-1
              WHEN 'R' THEN  INSTR('RFSUMTWR',substr(schedule.days,4,1),2)-1
              WHEN 'F' THEN INSTR('FSUMTWRF',substr(schedule.days,4,1),2)-1
              WHEN 'S' THEN INSTR('SUMTWRFS',substr(schedule.days,4,1),2)-1
              END AS MEETING_4,  
               CASE substr(schedule.days,4,1)
              WHEN 'U' THEN INSTR('UMTWRFSU',substr(schedule.days,5,1),2)-1
              WHEN 'M' THEN INSTR('MTWRFSUM',substr(schedule.days,5,1),2)-1
              WHEN 'T' THEN  INSTR('TWRFSUMT',substr(schedule.days,5,1),2)-1
              WHEN 'W' THEN INSTR('WRFSUMTW',substr(schedule.days,5,1),2)-1
              WHEN 'R' THEN  INSTR('RFSUMTWR',substr(schedule.days,5,1),2)-1
              WHEN 'F' THEN INSTR('FSUMTWRF',substr(schedule.days,5,1),2)-1
              WHEN 'S' THEN INSTR('SUMTWRFS',substr(schedule.days,5,1),2)-1
              END AS MEETING_5,  
              CASE substr(schedule.days,5,1)
              WHEN 'U' THEN INSTR('UMTWRFSU',substr(schedule.days,6,1),2)-1
              WHEN 'M' THEN INSTR('MTWRFSUM',substr(schedule.days,6,1),2)-1
              WHEN 'T' THEN  INSTR('TWRFSUMT',substr(schedule.days,6,1),2)-1
              WHEN 'W' THEN INSTR('WRFSUMTW',substr(schedule.days,6,1),2)-1
              WHEN 'R' THEN  INSTR('RFSUMTWR',substr(schedule.days,6,1),2)-1
              WHEN 'F' THEN INSTR('FSUMTWRF',substr(schedule.days,6,1),2)-1
              WHEN 'S' THEN INSTR('SUMTWRFS',substr(schedule.days,6,1),2)-1
              END AS MEETING_6 
        from 
              (select 
              SSRMEET_TERM_CODE AS TERM, 
              SSRMEET_CRN AS CRN, 
              SSRMEET_START_DATE AS START_DATE,
              (select STVSCHD_DESC from STVSCHD where STVSCHD_CODE = SSRMEET_SCHD_CODE) SCHEDULE_DESC,
              SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY AS MEETINGS,
              --first six meetings
              substr(
              SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY 
              ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY 
              ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY 
              ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY 
              ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY 
              ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY
              ,1,6)
              as days
              from SSRMEET
              where SSRMEET_TERM_CODE = '201502')schedule)) class_schd 
WHERE          
        sfrstcr_term_code = '201502'
        and SFRSTCR_RSTS_CODE not like 'R%'
        and  (SFRSTCR_CREDIT_HR  > 0 or  SFRSTCR_BILL_HR > 0)
        and SSBSECT_TERM_CODE = sfrstcr_term_code
        and SSBSECT_CRN = SFRSTCR_CRN
        and SSBSECT_TERM_CODE = class_schd.TERM (+)
        and SSBSECT_CRN = class_schd.CRN (+)
        and SCBCRSE_SUBJ_CODE = SSBSECT_SUBJ_CODE
        and SCBCRSE_CRSE_NUMB = SSBSECT_CRSE_NUMB
        and SSBSECT_CAMP_CODE = campus.stvcamp_code;
    