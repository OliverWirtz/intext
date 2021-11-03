/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_1_adcm);
/*
 * Purpose          : Table 8-7/-8 Most common (>= 20% of patients in either treatment arm) prior medication by ATC subclass (FAS)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 04JUN2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 03JUL2020
 * Reason           : changed titles population
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 13AUG2020
 * Reason           : changed table numbering
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 29SEP2020
 * Reason           : used inseroption to avoid column breaks
 ******************************************************************************/

%macro cm(thres=20,inds=t_14_1_adcm_prior_conco_med_1,tabno=1, phase=,title=,foot1=);



%m_threshold(
        indata=&inds.
      , lib=tlfmeta
      , topvar=class
      , secvar=subclass
      , outvar=_levtxt
      , renameto=%str("Any &phase. medication")
      , renamevar=_levtxt
      , treat=_t_1 _t_2
      , datawhere=%str()
      , threshold=&thres.
      , debug=N
  );

  data cm;
      set sub_subclass_out;
      label _levtxt="ATC subclass (WHO-DD v. %cmpres(&WHODDV.))";
      _levtxt=left(_levtxt);
  RUN;
  %m_rename(
      indata  = cm
    , inarray = %str('_t_1', '_t_2', '_t_3')
    , _split  = "@"
  )

  %printline(##Table %sysfunc(scan(&title.,2,' ')));

  %m_itmtitle(
      mymeta    = tlfmeta
    , tableno   = &tabno.
    , itdata    = t_14_1_adcm_prior_conco_med
    , title     = &title.
    , foot      = 'ATC = Anatomical therapeutic chemical; N = Total number of patients (100%); n = Number of patients with event; WHO-DD = World Health Organization Drug Dictionary
Note: Subject may have more than one entry.'
    , foot1     = &foot1.
    , evaltable =
    , keepftn   = N
  )
  %insertOption(
      namevar   = _levtxt
    , align     =
    , width     = 20
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
)
/**//**/
/*proc datasets lib=work kill memtype=data nolist;*/
/*quit;*/


%mend cm;
*prior;
%cm(thres=20,inds=t_14_1_adcm_prior_conco_med_1,tabno=1
  , phase= prior
  ,title=%nrbquote(Table 8-7 Most common (>= %nrstr(&thres.)% in either treatment arm) prior medication by ATC subclass (FAS))
  , foot1=%nrbquote(Source: Table 14.1.5/1 ));
*conmed;

%cm(thres=30,inds=t_14_1_adcm_prior_conco_med_2,tabno=2
  , phase= concomitant
  ,title=%nrbquote(Table 8-8 Most common (>= %nrstr(&thres.)% in either treatment arm) concomitant medication by ATC subclass (FAS))
  , foot1=%nrbquote(Source: Table 14.1.5/2 ));


*cleanup;

%endprog;


