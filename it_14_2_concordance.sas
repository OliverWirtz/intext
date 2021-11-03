/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_2_concordance);
/*
 * Purpose          : Tbale 9-3 concordance
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.2
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 14AUG2020
 * Reference prog   :
 ******************************************************************************/
*retrieve data;
data con;
    set tlfmeta.t_14_2_adtte_pfs_concord_1;
    format trt $200.;
    label trt='Treatment';
    by trt01pn;
    if  first.trt01pn then do;
        trt=compress(put(trt01pn, _z_trt.));
    end;

RUN;
%printline(##Table 9-3)

%m_itmtitle(mymeta=tl_meta,tableno=1, itdata=t_14_2_adtte_pfs_concord,
 title=%nrbquote(Table 9-3 Concordance of PD between independent review and investigator's review (FAS) )
,foot=%nrbquote(Source: Table 14.2.1.2/1: Concordance of Progressive Disease (PD) between independent assessor and investigator's assessment (full analysis set) )

);

%datalist(
    data   = con
  , var    = trt _nwtxt ("Independent assessments" _v_1_1 _v_1_2 _v_1_3 )
  , maxlen = 50
  , label  = no
  ,split='@'
)

%endprog(
    cleanWork       = y
  , cleanTitlesFoot = y
  , verbose         = Y
)
