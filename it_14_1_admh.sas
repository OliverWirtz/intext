/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_1_admh);
/*
 * Purpose          : Table 8-6 Most common (? x% of patients in either treatment arm) medical history findings by MedDRA PT (FAS)
 *
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 23APR2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 08JUL2020
 * Reason           : nicer
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 03AUG2020
 * Reason           : changed table number
 ******************************************************************************/

*threshold in a macro variable ;
%let thres=1;

%m_threshold(
        indata=t_14_1_admh_1
      , lib=tlfmeta
      , topvar=_ic_var1
      , secvar=_ic_var2
      , outvar=_levtxt
      , renameto=%str("Any medical history finding")
      , renamevar=_levtxt
      , treat=_t_1 _t_2
      , datawhere=%str()
      , threshold=&thres.
      , debug=N
  );

  data mh;
      set sub__ic_var2_out;
      label _levtxt="MedDRA PT (v. &MEDDRAV.)";
  RUN;
 %m_rename(
     indata  = mh
   , inarray = %str('_t_1', '_t_2', '_t_3')
   , _split  = "@"
 )
 %printline(##Table 8-6);
  %m_itmtitle(
      mymeta    = tlfmeta
    , tableno   = 1
    , itdata    = t_14_1_admh
    , title     = %nrbquote(Table 8-6 Most common (>= &thres.% of patients in either treatment arm) medical history findings by MedDRA PT (FAS))
    , foot      = %nrbquote(FAS = Full analysis set; MedDRA = Medical Dictionary for Regulatory Activities; N = Total number of patients
(100%); n = Number of patients with event; PT = Preferred term)
    , foot1     = %str(Source: Table 14.1.3/1 )
    , evaltable =
  )
  %datalist(
      data            = mh
    , var             = _levtxt _t_1 _t_2 _t_3
    , split           = '/ * @'
)

*cleanup;
%symdel thres;
%endprog;


