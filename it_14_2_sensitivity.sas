/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_2_sensitivity);
/*
 * Purpose          : Table 9-5 Summary of sensitivity
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 26JUN2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 14AUG2020
 * Reason           : changed numbering
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 07OCT2020
 * Reason           : included analysis 5
 ******************************************************************************/

*retrieve data in=ax where x stands for analysis number;
data sen;
    set
        tlfmeta.t_14_2_adtte_pfs_allstrat_1 (in=a1)
        tlfmeta.t_14_2_adtte_pfs_nocens_1 (in=a2)
        tlfmeta.t_14_2_adtte_pfs_unstrat_1 (in=a3)
        tlfmeta.t_14_2_adtte_pfs_crfstrat_1(in=a4)
        tlfmeta.t_14_2_adtte_pfs_chgevt_1(in=a5)
        tlfmeta.t_14_2_adtte_pfs_cntystrat_1(in=a6)

    ;
    format sens $200.;
    where group1=5;
    if a1 then sens='Analysis 1';
    if a2 then sens='Analysis 2';
    if a3 then sens='Analysis 3';
    if a4 then sens='Analysis 4';
    if a5 then sens='Analysis 5';
    if a6 then sens='Analysis 6';
    gr=_n_;
    if _n_free=1 then nam='HR';
    else nam='p';
RUN;
proc sort data = sen out=sen1;
    by SENS ;
RUN;
proc transpose data=sen1 out=_sen1;
    by sens;
    var ttt30;
    id nam;
    idlabel _label_;
RUN;



*retrieve footnotes to fill analysis ;
%m_itmtitle(itdata    = t_14_2_adtte_pfs_allstrat)
*create collector for analyses description;
data ana;
    set _ittitles1;
    format descr $200.;
    where variable='FOOTNOTE2';
    descr='Analysis 1';
RUN;

%m_itmtitle(itdata    = t_14_2_adtte_pfs_nocens)
*create collector for analyses description;
data ana;
    set ana(in=a) _ittitles1(in=b);
    format descr $200.;
    if a or (b and variable='FOOTNOTE1') ;
    if b then descr='Analysis 2';
RUN;
*retrieve footnotes to fill analysis ;
%m_itmtitle(itdata    = t_14_2_adtte_pfs_unstrat)

data ana;
    set ana(in=a) _ittitles1(in=b);
    if a or (b and variable='FOOTNOTE2') ;
    if b then descr='Analysis 3';
RUN;
*retrieve footnotes to fill analysis ;
%m_itmtitle(itdata    = t_14_2_adtte_pfs_crfstrat)
data ana;
    set ana(in=a) _ittitles1(in=b);
    if a or (b and variable='FOOTNOTE3') ;
    if b then descr='Analysis 4';
RUN;

%m_itmtitle(itdata    = t_14_2_adtte_pfs_chgevt)
data ana;
    set ana(in=a) _ittitles1(in=b);
    if a or (b and variable='FOOTNOTE1') ;
    if b then descr='Analysis 5';
RUN;

***;
%m_itmtitle(itdata    = t_14_2_adtte_pfs_cntystrat)
data ana;
    set ana(in=a) _ittitles1(in=b);
    if a or (b and variable='FOOTNOTE2') ;
    if b then descr='Analysis 6';
RUN;

*mrge to results;
proc sql noprint;
    create table sen2 as select a.*,b.value from _sen1 as a left join ana as b on a.sens=b.descr
          ;

QUIT;
data sen3;
    set sen2 ;
    label sens='Sensitivity analysis' value=' ';
RUN;

%printline(##Table 9-5)

%set_titles_footnotes(
    tit1           = 'Table 9-5 Summary of the sensitivity analyses of the PFS by independent assessment (FAS) '
  , ftn1           = %nrbquote('CI = Confidence interval; COVID-19 = Coronavirus Disease 2019; CRF = Case report form; FAS = Full
analysis set; IxRS = Interactive Voice/Web Response System; N = Total number of patients (100%); PFS = Progression-free survival; SAP = Statistical analysis plan')
  , ftn2           = %nrbquote('a. In case of many discrepancies between stratification factors entered in the IxRS and information entered
in CRF; some patients were excluded from this analysis, since these patients should not have been enrolled; For details, refer to Section 6.2.1 of Section 16.1.9 SAP.')
  , ftn3           = %nrbquote('b. e.g., treating initiation of a new anticancer agent as an event at the date of start of new anticancer agent,
treating disease progression as an event at the date of progression ignoring scheduled missing assessments, treating treatment discontinuation as an event at the date
of discontinuation, For details, refer to Section 6.2.1 of Section 16.1.9 SAP. ')

  );

%datalist(
    data            = sen3
  , page            =
  , by              =
  , var             = sens value hr p
  ,label=no
  ,maxlen=30
);

%endprog;