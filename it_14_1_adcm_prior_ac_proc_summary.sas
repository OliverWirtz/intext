/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_1_adcm_prior_ac_proc_summary);
/*
 * Purpose          : Table 8-9 Summary of prior anti-cancer therapies and therapeutic procedures (FAS)
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
 * Reason           : changed table numbering
 ******************************************************************************/

*retrieve data;
data in;
    set tlfmeta.t_14_1_adcm_adxp_prior_summ_1;
    where _varl_="Yes";
    if _n_=1 then do;
        output;
        output;
    end;
    else output;

  run;
%m_threshold(
        indata=in
      , lib=work
      , topvar=proced
      , secvar=_varl_
      , outvar=_varl_
      , renameto=
      , renamevar=
      , treat=_cptog2
      , datawhere=%str(where _varl_="Yes" or _orderN=1)
      , threshold=0
      , debug=N
  );
*get rid of first record, it was needed to have a fake any group;
data cm ;
    set work.sub__varl__out;
    format procedtxt $100.;
    label procedtxt='Any prior';
    if _n_>1;
    procedtxt=propcase(substr(put(proced,_prior.),11),'$');
RUN;
*a bit cumber some;
*remove (100%) (type=1);
  %m_rename(
      indata  = cm
    , inarray = %str('_cptog2', '_cptog3')
    , _split  = "@"
    , type=1
  )
*add n(%) (type=0);

  %m_rename(
    indata  = cm
  , inarray = %str('_cptog2', '_cptog3')
  , _split  = "@"
  , type=0
  )

  %printline(##Table 8-9);
  %m_itmtitle(
      mymeta    = tlfmeta
    , tableno   = 1
    , itdata    = t_14_1_adcm_adxp_prior_summ
    , title     = %str(Table 8-9 Summary of prior anti-cancer therapies and therapeutic procedures (FAS))
    , foot      = %nrbquote(FAS = Full analysis set; Max = Maximum, Min = Minimum; N = Total number of patients (100%); n = Number of
patients with event; PD = Progressive disease; StD = Standard deviation; a. Time between the start day of last course of systemic anti-cancer
therapy and the day of confirmation of the most recent progression)
    , foot1     = %str(Source: Table 14.1.4/1)
    , keepftn=N
    , evaltable =
  )
  %datalist(
      data            = cm
    , var             = procedtxt _cptog2 _cptog3
    , split           = '/ * @'
    , optimal=yes
    , maxlen=40
)
proc datasets lib=work kill memtype=data nolist;
quit;


%endprog;
