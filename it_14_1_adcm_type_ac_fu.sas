/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_1_adcm_type_ac_fu);
/*
 * Purpose          : Table 8-13 Type of systemic anti-cancer therapy during follow-up (FAS)
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
/* Changed by       : gghcj (Oliver Wirtz) / date: 07OCT2020
 * Reason           : added header
 ******************************************************************************/

*retrieve data;

proc format lib=work.formats;
    /* used in macro %mcmsummary*/
    VALUE  _at_no
           1="none"
           2="at least 1";

run;

DATA ALL;
    SET TLFMETA.t_14_1_adcm_type_systemic_c_1;
    where _varl_='Any';
    format text $200.;
    label text='Type of therapy';
    text=propcase(put(cmscatn,_cmscat.),'$');
RUN;
%m_threshold(
    indata    = all
  , lib       = work
  , topvar    = _varl_
  , secvar    = text
  , outvar    = text
  , renameto  =
  , renamevar =
  , treat     = _cptog2 _cptog3
  , datawhere = %str( )
  , threshold = 0
  , debug     = Y
)
data all;
    set
        sub_text_out;
RUN;
%m_rename(
    indata  = all
  , inarray = %STR('_cptog2', '_cptog3', '_cptog1')
  , _split  = "@"
)
%printline(##Table 8-13);
  %m_itmtitle(
      mymeta    = tlfmeta
    , tableno   = 1
    , itdata    = t_14_1_adcm_type_systemic_c
    , title     = %nrbquote(Table 8-13 Type of systemic anti-cancer therapy during follow-up (FAS))
    , foot      = 'FAS = Full analysis set; N = Total number of patients (100%); n = Number of patients with event'
    , foot1     = %str(Source: Table 14.1.4/12)
    , keepftn   = N
    , evaltable =
  )
  %datalist(
      data            = all
    , var             = text _cptog2 _cptog3
    , split           = '/ * @'
    , optimal=yes
    , maxlen=40
    , label=n
)

%endprog;