/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_adlbgluc_cf_pre);
/*
 * Purpose          : Table 10-31/39 Mean glucose levels (mg/dL)/BP and change from pre-dose values for Cycles 1 and 2 (SAF)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 17AUG2020
 * Reference prog   :
 ******************************************************************************/

%macro means(data1=t_14_3_5_adlbgluc_mean_chg_1
       ,data2=t_14_3_5_adlbgluc_mean_chg_2
       ,cat1='(pre-dose) fasting'
       ,cat2='(pre-dose) non-fasting'
       ,ref= t_14_3_5_adlbgluc_mean_chg
       ,title=%NRBQUOTE(Table 10-31 Mean glucose levels (mg/dL) and change from pre-dose values for Cycles 1 and 2 (SAF) )
       ,foot= %NRBQUOTE(BL = Baseline; N = Total number of patients (100%); n = Number of patients with event; SAF = Safety analysis
set; StD = Standard deviation a. On C1D1 patients were supposed to be fasting for 8 h before the copanlisib/placebo infusion. Subsequent
dosing days fasting was not required. Note: The post infusion timings shown in the table are all related to post end of infusion.)
       ,foot1=%NRBQUOTE(Source: Table 14.3.5/9 )
        , ord=14.5       );

data lab;
    set tlfmeta.&data1.(in=a)
        tlfmeta.&data2.(in=b);
    format vis tim id $100.;
    label vis = 'Visit'
          tim='Time point'
          ;
    where _statnr_ in(1,3)
         and avisitn <3 and _timepoint<2000;

    vis=put(avisitn,z_avisit.);
    vis=tranwrd(vis,'CYCLE','C');
    vis=tranwrd(vis,'DAY','D');
    vis=compress(vis,' ,');
    tim=put(_timepoint,_atpt.);
    tim=tranwrd(tim,'of','');
    tim=tranwrd(tim,'copanlisib/placebo','');
    id=scan(_stat_,1);

   *keep labels;
   call symput('_mycop',vlabel(count1));
   call symput('_mypla',vlabel(count2));
   if a then catord=1;
   else catord=2;
RUN;

proc sort data=lab;
    by catord avisitn _timepoint _vlabel_ vis tim;
RUN;
proc transpose data=lab out=_labcop;
    by catord avisitn _timepoint _vlabel_ vis tim;
    var count1 ;
    id id;
    idlabel _stat_;
RUN;

proc transpose data=lab out=_labpla;
    by catord avisitn _timepoint _vlabel_ vis tim;
    var count2 ;
    id id;
    idlabel _stat_;
RUN;


*merge ;
proc sql noprint;
    create table template as select distinct catord, avisitn, _timepoint, vis, tim from lab;
    create table all1 as select a.*,b.n, b.mean from template as a left join _labcop(where=(_vlabel_='Value')) as b
    on a.catord=b.catord and a.avisitn=b.avisitn and a._timepoint =b._timepoint;
    create table all2 as select a.*,b.n as ncop, b.mean as meancop from all1 as a left join _labcop(where=(_vlabel_='Change from respective pre-dose value')) as b
    on a.catord=b.catord and a.avisitn=b.avisitn and a._timepoint =b._timepoint;

    create table all3 as select a.*,b.n as npla, b.mean as meanpla from all2 as a left join _labpla(where=(_vlabel_='Value')) as b
    on a.catord=b.catord and a.avisitn=b.avisitn and a._timepoint =b._timepoint;
    create table all4 as select a.*,b.n as nplac, b.mean as meanplac from all3 as a left join _labpla(where=(_vlabel_='Change from respective pre-dose value')) as b
    on a.catord=b.catord and a.avisitn=b.avisitn and a._timepoint =b._timepoint
    order by catord, avisitn, _timepoint, _vlabel_, vis, tim;

QUIT;

*include freelines;
data all4;
    set all4;
    by catord avisitn;
    if ~first.avisitn then call missing(vis);
    ord=_n_;
RUN;
*insert extra lines;
proc sql noprint;
    insert into all4 set ord=0, tim=&cat1.;
    insert into all4 set ord=&ord., tim=&cat2.;

QUIT;
proc sort data=all4;
    by ord ;
RUN;

%printline(##Table %sysfunc(scan(&title.,2,' ')));
%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = &ref.
  , title     = &title.
  , keepftn   = N
  , foot      =&foot.
  , foot1     = &foot1.
  , evaltable =
);


%datalist(
    data   = all4
  , var    = vis tim ("&_mycop. @Value at timepoint" n mean )("Change from pre-dose" ncop meancop )("&_mypla. @Value at timepoint" npla meanpla )("Change from pre-dose" nplac meanplac )
  , maxlen = 15
  , label  = no
);

/*%endprog;*/
%mend means;
*glucose;
%means(data1=t_14_3_5_adlbgluc_mean_chg_1
       ,data2=t_14_3_5_adlbgluc_mean_chg_2
       ,cat1='(pre-dose) fasting'
       ,cat2='(pre-dose) non-fasting'
       ,ref= t_14_3_5_adlbgluc_mean_chg
       ,title=%NRBQUOTE(Table 10-31 Mean glucose levels (mg/dL) and change from pre-dose values for Cycles 1 and 2 (SAF) )
       ,foot= %NRBQUOTE(BL = Baseline; N = Total number of patients (100%); n = Number of patients with event; SAF = Safety analysis
set; StD = Standard deviation a. On C1D1 patients were supposed to be fasting for 8 h before the copanlisib/placebo infusion. Subsequent
dosing days fasting was not required. Note: The post infusion timings shown in the table are all related to post end of infusion.)
       ,foot1=%NRBQUOTE(Source: Table 14.3.5/9 )
       );

*bp;
*attention: order of datasets reversed to get systolic first;
%means(data1=t_14_3_5_advsbp_mean_chg_2
       ,data2=t_14_3_5_advsbp_mean_chg_1
       ,cat1='Systolic blood pressure'
       ,cat2='Diastolic blood pressure'
       ,ref= t_14_3_5_advsbp_mean_chg
       ,title=%NRBQUOTE(Table 10-37 Mean blood pressure values (mmHg) and change from pre-dose values for Cycles 1 and 2 (SAF) )
       ,foot= %NRBQUOTE(C = Cylcle; BL = Baseline; D = Day; N = Total number of patients (100%); n = Number of patients with event;
SAF = Safety analysis set; StD = Standard deviation )
       ,foot1=%NRBQUOTE(Source: Table 14.3.5/23 )
       ,ord=30.5
       );

