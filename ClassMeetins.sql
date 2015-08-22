SELECT  
	  TERM, 
	  CRN, 
	  SCHEDULE_DESC,
	  MEETINGS,
	  START_DATE AS MEETING1,  
	  (START_DATE + MEETING_2) AS MEETING_2,
	  (START_DATE + MEETING_2 + MEETING_3) AS MEETING_3,
	  (START_DATE + MEETING_2 + MEETING_3 + MEETING_4) AS MEETING_4,
	  (START_DATE + MEETING_2 + MEETING_3 + MEETING_4 + MEETING_5) AS MEETING_5,
	  (START_DATE + MEETING_2 + MEETING_3 + MEETING_4 + MEETING_5 + MEETING_6) AS MEETING_6
FROM 
	(select 
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
		  WHEN 'T' THEN INSTR('TWRFSUMT',substr(schedule.days,3,1),2)-1
		  WHEN 'W' THEN INSTR('WRFSUMTW',substr(schedule.days,3,1),2)-1
		  WHEN 'R' THEN INSTR('RFSUMTWR',substr(schedule.days,3,1),2)-1
		  WHEN 'F' THEN INSTR('FSUMTWRF',substr(schedule.days,3,1),2)-1
		  WHEN 'S' THEN INSTR('SUMTWRFS',substr(schedule.days,3,1),2)-1
		  END AS MEETING_3,  
		  CASE substr(schedule.days,3,1)
		  WHEN 'U' THEN INSTR('UMTWRFSU',substr(schedule.days,4,1),2)-1
		  WHEN 'M' THEN INSTR('MTWRFSUM',substr(schedule.days,4,1),2)-1
		  WHEN 'T' THEN INSTR('TWRFSUMT',substr(schedule.days,4,1),2)-1
		  WHEN 'W' THEN INSTR('WRFSUMTW',substr(schedule.days,4,1),2)-1
		  WHEN 'R' THEN INSTR('RFSUMTWR',substr(schedule.days,4,1),2)-1
		  WHEN 'F' THEN INSTR('FSUMTWRF',substr(schedule.days,4,1),2)-1
		  WHEN 'S' THEN INSTR('SUMTWRFS',substr(schedule.days,4,1),2)-1
		  END AS MEETING_4,  
		   CASE substr(schedule.days,4,1)
		  WHEN 'U' THEN INSTR('UMTWRFSU',substr(schedule.days,5,1),2)-1
		  WHEN 'M' THEN INSTR('MTWRFSUM',substr(schedule.days,5,1),2)-1
		  WHEN 'T' THEN INSTR('TWRFSUMT',substr(schedule.days,5,1),2)-1
		  WHEN 'W' THEN INSTR('WRFSUMTW',substr(schedule.days,5,1),2)-1
		  WHEN 'R' THEN INSTR('RFSUMTWR',substr(schedule.days,5,1),2)-1
		  WHEN 'F' THEN INSTR('FSUMTWRF',substr(schedule.days,5,1),2)-1
		  WHEN 'S' THEN INSTR('SUMTWRFS',substr(schedule.days,5,1),2)-1
		  END AS MEETING_5,  
		  CASE substr(schedule.days,5,1)
		  WHEN 'U' THEN INSTR('UMTWRFSU',substr(schedule.days,6,1),2)-1
		  WHEN 'M' THEN INSTR('MTWRFSUM',substr(schedule.days,6,1),2)-1
		  WHEN 'T' THEN INSTR('TWRFSUMT',substr(schedule.days,6,1),2)-1
		  WHEN 'W' THEN INSTR('WRFSUMTW',substr(schedule.days,6,1),2)-1
		  WHEN 'R' THEN INSTR('RFSUMTWR',substr(schedule.days,6,1),2)-1
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
		  substr(SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY 
			   ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY 
			   ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY 
			   ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY 
			   ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY 
			   ||SSRMEET_SUN_DAY|| SSRMEET_MON_DAY||SSRMEET_TUE_DAY|| SSRMEET_WED_DAY|| SSRMEET_THU_DAY|| SSRMEET_FRI_DAY|| SSRMEET_SAT_DAY,1,6)
		  as days
		  from SSRMEET
		  where SSRMEET_TERM_CODE = '201502') schedule) class_schd