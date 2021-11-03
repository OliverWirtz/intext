/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_adae_over);
/*
 * Purpose          : AE overview intext table
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 05MAY2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 02JUL2020
 * Reason           : incldued printline
 ******************************************************************************/

data tot;
    set tlfmeta.t_14_3_adae_over_1;
    %_get_it_label(inds=tot,invar=_col3_, debug=n);
    drop _col3_;
RUN;
data fl;
    set tlfmeta.t_14_3_adae_over_2;
    %_get_it_label(inds=FL,invar=_col3_, debug=n);

RUN;

data mzl;
    set tlfmeta.t_14_3_adae_over_3;
    %_get_it_label(inds=MZL,invar=_col3_, debug=n);
RUN;

proc sql noprint;
    create table all0 as select a.*, b._col3_,b._col4_
           from  tot as a
                    left join fl(keep=_col1_ _col2_  _order_ rename=(_col1_=_col3_ _col2_=_col4_)) as b
                    on a._order_=b._order_;
    create table all1 as select a.*,b._col5_,b._col6_ from all0 as a
                left join  mzl(keep=_col1_ _col2_ _order_ rename=(_col1_=_col5_ _col2_=_col6_)) as b
            on a._order_=b._order_;
QUIT;


%m_rename(indata=all1, inarray=%str('_col1_', '_col2_', '_col3_', '_col4_', '_col5_', '_col6_'))

%printline(##Table 10-5)

%m_itmtitle(mymeta=tl_meta,tableno=1, itdata=t_14_3_adae_over,title=%str(Table 10-5 Overview of TEAEs (SAF))
,foot=%nrbquote(CTCAE = Common Terminology Criteria for Adverse Events; FL = Follicular lymphoma; iNHL = Indolent
NHL; LPL = Lymphoplasmacytoid lymphoma; Max = Maximum; Min = Minimum; MZL = Marginal zone
lymphoma; N = Total number of patients (100%); n = Number of patients with event; NHL = Non-
Hodgkin's lymphoma; SAF = Safety analysis set; SLL = Small lymphocytic lymphoma; StD = Standard
deviation; TEAE = Treatment-emergent adverse event; TESAE = Treatment-emergent serious adverse
event; WM = Waldenstroem macroglobulinemia a. Number (%) of patients with the specified event starting or worsening between start of treatment and 30
days after end of treatment. b. 'Any AE' also includes patients with grade not available for all adverse events.
c. Modifications with copanlisib include reductions, interruptions/delays, changes in infusion duration or
rate, and re-escalations. Modifications with rituximab include interruptions/delays and changes in infusion duration or rate.
Note: Table contains deaths only if due to a treatment-emergent AE. Source: Table 14.3.1/1 and Table 14.3.1/2 )
,keepftn=N);

%insertOption(
    namevar   = _name_
  , align     =
  , width     = 20
  , other     =
  , charnum   = .
  , keep      = N
  , overwrite = Y
  , comment   = YES
)

%datalist(
    data   = all1
  , var    = _name_ ("&_mytot." _col1_ _col2_) ("&_myfl." _col3_ _col4_) ("&_mymzl." _col5_ _col6_)
  , maxlen = 17
  , label  = no
  ,split='@'
)
%endprog;