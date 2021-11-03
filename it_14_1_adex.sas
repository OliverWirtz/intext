/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_1_adex);
/*
 * Purpose          : Intext Exposure
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 27APR2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 02JUL2020
 * Reason           : add printline and table number
 ******************************************************************************/

%macro _ex(inds1=t_14_1_adex_trt_duration_cen,inds2=t_14_1_adex_trt_dosage,tableno=1,_title=%str(Copanlisib/Placebo: Extent of exposure (safety analysis set)));

data tot;
    set tlfmeta.&inds1._1(in=a)
        tlfmeta.&inds2._1(in=b)
        ;
    %_get_it_label(inds=tot,invar=col3, debug=n);
    drop col3;

    if a then _bsort=1;
    else _bsort=2;

RUN;
data fl;
      set tlfmeta.&inds1._2(in=a)
        tlfmeta.&inds2._2(in=b)
        ;
    %_get_it_label(inds=FL,invar=col3, debug=n);
    if a then _bsort=1;
    else _bsort=2;
RUN;
data mzl;
    set tlfmeta.&inds1._3(in=a)
    tlfmeta.&inds2._3(in=b)
    ;
    %_get_it_label(inds=MZL,invar=col3, debug=n);
    if a then _bsort=1;
    else _bsort=2;
RUN;

proc sql noprint;
    create table all0 as select a.*, b.col3,b.col4
           from  tot as a
                    left join fl(keep=col1 col2 text _ordern _bsort rename=(col1=col3 col2=col4)) as b
                    on a._bsort=b._bsort and a._ordern=b._ordern;
    create table all1 as select a.*,b.col5,b.col6 from all0 as a
                left join  mzl(keep=col1 col2 text _ordern _bsort  rename=(col1=col5 col2=col6)) as b
            on a._bsort=b._bsort and a._ordern=b._ordern;
QUIT;


proc sort data= all1;
    by _bsort _posi_ _nr_ pos _widownr _newvar _kind_ _ord_;
RUN;
data all2;
    set all1;
    *keep relevant only;
    if _posi_ in(1,18, 24,40) and (pos=0 or text in('   Mean (SD)' '   Median' '   Min, Max'));

RUN;

%m_rename(indata=all2, inarray=%str('col1', 'col2', 'col3', 'col4', 'col5', 'col6'),type=1)
%printline(##Table %sysfunc(scan(&_title.,2,' ')));
%m_itmtitle(mymeta=tl_meta,tableno=&tableno., itdata=&inds1.,title=&_title.
,foot=%nrbquote(FL = Follicular lymphoma; iNHL = Indolent NHL; LPL = Lymphoplasmacytoid lymphoma; Max = Maximum;
Min = Minimum; MZL = Marginal zone lymphoma; N = Total number of patients (100%); NHL = Non-Hodgkin%str(%')s lymphoma;
SAF = Safety analysis set; SLL = Small lymphocytic lymphoma; StD = Standard deviation; WM = Waldenstroem macroglobulinemia a. Including interruptions/delays and drug holidays.
b. ((Day of last dose minus day of first dose) +7)/30.4375 c. The number of cycles was based on the last cycle number that a patient had copanlisib infusion.
d. Actual dose per timepoint = Prescribed dose [mg] x (Total amount administered [mL] / Total amount prior to
administration [mL]) e. Percent of planned dose received = Actual dose [mg] / Planned dose [mg] x 100%. Source: Table 14.1.6/1 and Table 14.1.6/3
)
,foot1=,keepftn=N,evaltable=);


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
      data            = all2
    , var             =  text ("&_mytot." col1 col2) ("&_myfl." col3 col4) ("&_mymzl." col5 col6)
    , split           = '/ * @'
    , optimal=yes
    , maxlen=17
    , label=no
)

%mend _ex;
*copanlisib saf;
%_ex(inds1=t_14_1_adex_trt_duration,inds2=t_14_1_adex_trt_dosage,tableno=1,_title=%str(Table 10-1 Copanlisib/placebo: Extent of exposure (SAF)));
*ritux saf;
%_ex(inds1=t_14_1_adex_ritux_duration,inds2=t_14_1_adex_ritux_dosage,tableno=1,_title=%str(Table 10-2 Rituximab: Extent of exposure (SAF)));

