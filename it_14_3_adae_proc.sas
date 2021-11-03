/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin’s lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_adae_proc);
/*
 * Purpose          : procedure related TEAE intext
 * Programming Spec :
 * Validation Level : 1 - verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 07MAY2020
 * Reference prog   :
 ******************************************************************************/
%let thres=1;
*do thresholds in total iNHL for Copanlisib ;
%m_threshold(
        indata=t_14_3_1_5_adae_oth_3
      , lib=tlfmeta
      , topvar=aebodsys
      , secvar=_ic_var1
      , outvar=_levtxt
      , renameto='Any TEAE'
      , renamevar=_levtxt
      , treat=_t_1
      , datawhere=%str(where _ct1='Total' and ~missing(aebodsys) )
      , threshold=&thres.
      , debug=N
  );
  data tot;
      set sub__ic_var1_out;
      %_get_it_label(inds=tot,invar=_t_3, debug=n);
      if _levtxt='Any TEAE' then _thresperc=999;
      drop _t_3;
  RUN;

  %_assign_meddralabel(
    inlib = work
  , inds  = tot
  , invar = _levtxt
  )


  %m_rename(indata=tot, inarray=%str('_t_1', '_t_2'))



  %m_itmtitle(mymeta=tl_meta,tableno=3, itdata=t_14_3_1_5_adae_oth,title=%nrstr(Incidence of study protocol procedure-related TEAEs occurring in >= &thres.% of the patients in either treatment arm by MedDRA PT (safety analysis set) )
  ,foot=%nrbquote(MedDRA = Medical Dictionary for Regulatory Activities; N = Total number of patients (100%); n = Number of patients with event; PT = Preferred term; TEAE = Treatment-emergent adverse event));

  %insertOption(
      namevar   = _levtxt
    , align     =
    , width     = 25
    , other     =
    , charnum   = .
    , keep      = N
    , overwrite = Y
    , comment   = YES
  )

  %datalist(
      data   = tot
    , var    = _levtxt ("&_mytot." _t_1 _t_2)
    , maxlen = 25
    , label  = no
    ,split='@'
  )


  %endprog(
      cleanWork       = y
    , cleanTitlesFoot = y
    , verbose         = Y
  )
