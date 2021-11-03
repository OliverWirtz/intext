/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_1_adcm_conc_proc_);
/*
 * Purpose          : Table 8-12 Concurrent diagnostic and/or therapeutic procedure for iNHL patients (FAS)
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
/* Changed by       : gghcj (Oliver Wirtz) / date: 03AUG2020
 * Reason           : changed numbering
 ******************************************************************************/

*retrieve data;

data in;
     set tlfmeta.t_14_1_adcm_adxp_conc_diag__1;
     where upcase(_varl_)="YES" or _orderN=1;
    if _ordern=1 then do;
        output;
        output;
    END;
    else output;
run;
%m_threshold(
        indata=in
      , lib=work
      , topvar=procedc
      , secvar=_varl_
      , outvar=_varl_
      , renameto=
      , renamevar=
      , treat=_cptog2
      , datawhere=%str(where upcase(_varl_)="YES" or _orderN=1)
      , threshold=0
      , debug=N
  );
*get rid of first record, tit was needed to have a fake any group;

data cm ;
    set work.sub__varl__out;
    label procedctxt='Any concurrent';
    format procedctxt $100.;
    if _n_>1;
    procedctxt=propcase(strip(tranwrd(put(procedc,_curr.),'Any concurrent','')),'$');
RUN;



  %m_rename(
    indata  = cm
  , inarray = %str('_cptog2', '_cptog3')
  , _split  = "@"
  , type=0
  )

  %printline(##Table 8-12);

  %m_itmtitle(
      mymeta    = tlfmeta
    , tableno   = 1
    , itdata    = t_14_1_adcm_adxp_conc_diag_
    , title     = %str(Table 8-12 Concurrent diagnostic and/or therapeutic procedure for iNHL patients (FAS))
    , foot      = %nrbquote(FAS = Full analysis set; iNHL = indolent non-Hodgkin's lymphoma; N = Total number of patients (100%); n = Number of patients with event )
    , foot1     = %str(Source: Table 14.1.4/10 )
    , evaltable =
    , keepftn   = N
  )
  %datalist(
      data            = cm
    , var             = procedctxt _cptog2 _cptog3
    , split           = '/ * @'
    , optimal=yes
    , maxlen=40
)

%endprog;



