/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_adxt_bp);
/*
 * Purpose          : Table 10-37 Abnormal post-infusion blood pressure according to grades of CTCAE term "hypertension" (SAF)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 17AUG2020
 * Reference prog   :
 ******************************************************************************/
data lb;
    set tlfmeta.t_14_3_5_advsbp_grade_1
        tlfmeta.t_14_3_5_advsbp_grade_2;
    where missing(avisitn);
    format visit $100.;
    label _varl_='Blood pressure@  Worst grade'
          visit='Visit';
    ord=_N_;
    visit=" ";
    _varl_=tranwrd(_varl_,'[1]','');
RUN;
proc sql noprint;
    insert into lb set visit='Any visits ', _varl_='Diastolic', ord=0;
    insert into lb set  _varl_='Systolic', ord=5.5;
QUIT;
proc sort data=lb;
    by ord;
RUN;
%m_rename(
    indata  = lb
  , inarray = %str('_cptog1','_cptog2','_cptog3')
  , _split  = "@"
  , type    = 0
)
%printline(##Table 10-35);

%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = t_14_3_5_advsbp_grade
  , title     = %NRBQUOTE(Table 10-35 Abnormal post-infusion blood pressure according to grades of CTCAE term 'hypertension' (SAF) )
  , keepftn   = N
  , foot      = %NRBQUOTE(N = Total number of patients (100%); n = Number of patients with a post-infusion measurement; SAF = Safety analysis
set Notes: CTCAE, version 4.03 grade 1 (systolic 120 mmHg - 139 mmHg or diastolic 80 mmHg - 89 mmHg); grade 2 (systolic 140 mmHg - 159 mmHg
or diastolic 90 mmHg - 99 mmHg); grade 3 (systolic >= 160 mmHg or diastolic >= 100 mmHg). )
  , foot1     = %NRBQUOTE(Source: Table 14.3.5/24 )
  , evaltable =
)
%datalist(
    data = lb
  , var  = visit  _varl_ _cptog2 _cptog3
  , label= No
)

%endprog(
    cleanWork       = y
  , cleanTitlesFoot = y
  , verbose         = Y

)