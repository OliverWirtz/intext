/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_2_concordance_rate);
/*
 * Purpose          : Table 9-7 Concordance rate summary between best overall response as evaluated by oncologist in independent and investigator's assessment (FAS)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.2
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 26JUN2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 13AUG2020
 * Reason           : changed numbering added footnotes
 ******************************************************************************/

*retrieve data;
data con;
    set tlfmeta.t_14_2_2_adrs_concord_rate_1;
    format trt rscat $200.;
    by trt01pn;
    if  first.trt01pn then do;
        trt=compress(put(trt01pn, _z_trt.));
    end;
    rscat=propcase(put(rscatn, _rscat.));
RUN;


%printline(##Table 9-7)
*retrieve tit foot;
%m_itmtitle(mymeta=tl_meta,tableno=1, itdata=t_14_2_2_adrs_concord_rate,
 title=%nrbquote(Table 9-7 Concordance rate summary between best overall response as evaluated by oncologist in independent and investigator's assessment (FAS) )
,foot=%nrbquote(FAS = Full analysis set; N = # of patients with non-missing post-baseline tumor assessments from both
independent assessment and investigator's assessment. Notes: The concordance rate - all categories=# of patients having same assessment results for investigator
and central reviewers / total patient number. Concordance rate - response vs. no response=# of patient having same assessment results of ORR (yes/no) for both
evaluators / total patient number.)
, foot1=%nrbquote(Source: Table 14.2.2.1/13)
,keepftn=N
);
/**minor adaptions;*/
/*data _ittitles3;*/
/*    set _ittitles2;*/
/*    if footnonum=6 then variable="FOOTNOTE7";*/
/*    if variable="FOOTNOTE5" then do;*/
/*        value='Source: Table 14.2.2.1/13 ';*/
/*        output;*/
/*        variable="FOOTNOTE6";*/
/*        call missing(value);*/
/*        output;*/
/*    end;*/
/*    else output;*/
/*RUN;*/
/**put tit foot from adaptions;*/
/*%m_itmtitle(mymeta=tl_meta,tableno=1, itdata=t_14_2_2_adrs_concord_rate,*/
/*evaltable=_ittitles3  )*/


%datalist(
    data   = con
  , var    = trt rscat n res_f res_r
  , maxlen = 30
  , label  = no
  ,split='#'
)

%endprog(
    cleanWork       = y
  , cleanTitlesFoot = y
  , verbose         = Y
)
