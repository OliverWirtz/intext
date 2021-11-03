/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_2_orr_dcr_crr_subgr);
/*
 * Purpose          : IT: subgroup orr results
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 07JUL2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 31JUL2020
 * Reason           : added printline
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 04AUG2020
 * Reason           : changd numbering
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 04SEP2020
 * Reason           : account for changed layout
 ******************************************************************************/

%macro subgroup(incrit='Objective response rate'
       ,title=%str(Table 9-20 Subgroup analysis of ORR by histology according to investigator pathology - independent assessment (FAS) )
       ,foot=
       ,foot1=);
data N orr;
    set tlfmeta.t_14_2_5_adrs_onccat_5_4_hi_1
     ;
    where find(_label_,&incrit.)>0
          or
          find(_label_,'Best overall response')>0;
    format text  $200.;
    text=put(subgroupn,_histgrp.);
    if subgroupn in (5 3 4) then do;
        _order=((30)+subgroupn)/10;
        text='  '||strip(text);
    end;
    else _order=_N_;
    if find(_label_,'Best overall response')>0 then do;
        if ~missing(ttt30)  then ttt30=substr(ttt30,anydigit(ttt30),find(ttt30,'(')-anydigit(ttt30));
        if ~missing(ttt31) then ttt31=substr(ttt31,anydigit(ttt31),find(ttt31,'(')-anydigit(ttt31));
        if ~missing(ttt30) then output N;
    end;
    else output orr;
run;


proc sql noprint;
    create table all0 as select
           a._order
           ,a.text label="Variable@  Subgroup"
           ,a.ttt30 label='n'

           ,b.ttt301 label='ORR@n (%)'
           ,a.ttt31 label='n'
           ,b.ttt311 label='ORR@n (%)'
           from n
           as a
           left join orr(rename= (ttt30=ttt301 ttt31=ttt311))
    as b
    on a.text=b.text order by _order;
QUIT;
%printline(##Table %sysfunc(scan(&title.,2,' ')));
%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = t_14_2_5_adrs_onccat_5_4_hi
  , title     =&title.
  , foot      = &foot.
  , foot1     =&foot1.
  , evaltable =
  , keepftn   = N
)


%datalist(
    data   = all0
  , var    = text ("Copanlisib/rituximab" ttt30 ttt301) ("Placebo/rituximab" ttt31 ttt311)
  , maxlen = 40
  , label  = no
)

proc datasets lib=work kill memtype=data nolist;
quit;
%mend;
 %subgroup(incrit='Objective response rate'
         ,title=%str(Table 9-18 Subgroup analysis of ORR by histology according to investigator pathology - independent assessment (FAS) )
         ,foot=%NRBQUOTE(FAS = Full analysis set; FL = Follicular lymphoma; LPL = Lymphoplasmacytoid lymphoma; MZL = Marginal-
zone lymphoma; N = Total number of patients (100%); n = number of patients with event; ORR = Objective response rate; SLL = Small lymphocytic lymphoma; WM = Waldenstroem macroglobulinemia
Notes: Note: Number (percentages) and 95% confidence intervals (CI) for percentages of patients. Percentages based on Total number of patients. 95% CI by exact binomial calculation.
Not evaluable (NE): Patients who have only post baseline tumor assessment(s) that could not be assessed by Investigator/Oncologist.
Unconfirmed SD is defined as SD on or before Study Day 48 relative to the first study drug dose date.
OWEN patients may include investigator assessments as absent of independent review. )
,foot1=%nrbquote(Source: Table 14.2.5.1/5 ));


 %subgroup(incrit='Complete response rate'
         ,title=%str(Table 9-19 Subgroup analysis of CRR by histology according to investigator pathology - independent assessment (FAS) )
         ,foot=%NRBQUOTE(CRR = Complete response rate; FAS = Full analysis set; FL = Follicular lymphoma; LPL = Lymphoplasmacytoid
lymphoma; MZL = Marginal-zone lymphoma; N = Total number of patients (100%); n = number of patients with event; SLL = Small lymphocytic lymphoma;
WM = Waldenstroem macroglobulinemia Notes: Note: Number (percentages) and 95% confidence intervals (CI) for percentages of patients. Percentages
based on Total number of patients. 95% CI by exact binomial calculation. Not evaluable (NE): Patients who have only post baseline tumor assessment(s)
that could not be assessed by Investigator/Oncologist. Unconfirmed SD is defined as SD on or before Study Day 48 relative to the first study drug dose date.
OWEN patients may include investigator assessments as absent of independent review. )
foot1=%nrbquote(Source: Table 14.2.5.1/5 ));

 %subgroup(incrit='Disease control rate'
         ,title=%str(Table 9-20 Subgroup analysis of DCR by histology according to investigator pathology - independent assessment (FAS) )
         , foot=%NRBQUOTE(DCR = Disease control rate; FAS = Full analysis set; FL = Follicular lymphoma; LPL = Lymphoplasmacytoid
lymphoma; MZL = Marginal-zone lymphoma; N = Total number of patients (100%); n = number of patients with event; SLL = Small lymphocytic lymphoma; WM = Waldenstroem macroglobulinemia
Notes: Note: Number (percentages) and 95% confidence intervals (CI) for percentages of patients.Percentages based on Total number of patients. 95% CI by exact binomial calculation.
Not evaluable (NE): Patients who have only post baseline tumor assessment(s) that could not be assessed by
Investigator/Oncologist. Unconfirmed SD is defined as SD on or before Study Day 48 relative to the first study drug dose date.
OWEN patients may include investigator assessments as absent of independent review. )
,foot1=%NRBQUOTE(Source: Table 14.2.5.1/5 )
         );





options nomprint notes;

%endprog;

