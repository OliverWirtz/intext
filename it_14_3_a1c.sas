/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin’s lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_a1c);
/*
 * Purpose          : Table 10-29 Mean of HbA1c levels (%) and change from baseline values by treatment group (SAF)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 04AUG2020
 * Reference prog   :
 ******************************************************************************/
*retrieve data;
data ae;
    set tlfmeta.t_14_3_5_adlbchem_hba1c_4;
    format text $200.;

    text=scan(_stat_,1,' ');
    where (avisitn in (0.5) or _vlabel_='Change from baseline') and _statnr_ not in (6) ;
RUN;

*transpose for both trt groups;
proc transpose data=ae out=ae_cop;
    by avisitn avisit ;
    var count1;
   idlabel _stat_;
   id text;
RUN;
proc transpose data=ae out=ae_pla  prefix=pla_ ;
    by avisitn avisit ;
    var count2;
    idlabel _stat_;
    id text;
RUN;

*retrieve label and merge for output;
proc sql noprint;
    select distinct(_label_) into :_cop from ae_cop;
    select distinct(_label_) into :_pla from ae_pla;
    create table all as select a.*,b.pla_n,b.pla_mean from ae_cop as a left join ae_pla as b on a.avisitn=b.avisitn;
QUIT;


%printline(##Table 10-29);

%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 4
  , itdata    = t_14_3_5_adlbchem_hba1c
  , title     = %nrbquote(Table 10-29 Mean of HbA1c levels (%) and change from baseline values by treatment group (SAF) )
  , keepftn   = N
  , foot      = %nrbquote(EOT = End of treatment; HbA1c = Hemoglobin A1c (glycated hemoglobin); N = Total number of patients (100%); n = Number of patients with event; SAF = Safety analysis set; StD = Standard deviation
Note: The same patient could be included in both EOT and post treatment categories. )
  , foot1     = %nrbquote(Source: Table 14.3.5/10 )
  , evaltable =
)


%datalist(
    data   = all
  , var    =  avisit ("&_cop." n mean) ("&_pla." pla_n pla_mean)
  , order  = avisitn
  , maxlen = 30
  , label  = no
  ,split='#'
)

%endprog(
    cleanWork       = y
  , cleanTitlesFoot = y
  , verbose         = Y
)


