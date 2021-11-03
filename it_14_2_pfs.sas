/*******************************************************************************
 * Bayer AG
 * Study            :
 * Proj/Subst/Pool  :  / ${SUBSTANCE} ${PROJECT_TITLE}
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_2_pfs);
/*
 * Purpose          : IT: PFS tables total anf FL/MZL
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 25MAY2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 25JUN2020
 * Reason           : included printline
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 07JUL2020
 * Reason           : cleanup
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 03AUG2020
 * Reason           : changed numbering and footnotes
 ******************************************************************************/


%macro _pfs(tot=t_14_2_adtte_pfs_1
       , fl=t_14_2_adtte_pfs_hist_1
       ,mzl=t_14_2_adtte_pfs_hist_2
       , itdata=t_14_2_adtte_pfs
       , title= %str(PFS for overall population and histologies, FL and MZL - independent assessment (FAS))
       , foot=
,foot1=
, param=PFS);
*retrieve PFS data;
data tot;
    set tlfmeta.&tot.;

    %_get_it_label(
        inds  = tot
      , invar = ttt9999
      , type = 1
      , debug = n
    )
    drop ttt9999;
RUN;

data fl;

   set tlfmeta.&fl.;

    %_get_it_label(
        inds  = FL
      , invar = ttt9999
      , type = 1
      , debug = n
    )
RUN;


data mzl;

   set tlfmeta.&mzl.;

    %_get_it_label(
        inds  = MZL
      , invar = ttt9999
      , type = 1
      , debug = n
    )
RUN;

*merge all;
proc sql noprint;
    create table all0 as select a.*, b.ttt32,b.ttt33
           from  tot as a
                    left join fl(keep=ttt30 ttt31  _name_ _label_ rename=(ttt30=ttt32 ttt31=ttt33)) as b
                    on a._label_=b._label_ and a._name_=b._name_;
    create table all1 as select a.*,b.ttt34,b.ttt35 from all0 as a
                left join  mzl(keep=ttt30 ttt31 _label_ _name_ rename=(ttt30=ttt34 ttt31=ttt35)) as b
            on a._label_=b._label_ and a._name_=b._name_ order by a._orderN;
QUIT;

*format layout;
data all2;
    set all1;
    format text $200.;
    array myarr(*) ttt30 - ttt35;
    if _orderN=1 then do;
        text='Number (%) of patients';
        call missing(of ttt:);
    end;
    else If _orderN=2 then text='  With event';
    else If _orderN=3 then text='  Censored';
    else if _orderN=4 then do;
        Text="&param. (month)";
        call missing(of ttt:);
    end;

    else if _orderN=6 then delete;

    else if _orderN in(7,8) then do;
        text='  '||strip(translate(_label_,'','(','',')'));
        do i=1 to 6;
            myarr(i)=compress(myarr(i),'()');
        END;
    end;
    else if _orderN=11 then do;
        text="&param. rate at";
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

    if ("&param." in ("DOR") and _orderN>17) or 9<=_orderN<=13 then delete;
RUN;
%printline(##Table %sysfunc(scan(&title.,2,' ')));
%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = &itdata.
  , title     =&title.
  , foot      = &foot.
  ,foot1=&foot1.
  , evaltable =
  , keepftn=N
)

%m_rename(
    indata  = all2
  , inarray = %str('ttt30', 'ttt31', 'ttt32', 'ttt33', 'ttt34', 'ttt35')
  , _split  = "@"
  , type=1
)

%datalist(
    data   = all2
  , var    = text ("&_mytot." ttt30 ttt31) ("&_myfl." ttt32 ttt33) ("&_mymzl." ttt34 ttt35)
  , maxlen = 15
  , label  = no
)
proc datasets lib=work kill memtype=data nolist;
quit;
%mend _pfs;

*PFS;

 %_pfs(tot=t_14_2_adtte_pfs_1
       , fl=t_14_2_adtte_pfs_hist_1
       ,mzl=t_14_2_adtte_pfs_hist_2
       , itdata=t_14_2_adtte_pfs
       , title= %str(Table 9-1 PFS for overall population and histologies, FL and MZL - independent assessment (FAS))
       , foot=%nrbquote(CI = Confidence interval; FAS = Full analysis set; FL = Follicular lymphoma; iNHL = Indolent non-Hodgkin's
lymphoma; LPL = Lymphoplasmacytoid lymphoma; MZL = Marginal-zone lymphoma; N = Total number of patients (100%); PFS = Progression-free survival;
SLL = Small lymphocytic lymphoma; WM = Waldenstroem macroglobulinemia Notes: OWEN patients may include investigator assessments in absence of independent review.
PFS is evaluated with the stratified log-rank test based on stratification factors NHL Histology and Entry Criterion
used for randomization. A: Value cannot be estimated due to censored data. ** censored observation
Median, percentile and other 95% CIs computed using Kaplan-Meier estimates. Hazard ratio and 95% CI was based on Cox Regression Model,
stratified by NHL Histology and Entry Criterion. A Hazard ratio < 1 indicates superiority of Copanlisib/rituximab over Placebo/rituximab. )
,foot1=%nrbquote(Source: Table 14.2.1.1/1 and Table 14.2.5.1/1 )
);

*same again for investigator;

 %_pfs(tot=t_14_2_adtte_pfsi_1
       , fl=t_14_2_adtte_pfsi_hist_1
       ,mzl=t_14_2_adtte_pfsi_hist_2
       , itdata=t_14_2_adtte_pfsi
       , title= %str(Table 9-2 PFS for overall population and histologies, FL and MZL - investigator assessment (FAS))
       , foot=%nrbquote(CI = Confidence interval; FAS = Full analysis set; FL = Follicular lymphoma; iNHL = Indolent non-Hodgkin's
       lymphoma; LPL = Lymphoplasmacytoid lymphoma; MZL = Marginal-zone lymphoma; N = Total number of patients (100%); PFS = Progression-free survival;
       SLL = Small lymphocytic lymphoma; WM = Waldenstroem macroglobulinemia Notes: Only patients with response in full analysis set were included in the analysis. OWEN patients may include investigator assessments in absence of independent review.
       PFS is evaluated with the stratified log-rank test based on stratification factors NHL Histology and Entry Criterion
       used for randomization. A: Value cannot be estimated due to censored data. ** censored observation
       Median, percentile and other 95% CIs computed using Kaplan-Meier estimates. Hazard ratio and 95% CI was based on Cox Regression Model,
       stratified by NHL Histology and Entry Criterion. A Hazard ratio < 1 indicates superiority of Copanlisib/rituximab over Placebo/rituximab. )
       ,foot1=%nrbquote(Source: Table 14.2.1.2/2 and Table 14.2.5.1/3 ));

*DOR;
 %_pfs(tot=t_14_2_adtte_dor_1
       , fl=t_14_2_adtte_dor_hist_1
       ,mzl=t_14_2_adtte_dor_hist_2
       , itdata=t_14_2_adtte_dor
       , title= %str(Table 9-8 DOR for overall population and histologies, FL and MZL - independent assessment (FAS))
       , foot=%nrbquote(CI = Confidence interval; FAS = Full analysis set; DOR = Duration of response; FL = Follicular lymphoma; iNHL
= Indolent non-Hodgkin's lymphoma; LPL = Lymphoplasmacytoid lymphoma; MZL = Marginal-zone lymphoma; N = Total number of patients (100%);
SLL = Small lymphocytic lymphoma; WM = Waldenstroem macroglobulinemia Notes: Only patients with response in full analysis set were included in the analysis.
OWEN patients may include investigator assessments in absence of independent review. Duration of response was evaluated with the stratified log-rank test based on
stratification factors NHL Histology and Entry Criterion used for randomization. A: Value cannot be estimated due to censored data.
** censored observation Median, percentile and other 95% CIs computed using Kaplan-Meier estimates.
Hazard ratio and 95% CI was based on Cox Regression Model, stratified by NHL Histology and Entry Criterion.
A Hazard ratio < 1 indicates superiority of Copanlisib/rituximab over Placebo/rituximab.)
,foot1=%nrbquote(Source: Table 14.2.2.1/17 and Table 14.2.5.1/17 )
, param=DOR);

*TTP;
 %_pfs(tot=t_14_2_adtte_TTP_1
       , fl=t_14_2_adtte_ttp_hist_1
       ,mzl=t_14_2_adtte_ttp_hist_2
       , itdata=t_14_2_adtte_ttp
       , title= %str(Table 9-9 TTP for overall population and histologies, FL and MZL - independent assessment (FAS))
       , foot=%nrbquote(CI = Confidence interval; FAS = Full analysis set; DOR = Duration of response; FL = Follicular lymphoma; iNHL
       = Indolent non-Hodgkin's lymphoma; LPL = Lymphoplasmacytoid lymphoma; MZL = Marginal-zone lymphoma; N = Total number of patients (100%);
       SLL = Small lymphocytic lymphoma; WM = Waldenstroem macroglobulinemia Notes: Only patients with response in full analysis set were included in the analysis.
       OWEN patients may include investigator assessments in absence of independent review. Time to progression was evaluated with the stratified log-rank test based
       on stratification factors NHL Histology and Entry Criterion used for randomization. A: Value cannot be estimated due to censored data. ** censored observation
       Median, percentile and other 95% CIs computed using Kaplan-Meier estimates. Hazard ratio and 95% CI was based on Cox Regression Model, stratified by NHL
       Histology and Entry Criterion. A Hazard ratio < 1 indicates superiority of Copanlisib/rituximab over Placebo/rituximab.)
       ,foot1=%nrbquote(Source: Table 14.2.2.1/14 and Table 14.2.5.1/15 )
, param=TTP);

*OS;
 %_pfs(tot=t_14_2_adtte_OS_1
       , fl=t_14_2_adtte_OS_hist_1
       ,mzl=t_14_2_adtte_OS_hist_2
       , itdata=t_14_2_adtte_os
       , title= %str(Table 9-10 OS for overall population and histologies, FL and MZL - independent assessment (FAS))
       , foot=%nrbquote(CI = Confidence interval; FAS = Full analysis set; DOR = Duration of response; FL = Follicular lymphoma; iNHL
       = Indolent non-Hodgkin's lymphoma; LPL = Lymphoplasmacytoid lymphoma; MZL = Marginal-zone lymphoma; N = Total number of patients (100%);
       SLL = Small lymphocytic lymphoma; WM = Waldenstroem macroglobulinemia Notes: Only patients with response in full analysis set were included in the analysis.
       OWEN patients may include investigator assessments in absence of independent review. Overall survival was evaluated with the stratified log-rank
       test based on stratification factors NHL Histology and Entry Criterion used for randomization.  A: Value cannot be estimated due to censored data.
       ** censored observation Median, percentile and other 95% CIs computed using Kaplan-Meier estimates. Hazard ratio and 95% CI was based on Cox Regression Model, stratified by NHL
       Histology and Entry Criterion. A Hazard ratio < 1 indicates superiority of Copanlisib/rituximab over Placebo/rituximab.)
       ,foot1=%nrbquote(Source: Table 14.2.2.1/16 and Table 14.2.5.1/13  )
, param=OS);


*DRSP deterioration;
 %_pfs(tot=t_14_2_adtte_DRSPD_1
       , fl=t_14_2_adtte_DRSPD_hist_1
       ,mzl=t_14_2_adtte_DRSPD_hist_2
       , itdata=t_14_2_adtte_DRSPD
       , title= %str(Table 9-11 Time to deterioration in DRS-P of at least 3 points (FAS) )
       ,foot=%nrbquote(CI = Confidence interval; FAS = Full analysis set; DOR = Duration of response; FL = Follicular lymphoma; iNHL
       = Indolent non-Hodgkin's lymphoma; LPL = Lymphoplasmacytoid lymphoma; MZL = Marginal-zone lymphoma; N = Total number of patients (100%);
       SLL = Small lymphocytic lymphoma; WM = Waldenstroem macroglobulinemia Notes: PDs are from independent assessments. OWEN patients may
       include investigator assessments in absence of independent review. Time to deterioration in DRS-P was evaluated with the stratified
       log-rank test based on stratification factors NHL Histology and Entry Criterion used for randomization. ** censored observation Median,
       percentile and other 95% CIs computed using Kaplan-Meier estimates. Hazard ratio and 95% CI was based on Cox Regression Model, stratified
       by NHL Histology and Entry Criterion. A Hazard ratio < 1 indicates superiority of Copanlisib/rituximab over Placebo/rituximab.)
       ,foot1=%nrbquote(Source: Table 14.2.2.1/19 and Table 14.2.5.1/9   )
, param=%str(Time to deterioration in DRS-P of at least 3 points));

*DRSP improvement;

 %_pfs(tot=t_14_2_adtte_DRSPI_1
       , fl=t_14_2_adtte_DRSPI_hist_1
       ,mzl=t_14_2_adtte_DRSPI_hist_2
       , itdata=t_14_2_adtte_DRSPD
       , title= %str(Table 9-12 Time to improvement in DRS-P of at least 3 points (FAS))
       ,foot=%nrbquote(CI = Confidence interval; FAS = Full analysis set; DOR = Duration of response; FL = Follicular lymphoma; iNHL
       = Indolent non-Hodgkin's lymphoma; LPL = Lymphoplasmacytoid lymphoma; MZL = Marginal-zone lymphoma; N = Total number of patients (100%);
       SLL = Small lymphocytic lymphoma; WM = Waldenstroem macroglobulinemia Notes: Time to improvement in DRS-P is evaluated with the stratified
       log-rank test based on stratification factors NHL Histology and Entry Criterion used for randomization. A: Value cannot be estimated due to
       censored data. ** censored observation Median, percentile and other 95% CIs computed using Kaplan-Meier estimates. Hazard ratio and 95% CI
       was based on Cox Regression Model, stratified by NHL Histology and Entry Criterion. A Hazard ratio < 1 indicates superiority of Copanlisib/
       rituximab over Placebo/rituximab.)
       ,foot1=%nrbquote(Source: Table 14.2.2.1/21 and Table 14.2.5.1/11  )
, param=%str(Time to improvement in DRS-P of at least 3 points));

%endprog;