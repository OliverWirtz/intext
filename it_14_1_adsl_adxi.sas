/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_1_adsl_adxi);
/*
 * Purpose          : Table 8 3 Analysis sets (all randomized)
 * Programming Spec :
 * Validation Level : 1 - Verification by Review
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
 * Reason           : changed table number
 ******************************************************************************/

data ds;
    set tlfmeta.t_14_1_adsl_adxi_primary_re_1;
    label _name_='Analysis set@  Primary reasons for exclusion from analysis set';
RUN;

%m_rename(
    indata  = ds
  , inarray = %str('_col1_', '_col2_', '_col3_')
  , _split  = "@"
)

%printline(##Table 8-3)

%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = t_14_1_adsl_adxi_primary_re
  , title     = Table 8-3 Analysis sets (all randomized)
  , foot      = %nrbquote(FAS = Full analyses set; N = Total number of patients (100%%);
n = Number of patients with event; PKS = Pharmacokinetic analysis set; SAF = Safety analyses set
)
  , foot1     =%str(Source: Table 14.1.1/9 )
  , evaltable =
  , keepftn=N
)

%datalist(
    data   = ds
  , var    = _name_ _col1_ _col2_ _col3_
  , maxlen = 30
  , label  = no
  ,split='@'
)
%endprog(
    cleanWork       = y
  , cleanTitlesFoot = y
  , verbose         = Y
)