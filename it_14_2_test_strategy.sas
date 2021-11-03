/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_2_test_strategy);
/*
 * Purpose          : Table 9-13 Overview of hierarchical statistical test strategy - US
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 02JUL2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 03AUG2020
 * Reason           : changed numbering and footnote.
 ******************************************************************************/

%macro _sens(title=%STR(Table 9-13 Overview of hierarchical statistical test strategy - US)
       ,data=t_14_2_adtte_adrs_hier_us
       ,so=%nrbquote(Source: Table 14.2.3/1)
       , foot=);

data dat;
    set tlfmeta.&data._1;
RUN;

%printline(##Table %sysfunc(scan(&title.,2,' ')));
%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = &data.
  , title     = &title.
  , keepftn   = N
  , foot      =&foot.
  ,foot1 =&so

);

/**minor adaptions;*/
/*data _ittitles3;*/
/*    set _ittitles2;*/
/*    if variable="FOOTNOTE5" then do;*/
/*        value=catt(value, " &so.");*/
/*    end;*/
/*RUN;*/
/**put tit foot from adaptions;*/
/*%m_itmtitle(mymeta=tl_meta,tableno=1, itdata=&data.,*/
/*evaltable=_ittitles3  );*/

%datalist(
    data   = dat
  , var    =  familyno thres test nullhyp pvalue decision
  , maxlen = 30
  , label  = no
  ,split='@'
)
proc datasets lib=work kill memtype=data nolist;
quit;
%mend _sens;
%_sens(title=%STR(Table 9-13 Overview of hierarchical statistical test strategy - US)
,data=t_14_2_adtte_adrs_hier_us
,so=%nrbquote(Source: Table 14.2.3/1)
, foot= %nrbquote(DRS-P = Disease-related symptoms - physical (subscale); FAS = Full analysis set; FL = Follicular lymphoma; iNHL = Indolent
non-Hodgkin's lymphoma; H0 =  Null hypothesis; N/A = Not applicable; ORR =  Objective response rate; PFS = Progression-free survival
Notes: The log-rank test for PFS in iNHL is stratified by iNHL histology and entry criterion used for randomization
Tests on the FL and MZL population are stratified by entry criterion used for randomization Not determined: As a previous null hypothesis
could not be rejected, the hierarchical test procedure was stopped and a test decision cannot be concluded.
))
;

%_sens(title=%STR(Table 9-14 Overview of hierarchical statistical test strategy - EU)
,data=t_14_2_adtte_adrs_hier_eu
,so=%nrbquote(Source: Table 14.2.3/2)
, foot= %nrbquote(DRS-P = Disease-related symptoms - physical (subscale); FAS = Full analysis set; FL = Follicular lymphoma; iNHL = Indolent
non-Hodgkin's lymphoma; H0 =  Null hypothesis; N/A = Not applicable; ORR =  Objective response rate; PFS = Progression-free survival Notes:
CMH and log-rank tests are stratified by iNHL histology and entry criterion used for randomization
Not determined: As a previous null hypothesis could not be rejected, the hierarchical test procedure was stopped and a test decision cannot be concluded
))
;


%endprog(
    cleanWork       = y
  , cleanTitlesFoot = y
  , verbose         = Y
)
