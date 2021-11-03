/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_2_adrs);
/*
 * Purpose          : Table 9-6 Tumor response - independent assessment by Cheson 2014/Owen Criteria (FAS)
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
/* Changed by       : gghcj (Oliver Wirtz) / date: 07JUL2020
 * Reason           : included printline
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 03AUG2020
 * Reason           : changed numbering
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 21SEP2020
 * Reason           : drop disp_:
 ******************************************************************************/

*best response + ORR data;
data tot;
    set tlfmeta.t_14_2_2_adrs_onccat_5_4_1(drop=disp_:);
RUN;

*retrieve  popcounts;
%_get_total_n(pop = %str(fasfn=1));

data fl;
    set tlfmeta.t_14_2_5_adrs_onccat_5_4_hi_1(where=(subgroupn=1));
RUN;

data mzl;
    set tlfmeta.t_14_2_5_adrs_onccat_5_4_hi_1(where=(subgroupn=2));
RUN;


*merge all;
proc sql noprint;
    create table all0 as select a.*, b.ttt32,b.ttt33
           from  tot as a
                    left join fl(keep=ttt30 ttt31  group1 _label_ rename=(ttt30=ttt32 ttt31=ttt33)) as b
                    on a._label_=b._label_ and a.group1=b.group1;
    create table all1 as select a.*,b.ttt34,b.ttt35 from all0 as a
                left join  mzl(keep=ttt30 ttt31 _label_ group1 rename=(ttt30=ttt34 ttt31=ttt35)) as b
            on a._label_=b._label_ and a.group1=b.group1 order by a._orderN;
QUIT;

*get label from first record;
data all1;
    set all1;
    format var $1000.;
    array myarr(*) ttt30-ttt35;
    if _n_=1 then do;
         var='';
        do i=1 to 6;
              var=compbl(var)||' '||vname(myarr(i))||'="'||translate(strip(vlabel(myarr(i))),'@','#')||'@'||strip(myarr(i))||'@n (%)" ';
              call missing(myarr(i));
        end;
        call symput('mylabel', var);

    END;
RUN;
options nomprint;
data all2;
    set all1;
    label &mylabel.;
RUN;

*add Diff in ORR;
data orr pv;
    set
        tlfmeta.t_14_2_2_adrs_onccat_5_5_1 (in=a where=(group1=1) drop=disp_:)
        tlfmeta.t_14_2_5_adrs_onccat_5_5_hi_1( in=a where=(subgroupn in(1,2) and group1=1));
    retain i 0;
    format diforr $200.;
    if a then do;
        label='Difference in ORR (95% CI)';
       difORR=catx(' ',strip(df),compbl(ci));
       if missing(subgroupn) then subgroupn=0;
       transp="ttt3"||strip(put(i,8.));
       output orr;
       label='p-value';
       output pv;
       i=i+2;
    end;
run;
proc sort data=orr;
    by label;
RUN;
proc transpose data=orr out=_orr;
    by label;
    var diforr ;
    id transp;
run;


proc transpose data=pv out=_pv;
    by label;
    var pv ;
    id transp;
run;

data all3;
    set all2 _orr _pv;
    if missing(_label_) then _label_=label;
    if aval ~in (102,103);
RUN;
%printline(##Table 9-6);

*footnote too long, left out in this table;
%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = t_14_2_2_adrs_onccat_5_4
  , title     = %str(Table 9-6 Tumor response - independent assessment by Cheson 2014/Owen Criteria (FAS))
  , foot      =
  , evaltable =
)


%datalist(
    data   = all3
  , var    = _label_ ("&_mytot." ttt30 ttt31) ("&_myfl." ttt32 ttt33) ("&_mymzl." ttt34 ttt35)
  , maxlen = 15
  , label  = no
)

%symdel _myfl _mymzl _mytot;

%endprog;