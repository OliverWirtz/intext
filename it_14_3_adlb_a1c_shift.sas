/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_adlb_a1c_shift);
/*
 * Purpose          : Table 10-28 Number of patients with transitions from baseline with respect to reference ranges in HbA1c values (SAF)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 08JUL2020
 * Reference prog   :
 ******************************************************************************/

data lb;
    set tlfmeta.t_14_3_5_adlbchem_hba1c_shi_1;
    where ~((_varl_='n' and trt01an=31) or trt01an=99); *record not needed for display;

    if _varl_='n' then _varl_=Avisit;
    else if _varl_='HbA1c value' then _varl_=put(trt01an, _z_trt.);
    if _type_=0 then call missing(of  _cptog:);

run;

%m_rename(
    indata  = lb
  , inarray = %str('_cptog1', '_cptog2', '_cptog3','_cptog4')
  , _split  = "@"
  , type    = 2
)

%printline(##Table 10-28);
%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = t_14_3_5_adlbchem_hba1c_shi
  , title     = %nrbquote(Table 10-28 Number of patients with transitions from baseline with respect to reference ranges in HbA1c values (SAF) )
  , keepftn   = N
  , foot      = %nrbquote(EOT = End of treatment; HbA1c = Hemoglobin A1c (glycated hemoglobin); SAF = Safety analysis set; N = All patients with at least one value for this parameter available; n = Number of patients with event
Notes: Only patients with valid values at both baseline and at EOT visit are included. The same patient can be included in both EOT and post treatment categories. )
  , foot1     = %nrbquote(Source: Table 14.3.5/11 )
  , evaltable =
);


%datalist(
    data   = lb
  , var    = _varl_ ("Baseline" _cptog1 _cptog2 _cptog3 _cptog4)
  , maxlen = 20
  , label  = no
);
%endprog;
