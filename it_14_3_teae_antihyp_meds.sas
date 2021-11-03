/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin’s lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_teae_antihyp_meds);
/*
 * Purpose          : Table 10-33 Summary of patients with TEAEs of hyperglycemia requiring post-baseline antihyperglycemic medication (SAF)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 07JUL2020
 * Reference prog   :
 ******************************************************************************/

data hyp;
  set  tlfmeta.t_14_3_5_adae_antihyperglyc_1;
RUN;
%m_rename(
    indata  = hyp
  , inarray = %str('_col1_', '_col2_')
  , _split  = "@"
  , type    = 1
)
%printline(##Table 10-33)
%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = t_14_3_5_adae_antihyperglyc
  , title     = %NRBQUOTE(Table 10-33 Summary of patients with TEAEs of hyperglycemia requiring post-baseline antihyperglycemic medication (SAF) )
  , keepftn   = N
  , foot      = %NRBQUOTE(MLG = Medical labelling group; N = Total number of patients (100%); n = Number of patients with event; SAF =
Safety analysis set; TEAE = Treatment-emergent adverse event Notes: Hyperglycemia was identified using MLG. Medications with start date on or after start date of first TEAE of hyperglycemia are included. )
  , foot1     = %NRBQUOTE(Source: Table 14.3.5/12 )
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