/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_1_addm);
/*
 * Purpose          : Table 8-4 Demographics and baseline characteristics (FAS)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 23APR2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 03JUL2020
 * Reason           : corrected source data tables
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 03AUG2020
 * Reason           : changed table number
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 13AUG2020
 * Reason           : removed n(%) from col header
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 07OCT2020
 * Reason           : minor change to make race look nicer
 ******************************************************************************/

%macro groupi(tot=, fl=, mzl=, tableno=, title=);
data tot;
    set tl_meta.&tot.;
    %_get_it_label(inds=tot,invar=col3, debug=n);
    drop col3;
    if anylower(text)=0 and anydigit(text)=0 and compress(text) not in ('US')
       then text=tranwrd(propcase(text),'Or' ,'or' );
RUN;
data fl;
    set tl_meta.&fl.;
    %_get_it_label(inds=FL,invar=col3, debug=n);

RUN;

data mzl;
    set tl_meta.&mzl.;
    %_get_it_label(inds=MZL,invar=col3, debug=n);
RUN;

proc sql noprint;
    create table all0 as select a.*, b.col3,b.col4
           from  tot as a
                    left join fl(keep=col1 col2 text _ordern rename=(col1=col3 col2=col4)) as b
                    on a._ordern=b._ordern;
    create table all1 as select a.*,b.col5,b.col6 from all0 as a
                left join  mzl(keep=col1 col2 text _ordern rename=(col1=col5 col2=col6)) as b
            on a._ordern=b._ordern;
QUIT;

proc sort data= all1;
    by _posi_ _nr_ pos _widownr _newvar _kind_ _ord_;
RUN;



%m_rename(indata=all1, inarray=%str('col1', 'col2', 'col3', 'col4', 'col5', 'col6'), type=1)



%printline(##Table %sysfunc(scan(&title.,2,' ')));

%m_itmtitle(mymeta=tl_meta,tableno=&tableno., itdata=t_14_1_addm,title=&title.
,foot=%nrbquote(BMI = Body mass index; FAS = Full analysis set; FL = Follicular lymphoma;
 iNHL = indolent Non-Hodgkin%str(%')s lymphoma;LPL = Lymphoplasmacytoid lymphoma; Max = Maximum, Min = Minimum; MZL = Marginal-zone
lymphoma; N = Total number of patients (100%); n = Number of patients with event; SLL = Small lymphocytic lymphoma; StD = Standard deviation;
WM = Waldenstroem macroglobulinemia a. Geographic Region 1: Europe includes Austria, Belgium, Bulgaria, Germany, Spain, France, Greece, Hungary,
Ireland, Italy, Lithuania, Poland, Portugal, Romania, Slovakia, and Ukraine. b. Geographic Region 2 was used for sensitivity analysis of PFS and subgroup
analysis of selected efficacy variables only; Asia Pacific includes China, Japan, Korea, Taiwan, Hongkong, Malaysia, Singapore, Thailand,
Vietnam, and Philippines)
,foot1=
%nrbquote(Source: Table 14.1.2/1, Table 14.1.2/3, Table 14.1.2/5 and Table 14.1.2/7 )
,keepftn=N
,evaltable=)


%insertOption(
    namevar   = text
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
  , var    = text ("&_mytot." col1 col2) ("&_myfl." col3 col4) ("&_mymzl." col5 col6)
  , maxlen = 17
  , label  = no
  ,split='@'
)

proc datasets lib=work kill memtype=data nolist;
quit;


%mend groupi;

%groupi(title=%str(Table 8-4 Demographics and baseline characteristics (FAS)),tot=t_14_1_addm_1, fl=t_14_1_addm_by_hist_1, mzl=t_14_1_addm_by_hist_2, tableno=1)
%*groupi(title=%str(Demographics and baseline characteristics (SAF)),tot=t_14_1_addm_2, fl=t_14_1_addm_by_hist_5, mzl=t_14_1_addm_by_hist_6, tableno=2)