/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_1_addv);
/*
 * Purpose          : IT: Table 8-2 Number of patients with major protocol deviations (FAS)
 * Programming Spec :
 * Validation Level : 1 - Verification by Review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 02JUL2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 03AUG2020
 * Reason           : changed table number
 ******************************************************************************/

data dv;
    set tlfmeta.t_14_1_addv_1;
    where _country='Total' and _cat not in('MINOR');
    label _levtxt='Deviation type@  Category';
    if _n_=1 then _levtxt='Any protocol deviation';
    else _levtxt='  '||strip(_levtxt);
    if _cat='MAJOR' and _sort1=0 then _levtxt=propcase(strip(_cat),'$');
RUN;

%m_rename(
    indata  =dv
  , inarray = %str('_t_1', '_t_2', '_t_3')
  , _split  = "@"
)

%printline(##Table 8-2)

%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = t_14_1_addv
  , title     = %str(Table 8-2 Number of patients with major protocol deviations (FAS))
  , foot      = %nrstr(FAS = Full analysis set; N = Total number of patients (100%%); n = Number of patients with event
Note: Subjects may have more than one protocol deviation but are only counted once within each deviation category.)
  , foot1     =  %str(Source: Table 14.1.1/10 )
  , evaltable =
)

%datalist(
    data   = dv
  , var    = _levtxt _t_1 _t_2
  , maxlen = 50
  , label  = no
  ,split='@'
)
%endprog;