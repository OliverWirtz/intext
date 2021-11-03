/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_1_addm_baseline_cancer);
/*
 * Purpose          : Table 8-5 Baseline cancer characteristics (FAS)
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
 * Reason           : changed to use correct source.
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 03AUG2020
 * Reason           : changed table number
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 07SEP2020
 * Reason           : account for missing categories in fl/mzl and therefore align key variables
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 07OCT2020
 * Reason           : use correct datasets after proggram name change for hist
 ******************************************************************************/

%macro groupi(tot=, fl=, mzl=, tableno=, title=);
data tot;
    set tl_meta.&tot.;*t_14_1_addm_1;
    %_get_it_label(inds=tot,invar=col3, debug=n);
    drop col3;
RUN;
proc sort data=tot;
    by _posi_;
RUN;
data tot;
    set tot;
    format keytext posi $200. ;
    retain posi '' ;
    by _posi_;
    if first._posi_ then do;
        posi=text;
    end;
    keytext=posi;
RUN;
data fl;
    set tl_meta.&fl.;*t_14_1_addm_by_hist_6;
    %_get_it_label(inds=FL,invar=col3, debug=n);

RUN;
proc sort data=fl;
    by _posi_;
RUN;
data fl;
    set fl;
    format keytext posi $200. ;
    retain posi '' ;
    by _posi_;
    if first._posi_ then do;
        posi=text;
    end;
    keytext=posi;
RUN;

data mzl;
    set tl_meta.&mzl.;*t_14_1_addm_by_hist_7;
    %_get_it_label(inds=MZL,invar=col3, debug=n);
RUN;
proc sort data=mzl;
    by _posi_;
RUN;
data mzl;
    set mzl;
    format keytext posi $200. ;
    retain posi '' ;
    by _posi_;
    if first._posi_ then do;
        posi=text;
    end;
    keytext=posi;
RUN;


proc sql noprint;


    create table all0 as select a.*, b.col3,b.col4
           from  tot as a
                    left join fl(keep=col1 col2 text _ordern keytext rename=(col1=col3 col2=col4)) as b
                    on a.keytext=b.keytext and a.text=b.text;
    create table all1 as select a.*,b.col5,b.col6 from all0 as a
                left join  mzl(keep=col1 col2 text _ordern keytext rename=(col1=col5 col2=col6)) as b
            on a.keytext=b.keytext and a.text=b.text order by a._ordern;
QUIT;

proc sort data= all1;
    by _posi_ _nr_ pos _widownr _newvar _kind_ _ord_;
RUN;



%m_rename(indata=all1, inarray=%str('col1', 'col2', 'col3', 'col4', 'col5', 'col6'))


%printline(##Table %sysfunc(scan(&title.,2,' ')));

%m_itmtitle(mymeta=tl_meta,tableno=&tableno., itdata=t_14_1_addm_baseline_cancer,title=&title.
,foot=%nrbquote(ECOG = Eastern Cooperative Oncology Group; FL = Follicular lymphoma; LM = Lymphoplasmacytic lymphoma;
MALT = Extranodal marginal zone lymphoma of mucosa-associated lymphoid tissue; Max = Maximum ,Min = Minimum; N = Total number of patients (100%);
MLZ = Marginal zone lymphoma; n = Number of patients with event; PI3K = Phosphatidylinositol-3-kinase; SLL = Small lymphocytic lymphoma;
StD = Standard deviation; WM= Waldenstroem macroglobulinemia a. Serum IgM level (mg/dL) at baseline is provided for WM patients only.
Note: Percentages are calculated including missing values)
,foot1=%str(Source: Table 14.1.2/3, Table 14.1.2/7 and Table 14.1.4/3 )
,keepftn=N
,evaltable=);


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
);

proc datasets lib=work kill memtype=data nolist;
quit;
%mend groupi;

%groupi(title=%str(Table 8-5 Baseline cancer characteristics (FAS)),tot=t_14_1_addm_baseline_cancer_1, fl=t_14_1_addm_bl_cancer_by_hi_1, mzl=t_14_1_addm_bl_cancer_by_hi_2, tableno=1);
