select distinct 
     (select spriden_id from spriden
        where spriden_pidm = SGBSTDN_PIDM
        and spriden_change_ind is null)  STU_GWID,
       SGBSTDN_PIDM                                   STU_PIDM,    
       SGBSTDN_LEVL_CODE                              STU_LEVEL_CODE,
       SGBSTDN_COLL_CODE_1                            STU_ENROLL_COLLEGE_CODE,
       SGBSTDN_RATE_CODE                              STU_RATE_CODE,
       SGBSTDN_DEGC_CODE_1                            STU_DEGREE_CODE,    
       (select STVDEGC_DESC from stvdegc where STVDEGC_CODE = SGBSTDN_DEGC_CODE_1) STU_DEGREE,
       SGBSTDN_MAJR_CODE_1                            STU_MAJOR_CODE,
       (select STVMAJR_DESC from stvMAJR where STVMAJR_CODE = SGBSTDN_MAJR_CODE_1) STU_MAJOR,
       SGBSTDN_TERM_CODE_ADMIT                        STU_TERM_CODE_ADMIT,   
       SGBSTDN_STYP_CODE                              STU_STYP,
       SGBSTDN_CAMP_CODE                              STU_CAMPUS,  
       SFRSTCR_CRN                                    REGIST_CRN,
       
       SSBSECT_SSTS_CODE                              CLASS_ACTV_INACTV_CANC,
       SFRSTCR_LEVL_CODE                              REGIST_COURSE_LEVEL,
       SFRSTCR_TERM_CODE                              REGIST_TERM_CODE,
       SFRSTCR_CREDIT_HR                              REGIST_CREDIT_HR,
       SFRSTCR_BILL_HR                                REGIST_BILL_HR,
       SFRSTCR_RSTS_CODE                              REGIST_STATUS, 
       SFRSTCR_ADD_DATE                                REGIST_ADD_DATE, 
       to_char(SFRSTCR_ADD_DATE , 'HH24') as REGIST_ADD_HOUR24,
       SFRSTCR_RSTS_DATE                              REGIST_STATUS_DATE,
       to_char(SFRSTCR_RSTS_DATE , 'HH24') as REGIST_STATUS_HOUR24,
       campus.ZONE,
       class_schd.meeting_DESC,
       class_schd.meetings,
       class_schd.MEETING_1 AS FIST_DAY_OF_CLASS,
       class_schd.MEETING_2,
       class_schd.MEETING_3,
       class_schd.MEETING_4,
       class_schd.MEETING_5,
       class_schd.MEETING_6,
       class_schd.WK1_SUN,
       class_schd.WK2_SUN,
       class_schd.WK3_SUN,
       class_schd.WK4_SUN,
      (SELECT SFBETRM_ADD_DATE FROM sfbetrm WHERE SFBETRM_PIDM = SGBSTDN_PIDM AND SFBETRM_TERM_CODE = SFRSTCR_TERM_CODE)   REGISTRATION_DATE,
       SSBSECT_CRSE_NUMB                              SECTION_COURSE_NO, 
       SSBSECT_SEQ_NUMB                               SECTION_SEQ_NO,
       SSBSECT_TUIW_IND                               SECTION_WAIVER, 
       SSBSECT_CAMP_CODE                              SECTION_CAMPUS_CODE, 
       
       SSBSECT_PTRM_START_DATE                        SECTION_PTRM_START_DATE, 
       SSBSECT_PTRM_END_DATE                          SECTION_PTRM_END_DATE,  
       SSBSECT_PTRM_CODE                              SECTION_PTRM_CODE,          
       SCBCRSE_COLL_CODE                              TEACH_COLLEGE_CODE,
       SCBCRSE_DEPT_CODE                              TEACH_DEPT_CODE,
       SCBCRSE_TITLE                                         TEACH_COURSE_TITLE,
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
                         WHEN SFRSTCR_RSTS_DATE BETWEEN SSBSECT_PTRM_START_DATE AND SSBSECT_PTRM_START_DATE + 7 THEN 
                              (SELECT SFRRFCR_TUIT_REFUND FROM  SFRRFCR WHERE SFRRFCR_TERM_CODE = SFRSTCR_TERM_CODE AND SFRRFCR_PTRM_CODE = SSBSECT_PTRM_CODE AND SFRRFCR_RSTS_CODE = SFRSTCR_RSTS_CODE)
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
      END AS REFUND_TUI_PERCENT, 
    (select gorvisa_vtyp_code 
                  from (select * from GORVISA a
                         where a.gorvisa_pidm = gorvisa_pidm
                         and (a.gorvisa_visa_expire_date > sysdate or a.gorvisa_visa_expire_date is null) 
                         order by a.GORVISA_VISA_START_DATE desc)
                  where gorvisa_pidm = SGBSTDN_PIDM
                  and rownum =1) VISA
    from 
        --class_schd,course info,campus, 
        sgbstdn b, 
        sfrstcr,
        ssbsect,
        (select a.scbcrse_subj_code,
               a.scbcrse_crse_numb,
               a.scbcrse_coll_code,
               a.scbcrse_dept_code,
               a.scbcrse_title  
        from scbcrse a
        where a.scbcrse_eff_term = (select max(b.scbcrse_eff_term) from scbcrse b
                                    where b.scbcrse_eff_term  <= '201603'
                                    and b.scbcrse_crse_numb = a.scbcrse_crse_numb
                                    and b.scbcrse_subj_code = a.scbcrse_subj_code)
               group by 
               a.scbcrse_subj_code ,
               a.scbcrse_crse_numb,
               a.scbcrse_coll_code,
               a.scbcrse_dept_code,
               a.scbcrse_title),
        (select stvcamp_code,stvcamp_desc, stvcamp_dicd_code, case stvcamp_dicd_code
            when 'OE' then 'Online'
            when '02' then 'Off-Campus'
            when '03' then 'Off-Campus'
            else 'Campus' end as "ZONE" from stvcamp) campus,
            
        --subquery returns classes with class schedule
         (SELECT  
	  schedule.TERM, 
	  schedule.CRN, 
	  schedule.meeting_DESC,
    schedule.PTRM_START_DATE,
    schedule.PTRM_START_DAY,
    schedule.MEETINGS,
	  (schedule.PTRM_START_DATE+ schedule.MEETING_1) AS MEETING_1,  
	  (schedule.PTRM_START_DATE+ schedule.MEETING_1 + MEETING_2) AS MEETING_2,
	  (schedule.PTRM_START_DATE+ schedule.MEETING_1 + MEETING_2 + MEETING_3) AS MEETING_3,
	  (schedule.PTRM_START_DATE+ schedule.MEETING_1 + MEETING_2 + MEETING_3 + MEETING_4) AS MEETING_4,
	  (schedule.PTRM_START_DATE+ schedule.MEETING_1 + MEETING_2 + MEETING_3 + MEETING_4 + MEETING_5) AS MEETING_5,
	  (schedule.PTRM_START_DATE+ schedule.MEETING_1 + MEETING_2 + MEETING_3 + MEETING_4 + MEETING_5 + MEETING_6) AS MEETING_6,
    (schedule.PTRM_START_DATE+ nvl(schedule.MEETING_1,0) + WK1) AS WK1_SUN,
    (schedule.PTRM_START_DATE+ nvl(schedule.MEETING_1,0) + WK2) AS WK2_SUN,
    (schedule.PTRM_START_DATE+ nvl(schedule.MEETING_1,0) + WK3) AS WK3_SUN,
    (schedule.PTRM_START_DATE+ nvl(schedule.MEETING_1,0) + WK4) AS WK4_SUN
FROM 
  (select 
              meeting.TERM,
              meeting.CRN,
              meeting.meeting_DESC,
              meeting.PTRM_START_DATE,
              meeting.PTRM_START_DAY,
              meeting.MEETINGS,
              meeting.days,
              CASE meeting.PTRM_START_DAY
              WHEN 'Sun' THEN INSTR('UMTWRFSU',substr(meeting.days,1,1),1)-1
              WHEN 'Mon' THEN INSTR('MTWRFSUM',substr(meeting.days,1,1),1)-1
              WHEN 'Tue' THEN INSTR('TWRFSUMT',substr(meeting.days,1,1),1)-1
              WHEN 'Wed' THEN INSTR('WRFSUMTW',substr(meeting.days,1,1),1)-1
              WHEN 'Thu' THEN INSTR('RFSUMTWR',substr(meeting.days,1,1),1)-1
              WHEN 'Fri' THEN INSTR('FSUMTWRF',substr(meeting.days,1,1),1)-1
              WHEN 'Sat' THEN INSTR('SUMTWRFS',substr(meeting.days,1,1),1)-1
              END AS MEETING_1, 
              CASE substr(meeting.days,1,1)
              WHEN 'U' THEN INSTR('UMTWRFSU',substr(meeting.days,2,1),2)-1
              WHEN 'M' THEN INSTR('MTWRFSUM',substr(meeting.days,2,1),2)-1
              WHEN 'T' THEN INSTR('TWRFSUMT',substr(meeting.days,2,1),2)-1
              WHEN 'W' THEN INSTR('WRFSUMTW',substr(meeting.days,2,1),2)-1
              WHEN 'R' THEN INSTR('RFSUMTWR',substr(meeting.days,2,1),2)-1
              WHEN 'F' THEN INSTR('FSUMTWRF',substr(meeting.days,2,1),2)-1
              WHEN 'S' THEN INSTR('SUMTWRFS',substr(meeting.days,2,1),2)-1
              END AS MEETING_2,  
              CASE substr(meeting.days,2,1)
              WHEN 'U' THEN INSTR('UMTWRFSU',substr(meeting.days,3,1),2)-1
              WHEN 'M' THEN INSTR('MTWRFSUM',substr(meeting.days,3,1),2)-1
              WHEN 'T' THEN INSTR('TWRFSUMT',substr(meeting.days,3,1),2)-1
              WHEN 'W' THEN INSTR('WRFSUMTW',substr(meeting.days,3,1),2)-1
              WHEN 'R' THEN INSTR('RFSUMTWR',substr(meeting.days,3,1),2)-1
              WHEN 'F' THEN INSTR('FSUMTWRF',substr(meeting.days,3,1),2)-1
              WHEN 'S' THEN INSTR('SUMTWRFS',substr(meeting.days,3,1),2)-1
              END AS MEETING_3,  
              CASE substr(meeting.days,3,1)
              WHEN 'U' THEN INSTR('UMTWRFSU',substr(meeting.days,4,1),2)-1
              WHEN 'M' THEN INSTR('MTWRFSUM',substr(meeting.days,4,1),2)-1
              WHEN 'T' THEN INSTR('TWRFSUMT',substr(meeting.days,4,1),2)-1
              WHEN 'W' THEN INSTR('WRFSUMTW',substr(meeting.days,4,1),2)-1
              WHEN 'R' THEN INSTR('RFSUMTWR',substr(meeting.days,4,1),2)-1
              WHEN 'F' THEN INSTR('FSUMTWRF',substr(meeting.days,4,1),2)-1
              WHEN 'S' THEN INSTR('SUMTWRFS',substr(meeting.days,4,1),2)-1
              END AS MEETING_4,  
              CASE substr(meeting.days,4,1)
              WHEN 'U' THEN INSTR('UMTWRFSU',substr(meeting.days,5,1),2)-1
              WHEN 'M' THEN INSTR('MTWRFSUM',substr(meeting.days,5,1),2)-1
              WHEN 'T' THEN INSTR('TWRFSUMT',substr(meeting.days,5,1),2)-1
              WHEN 'W' THEN INSTR('WRFSUMTW',substr(meeting.days,5,1),2)-1
              WHEN 'R' THEN INSTR('RFSUMTWR',substr(meeting.days,5,1),2)-1
              WHEN 'F' THEN INSTR('FSUMTWRF',substr(meeting.days,5,1),2)-1
              WHEN 'S' THEN INSTR('SUMTWRFS',substr(meeting.days,5,1),2)-1
              END AS MEETING_5,  
              CASE substr(meeting.days,5,1)
              WHEN 'U' THEN INSTR('UMTWRFSU',substr(meeting.days,6,1),2)-1
              WHEN 'M' THEN INSTR('MTWRFSUM',substr(meeting.days,6,1),2)-1
              WHEN 'T' THEN INSTR('TWRFSUMT',substr(meeting.days,6,1),2)-1
              WHEN 'W' THEN INSTR('WRFSUMTW',substr(meeting.days,6,1),2)-1
              WHEN 'R' THEN INSTR('RFSUMTWR',substr(meeting.days,6,1),2)-1
              WHEN 'F' THEN INSTR('FSUMTWRF',substr(meeting.days,6,1),2)-1
              WHEN 'S' THEN INSTR('SUMTWRFS',substr(meeting.days,6,1),2)-1
              END AS MEETING_6,
              case when meeting.days is null then
                CASE meeting.PTRM_START_DAY
                WHEN 'Sun' THEN INSTR('UMTWRFSU','U',1)-1
                WHEN 'Mon' THEN INSTR('MTWRFSUM','U',1)-1
                WHEN 'Tue' THEN INSTR('TWRFSUMT','U',1)-1
                WHEN 'Wed' THEN INSTR('WRFSUMTW','U',1)-1
                WHEN 'Thu' THEN INSTR('RFSUMTWR','U',1)-1
                WHEN 'Fri' THEN INSTR('FSUMTWRF','U',1)-1
                WHEN 'Sat' THEN INSTR('SUMTWRFS','U',1)-1
                END
              else
                CASE substr(meeting.days,1,1)
                WHEN 'U' THEN INSTR('UMTWRFS','U',2)-1
                WHEN 'M' THEN INSTR('MTWRFSUM','U',2)-1
                WHEN 'T' THEN INSTR('TWRFSUMT','U',2)-1
                WHEN 'W' THEN INSTR('WRFSUMTW','U',2)-1
                WHEN 'R' THEN INSTR('RFSUMTWR','U',2)-1
                WHEN 'F' THEN INSTR('FSUMTWRF','U',2)-1
                WHEN 'S' THEN INSTR('SUMTWRFS','U',2)-1
                END
              end AS WK1, 
              case when meeting.days is null then
                CASE meeting.PTRM_START_DAY
                WHEN 'Sun' THEN INSTR('UMTWRFSU','U',1)-1+7
                WHEN 'Mon' THEN INSTR('MTWRFSUM','U',1)-1+7
                WHEN 'Tue' THEN INSTR('TWRFSUMT','U',1)-1+7
                WHEN 'Wed' THEN INSTR('WRFSUMTW','U',1)-1+7
                WHEN 'Thu' THEN INSTR('RFSUMTWR','U',1)-1+7
                WHEN 'Fri' THEN INSTR('FSUMTWRF','U',1)-1+7
                WHEN 'Sat' THEN INSTR('SUMTWRFS','U',1)-1+7
                END
              else
                CASE substr(meeting.days,1,1)
                WHEN 'U' THEN INSTR('UMTWRFS','U',2)-1 +7
                WHEN 'M' THEN INSTR('MTWRFSUM','U',2)-1 +7
                WHEN 'T' THEN INSTR('TWRFSUMT','U',2)-1 +7
                WHEN 'W' THEN INSTR('WRFSUMTW','U',2)-1 +7
                WHEN 'R' THEN INSTR('RFSUMTWR','U',2)-1 +7
                WHEN 'F' THEN INSTR('FSUMTWRF','U',2)-1 +7
                WHEN 'S' THEN INSTR('SUMTWRFS','U',2)-1 +7
                END
              end AS WK2, 
              case when meeting.days is null then
                CASE meeting.PTRM_START_DAY
                WHEN 'Sun' THEN INSTR('UMTWRFSU','U',1)-1+7+ 7
                WHEN 'Mon' THEN INSTR('MTWRFSUM','U',1)-1+7+ 7
                WHEN 'Tue' THEN INSTR('TWRFSUMT','U',1)-1+7+ 7
                WHEN 'Wed' THEN INSTR('WRFSUMTW','U',1)-1+7+ 7
                WHEN 'Thu' THEN INSTR('RFSUMTWR','U',1)-1+7+ 7
                WHEN 'Fri' THEN INSTR('FSUMTWRF','U',1)-1+7+ 7
                WHEN 'Sat' THEN INSTR('SUMTWRFS','U',1)-1+7+ 7
                END
              else
                CASE substr(meeting.days,1,1)
                WHEN 'U' THEN INSTR('UMTWRFS','U',2)-1 +7 + 7
                WHEN 'M' THEN INSTR('MTWRFSUM','U',2)-1 +7 + 7  
                WHEN 'T' THEN INSTR('TWRFSUMT','U',2)-1 +7 + 7
                WHEN 'W' THEN INSTR('WRFSUMTW','U',2)-1 +7 + 7 
                WHEN 'R' THEN INSTR('RFSUMTWR','U',2)-1 +7 + 7
                WHEN 'F' THEN INSTR('FSUMTWRF','U',2)-1 +7 + 7
                WHEN 'S' THEN INSTR('SUMTWRFS','U',2)-1 + 7 + 7 
                END
              end AS WK3, 
              case when meeting.days is null then
                CASE meeting.PTRM_START_DAY
                WHEN 'Sun' THEN INSTR('UMTWRFSU','U',1)-1 +7+7+ 7
                WHEN 'Mon' THEN INSTR('MTWRFSUM','U',1)-1+7+7+ 7
                WHEN 'Tue' THEN INSTR('TWRFSUMT','U',1)-1+7+7+ 7
                WHEN 'Wed' THEN INSTR('WRFSUMTW','U',1)-1+7+7+ 7
                WHEN 'Thu' THEN INSTR('RFSUMTWR','U',1)-1+7+7+ 7
                WHEN 'Fri' THEN INSTR('FSUMTWRF','U',1)-1+7+7+ 7
                WHEN 'Sat' THEN INSTR('SUMTWRFS','U',1)-1+7+7+ 7
                END
              else
                CASE substr(meeting.days,1,1)
                WHEN 'U' THEN INSTR('UMTWRFS','U',2)-1 +7 +7+ 7
                WHEN 'M' THEN INSTR('MTWRFSUM','U',2)-1 +7+7 + 7  
                WHEN 'T' THEN INSTR('TWRFSUMT','U',2)-1 +7+7 + 7
                WHEN 'W' THEN INSTR('WRFSUMTW','U',2)-1 +7+7 + 7 
                WHEN 'R' THEN INSTR('RFSUMTWR','U',2)-1 +7+7 + 7
                WHEN 'F' THEN INSTR('FSUMTWRF','U',2)-1 +7+7 + 7
                WHEN 'S' THEN INSTR('SUMTWRFS','U',2)-1 + 7+7 + 7 
                END
              end AS WK4              
          FROM  
               (select 
                SSRMEET_TERM_CODE AS TERM, 
                SSRMEET_CRN AS CRN, 
                (select STVSCHD_DESC from STVSCHD where STVSCHD_CODE = SSRMEET_SCHD_CODE) meeting_DESC,
                SSBSECT_PTRM_START_DATE AS PTRM_START_DATE,
                 to_char(SSBSECT_PTRM_START_DATE, 'Dy') AS PTRM_START_DAY,
                 SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY AS MEETINGS,
                CASE to_char(SSBSECT_PTRM_START_DATE, 'Dy') 
                    WHEN 'Sun'    THEN SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY
                    WHEN 'Mon'    THEN SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY
                    WHEN 'Tue'     THEN  SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY
                    WHEN 'Wed'    THEN SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY
                    WHEN 'Thu'     THEN SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY
                    WHEN 'Fri'      THEN SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY
                    WHEN 'Sat'     THEN SSRMEET_SAT_DAY
                END||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY 
                 ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY 
                 ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY 
                 ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY 
                 ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY
                 ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY as days
            from            
             ( SELECT 
                     B.SSRMEET_TERM_CODE,
                     B.SSRMEET_CRN,
                     B.SSRMEET_SCHD_CODE,
                     (SELECT  SSRMEET_SUN_DAY  FROM SSRMEET  WHERE  SSRMEET_TERM_CODE = B.SSRMEET_TERM_CODE AND SSRMEET_CRN  = B.SSRMEET_CRN AND SSRMEET_SUN_DAY IS NOT NULL AND ROWNUM = 1) AS SSRMEET_SUN_DAY,
                     (SELECT  SSRMEET_MON_DAY  FROM SSRMEET  WHERE  SSRMEET_TERM_CODE = B.SSRMEET_TERM_CODE AND SSRMEET_CRN  = B.SSRMEET_CRN AND SSRMEET_MON_DAY IS NOT NULL AND ROWNUM = 1) AS SSRMEET_MON_DAY,
                     (SELECT  SSRMEET_TUE_DAY  FROM SSRMEET  WHERE  SSRMEET_TERM_CODE = B.SSRMEET_TERM_CODE AND SSRMEET_CRN  = B.SSRMEET_CRN AND SSRMEET_TUE_DAY IS NOT NULL AND ROWNUM = 1) AS SSRMEET_TUE_DAY,
                     (SELECT  SSRMEET_WED_DAY  FROM SSRMEET  WHERE  SSRMEET_TERM_CODE = B.SSRMEET_TERM_CODE AND SSRMEET_CRN  = B.SSRMEET_CRN AND SSRMEET_WED_DAY IS NOT NULL AND ROWNUM = 1) AS SSRMEET_WED_DAY,
                     (SELECT  SSRMEET_THU_DAY  FROM SSRMEET  WHERE  SSRMEET_TERM_CODE = B.SSRMEET_TERM_CODE AND SSRMEET_CRN  = B.SSRMEET_CRN AND SSRMEET_THU_DAY IS NOT NULL AND ROWNUM = 1) AS SSRMEET_THU_DAY,
                     (SELECT  SSRMEET_FRI_DAY  FROM SSRMEET  WHERE  SSRMEET_TERM_CODE = B.SSRMEET_TERM_CODE AND SSRMEET_CRN  = B.SSRMEET_CRN AND SSRMEET_FRI_DAY IS NOT NULL AND ROWNUM = 1) AS SSRMEET_FRI_DAY,
                     (SELECT  SSRMEET_SAT_DAY  FROM SSRMEET  WHERE  SSRMEET_TERM_CODE = B.SSRMEET_TERM_CODE AND SSRMEET_CRN  = B.SSRMEET_CRN AND SSRMEET_SAT_DAY IS NOT NULL AND ROWNUM = 1) AS SSRMEET_SAT_DAY
                     FROM SSRMEET B
                     WHERE  B.SSRMEET_TERM_CODE = '201603' 
                     GROUP BY 
                     B.SSRMEET_TERM_CODE,
                     B.SSRMEET_CRN,
                     B.SSRMEET_SCHD_CODE),               
            SSBSECT
            where
            SSBSECT_TERM_CODE = '201603' AND
            SSBSECT_TERM_CODE =  SSRMEET_TERM_CODE
            and SSBSECT_CRN = SSRMEET_CRN) meeting) schedule) class_schd   
            
        where           
           b.sgbstdn_term_code_eff   = (select max(a.sgbstdn_term_code_eff)
                from sgbstdn a where a.sgbstdn_pidm = b.sgbstdn_pidm and a.sgbstdn_term_code_eff <= sfrstcr_term_code)
           
           and sfrstcr_term_code = '201603'
           --and sfrstcr_crn = '10046'
           and sfrstcr_pidm = b.sgbstdn_pidm    
           and SSBSECT_TERM_CODE = sfrstcr_term_code
           and SSBSECT_CRN = sfrstcr_crn
           and SSBSECT_CAMP_CODE = campus.stvcamp_code
           and SCBCRSE_SUBJ_CODE = SSBSECT_SUBJ_CODE
           and SCBCRSE_CRSE_NUMB = SSBSECT_CRSE_NUMB
           and SSBSECT_TERM_CODE = class_schd.TERM (+)
           and SSBSECT_CRN = class_schd.CRN (+)