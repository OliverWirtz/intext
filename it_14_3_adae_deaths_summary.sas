/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_adae_deaths_summary);
/*
 * Purpose          : death list for intext
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
 * Reason           : renumbered
 ******************************************************************************/

data death;
    set tlfmeta.t_14_3_1_5_adds_death_1;
    if ~missing(_name_) then do;
        _name_=substr(_name_,1,anyalpha(_name_)-1)||propcase(substr(_name_,anyalpha(_name_)),'$');
    end;
RUN;

*remove (100%);
%m_rename(
    indata  = death
  , inarray = %str('_col1_', '_col2_')
  , _split  = "@"
  , type    = 1
)
*add n(%);
%m_rename(
    indata  = death
  , inarray = %str('_col1_', '_col2_')
  , _split  = "@"
  , type    = 0
 )
%printline(##Table 10-15)

%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = t_14_3_1_5_adds_death
  , title     = %nrbquote(Table 10-15 Overview of all deaths (SAF) )
  , keepftn   = N
  , foot      = %nrbquote(N = Total number of patients (100%); n = Number of patients with event; SAF = Safety analysis set)
  , foot1     = %nrbquote(Source: Table 14.3.1.5/1 )
  , evaltable =
)


%datalist(
    data   = death
  , var    = _name_ _col1_ _col2_
  , maxlen = 40
  , label  = no
)

%endprog(
    cleanWork       = y
  , cleanTitlesFoot = y
  , verbose         = Y
)