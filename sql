SELECT 
     PERIOD,
            DATASET_ID,
            RULE_NM,
            RUN_ID,
            SCHEDULE_NM,
            SUB_SCHEDULE_NM,
            MDRM,
           (RPRT_PT),
            sum(BALNCE) BALNCE,
            'S' AS  SOURCE_FLAG from (             
     SELECT PERIOD,
            DATASET_ID,
            RULE_NM,
            RUN_ID,
            SCHEDULE_NM,
            SUB_SCHEDULE_NM,
            DATA_ROW_SEQ,
            DISPLAY_ROW_SEQ,
            MAX (MDRM) MDRM,
            MAX (BALNCE) BALNCE,
              MAX (RPRT_PT) RPRT_PT,
            MAX (FRS_BU) FRS_BU,
            'S' AS SOURCE_FLAG
       FROM (  SELECT B.PERIOD,
                      B.DATASET_ID,
                      RULE_NM,
                      DATA_COL_HEADER_NM,
                      SCHEDULE_NM,
                      SUB_SCHEDULE_NM,
                      DISPLAY_ROW_SEQ,
                      DATA_ROW_SEQ,
                      B.RUN_ID,
                      VALUE_TEXT || VALUE_NUM VALUE1
                 FROM REGINSIGHT_RDM.RR_FORM_FACT FACT,
                      (  SELECT RR.FISCAL_YEAR
                                || TO_CHAR (RR.ACCOUNTING_PERIOD, 'FM00')
                                   PERIOD,
                                RR.DATASET_ID,
                                RR.SCHEDULE_NM,
                                RR.SUB_SCHEDULE_NM,
                                MAX (RR.RUN_ID) RUN_ID
                           FROM REGINSIGHT_ODS.RR_RUN RR,
                                REGINSIGHT_META.RR_RUN_PROC_SETUP rs
                          WHERE     rr.FORM_NM = rs.FORM_NM
                                AND rr.SCHEDULE_NM = rs.SCHEDULE_NM
                                AND rr.SUB_SCHEDULE_NM = rs.SUB_SCHEDULE_NM
                                AND rr.PROJECT_ID = rs.PROJECT_ID
                                AND RS.SOURCE = RR.SOURCE
                                AND rs.MODULE ='FRY14Q_G_Citigroup_SYST_RPT_LOAD_CCR_AGG'
                                AND RR.STATUS_LATEST = 'Y'
                                AND RR.PROC_NM = RS.PROC_NM
                                AND RR.SUB_PROC_NM = RS.SUB_PROC_NM
                       GROUP BY RR.FISCAL_YEAR
                                || TO_CHAR (RR.ACCOUNTING_PERIOD, 'FM00'),
                                RR.DATASET_ID,
                                RR.SCHEDULE_NM,
                                RR.SUB_SCHEDULE_NM) B
                WHERE FACT.RUN_ID = B.RUN_ID --AND FACT.RULE_NM = 'RL_FRY14Q_E1'
                      AND DATA_COL_HEADER_NM IN
                             ('MDRM' ,
             'BALNCE' ,
             'RPRT_PT',
           'FRS_BU' )
             ORDER BY DATA_ROW_SEQ) PIVOT (MAX (VALUE1)
                                    FOR DATA_COL_HEADER_NM
                                    IN  (  'MDRM' MDRM,
             'BALNCE' BALNCE,
             'RPRT_PT' RPRT_PT,
           'FRS_BU' FRS_BU))
   GROUP BY PERIOD,
            DATASET_ID,
            RULE_NM,
            RUN_ID,
            SCHEDULE_NM,
            SUB_SCHEDULE_NM,
            DATA_ROW_SEQ,
            DISPLAY_ROW_SEQ)
     group by     PERIOD,
            DATASET_ID,
            RULE_NM,
            RUN_ID,
            SCHEDULE_NM,
            SUB_SCHEDULE_NM,
            MDRM,
           (RPRT_PT);
