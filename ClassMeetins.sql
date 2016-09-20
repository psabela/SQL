SELECT  
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
             SSBSECT_TERM_CODE = '201503' AND
             SSBSECT_CRN  = '61572' AND
            SSBSECT_TERM_CODE =  SSRMEET_TERM_CODE
            and SSBSECT_CRN = SSRMEET_CRN) meeting) schedule;
            
          
  
  