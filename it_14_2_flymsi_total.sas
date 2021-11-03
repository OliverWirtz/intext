/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin’s lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_2_flymsi_total);
/*
 * Purpose          : Table 9-15 FLymSI-18 total score and changes from baseline by visit (FAS)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 29JUN2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 04AUG2020
 * Reason           : changed numbering
 ******************************************************************************/

%macro flym(data=t_14_2_adqsflym_flymsi18
       , tabno=1
       , title=%str(Table 9-15 FLymSI-18 total score and changes from baseline by visit (FAS) )
       , table=##Table 9-17);
data flym;
    set tlfmeta.&data._&tabno.;
    call symput("_mycop",vlabel(count1));
    call symput("_mypla",vlabel(count2));
RUN;

proc sort data=flym  ;
    by avisitn avisit _vlabel_ _statnr_;
RUN;
*get copanlisib;
proc transpose data=flym(where=(_vlabel_='Value at Visit')) out=_flym ;
    by avisitn avisit _vlabel_ ;
    var count1;
    id _statnr_;
    idlabel _stat_;

RUN;
proc transpose data=flym(where=(_vlabel_^='Value at Visit')) out=_flymcfb(drop= _name_ _label_ _vlabel_) prefix=cfb_;
    by avisitn avisit _vlabel_ ;
    var count1;
    id _statnr_;
    idlabel _stat_;
RUN;


data cp;
    merge _flym _flymcfb;
    by avisitn avisit ;

RUN;
*insert treatment group and N;
proc sql noprint;
    insert into cp set _1=  "&_mycop." ;
QUIT;
proc sort data=cp;
    by _label_;
RUN;
*get placebo;


proc transpose data=flym(where=(_vlabel_='Value at Visit')) out=_flym ;
    by avisitn avisit _vlabel_ ;
    var count2;
    id _statnr_;
    idlabel _stat_;

RUN;
proc transpose data=flym(where=(_vlabel_^='Value at Visit')) out=_flymcfb(drop= _name_ _label_ _vlabel_) prefix=cfb_;
    by avisitn avisit _vlabel_ ;
    var count2;
    id _statnr_;
    idlabel _stat_;
RUN;

*insert treatment group and N;
data plac;
    merge _flym _flymcfb;
    by avisitn avisit ;

RUN;


proc sql noprint;
    insert into plac set _1=  "&_mypla." ;
QUIT;

proc sort data=plac;
    by _label_;
RUN;
data all;

    set cp(in=a) plac(in=b) ;

RUN;

%printline(&Table.)

%m_itmtitle(mymeta=tl_meta,tableno=&tabno., itdata=t_14_2_adqsflym_flymsi18,title=&title.,
            foot=%nrbquote(BL = Baseline; C1D1 = Cycle 1 Day 1; EOT = End of treatment; FAS = Full analysis set; FLymSI-18 = NCCN-FACT
Lymphoma Symptom Index-18, FU = Follow-up; N = Total number of patients (100%); StD = Standard deviation Note: For each patient the time to the first onset of physical symptoms is summarized. Unscheduled visits are included.
Source: Table 14.2.4/2 ),
evaltable=  )


%datalist(
    data   = all
  , var    = avisit ("Value at visit" _1 _3 _5 _6 ) ("change from BL(C1D1)" cfb_1 cfb_3 cfb_5 cfb_6)
  , maxlen = 20
  , label  = no
  ,split='@'
)


proc datasets lib=work
    kill memtype=data nolist;
QUIT;
%mend flym;

    %flym(data=t_14_2_adqsflym_flymsi18
        , tabno=1
    , title=%str(Table 9-15 FLymSI-18 total score and changes from baseline by visit (FAS) )
    , table=##Table 9-15);


    %flym(data=t_14_2_adqsflym_flymsi18
    , tabno=3
    , title=%str(Table 9-16 FLymSI-18 DRS-P score and changes from baseline by visit (FAS)  )
    , table=##Table 9-16);


    %endprog;
