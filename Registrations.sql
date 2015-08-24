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
       class_schd.SCHEDULE_DESC,
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
       class_schd.WK1_SUN,
       class_schd.WK2_SUN,
       class_schd.WK3_FRI,
       class_schd.WK4_FRI,
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
                                    where b.scbcrse_eff_term  <= '201502'
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
         TERM, 
          CRN, 
          SCHEDULE_DESC,
          MEETINGS,
          START_DATE AS MEETING1,  
          START_DATE + MEETING_2 AS MEETING_2,
          START_DATE + MEETING_2 + MEETING_3 AS MEETING_3,
          START_DATE + MEETING_2 + MEETING_3 + MEETING_4 AS MEETING_4,
          START_DATE + MEETING_2 + MEETING_3 + MEETING_4 + MEETING_5 AS MEETING_5,
          START_DATE + MEETING_2 + MEETING_3 + MEETING_4 + MEETING_5 + MEETING_6 AS MEETING_6,
          (START_DATE + WK1) AS WK1_SUN,
          (START_DATE + WK2) AS WK2_SUN,
          (START_DATE + WK3) AS WK3_FRI,
          (START_DATE + WK4) AS WK4_FRI
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
              END AS MEETING_6,
                CASE substr(schedule.days,1,1)
              WHEN 'U' THEN INSTR('UMTWRFS','U',2)-1
              WHEN 'M' THEN INSTR('MTWRFSUM','U',2)-1
              WHEN 'T' THEN INSTR('TWRFSUMT','U',2)-1
              WHEN 'W' THEN INSTR('WRFSUMTW','U',2)-1
              WHEN 'R' THEN INSTR('RFSUMTWR','U',2)-1
              WHEN 'F' THEN INSTR('FSUMTWRF','U',2)-1
              WHEN 'S' THEN INSTR('SUMTWRFS','U',2)-1
              END AS WK1,
              CASE substr(schedule.days,1,1)
              WHEN 'U' THEN INSTR('UMTWRFS','U',2)-1 +7
              WHEN 'M' THEN INSTR('MTWRFSUM','U',2)-1 +7
              WHEN 'T' THEN INSTR('TWRFSUMT','U',2)-1 +7
              WHEN 'W' THEN INSTR('WRFSUMTW','U',2)-1 +7
              WHEN 'R' THEN INSTR('RFSUMTWR','U',2)-1 +7
              WHEN 'F' THEN INSTR('FSUMTWRF','U',2)-1 +7
              WHEN 'S' THEN INSTR('SUMTWRFS','U',2)-1 +7
              END AS WK2,
              CASE substr(schedule.days,1,1)
              WHEN 'U' THEN INSTR('UMTWRFS','U',2)-1 +7 + 5
              WHEN 'M' THEN INSTR('MTWRFSUM','U',2)-1 +7 + 5  
              WHEN 'T' THEN INSTR('TWRFSUMT','U',2)-1 +7 + 5
              WHEN 'W' THEN INSTR('WRFSUMTW','U',2)-1 +7 + 5 
              WHEN 'R' THEN INSTR('RFSUMTWR','U',2)-1 +7 + 5
              WHEN 'F' THEN INSTR('FSUMTWRF','U',2)-1 +7 + 5
              WHEN 'S' THEN INSTR('SUMTWRFS','U',2)-1 + 7 + 5 
              END AS WK3,
              
                CASE substr(schedule.days,1,1)
              WHEN 'U' THEN INSTR('UMTWRFS','U',2)-1 +7 +7+ 5
              WHEN 'M' THEN INSTR('MTWRFSUM','U',2)-1 +7+7 + 5  
              WHEN 'T' THEN INSTR('TWRFSUMT','U',2)-1 +7+7 + 5
              WHEN 'W' THEN INSTR('WRFSUMTW','U',2)-1 +7+7 + 5 
              WHEN 'R' THEN INSTR('RFSUMTWR','U',2)-1 +7+7 + 5
              WHEN 'F' THEN INSTR('FSUMTWRF','U',2)-1 +7+7 + 5
              WHEN 'S' THEN INSTR('SUMTWRFS','U',2)-1 + 7+7 + 5 
              END AS WK4
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
            
        where           
           b.sgbstdn_term_code_eff   = (select max(a.sgbstdn_term_code_eff)
                from sgbstdn a
                where a.sgbstdn_pidm = b.sgbstdn_pidm
                and a.sgbstdn_term_code_eff <= sfrstcr_term_code)
            and sfrstcr_pidm = b.sgbstdn_pidm    
            and sfrstcr_term_code = '201502'
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
            where ssrfees_term_code = '201502'),

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
    where sfrrgfe_term_code='201502' 
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
  ST.SCHEDULE_DESC,
  ST.CLASS_ACTV_INACTV_CANC,
  ST.SECTION_PTRM_CODE,
  ST.REGIST_STATUS,
  ST.REGIST_ADD_DATE,
  ST.REGIST_ADD_HOUR24,
  ST.REGIST_STATUS_DATE,
  ST.REGIST_STATUS_HOUR24,
  ST.WK1_SUN,
  ST.WK2_SUN,
  ST.WK3_FRI,
  ST.WK4_FRI,
  ST.REGISTRATION_DATE,
  ST.SECTION_PTRM_START_DATE,
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
  ST.SCHEDULE_DESC,
  ST.CLASS_ACTV_INACTV_CANC,
  ST.SECTION_PTRM_CODE,
  ST.REGIST_STATUS,  
  ST.REGIST_ADD_DATE,
  ST.REGIST_ADD_HOUR24,
  ST.REGIST_STATUS_DATE,
  ST.REGIST_STATUS_HOUR24,
  ST.WK1_SUN,
  ST.WK2_SUN,
  ST.WK3_FRI,
  ST.WK4_FRI,
  ST.REGISTRATION_DATE,
  ST.SECTION_PTRM_START_DATE,
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