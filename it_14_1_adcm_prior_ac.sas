/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_1_adcm_prior_ac);
/*
 * Purpose          : Table 8.-11 Most common (>= 15% of patients in either treatment arm) prior systemic anti-cancer therapies (FAS)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 03JUL2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 14AUG2020
 * Reason           : changed numbering
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 29SEP2020
 * Reason           : insertoption due to column breaks
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 07OCT2020
 * Reason           : changed column name
 ******************************************************************************/

%macro cm(thres=15);

%m_threshold(
        indata=t_14_1_adcm_prior_sys_anti__1
      , lib=tlfmeta
      , topvar=sub_name
      , secvar=_levtxt
      , outvar=_levtxt
      , renameto=%str("Any medication")
      , renamevar=_levtxt
      , treat=_t_1 _t_2
      , datawhere=
      , threshold=&thres.
      , debug=Y
  );

  data cm;
      set work.sub__levtxt_out;
      label _levtxt="Preferred base name @(WHO-DD v. %cmpres(&WHODDV.))";
      _levtxt=propcase(left(_levtxt),'$');
      if _levtxt ~in('Any medication');
  RUN;
  %m_rename(
      indata  = cm
    , inarray = %str('_t_1', '_t_2', '_t_3')
    , _split  = "@"
  )
  %printline(##Table 8-11);
  %m_itmtitle(
      mymeta    = tlfmeta
    , tableno   = 1
    , itdata    = t_14_1_adcm_prior_conco_med
    , title     = %nrbquote(Table 8-11 Most common (>= &thres.% of patients in either treatment arm) prior systemic anti-cancer therapies (FAS))
    , foot      = 'FAS = Full analysis set; N = Total number of patients (100%); n = Number of patients with event; WHO-DD = World Health Organization Drug Dictionary
@a: Different drug names listed under the same WHO-DD drug record number were combined and only the generic name is presented.
'
    , foot1     = %str(Source: Table 14.1.4/8)
    , evaltable =
  );
  %insertOption(
      namevar   = _levtxt
    , align     =
    , width     = 40
    , other     =
    , charnum   = .
    , keep      = N
    , overwrite = Y
    , comment   = YES
  )
  %datalist(
      data            = cm
    , var             = _levtxt _t_1 _t_2
    , split           = '/ * @'
    , optimal=yes
    , maxlen=20
);
proc datasets lib=work kill memtype=data nolist;
quit;
%mend cm;
*prior;
%cm(thres=15);


*cleanup;

%endprog;


