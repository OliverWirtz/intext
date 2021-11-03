/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_2_pfs_inv);
/*
 * Purpose          : Table 9 4	PFS including clinical progression by investigator assessment (FAS)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 18MAY2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 25JUN2020
 * Reason           : included printline
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 03AUG2020
 * Reason           : changed numbering and footnote
 ******************************************************************************/



*retrieve PFS data;
data tot;
    set tlfmeta.t_14_2_adtte_pfsic_1;

    drop ttt9999;
RUN;


*format layout;
data all2;
    set tot;
    format text $200.;
    if _orderN=1 then do;
        text='Number (%) of patients';
        call missing(of ttt:);
    end;
    else If _orderN=2 then text='  With event';
    else If _orderN=3 then text='  Censored';
    else if _orderN=4 then do;
        Text='PFS (month)';
        call missing(of ttt:);
    end;

    else if _orderN=6 then delete;

    else if _orderN in(7,8) then text='  '||strip(translate(_label_,'','(','',')'));
    else if _orderN=11 then do;
        text='PFS rate at';
        _orderN=13.1;
        call missing(of ttt:);
    end;
    else if 13.1<_orderN<18 then do;
        text=cat('  ',substr(_name_,anydigit(_name_),find(_name_,'[')-anydigit(_name_)),'months [95% CI]');
    end;
    else if _orderN=18 then do;
        text='Hazard ratio [95% CI]';
        if find(_label_,'Progression')>0 then put "ERR" "OR: Check output" ;
    end;
    else if _orderN=19 then text='  One-sided p-value';
    else do;
        text=cat('  ',strip(_label_));
    END;
RUN;

%printline(##Table 9-4);
%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = t_14_2_adtte_pfsic
  , title     =%str(Table 9-4 PFS including clinical progression by investigator assessment (FAS))
  , foot      = %nrbquote(CI = Confidence interval; FAS = Full analysis set; N = Total number of patients (100%);
PFS = Progression-free survival Notes: PFS is evaluated with the stratified log-rank test based on stratification
factors iNHL histology and entry criterion used for randomization. A: Value cannot be estimated due to censored data.
** censored observation Median, percentile and other 95% CIs computed using Kaplan-Meier estimates. Hazard ratio and 95% CI
was based on Cox Regression Model, stratified by iNHL histology and entry criterion. A Hazard ratio < 1 indicates superiority
of copanlisib/rituximab over placebo/rituximab.)
,foot1=%nrbquote(Source: Table 14.2.1.2/3)
  , evaltable =
)

%m_rename(
    indata  = all2
  , inarray = %str('ttt30', 'ttt31')
  , _split  = "@"
  , type=1
)

%datalist(
    data   = all2
  , var    = text ttt30 ttt31
  , maxlen = 30
  , label  = no
)



%endprog;