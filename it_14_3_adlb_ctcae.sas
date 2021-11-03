/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_adlb_ctcae);
/*
 * Purpose          : Table 10-36 Incidence of treatment-emergent hematological and chemical laboratory values by worst CTCAE grade (SAF)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 07JUL2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 29SEP2020
 * Reason           : changed source data
 ******************************************************************************/

*retrieve data and treatment labels;
data lb;
    set tlfmeta.t_14_3_4_lab_wg_1(in=a) tlfmeta.t_14_3_4_lab_wg_2(in=b);
    format newlabel $40.;
    where _varl_ in('Grade 3' 'Grade 4' 'Grade 1-4' 'All');
    if b then cat=4;
    if a then cat=2;
    if _varl_ not in ('All') then newlabel=Strip(_varl_)||'@n (%)';
    call symput('cop',compress(vlabel(_cptog2)));
    call symput('rit', compress(vlabel(_cptog3)));

run;
proc sort data=lb;
    by cat  paramcd _orderN;
RUN;
*copanlisib;
proc transpose data=lb(where=(_varl_^='All')) out=_lb1;
    by cat  paramcd ;
    var _cptog2;
    id _varl_;
    idlabel newlabel;
RUN;
*rituximab;
proc transpose data=lb(where=(_varl_^='All')) out=_lb2 prefix=rit;
    by cat  paramcd ;
    var _cptog3;
    id _varl_;
    idlabel newlabel;
RUN;
*all subjects;
proc transpose data=lb(where=(_varl_='All')) out=_lb3 prefix=tot;
    by cat  paramcd ;
    var _cptog1;
    id _varl_;
    idlabel _varl_;
RUN;

*merge;
proc sql noprint;
    create table _lb4 as select a.*,b.Grade_1_4 , b.Grade_3, b.Grade_4 from _lb3 as a left join _lb1 as b on a.cat=b.cat and a.paramcd=b.paramcd;
    create table _lb5 as select a.*, b.ritGrade_1_4, b.ritGrade_3, b.ritGrade_4  from _lb4 as a left join _lb2 as b on a.cat=b.cat and a.paramcd=b.paramcd;

QUIT;

*format and label and sort by grades 1-4 in copa;
data _lb6;
    set _lb5;
    format _sort 8.;
    totAll=substr(totall,1,find(totall,'(')-1);
    _sort=input(trim(substr(grade_1_4,1,find(grade_1_4,'(')-1)),8.);
RUN;
proc sort data=_lb6;
    by cat descending _sort;
RUN;
*insert record for category;
data _lb7;
    set _lb6;
    format text $40.;
    label totall='Number of patients with measurements '
          text="NCI CTCAE term (v. %cmpres(&CTCAEV.))"

          ;
    by cat;
    text=put(paramcd,$xct04ff.);
    if first.cat then do;
        output;
        if cat=2 then text="Hematological values ";
        if cat=4 then text="Chemical values ";
        cat=cat-1;
        call missing( Grade_1_4, Grade_3, Grade_4, ritGrade_1_4, ritGrade_3, ritGrade_4, totAll);
        output;
    END;
    else do;
        output;
    END;
RUN;
proc sort data=_lb7;
    by cat;
RUN;
%printline(##Table 10-34);
  %m_itmtitle(
      mymeta    = tlfmeta
    , tableno   = 1
    , itdata    = t_14_3_4_lab_wg
    , title     = %nrbquote(Table 10-34 Incidence of treatment-emergent hematological and chemical laboratory values by worst CTCAE grade (SAF))
    , foot      = 'CTCAE = Common Terminology Criteria for Adverse Events; Den = Denominator; NCI = National Cancer Institute;  Num = Numerator'
    ,foot1     = %nrbquote(Source: Table 14.3.4/1 and Table 14.3.4/2);
    ,keepftn=N
    , evaltable =
  )
  %datalist(
      data            = _lb7
    , var             = text totAll ("&cop." Grade_1_4 Grade_3 Grade_4) ("&rit." ritGrade_1_4 ritGrade_3 ritGrade_4)
    , split           = '/ * @'
    , optimal=yes
    , maxlen=20
    ,label=no
)

%endprog;
