
--DROPPED CLASSES
WITH SAIG_SB_V2_DATA_STUDENT 
AS (select distinct 
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
       SGBSTDN_CAMP_CODE          STU_CAMPUS,  
       SFRSTCR_CRN                                       REGIST_CRN,
       class_schd.meeting_DESC,
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
       class_schd.MEETINGS,
       class_schd.MEETING_1 AS FIST_DAY_OF_CLASS,
       class_schd.WK1_SUN,
       class_schd.WK2_SUN,
       class_schd.WK3_SUN,
       class_schd.WK4_SUN,
      (SELECT SFBETRM_ADD_DATE FROM sfbetrm WHERE SFBETRM_PIDM = SGBSTDN_PIDM AND SFBETRM_TERM_CODE = SFRSTCR_TERM_CODE)   REGISTRATION_DATE,
       SSBSECT_CRSE_NUMB                              SECTION_COURSE_NO, 
       SSBSECT_SEQ_NUMB                               SECTION_SEQ_NO,
       SSBSECT_TUIW_IND                               SECTION_WAIVER, 
       SSBSECT_CAMP_CODE                              SECTION_CAMPUS_CODE, 
       campus.ZONE,
       SSBSECT_PTRM_START_DATE                        SECTION_PTRM_START_DATE, 
       SSBSECT_PTRM_END_DATE                          SECTION_PTRM_END_DATE,  
       SSBSECT_PTRM_CODE                              SECTION_PTRM_CODE,          
       SCBCRSE_COLL_CODE                              TEACH_COLLEGE_CODE,
       SCBCRSE_DEPT_CODE                              TEACH_DEPT_CODE,
       SCBCRSE_TITLE                                         TEACH_COURSE_TITLE,
       --REFUND CALCULATION
       --http://registrar.gwu.edu/withdrawals-refunds#UG8th
       CASE WHEN SFRSTCR_RSTS_CODE not like 'R%' THEN
         CASE WHEN SUBSTR(SFRSTCR_TERM_CODE,-2,2) IN ('01','03') AND CAMPUS.ZONE = 'Campus' 
                   THEN /*ON-CAMPUS/Fall/Spring*/
                        CASE 
                          /*On-campus courses dropped prior to the start of the semester (before the first day of classes) will have 100% of the tuition charges cancelled. */
                          WHEN TRUNC(SFRSTCR_RSTS_DATE) < TRUNC(SSBSECT_PTRM_START_DATE) THEN 100
                          
                          /*Before the end of the first week of classes (by 10pm Sunday)*/
                          WHEN (TRUNC(SFRSTCR_RSTS_DATE) BETWEEN TRUNC(SSBSECT_PTRM_START_DATE) AND class_schd.WK1_SUN-1) THEN 90
                          WHEN (TRUNC(SFRSTCR_RSTS_DATE)  = class_schd.WK1_SUN)  AND to_char(SFRSTCR_RSTS_DATE , 'HH24') < '22' THEN 90
                          
                          /*Before the end of the second week of classes (by 10pm Sunday)*/
                          WHEN (TRUNC(SFRSTCR_RSTS_DATE) BETWEEN class_schd.WK1_SUN AND class_schd.WK2_SUN-1) THEN 60
                          WHEN (TRUNC(SFRSTCR_RSTS_DATE) =  class_schd.WK2_SUN)  AND to_char(SFRSTCR_RSTS_DATE , 'HH24') < '22' THEN 60
                                             
                          /*Before the end of the third week of classes (by 10pm Sunday)*/
                          WHEN (TRUNC(SFRSTCR_RSTS_DATE) BETWEEN class_schd.WK2_SUN AND class_schd.WK3_SUN -1) THEN 40
                          WHEN (TRUNC(SFRSTCR_RSTS_DATE) =  class_schd.WK3_SUN) AND to_char(SFRSTCR_RSTS_DATE , 'HH24') < '22' THEN 40
                          
                          /*Before the end of the fourth week of classes (by 10pm Sunday)*/
                          WHEN (TRUNC(SFRSTCR_RSTS_DATE) BETWEEN class_schd.WK3_SUN AND class_schd.WK4_SUN-1) THEN 25
                           WHEN (TRUNC(SFRSTCR_RSTS_DATE) =  class_schd.WK4_SUN)  AND to_char(SFRSTCR_RSTS_DATE , 'HH24') < '22' THEN 25
                           
                          ELSE 0 END
                  
                   WHEN SUBSTR(SFRSTCR_TERM_CODE,-2,2) IN ('02') AND CAMPUS.ZONE = 'Campus' 
                   THEN /*ON-CAMPUS/Summer*/
                        CASE 
                         /*On-campus courses dropped prior to the start of the session (before the first day of classes) will have 100% of the tuition charges cancelled. */
                         WHEN TRUNC(SFRSTCR_RSTS_DATE) < TRUNC(SSBSECT_PTRM_START_DATE) THEN 100
                         /*Courses dropped during the first seven (7) calendar days of the session will have 85% of the tuition charges cancelled.*/
                         WHEN TRUNC(SFRSTCR_RSTS_DATE) BETWEEN TRUNC(SSBSECT_PTRM_START_DATE) AND TRUNC(SSBSECT_PTRM_START_DATE + 7) THEN  85
                         --(SELECT SFRRFCR_TUIT_REFUND FROM  SFRRFCR WHERE SFRRFCR_TERM_CODE = SFRSTCR_TERM_CODE AND SFRRFCR_PTRM_CODE = SSBSECT_PTRM_CODE AND SFRRFCR_RSTS_CODE = SFRSTCR_RSTS_CODE)
                         ELSE 0 END
                         
                   WHEN CAMPUS.ZONE = 'Off-Campus' 
                   THEN /*Off-Campus fall and spring and summer*/  
                        CASE 
                         /*prior to first day of semester*/
                        WHEN TRUNC(SFRSTCR_RSTS_DATE) < class_schd.MEETING_1 THEN 100
                        /*From the day of the 1st class meeting until the day before the 3rd class meeting*/
                        WHEN TRUNC(SFRSTCR_RSTS_DATE) BETWEEN class_schd.MEETING_1 and class_schd.MEETING_3 -1 THEN 90
                        /*From the day of the 3rd class meeting until the day before the 5th class meeting*/
                        WHEN TRUNC(SFRSTCR_RSTS_DATE) BETWEEN class_schd.MEETING_3 and class_schd.MEETING_5 -1 THEN 50
                        ELSE 0 END           
                        
                   WHEN CAMPUS.ZONE = 'Online' 
                   THEN /*Online fall spring and summer*/ 
                        CASE 
                        /*prior to first day of semester*/
                        WHEN TRUNC(SFRSTCR_RSTS_DATE) < TRUNC(SSBSECT_PTRM_START_DATE) THEN 100
                        /*From the first day of the academic semester or session until the end of the second week of the academic semester or session*/
                        WHEN (TRUNC(SFRSTCR_RSTS_DATE) BETWEEN TRUNC(SSBSECT_PTRM_START_DATE) AND class_schd.WK2_SUN-1) THEN 90
                        WHEN (TRUNC(SFRSTCR_RSTS_DATE) = class_schd.WK2_SUN)  AND to_char(SFRSTCR_RSTS_DATE , 'HH24') < '22' THEN 90
                         
                        /*From the first day of the third week of the academic semester or session until the end of the fourth week of the academic semester or session*/
                        WHEN (TRUNC(SFRSTCR_RSTS_DATE) BETWEEN class_schd.WK2_SUN AND class_schd.WK4_SUN-1) THEN 50
                        WHEN (TRUNC(SFRSTCR_RSTS_DATE) =  class_schd.WK4_SUN)  AND to_char(SFRSTCR_RSTS_DATE , 'HH24') < '22' THEN 50
                        ELSE 0 END
                                                
                   WHEN  CAMPUS.ZONE != 'Campus'  AND SCBCRSE_DEPT_CODE IN ('EMSE','NGO')
                   THEN /*EMSE + NGO*/ 
                        CASE 
                        WHEN TRUNC(SFRSTCR_RSTS_DATE) < TRUNC(SSBSECT_PTRM_START_DATE) THEN 100
                        WHEN TRUNC(SFRSTCR_RSTS_DATE) < class_schd.MEETING_3 THEN 90
                        WHEN TRUNC(SFRSTCR_RSTS_DATE) < class_schd.MEETING_6 THEN 50
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
                                    where b.scbcrse_eff_term  <= '201503'
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
           WHERE  B.SSRMEET_TERM_CODE = '201503' 
           GROUP BY 
           B.SSRMEET_TERM_CODE,
           B.SSRMEET_CRN,
           B.SSRMEET_SCHD_CODE),             
            SSBSECT
            where
            SSBSECT_TERM_CODE =  SSRMEET_TERM_CODE
            and SSBSECT_CRN = SSRMEET_CRN) meeting) schedule) class_schd               
        where           
           b.sgbstdn_term_code_eff   = (select max(a.sgbstdn_term_code_eff)
                from sgbstdn a
                where a.sgbstdn_pidm = b.sgbstdn_pidm
                and a.sgbstdn_term_code_eff <= sfrstcr_term_code)              
                
           
            and sfrstcr_pidm = b.sgbstdn_pidm    
            and sfrstcr_term_code = '201503'
            and SFRSTCR_RSTS_CODE not like 'R%'
            and  (SFRSTCR_CREDIT_HR  > 0 or  SFRSTCR_BILL_HR > 0)
            and SSBSECT_TERM_CODE = sfrstcr_term_code
            and SSBSECT_CRN = SFRSTCR_CRN
            and SSBSECT_CAMP_CODE = campus.stvcamp_code
            and SCBCRSE_SUBJ_CODE = SSBSECT_SUBJ_CODE
            and SCBCRSE_CRSE_NUMB = SSBSECT_CRSE_NUMB
            and SSBSECT_TERM_CODE = class_schd.TERM (+)
            and SSBSECT_CRN = class_schd.CRN (+)),    
        
SAIG_SB_V2_DATA_COURSE_FEE AS (select  
            ssrfees_term_code,
            ssrfees_crn,
            ssrfees_detl_code,
            ssrfees_ftyp_code,
            ssrfees_amount,
            SSRFEES_TERM_CODE_ADMIT,
            SSRFEES_LEVL_CODE,
            SSRFEES_LEVL_CODE_STDN,
            SSRFEES_DEGC_CODE,
            SSRFEES_COLL_CODE,
            SYSDATE AS DATA_REFRESH_DATE
            from ssrfees
            where ssrfees_term_code = '201503'),

SAIG_SB_V2_STAGE_SECTION_RULES AS (SELECT DISTINCT
    STU_PIDM AS PIDM,
    REGIST_STATUS,
    REGIST_TERM_CODE,
    REGIST_CRN AS CRN,
    SSRFEES_DETL_CODE ,
	   (select distinct TBBDETC_DCAT_CODE from TBBDETC
			  where TBBDETC_DETAIL_CODE = SSRFEES_DETL_CODE) AS DCAT_CODE,
    SSRFEES_FTYP_CODE,
    SSRFEES_AMOUNT,
    REGIST_BILL_HR,
    CASE WHEN SSRFEES_FTYP_CODE = 'BILL' 
        THEN SSRFEES_AMOUNT * REGIST_BILL_HR
    ELSE SSRFEES_AMOUNT END AS AMOUNT,
    SECTION_WAIVER,
    SECTION_CAMPUS_CODE,
    SECTION_PTRM_START_DATE,
    SECTION_PTRM_END_DATE
FROM
	SAIG_SB_V2_DATA_STUDENT LEFT OUTER JOIN
	SAIG_SB_V2_DATA_COURSE_FEE ON
        REGIST_CRN = SSRFEES_CRN
        AND REGIST_TERM_CODE = SSRFEES_TERM_CODE
WHERE 
	(REGIST_COURSE_LEVEL = SSRFEES_LEVL_CODE OR SSRFEES_LEVL_CODE IS NULL OR SSRFEES_LEVL_CODE = '')
   AND (STU_LEVEL_CODE = SSRFEES_LEVL_CODE_STDN OR SSRFEES_LEVL_CODE_STDN IS NULL OR SSRFEES_LEVL_CODE_STDN = '')
	 AND (STU_DEGREE_CODE = SSRFEES_DEGC_CODE OR SSRFEES_DEGC_CODE IS NULL OR SSRFEES_DEGC_CODE = '')
	 AND (STU_TERM_CODE_ADMIT = SSRFEES_TERM_CODE_ADMIT OR SSRFEES_TERM_CODE_ADMIT IS NULL OR SSRFEES_TERM_CODE_ADMIT = '')
   AND (STU_ENROLL_COLLEGE_CODE = SSRFEES_COLL_CODE OR SSRFEES_COLL_CODE IS NULL OR SSRFEES_COLL_CODE = '')),
    
 SAIG_SB_V2_STAGE_BILLING_RULES   AS (select distinct
	 	BILLING_RULE_ID,
		SFRRGFE_TERM_CODE					AS TERM,
		STU_GWID							AS GWID,
		STU_PIDM							AS PIDM,
		SFRRGFE_TYPE						AS TYPE,
		SFRRGFE_DETL_CODE					AS DETAIL_CODE,
		(select distinct TBBDETC_DCAT_CODE from TBBDETC
			  where TBBDETC_DETAIL_CODE = SFRRGFE_DETL_CODE) AS DCAT_CODE,
		SFRRGFE_SEQNO						AS SEQNO,
		SFRRGFE_CRSE_WAIV_IND				AS WAIVER,
		REGIST_CRN							AS CRN,
		SFRRGFE_TERM_CODE_ADMIT				AS TERM_ADMIT,
		SFRRGFE_COLL_CODE					AS ENROL_COLLEGE,
		SFRRGFE_DEGC_CODE					AS DEGREE_CODE,
		SFRRGFE_LEVL_CODE					AS STUDENT_LEVEL,
		SFRRGFE_LEVL_CODE_CRSE				AS COURSE_LEVEL,
		SFRRGFE_RATE_CODE					AS RATE_CODE,
		SFRRGFE_CAMP_CODE					AS STUDENT_CAMPUS,
		SFRRGFE_CAMP_CODE_CRSE				AS COURSE_CAMPUS,
		SFRRGFE_MAJR_CODE					AS MAJOR_CODE,
		REGIST_STATUS						AS REGISTRATION_CODE,
		SFRRGFE_FROM_CRED_HRS,
		SFRRGFE_TO_CRED_HRS,
		SFRRGFE_MIN_CHARGE,
		SFRRGFE_MAX_CHARGE,
		SFRRGFE_PER_CRED_CHARGE,
		SFRRGFE_FLAT_FEE_AMOUNT,
		SFRRGFE_CRSE_OVERLOAD_START_HR,
		REGIST_BILL_HR						AS BILL_HOURS,
		(select sum(s.REGIST_BILL_HR) 
			 from SAIG_SB_V2_DATA_STUDENT s
			 where s.STU_PIDM = st.STU_PIDM
				   and s.REGIST_TERM_CODE = st.REGIST_TERM_CODE
				   and (s.REGIST_COURSE_LEVEL = SFRRGFE_LEVL_CODE_CRSE or SFRRGFE_LEVL_CODE_CRSE is null or SFRRGFE_LEVL_CODE_CRSE = '')
				   and (s.SECTION_CAMPUS_CODE = SFRRGFE_CAMP_CODE_CRSE or SFRRGFE_CAMP_CODE_CRSE is null or SFRRGFE_CAMP_CODE_CRSE = '')) 
		AS TOTAL_BILL_HOURS
from 
  SAIG_SB_V2_DATA_STUDENT st,
	(select rowid as BILLING_RULE_ID, 
    SFRRGFE_SEQNO,
    sfrrgfe_type,
    SFRRGFE_DETL_CODE,
    SFRRGFE_LEVL_CODE,
    SFRRGFE_LEVL_CODE_CRSE,
    SFRRGFE_COLL_CODE,
    SFRRGFE_CAMP_CODE,
    SFRRGFE_CAMP_CODE_CRSE,
    SFRRGFE_RATE_CODE,
    SFRRGFE_DEGC_CODE,
    SFRRGFE_MAJR_CODE,
    SFRRGFE_TERM_CODE_ADMIT,
    SFRRGFE_FROM_CRED_HRS,
    SFRRGFE_TO_CRED_HRS,   
    SFRRGFE_FLAT_FEE_AMOUNT,
    SFRRGFE_CRSE_OVERLOAD_START_HR,
    SFRRGFE_PER_CRED_CHARGE,   
    SFRRGFE_MIN_CHARGE,
    SFRRGFE_MAX_CHARGE,
    SFRRGFE_CRSE_WAIV_IND,
    SFRRGFE_TERM_CODE,
    SFRRGFE_STYP_CODE,
    SFRRGFE_PTRM_CODE,
    SFRRGFE_FROM_ADD_DATE,
    SFRRGFE_TO_ADD_DATE,
    SFRRGFE_VTYP_CODE
    from SFRRGFE 
    where sfrrgfe_term_code='201503' 
    and sfrrgfe_entry_type = 'R' 
    and sfrrgfe_type IN ('CAMPUS','LEVEL','STUDENT'))
where
	SFRRGFE_TERM_CODE = REGIST_TERM_CODE
	 --campus code student
    and (STU_CAMPUS = SFRRGFE_CAMP_CODE or SFRRGFE_CAMP_CODE is null or SFRRGFE_CAMP_CODE = '')    
    --campus code campus
	and (SECTION_CAMPUS_CODE = SFRRGFE_CAMP_CODE_CRSE or SFRRGFE_CAMP_CODE_CRSE is null or SFRRGFE_CAMP_CODE_CRSE = '')
	--student level code
	and (STU_LEVEL_CODE = SFRRGFE_LEVL_CODE or SFRRGFE_LEVL_CODE is null or SFRRGFE_LEVL_CODE = '')
	--course level code
	and (REGIST_COURSE_LEVEL = SFRRGFE_LEVL_CODE_CRSE or SFRRGFE_LEVL_CODE_CRSE is null or SFRRGFE_LEVL_CODE_CRSE = '')
	--student college code
	and (STU_ENROLL_COLLEGE_CODE = SFRRGFE_COLL_CODE or SFRRGFE_COLL_CODE is null or SFRRGFE_COLL_CODE = '')
	--rate code
	and (STU_RATE_CODE = SFRRGFE_RATE_CODE or SFRRGFE_RATE_CODE is null or SFRRGFE_RATE_CODE = '')
	--degree code 
	and (STU_DEGREE_CODE = SFRRGFE_DEGC_CODE or SFRRGFE_DEGC_CODE is null or SFRRGFE_DEGC_CODE = '')
	--major code
	and (STU_MAJOR_CODE = SFRRGFE_MAJR_CODE or SFRRGFE_MAJR_CODE is null or SFRRGFE_MAJR_CODE = '')
	--student type
	and (STU_STYP = SFRRGFE_STYP_CODE or SFRRGFE_STYP_CODE is null or SFRRGFE_STYP_CODE = '') 
	--admission term
	and (STU_TERM_CODE_ADMIT = SFRRGFE_TERM_CODE_ADMIT or SFRRGFE_TERM_CODE_ADMIT is null or SFRRGFE_TERM_CODE_ADMIT = '')
	--visa
	and (SFRRGFE_VTYP_CODE is null or SFRRGFE_VTYP_CODE = '' or SFRRGFE_VTYP_CODE = VISA)
	--part term 
	and (SECTION_PTRM_CODE = SFRRGFE_PTRM_CODE or SFRRGFE_PTRM_CODE is null or SFRRGFE_PTRM_CODE = '')
	--registration dates
	and (SFRRGFE_FROM_ADD_DATE is null or SFRRGFE_FROM_ADD_DATE = '' or REGISTRATION_DATE between SFRRGFE_FROM_ADD_DATE and SFRRGFE_TO_ADD_DATE + 1 )
	--billing hours
	and ((select sum(s.REGIST_BILL_HR) 
		 from SAIG_SB_V2_DATA_STUDENT s
		 where s.STU_PIDM = st.STU_PIDM
			   and s.REGIST_TERM_CODE = st.REGIST_TERM_CODE
			   and (s.REGIST_COURSE_LEVEL = SFRRGFE_LEVL_CODE_CRSE or SFRRGFE_LEVL_CODE_CRSE is null or SFRRGFE_LEVL_CODE_CRSE = '')
			   and (s.SECTION_CAMPUS_CODE = SFRRGFE_CAMP_CODE_CRSE or SFRRGFE_CAMP_CODE_CRSE is null or SFRRGFE_CAMP_CODE_CRSE = ''))
		  between NVL(SFRRGFE_FROM_CRED_HRS,0) and NVL(SFRRGFE_TO_CRED_HRS,999)))


------------------------
--FINAL QUERY
-----------------------
SELECT distinct
	ST.STU_gwid,
	ST.STU_PIDM,
	SR.REGIST_TERM_CODE,
  SR.crn,
  ST.meeting_DESC,
  ST.CLASS_ACTV_INACTV_CANC,
  ST.SECTION_PTRM_CODE,
  ST.REGIST_STATUS,
  ST.REGIST_ADD_DATE,
  ST.REGIST_ADD_HOUR24,
  ST.REGIST_STATUS_DATE,
  ST.REGIST_STATUS_HOUR24,
  ST.SECTION_PTRM_START_DATE,
  ST.FIST_DAY_OF_CLASS,  
  ST.WK1_SUN,
  ST.WK2_SUN,
  ST.WK3_SUN,
  ST.WK4_SUN,
  ST.REGISTRATION_DATE,
  SR.ssrfees_detl_code,
  SR.DCAT_CODE,
  ST.REGIST_BILL_HR AS REGIST_BILL_HR_ORIG,
  ST.REGIST_BILL_HR * (100 - NVL(ST.REFUND_TUI_PERCENT,0)) / 100 AS REGIST_BILL_HR,
	ST.REGIST_CREDIT_HR,
	ST.STU_TERM_CODE_ADMIT,
	ST.STU_ENROLL_COLLEGE_CODE,
	ST.STU_DEGREE_CODE,
	ST.STU_DEGREE,
	ST.STU_MAJOR_CODE,
	ST.STU_MAJOR,
	ST.STU_LEVEL_CODE,
	ST.STU_RATE_CODE,
	SR.SECTION_CAMPUS_CODE,
  ST.ZONE,
	ST.SECTION_COURSE_NO,
	ST.SECTION_SEQ_NO,
	ST.TEACH_DEPT_CODE,
  ST.TEACH_COLLEGE_CODE,
  ST.TEACH_COURSE_TITLE,
  ST.REFUND_TUI_PERCENT
FROM 
	SAIG_SB_V2_DATA_STUDENT ST,
	SAIG_SB_V2_STAGE_SECTION_RULES SR 	
WHERE
	ST.STU_PIDM = SR.PIDM
	AND ST.REGIST_CRN = SR.crn
	AND ST.REGIST_TERM_CODE = SR.REGIST_TERM_CODE
	AND SR.AMOUNT IS NOT NULL
  AND SR.DCAT_CODE = 'TUI'

UNION ALL

--BILLING RULES
SELECT distinct
	ST.STU_gwid,
	ST.STU_PIDM,
	ST.REGIST_TERM_CODE,
  BR.CRN,
  ST.meeting_DESC,
  ST.CLASS_ACTV_INACTV_CANC,
  ST.SECTION_PTRM_CODE,
  ST.REGIST_STATUS,  
  ST.REGIST_ADD_DATE,
  ST.REGIST_ADD_HOUR24,
  ST.REGIST_STATUS_DATE,
  ST.REGIST_STATUS_HOUR24,
  ST.SECTION_PTRM_START_DATE,
  ST.FIST_DAY_OF_CLASS,  
  ST.WK1_SUN,
  ST.WK2_SUN,
  ST.WK3_SUN,
  ST.WK4_SUN,
  ST.REGISTRATION_DATE,
  BR.DETAIL_CODE,
  BR.DCAT_CODE,
  ST.REGIST_BILL_HR AS REGIST_BILL_HR_ORIG,
  ST.REGIST_BILL_HR * (100 - NVL(ST.REFUND_TUI_PERCENT,0)) / 100 AS REGIST_BILL_HR,
	ST.REGIST_CREDIT_HR,
	ST.STU_TERM_CODE_ADMIT,
	ST.STU_ENROLL_COLLEGE_CODE,
	ST.STU_DEGREE_CODE,
	ST.STU_DEGREE,
	ST.STU_MAJOR_CODE,
	ST.STU_MAJOR,
	ST.STU_LEVEL_CODE,
	ST.STU_RATE_CODE,
	ST.SECTION_CAMPUS_CODE,  
  ST.ZONE,
	ST.SECTION_COURSE_NO,
	ST.SECTION_SEQ_NO,
	ST.TEACH_DEPT_CODE,
  ST.TEACH_COLLEGE_CODE,
  ST.TEACH_COURSE_TITLE,
  ST.REFUND_TUI_PERCENT
FROM 
	SAIG_SB_V2_DATA_STUDENT ST,
	SAIG_SB_V2_STAGE_BILLING_RULES BR
	LEFT OUTER JOIN SAIG_SB_V2_STAGE_SECTION_RULES SR 
	ON  BR.PIDM        = SR.PIDM 
	AND BR.CRN         = SR.crn
	AND (
		  ((BR.DCAT_CODE = 'TUI' AND SR.DCAT_CODE = 'TUI') OR SR.DCAT_CODE IS NULL)
		    )
	AND BR.TERM = SR.REGIST_TERM_CODE	
WHERE
	ST.STU_PIDM = BR.PIDM
	AND ST.REGIST_CRN = BR.CRN	
	AND ST.REGIST_TERM_CODE  = BR.TERM
	AND (NVL(BR.WAIVER,'N') <> 'Y' 
	OR NVL(SR.SECTION_WAIVER,'N')  <> 'Y')
  AND BR.DCAT_CODE = 'TUI';