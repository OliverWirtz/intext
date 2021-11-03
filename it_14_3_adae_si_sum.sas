/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin’s lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_adae_si_sum);
/*
 * Purpose          : Table 10-27 Summary of patients with treatment-emergent non-infectious pneumonitis/interstitial lung disease requiring corticosteroids, antibiotics, or both (SAF)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 06JUL2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 04AUG2020
 * Reason           : changed title
 ******************************************************************************/

data ae;
    set tlfmeta.t_14_3_1_5_teae_inf_1;
    where _ordern>1 and find(_levtxt,"Number")>0;
    label _levtxt= "Number (%) of patients requiring at least one ";
    _levtxt=Propcase(strip(tranwrd(_levtxt,'Number (%) of subjects requiring at least one',"")),'$');

RUN;

%m_rename(
   indata  = ae
 , inarray = %str('_t_1', '_t_2')
 , _split  = "@"
 , type    = 0
)

%printline(##Table 10-27)

%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = t_14_3_1_5_teae_inf
  , title     = %nrbquote(Table 10-27 Summary of patients with treatment-emergent NIP requiring corticosteroids, antibiotics, or both (SAF))
  , keepftn   = N
  , foot      = %nrbquote(MedDRA = Medical Dictionary for Regulatory Activities; N = Total number of patients (100%); SAF = Safety
analysis set; SMQ = Standardized MedDRA queries Notes: Non-infectious pneumonitis was defined as SMQ: Interstitial lung disease (narrow, ie category 2A)
Medications with start date on or after start date of first non-infectious pneumonitis are included. )
  , foot1     = %nrbquote(Source: Table 14.3.1.5/10 )
  , evaltable =
)

%datalist(
    data   = ae
  , var    = _levtxt  _t_1 _t_2
  , maxlen = 35
  , label  = no
  ,split='@'
)

%endprog;