/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_2_dcr_subgr);
/*
 * Purpose          : Table 9-27 Subgroup analysis of time to deterioration in DRS-P by histology according to investigator pathology (FAS)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 04AUG2020
 * Reference prog   :
 ******************************************************************************/


data main;
    set tlfmeta.t_14_2_adtte_drspd_hist_1
        tlfmeta.t_14_2_adtte_drspd_hist_2
        tlfmeta.t_14_2_adtte_drspd_submzl_1(in=a)
    tlfmeta.t_14_2_adtte_drspd_submzl_2(in=a)
    tlfmeta.t_14_2_adtte_drspd_submzl_3(in=a)
        tlfmeta.t_14_2_adtte_drspd_hist_3
        tlfmeta.t_14_2_adtte_drspd_hist_4
     ;
    where _orderN in(1,2,3,5,18);
    format text vartxt grptext chck $200.;
    if _orderN=1 then do;
        text='n';
        vartxt='N';
    end;
    else if _orderN=2 then do;
        text='n with events';
        vartxt='nev';
    end;
    else if _orderN=3 then do;
        text='n censored';
        vartxt='cens';
    end;
    else if _orderN=5 then do;
        text='Median (months)';
        vartxt='median';
    end;

    if _orderN=18 then do;
        text='Hazard ratio@Estimate [95% CI]';
        vartxt='HR';
    end;
    else do;
        %_strip_num(invar=ttt30);
        %_strip_num(invar=ttt31);
    END;

    if a then do;
        histgrpn=2;
        grptext=put(histgr3n,z_mzlsgr.) ;
    end;
    else do;
        grptext=put(histgrpn,Z_hist.);
        if histgrpn>2 then histgr3n=4;
    end;
    chck=translate(vlabel(ttt30),'@',' ');
    call symput('cop', translate(chck,'@','# '));

    chck=translate(vlabel(ttt31),'@',' ');
    call symput('pla',translate(chck,'@','# '));


RUN;
*transpose all but median;
proc transpose data=main out=_main;
    by histgrpn histgr3n grptext ;
    var ttt30;
    id vartxt;
    idlabel text;
RUN;

proc transpose data=main(where=(_orderN not in(18))) prefix=pla_ out=_main1;
    by histgrpn histgr3n grptext ;
    var ttt31;
    id vartxt;
    idlabel text;
RUN;
proc sql noprint;
    create table _main2 as select a.*,b.pla_n,b.pla_nev, b.pla_cens,b.pla_median from _main as a left join _main1 as b on
            a.histgrpn=b.histgrpn and  a.histgr3n=b.histgr3n and  a.grptext=b.grptext ;
QUIT;

*final formatting;
data all1;
    set _main2;*all0;
    label grptext="Variable@  Subgroup";
    if histgr3n in(1,2,3) then grptext='  '||strip(grptext);
RUN;
%printline(##Table 9-22);
%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = t_14_2_adtte_pfsi_hist
  , title     =%str(Table 9-22 Subgroup analysis of time to deterioration in DRS-P by histology according to investigator pathology (FAS))
  , foot      = %nrbquote(CI = Confidence interval; DRS-P = Disease-related symptoms - physical (subscale); FAS = Full analysis set;
FL = Follicular lymphoma; LPL = Lymphoplasmacytoid lymphoma; MZL = Marginal-zone lymphoma; N = Total number of patients (100%); n = number of patients with event;
SLL = Small lymphocytic lymphoma; WM = Waldenstroem macroglobulinemia Notes: PDs are from independent assessments. OWEN patients may include investigator assessments
in absence of independent review. Time to deterioration in DRS-P is evaluated with the stratified log-rank test based on stratification factor Entry Criterion used
for randomization. A: Value cannot be estimated due to censored data. ** censored observation Median, percentile and other 95% CIs computed using Kaplan-Meier estimates.
Hazard ratio and 95% CI was based on Cox Regression Model, stratified by Entry Criterion. A Hazard ratio < 1 indicates superiority of Copanlisib/rituximab over
Placebo/rituximab.);
 ,foot1=%nrbquote(Source: Table 14.2.5.1/9 and Table 14.2.5.1/10)
  ,keepftn=N
  ,evaltable =
)


%insertOption(
    namevar   = HR
  , align     =
  , width     = 25
  , other     =
  , charnum   = .
  , keep      = N
  , overwrite = Y
  , comment   = YES
)
%datalist(
    data   = all1
  , var    = grptext ("&cop" N nev cens median) ("&pla" pla_n pla_nev pla_cens pla_median) HR
  , maxlen = 10
  , label  = no
)

%endprog;
