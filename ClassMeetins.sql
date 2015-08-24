SELECT  
	  TERM, 
	  CRN, 
	  meeting_DESC,
    schedule.PTRM_START_DATE,
    schedule.PTRM_START_DAY,
    schedule.MEETINGS,
	  (schedule.PTRM_START_DATE+ schedule.MEETING_1) AS MEETING1,  
	  (schedule.PTRM_START_DATE+ schedule.MEETING_1 + MEETING_2) AS MEETING_2,
	  (schedule.PTRM_START_DATE+ schedule.MEETING_1 + MEETING_2 + MEETING_3) AS MEETING_3,
	  (schedule.PTRM_START_DATE+ schedule.MEETING_1 + MEETING_2 + MEETING_3 + MEETING_4) AS MEETING_4,
	  (schedule.PTRM_START_DATE+ schedule.MEETING_1 + MEETING_2 + MEETING_3 + MEETING_4 + MEETING_5) AS MEETING_5,
	  (schedule.PTRM_START_DATE+ schedule.MEETING_1 + MEETING_2 + MEETING_3 + MEETING_4 + MEETING_5 + MEETING_6) AS MEETING_6,
    (schedule.PTRM_START_DATE+ schedule.MEETING_1 + WK1) AS WK1_SUN,
    (schedule.PTRM_START_DATE+ schedule.MEETING_1+  WK2) AS WK2_SUN,
    (schedule.PTRM_START_DATE+ schedule.MEETING_1 + WK3) AS WK3_FRI,
    (schedule.PTRM_START_DATE+ schedule.MEETING_1 + WK4) AS WK4_FRI
FROM 
  (select 
		  meeting.TERM,
		  meeting.CRN,
		  meeting.meeting_DESC,
		  SSBSECT_PTRM_START_DATE AS PTRM_START_DATE,
      to_char(SSBSECT_PTRM_START_DATE, 'Dy') PTRM_START_DAY,
      meeting.MEETINGS,
      CASE to_char(SSBSECT_PTRM_START_DATE, 'Dy')
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
      CASE substr(meeting.days,1,1)
      WHEN 'U' THEN INSTR('UMTWRFS','U',2)-1
      WHEN 'M' THEN INSTR('MTWRFSUM','U',2)-1
      WHEN 'T' THEN INSTR('TWRFSUMT','U',2)-1
      WHEN 'W' THEN INSTR('WRFSUMTW','U',2)-1
      WHEN 'R' THEN INSTR('RFSUMTWR','U',2)-1
      WHEN 'F' THEN INSTR('FSUMTWRF','U',2)-1
      WHEN 'S' THEN INSTR('SUMTWRFS','U',2)-1
      END AS  WK1,      
      CASE substr(meeting.days,1,1)
      WHEN 'U' THEN INSTR('UMTWRFS','U',2)-1 +7
      WHEN 'M' THEN INSTR('MTWRFSUM','U',2)-1 +7
      WHEN 'T' THEN INSTR('TWRFSUMT','U',2)-1 +7
      WHEN 'W' THEN INSTR('WRFSUMTW','U',2)-1 +7
      WHEN 'R' THEN INSTR('RFSUMTWR','U',2)-1 +7
      WHEN 'F' THEN INSTR('FSUMTWRF','U',2)-1 +7
      WHEN 'S' THEN INSTR('SUMTWRFS','U',2)-1 +7
      END AS WK2,
      CASE substr(meeting.days,1,1)
      WHEN 'U' THEN INSTR('UMTWRFS','U',2)-1 +7 + 5
      WHEN 'M' THEN INSTR('MTWRFSUM','U',2)-1 +7 + 5  
      WHEN 'T' THEN INSTR('TWRFSUMT','U',2)-1 +7 + 5
      WHEN 'W' THEN INSTR('WRFSUMTW','U',2)-1 +7 + 5 
      WHEN 'R' THEN INSTR('RFSUMTWR','U',2)-1 +7 + 5
      WHEN 'F' THEN INSTR('FSUMTWRF','U',2)-1 +7 + 5
      WHEN 'S' THEN INSTR('SUMTWRFS','U',2)-1 + 7 + 5 
      END AS WK3,      
        CASE substr(meeting.days,1,1)
      WHEN 'U' THEN INSTR('UMTWRFS','U',2)-1 +7 +7+ 5
      WHEN 'M' THEN INSTR('MTWRFSUM','U',2)-1 +7+7 + 5  
      WHEN 'T' THEN INSTR('TWRFSUMT','U',2)-1 +7+7 + 5
      WHEN 'W' THEN INSTR('WRFSUMTW','U',2)-1 +7+7 + 5 
      WHEN 'R' THEN INSTR('RFSUMTWR','U',2)-1 +7+7 + 5
      WHEN 'F' THEN INSTR('FSUMTWRF','U',2)-1 +7+7 + 5
      WHEN 'S' THEN INSTR('SUMTWRFS','U',2)-1 + 7+7 + 5 
      END AS WK4      
  FROM  
       SSBSECT,
		  (     select 
                SSRMEET_TERM_CODE AS TERM, 
                SSRMEET_CRN AS CRN, 
                (select STVSCHD_DESC from STVSCHD where STVSCHD_CODE = SSRMEET_SCHD_CODE) meeting_DESC,
                SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY AS MEETINGS,
                substr(SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY 
                   ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY 
                   ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY 
                   ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY 
                   ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY 
                   ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY,1,6) as days
            from SSRMEET 
            where SSRMEET_TERM_CODE = '201501') meeting
  WHERE
  SSBSECT_TERM_CODE = meeting.TERM
  and SSBSECT_CRN = meeting.CRN) schedule;
  
  