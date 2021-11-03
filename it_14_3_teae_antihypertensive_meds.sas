/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_teae_antihypertensive_meds);
/*
 * Purpose          : Table 10-40 Number of patients requiring post-baseline antihypertensive treatment (SAF)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 17AUG2020
 * Reference prog   :
 ******************************************************************************/

data hyp;
  set  tlfmeta.t_14_3_5_adae_antihypertens_1;
RUN;
%m_rename(
    indata  = hyp
  , inarray = %str('_col1_', '_col2_')
  , _split  = "@"
  , type    = 1
)
%m_rename(
    indata  = hyp
  , inarray = %str('_col1_', '_col2_')
  , _split  = "@"
  , type    = 0
)
%printline(##Table 10-38)
%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = t_14_3_5_adae_antihypertens
  , title     = %NRBQUOTE(Table 10-38 Number of patients requiring post-baseline antihypertensive treatment (SAF) )
  , keepftn   = N
  , foot      = %NRBQUOTE(MLG = Medical labelling group; N = Total number of patients (100%); n = Number of patients with event; SAF =
Safety analysis set; TEAE = Treatment-emergent adverse event Notes: Hypertension was identified using MLG.
Medications with start date on or after start date of first TEAE of hypertension are included. )
  , foot1     = %NRBQUOTE(Source: Table 14.3.5/24)
  , evaltable =
)

%datalist(
    data   = hyp
  , var    = _name_ _col1_ _col2_
  , maxlen = 40
  , label  = no
)
%endprog(
    cleanWork       = y
  , cleanTitlesFoot = y
  , verbose         = Y
)