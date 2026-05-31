
/* ============================================================
    IMPORT DATA : 
   ============================================================ */

PROC IMPORT
    DATAFILE="/home/u64509879/final_churn_project_data.csv"
    OUT=work.churn_data
    DBMS=CSV
    REPLACE;
    GETNAMES=YES;
    GUESSINGROWS=1000;
RUN;



/*============================================================
   EDA : 
============================================================*/

/* 1. Dataset Structure */
TITLE "Dataset Structure and Variable Names";
PROC CONTENTS DATA=WORK.churn_data;
RUN;

/* 2. Preview Data */
TITLE "First 10 Rows of Dataset";
PROC PRINT DATA=WORK.churn_data (OBS=10);
RUN;

/* 3. Missing Values Check */
TITLE "Missing Values Check";
PROC MEANS DATA=WORK.churn_data N NMISS;
RUN;

/* 4. Summary Statistics for Numeric Variables */
TITLE "Summary Statistics";
PROC MEANS DATA=WORK.churn_data MEAN MEDIAN Q1 Q3 MIN MAX STD;
    VAR Age Tenure
        "Usage Frequency"n
        "Support Calls"n
        "Payment Delay"n
        "Total Spend"n
        "Last Interaction"n;
RUN;

/* 5. Frequency Distribution for Categorical Variables */
TITLE "Categorical Variable Distribution";
PROC FREQ DATA=WORK.churn_data;
    TABLES Gender
           "Subscription Type"n
           "Contract Length"n
           Churn;
RUN;

/* 6. Correlation Analysis */
TITLE "Correlation Matrix for Numeric Variables";
PROC CORR DATA=WORK.churn_data;
    VAR Age Tenure
        "Usage Frequency"n
        "Support Calls"n
        "Payment Delay"n
        "Total Spend"n
        "Last Interaction"n;
RUN;

/* 7. Average Numeric Values by Churn Status */
TITLE "Average Numeric Values by Churn Status";
PROC MEANS DATA=WORK.churn_data MEAN;
    CLASS Churn;
    VAR Age Tenure
        "Usage Frequency"n
        "Support Calls"n
        "Payment Delay"n
        "Total Spend"n
        "Last Interaction"n;
RUN;





/*============================================================
   VISUALIZATIONS :
============================================================*/

/* Boxplot 1 – Age */
TITLE "Boxplot | Age — Outlier Detection";
PROC SGPLOT DATA=WORK.churn_data;
    VBOX Age;
RUN;
TITLE;

/* Boxplot 2 – Tenure */
TITLE "Boxplot | Tenure — Outlier Detection";
PROC SGPLOT DATA=WORK.churn_data;
    VBOX Tenure;
RUN;
TITLE;

/* Boxplot 3 – Usage Frequency */
TITLE "Boxplot | Usage Frequency — Outlier Detection";
PROC SGPLOT DATA=WORK.churn_data;
    VBOX "Usage Frequency"n;
RUN;
TITLE;

/* Boxplot 4 – Support Calls */
TITLE "Boxplot | Support Calls — Outlier Detection";
PROC SGPLOT DATA=WORK.churn_data;
    VBOX "Support Calls"n;
RUN;
TITLE;

/* Boxplot 5 – Payment Delay */
TITLE "Boxplot | Payment Delay — Outlier Detection";
PROC SGPLOT DATA=WORK.churn_data;
    VBOX "Payment Delay"n;
RUN;
TITLE;

/* Boxplot 6 – Total Spend */
TITLE "Boxplot | Total Spend — Outlier Detection";
PROC SGPLOT DATA=WORK.churn_data;
    VBOX "Total Spend"n;
RUN;
TITLE;

/* Boxplot 7 – Last Interaction */
TITLE "Boxplot | Last Interaction — Outlier Detection";
PROC SGPLOT DATA=WORK.churn_data;
    VBOX "Last Interaction"n;
RUN;
TITLE;








/* PLOT 1 – Overall Churn Distribution */
TITLE "Plot 1 | Overall Churn Distribution";
PROC SGPLOT DATA=WORK.churn_data;
    VBAR Churn / DATALABEL;
RUN;
TITLE;




/* PLOT 2 – Age Distribution by Churn */
TITLE "Plot 2 | Age Distribution by Churn";
PROC SGPLOT DATA=WORK.churn_data;
    HISTOGRAM Age / GROUP=Churn TRANSPARENCY=0.3;
    DENSITY Age / GROUP=Churn TYPE=KERNEL;
RUN;
TITLE;




/* PLOT 3 – Tenure by Churn */
TITLE "Plot 3 | Tenure by Churn";
PROC SGPLOT DATA=WORK.churn_data;
    VBOX Tenure / CATEGORY=Churn;
RUN;
TITLE;



/* PLOT 4 – Contract Length vs Churn */
PROC FREQ DATA=WORK.churn_data NOPRINT;
    TABLES "Contract Length"n * Churn / OUT=WORK.freq_contract OUTPCT;
RUN;

TITLE "Plot 4 | Contract Length vs Churn";
PROC SGPLOT DATA=WORK.freq_contract;
    VBAR "Contract Length"n / RESPONSE=PCT_COL GROUP=Churn GROUPDISPLAY=CLUSTER;
RUN;
TITLE;



/* PLOT 5 – Subscription Type vs Churn */
PROC FREQ DATA=WORK.churn_data NOPRINT;
    TABLES "Subscription Type"n * Churn / OUT=WORK.freq_sub OUTPCT;
RUN;

TITLE "Plot 5 | Subscription Type vs Churn";
PROC SGPLOT DATA=WORK.freq_sub;
    VBAR "Subscription Type"n / RESPONSE=PCT_COL GROUP=Churn GROUPDISPLAY=STACK;
RUN;
TITLE;


/* PLOT 6 – Support Calls by Churn */
TITLE "Plot 6 | Support Calls by Churn";
PROC SGPLOT DATA=WORK.churn_data;
    VBOX "Support Calls"n / CATEGORY=Churn;
RUN;
TITLE;




/* PLOT 7 – Payment Delay vs Support Calls */
TITLE "Plot 7 | Payment Delay vs Support Calls";
PROC SGPLOT DATA=WORK.churn_data (OBS=5000);
    SCATTER X="Payment Delay"n Y="Support Calls"n / GROUP=Churn TRANSPARENCY=0.5;
    REG     X="Payment Delay"n Y="Support Calls"n / GROUP=Churn;
RUN;
TITLE;



/* PLOT 8 – Churn Rate by Tenure Decile */
DATA WORK.churn_flag;
    SET WORK.churn_data;
    Churn_Num = (Churn = 'Yes');
RUN;

PROC RANK DATA=WORK.churn_flag OUT=WORK.rank_tenure GROUPS=10;
    VAR Tenure;
    RANKS Tenure_Dec;
RUN;

PROC MEANS DATA=WORK.rank_tenure NOPRINT NWAY;
    CLASS Tenure_Dec;
    VAR Churn_Num;
    OUTPUT OUT=WORK.mean_tenure MEAN=Churn_Rate;
RUN;

TITLE "Plot 8 | Churn Rate by Tenure Decile";
PROC SGPLOT DATA=WORK.mean_tenure;
    FORMAT Churn_Rate PERCENT8.2;
    SERIES X=Tenure_Dec Y=Churn_Rate / MARKERS;
    BAND   X=Tenure_Dec LOWER=0 UPPER=Churn_Rate / TRANSPARENCY=0.7;
RUN;
TITLE;




/* PLOT 9 – Heatmap: Support Calls vs Payment Delay */
DATA WORK.heatmap_prep;
    SET WORK.churn_flag;
    SC_Bin = MIN(FLOOR("Support Calls"n / 2) * 2, 8);
    PD_Bin = MIN(FLOOR("Payment Delay"n / 6) * 6, 24);
RUN;

PROC MEANS DATA=WORK.heatmap_prep NOPRINT NWAY;
    CLASS SC_Bin PD_Bin;
    VAR Churn_Num;
    OUTPUT OUT=WORK.heat_out MEAN=Churn_Rate;
RUN;

TITLE "Plot 9 | Heatmap: Support Calls vs Payment Delay Churn Rate";
PROC SGPLOT DATA=WORK.heat_out;
    FORMAT Churn_Rate PERCENT8.2;
    HEATMAPPARM X=PD_Bin Y=SC_Bin COLORRESPONSE=Churn_Rate;
    GRADLEGEND;
RUN;
TITLE;



/* PLOT 10 – Usage Frequency Density by Churn */
TITLE "Plot 10 | Usage Frequency Density by Churn";
PROC SGPLOT DATA=WORK.churn_data;
    DENSITY "Usage Frequency"n / GROUP=Churn TYPE=KERNEL;
RUN;
TITLE;


/* PLOT 11 – Gender vs Churn */
PROC FREQ DATA=WORK.churn_data NOPRINT;
    TABLES Gender * Churn / OUT=WORK.freq_gender OUTPCT;
RUN;

TITLE "Plot 11 | Gender vs Churn";
PROC SGPLOT DATA=WORK.freq_gender;
    VBAR Gender / RESPONSE=PCT_COL GROUP=Churn GROUPDISPLAY=CLUSTER;
RUN;
TITLE;


/* PLOT 12 – Subscription Type Pie Chart */
TITLE "Plot 12 | Subscription Type Distribution";
PROC GCHART DATA=WORK.churn_data;
    PIE "Subscription Type"n / PERCENT=OUTSIDE VALUE=NONE SLICE=OUTSIDE;
RUN;
QUIT;
TITLE;

/* PLOT 13 – Mean Comparison across Key Variables */
PROC MEANS DATA=WORK.churn_flag NOPRINT NWAY;
    CLASS Churn;
    VAR Age Tenure "Usage Frequency"n "Support Calls"n "Payment Delay"n;
    OUTPUT OUT=WORK.means_churn MEAN=;
RUN;

PROC TRANSPOSE DATA=WORK.means_churn OUT=WORK.means_long;
    BY Churn;
    VAR Age Tenure "Usage Frequency"n "Support Calls"n "Payment Delay"n;
RUN;

TITLE "Plot 13 | Mean Comparison by Churn";
PROC SGPLOT DATA=WORK.means_long;
    HBAR _NAME_ / RESPONSE=COL1 GROUP=Churn GROUPDISPLAY=CLUSTER;
RUN;
TITLE;


/* PLOT 17 – Subscription Type vs Churn Paneled by Contract Length */
TITLE "Plot 17 | Subscription Type vs Churn — Paneled by Contract Length";
PROC SGPANEL DATA=WORK.churn_data;
    PANELBY "Contract Length"n / COLUMNS=3 NOVARNAME;
    VBAR "Subscription Type"n / GROUP=Churn GROUPDISPLAY=CLUSTER STAT=PERCENT;
    ROWAXIS LABEL="Percentage (%)" GRID;
    COLAXIS LABEL="Subscription Type";
RUN;
TITLE;


/*============================================================
  CLEANING :
============================================================*/




/* Check for duplicate CustomerIDs*/
PROC FREQ DATA=WORK.churn_data;
    TABLES CustomerID / OUT=WORK.id_counts NOPRINT;
RUN;

DATA WORK.duplicates_check;
    SET WORK.id_counts;
    WHERE COUNT > 1;
RUN;

PROC PRINT DATA=WORK.duplicates_check;
    TITLE "Duplicate CustomerIDs Found";
RUN;


/* Check for invalid values  */
DATA WORK.invalid_check;
    SET WORK.churn_data;
    Invalid_Age          = (Age < 0 OR Age > 100);
    Invalid_Spend        = ("Total Spend"n < 0);
    Invalid_Tenure       = (Tenure < 0);
    Invalid_UsageFreq    = ("Usage Frequency"n < 0);
    Invalid_SupportCalls = ("Support Calls"n < 0);
    Invalid_PayDelay     = ("Payment Delay"n < 0);
    IF Invalid_Age OR Invalid_Spend OR Invalid_Tenure
       OR Invalid_UsageFreq OR Invalid_SupportCalls OR Invalid_PayDelay;
RUN;

PROC PRINT DATA=WORK.invalid_check (OBS=20);
    TITLE "Invalid Values Found (Sample of 20)";
RUN;




/*  Remove fully duplicate rows ────────────────── */
PROC SORT DATA=WORK.churn_data
          OUT=WORK.churn_nodup
          NODUPKEY;
    BY _ALL_;
RUN;

/*  Remove duplicate CustomerIDs ───────────────── */
PROC SORT DATA=WORK.churn_nodup
          OUT=WORK.churn_nodupid
          DUPOUT=WORK.churn_dups
          NODUPKEY;
    BY CustomerID;
RUN;



/* Check duplicates after removal */
PROC SQL;
    SELECT COUNT(*) AS Total_Rows,
           COUNT(DISTINCT CustomerID) AS Unique_Customers
    FROM WORK.churn_nodupid;
QUIT;


PROC CONTENTS DATA=WORK.churn_nodupid;
RUN;

/*  Compute IQR bounds for outlier capping ─────── */
PROC UNIVARIATE DATA=WORK.churn_nodupid NOPRINT;
    VAR Age "Total Spend"n;
    OUTPUT OUT    = WORK.outlier_stats
           Q1     = Age_Q1    Spend_Q1
           Q3     = Age_Q3    Spend_Q3
           QRANGE = Age_IQR   Spend_IQR;
RUN;

/* Standardize Gender + nullify invalid values ── */
DATA WORK.churn_flagged;
    SET WORK.churn_nodupid;

    IF      UPCASE(STRIP(Gender)) IN ('F', 'FEMALE') THEN Gender = 'Female';
    ELSE IF UPCASE(STRIP(Gender)) IN ('M', 'MALE')   THEN Gender = 'Male';
    ELSE Gender = ' ';

    IF Age < 0 OR Age > 100   THEN Age            = .;
    IF "Total Spend"n > 10000 THEN "Total Spend"n = .;
RUN;

/* Confirm Gender standardization */
PROC FREQ DATA=WORK.churn_flagged;
    TABLES Gender / MISSING;
RUN;

/* Confirm Age invalid values nullified */
PROC MEANS DATA=WORK.churn_flagged NMISS MIN MAX;
    VAR Age "Total Spend"n;
RUN;




/* Compute medians for imputation ─────────────── */
PROC MEANS DATA=WORK.churn_flagged MEDIAN NOPRINT;
    VAR Age "Total Spend"n;
    OUTPUT OUT    = WORK.medians
           MEDIAN(Age)            = med_Age
           MEDIAN("Total Spend"n) = med_Spend;
RUN;

DATA _NULL_;
    SET WORK.medians;
    CALL SYMPUTX('med_Age',   med_Age);
    CALL SYMPUTX('med_Spend', med_Spend);
RUN;



/* ── STEP 9: Compute Gender mode ────────────────────────── */
PROC FREQ DATA=WORK.churn_flagged ORDER=FREQ;
    TABLES Gender / OUT=WORK.gender_freq MISSING;
RUN;

DATA _NULL_;
    SET WORK.gender_freq;
    WHERE NOT MISSING(Gender);
    IF _N_ = 1 THEN CALL SYMPUTX('GENDER_MODE', Gender);
RUN;



/*  Apply imputation ──────────────────────────── */
DATA WORK.churn_imputed;
    SET WORK.churn_flagged;

    IF MISSING(Age)            THEN Age            = &med_Age;
    IF MISSING("Total Spend"n) THEN "Total Spend"n = &med_Spend;
    IF MISSING(Gender)         THEN Gender         = "&GENDER_MODE";

    Age            = INT(Age);
    "Total Spend"n = INT("Total Spend"n);
RUN;

/* check nulls after imputation */
PROC MEANS DATA=WORK.churn_imputed NMISS;
    VAR Age "Total Spend"n;
RUN;

PROC FREQ DATA=WORK.churn_imputed;
    TABLES Gender / MISSING;
RUN;




/* ── STEP 11: Cap outliers using IQR bounds ─────────────── */
DATA _NULL_;
    SET WORK.outlier_stats;
    CALL SYMPUTX('Age_low',    Age_Q1   - 1.5 * Age_IQR);
    CALL SYMPUTX('Age_high',   Age_Q3   + 1.5 * Age_IQR);
    CALL SYMPUTX('Spend_low',  Spend_Q1 - 1.5 * Spend_IQR);
    CALL SYMPUTX('Spend_high', Spend_Q3 + 1.5 * Spend_IQR);
RUN;

DATA WORK.churn_capped;
    SET WORK.churn_imputed;

    IF Age < &Age_low  THEN Age = &Age_low;
    IF Age > &Age_high THEN Age = &Age_high;

    IF "Total Spend"n < &Spend_low  THEN "Total Spend"n = &Spend_low;
    IF "Total Spend"n > &Spend_high THEN "Total Spend"n = &Spend_high;
RUN;


/* Boxplot After Cleaning – Age */
TITLE "Boxplot | Age — After Cleaning";
PROC SGPLOT DATA=WORK.churn_capped;
    VBOX Age;
RUN;
TITLE;

/* Boxplot After Cleaning – Total Spend */
TITLE "Boxplot | Total Spend — After Cleaning";
PROC SGPLOT DATA=WORK.churn_capped;
    VBOX "Total Spend"n;
RUN;
TITLE;



/*  Feature Engineering ──────────────────────── */
DATA WORK.churn_final;
    SET WORK.churn_capped;
    
    /*  Engagement Score */
    Engagement_Score = "Usage Frequency"n / Tenure;

    /* Problem Ratio */
    Problem_Ratio = "Support Calls"n / ("Usage Frequency"n + 1);

    /* Ordinal Encoding */
    SELECT (STRIP("Subscription Type"n));
        WHEN ('Basic')    Sub_Score = 1;
        WHEN ('Standard') Sub_Score = 2;
        WHEN ('Premium')  Sub_Score = 3;
        OTHERWISE         Sub_Score = .;
    END;

    SELECT (STRIP("Contract Length"n));
        WHEN ('Monthly')   Contract_Score = 1;
        WHEN ('Quarterly') Contract_Score = 2;
        WHEN ('Annual')    Contract_Score = 3;
        OTHERWISE          Contract_Score = .;
    END;

    /* One-Hot Encoding – Gender */
    IF Gender = 'Female' THEN DO;
        Gender_Female = 1;
        Gender_Male   = 0;
    END;
    ELSE DO;
        Gender_Female = 0;
        Gender_Male   = 1;
    END;

    /* Binary Encoding – Churn */
    IF Churn = 'Yes' THEN Churn_Num = 1;
    ELSE                  Churn_Num = 0;

    LABEL
        Engagement_Score = "Engagement Score (Usage Frequency / Tenure)"
        Problem_Ratio    = "Problem Ratio (Support Calls / (Usage Frequency + 1))"
        Sub_Score        = "Subscription Type Score (1=Basic, 2=Standard, 3=Premium)"
        Contract_Score   = "Contract Length Score (1=Monthly, 2=Quarterly, 3=Annual)"
        Gender_Female    = "Gender Female Flag (1=Female, 0=Male)"
        Gender_Male      = "Gender Male Flag (1=Male, 0=Female)"
        Churn_Num        = "Churn Flag (1=Yes, 0=No)";
RUN;


/* ── SNAPSHOT: Before vs After ──────────────────────────── */
PROC MEANS DATA=WORK.churn_data
    N NMISS MEAN MEDIAN STD MIN MAX;
    VAR Age "Total Spend"n Tenure "Usage Frequency"n
        "Support Calls"n "Payment Delay"n "Last Interaction"n;
    TITLE "Numeric Stats Before Cleaning";
RUN;

PROC MEANS DATA=WORK.churn_final
    N NMISS MEAN MEDIAN STD MIN MAX;
    VAR Age "Total Spend"n Tenure "Usage Frequency"n
        "Support Calls"n "Payment Delay"n "Last Interaction"n;
    TITLE "Numeric Stats After Cleaning";
RUN;

PROC MEANS DATA=WORK.churn_final NMISS;
    VAR Age "Total Spend"n Sub_Score Contract_Score Gender_Female Churn_Num;
    TITLE "Missing Values After Cleaning";
RUN;

PROC FREQ DATA=WORK.churn_final;
    TABLES Gender Churn "Subscription Type"n "Contract Length"n;
    TITLE "Categorical Distributions After Cleaning";
RUN;

PROC CONTENTS DATA=WORK.churn_final;
    TITLE "Final Dataset Info";
RUN;

TITLE;



TITLE "First 10 Rows of Dataset";
PROC PRINT DATA=WORK.churn_final (OBS=10);
RUN;




/*============================================================
  Model building and Evaluation:
============================================================*/



/*  TRAIN / TEST SPLIT */
DATA WORK.train WORK.test;
    SET WORK.churn_final;
    RAND = RAND("uniform");
    IF RAND < 0.7 THEN OUTPUT WORK.train;
    ELSE OUTPUT WORK.test;
    DROP RAND;
RUN;

/* LOGISTIC REGRESSION MODEL */
PROC LOGISTIC DATA=WORK.train OUTMODEL=WORK.log_model;
    MODEL Churn_Num(EVENT='1') =
    	Age
    	Tenure
    	"Usage Frequency"n
        Engagement_Score
        Problem_Ratio
        "Total Spend"n
        "Last Interaction"n
        "Support Calls"n
        "Payment Delay"n
        Sub_Score
        Contract_Score
        / SELECTION=STEPWISE;
RUN;

/*  PREDICTION ON TEST SET */
PROC LOGISTIC INMODEL=WORK.log_model;
    SCORE DATA=WORK.test OUT=WORK.predicted;
RUN;

/*  CONFUSION MATRIX */
PROC FREQ DATA=WORK.predicted;
    TABLES Churn_Num*I_Churn_Num / NOCOL NOPERCENT;
RUN;

/*  BASELINE COMPARISON */
PROC MEANS DATA=WORK.train MEAN;
    CLASS Churn_Num;
    VAR Engagement_Score 
        "Support Calls"n "Payment Delay"n;
    TITLE "Mean Comparison — Churned vs Not Churned";
RUN;

/*  SUMMARY INSIGHT TABLE */
PROC MEANS DATA=WORK.predicted MEAN;
    CLASS Churn_Num I_Churn_Num;
    VAR  "Total Spend"n Tenure;
    TITLE "Summary: Actual vs Predicted Churn";
RUN;

/* model stats*/
PROC LOGISTIC DATA=WORK.train;
    MODEL Churn_Num(EVENT='1') = Age Tenure "Usage Frequency"n
        Engagement_Score Problem_Ratio "Total Spend"n
        "Support Calls"n "Payment Delay"n Sub_Score Contract_Score;

    SCORE DATA=WORK.test OUT=WORK.predicted FITSTAT;
RUN;


/* STEP 19 — ROC Curve */

PROC LOGISTIC DATA=WORK.train PLOTS(ONLY)=ROC;
    MODEL Churn_Num(EVENT='1') =
    	Age
    	Tenure
    	"Usage Frequency"n
        Engagement_Score
        Problem_Ratio
        "Total Spend"n
        "Last Interaction"n
        "Support Calls"n
        "Payment Delay"n
        Sub_Score
        Contract_Score
        / SELECTION=STEPWISE;
RUN;

