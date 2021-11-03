/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_adae_perc_specs_sub);
/*
 * Purpose          : AE by age group intext table
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 08JUL2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 31JUL2020
 * Reason           : changed source tables
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 04AUG2020
 * Reason           : renumbered and removed related AE groupings
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 04SEP2020
 * Reason           : cahnged number for diabetes
 ******************************************************************************/

*helper macro to get all data prepared;
%macro get_data(firstline=1,second=0,grp=agegrp0,outds=any1,inds=t_14_3_1_4_adae_teae_9, text=%str(Any TEAE));
*Any teae;
proc sql noprint;
    select distinct &grp.  into :mygrp from  tlfmeta.&inds.;
QUIT;

data &outds.;
    set tlfmeta.&inds. end=eof;
    format text var1 var2 $100.;
    where aebodsys='All system organ classes';
    var1='';
    var2='';
    if _ct1='Total' then do;
        _orderN=-1;
        text="&text.";
    end;
    else if strip(_ct1)='Grade 5' then text="  "||trim(_ct1)||" (death)";

    else if find(_ct1,"Grade")>0 then text='  '||trim(_ct1);

    if eof then do;
        output;
        text='Worst Grade';
        call missing(_t_1,_t_2);
        _orderN=0;
        output;
        %if %eval(&firstline=1) %then %do;
            _orderN=-2;
            text='Number of patients (%) with';
            var1=vlabel(_t_1);
            var2=vlabel(_t_2);
            _t_1=substr(var1,find(var1,'@')+1,find(var1,'(')-find(var1,'@')-2)||"@n (%)";
            _t_2=substr(var2,find(var2,'@')+1,find(var2,'(')-find(var2,'@')-2)||"@n (%)";
            output;
        %end;
    END;
    else output;
    drop _t_3 var1 var2;

RUN;
data &outds;
    set &outds;
    label _t_1="&mygrp."
          _t_2="&mygrp.";
    %if %eval(&second.)=1 %then %do;
        rename _t_1=_t_2
               _t_2=_t_4;
    %end;
    %else %do;
        rename _t_2=_t_3
               ;
    %end;
RUN;

%mend  get_data;


*age group;
*any TEAE;
%get_data(firstline=1,grp=agegr01N,outds=any1,inds=t_14_3_1_4_adae_teae_subg1_9, text=%str(Any TEAE));
%get_data(firstline=1,second=1,grp=agegr01N,outds=any2,inds=t_14_3_1_4_adae_teae_subg1_10, text=%str(Any TEAE));
proc sql noprint;
    create table any3 as select a.*,b._t_2,b._t_4 from any1 as a left join any2 as b on a.text=b.text
           order by _orderN;
QUIT;


*any TESAE;
%get_data(firstline=0,grp=agegr01N,outds=anysae1,inds=t_14_3_1_4_adae_teae_subg3_9, text=%str(Any TESAE));
%get_data(firstline=0,second=1,grp=agegr01N,outds=anysae2,inds=t_14_3_1_4_adae_teae_subg3_10, text=%str(Any TESAE));
proc sql noprint;
    create table anysae3 as select a.*,b._t_2,b._t_4 from anysae1 as a left join anysae2 as b on a.text=b.text
           order by _orderN;
QUIT;
/*
*any Copa related;
%get_data(firstline=0,grp=agegr01n,outds=anycop1,inds=t_14_3_1_4_adae_teae_subg5_1, text=%str(Any copanlisib/placebo-related TEAEs ));
%get_data(firstline=0,second=1,grp=agegr01n,outds=anycop2,inds=t_14_3_1_4_adae_teae_subg5_2, text=%str(Any copanlisib/placebo-related TEAEs ));
proc sql noprint;
  create table anycop3 as select a.*,b._t_2,b._t_4 from anycop1 as a left join anycop2 as b on a.text=b.text
         order by _orderN;
QUIT;


*any rituximab related;
%get_data(firstline=0,grp=agegr01n,outds=anyrit1,inds=t_14_3_1_4_adae_teae_subg5_3, text=%str(Any rituximab-related TEAEs ));
%get_data(firstline=0,second=1,grp=agegr01n,outds=anyrit2,inds=t_14_3_1_4_adae_teae_subg5_4, text=%str(Any rituximab-related TEAEs ));
proc sql noprint;
create table anyrit3 as select a.*,b._t_2,b._t_4 from anyrit1 as a left join anyrit2 as b on a.text=b.text
       order by _orderN;
QUIT;
*/
%printline(##Table 10-12);
%m_itmtitle(mymeta=tl_meta,tableno=9, itdata=t_14_3_1_4_adae_teae_subg1,title=%str(Table 10-12 Overview of TEAEs by age (SAF))
,foot=%nrbquote(CTCAE = Common Terminology Criteria for Adverse Events; N = Total number of patients (100%); n = Number
of patients with event; TEAE = Treatment-emergent adverse event; TESAE = Treatment-emergent serious adverse event )
, foot1=%nrbquote(Source: Table 14.3.1.4/4 and Table 14.3.1.4/12 ),keepftn=N
);

data all;
    set any3 anysae3; /* anycop3 anyrit3;*/
RUN;


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
    data   = all
  , var    = text ("Copanlisib/@rituximab@Age (years)" _t_1 _t_2) ("Placebo/@rituxima@Age (years)" _t_3 _t_4)
  , maxlen = 17
  , label  = no
  ,split='@'
)
proc datasets lib=work kill memtype=data nolist;
quit;



*history of hypertension;
 *any TEAE;
 %get_data(firstline=1,grp=mhhyptfn,outds=any1,inds=t_14_3_1_4_adae_teae_subg2_4, text=%str(Any TEAE));
 %get_data(firstline=1,second=1,grp=mhhyptfn,outds=any2,inds=t_14_3_1_4_adae_teae_subg2_3, text=%str(Any TEAE));
 proc sql noprint;
     create table any3 as select a.*,b._t_2,b._t_4 from any1 as a left join any2 as b on a.text=b.text
            order by _orderN;
 QUIT;


 *any TESAE;
 %get_data(firstline=0,grp=mhhyptfn,outds=anysae1,inds=t_14_3_1_4_adae_teae_subg3_14, text=%str(Any TESAE));
 %get_data(firstline=0,second=1,grp=mhhyptfn,outds=anysae2,inds=t_14_3_1_4_adae_teae_subg3_13, text=%str(Any TESAE));
 proc sql noprint;
     create table anysae3 as select a.*,b._t_2,b._t_4 from anysae1 as a left join anysae2 as b on a.text=b.text
            order by _orderN;
 QUIT;
/*
  *any Copa related;
  %get_data(firstline=0,grp=mhhyptfn,outds=anycop1,inds=t_14_3_1_4_adae_teae_subg5_9, text=%str(Any copanlisib/placebo-related TEAEs ));
  %get_data(firstline=0,second=1,grp=mhhyptfn,outds=anycop2,inds=t_14_3_1_4_adae_teae_subg5_10, text=%str(Any copanlisib/placebo-related TEAEs ));
  proc sql noprint;
      create table anycop3 as select a.*,b._t_2,b._t_4 from anycop1 as a left join anycop2 as b on a.text=b.text
             order by _orderN;
  QUIT;


  *any rituximab related;
  %get_data(firstline=0,grp=mhhyptfn,outds=anyrit1,inds=t_14_3_1_4_adae_teae_subg5_12, text=%str(Any rituximab-related TEAEs ));
  %get_data(firstline=0,second=1,grp=mhhyptfn,outds=anyrit2,inds=t_14_3_1_4_adae_teae_subg5_11, text=%str(Any rituximab-related TEAEs ));
  proc sql noprint;
    create table anyrit3 as select a.*,b._t_2,b._t_4 from anyrit1 as a left join anyrit2 as b on a.text=b.text
           order by _orderN;
  QUIT;
 */
  %printline(##Table 10-13);
 %m_itmtitle(mymeta=tl_meta,tableno=4, itdata=t_14_3_1_4_adae_teae_subg2,title=%str(Table 10-13 Overview of TEAEs by history of hypertension (SAF))
           ,foot=%nrbquote(CTCAE = Common Terminology Criteria for Adverse Events; N = Total number of patients (100%); n = Number
           of patients with event; TEAE = Treatment-emergent adverse event; TESAE = Treatment-emergent serious adverse event )
           , foot1=%nrbquote(Source: Table 14.3.1.4/6 and Table 14.3.1.4/14  ),keepftn=N);
 data all;
     set any3 anysae3 ;/*anycop3 anyrit3;*/
 RUN;


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
     data   = all
   , var    = text ("Copanlisib/@rituximab@History of hypertension" _t_1 _t_2) ("Placebo/@rituxima@History of hypertension" _t_3 _t_4)
   , maxlen = 17
   , label  = no
   ,split='@'
 )
 proc datasets lib=work kill memtype=data nolist;
 quit;


*history of diabetes;
 *any TEAE;
 %get_data(firstline=1,grp=mhdiabfn,outds=any1,inds=t_14_3_1_4_adae_teae_subg2_6, text=%str(Any TEAE));
 %get_data(firstline=1,second=1,grp=mhdiabfn,outds=any2,inds=t_14_3_1_4_adae_teae_subg2_5, text=%str(Any TEAE));
 proc sql noprint;
     create table any3 as select a.*,b._t_2,b._t_4 from any1 as a left join any2 as b on a.text=b.text
            order by _orderN;
 QUIT;


 *any TESAE;
 %get_data(firstline=0,grp=mhdiabfn,outds=anysae1,inds=t_14_3_1_4_adae_teae_subg3_16, text=%str(Any TESAE));
 %get_data(firstline=0,second=1,grp=mhdiabfn,outds=anysae2,inds=t_14_3_1_4_adae_teae_subg3_15, text=%str(Any TESAE));
 proc sql noprint;
     create table anysae3 as select a.*,b._t_2,b._t_4 from anysae1 as a left join anysae2 as b on a.text=b.text
            order by _orderN;
 QUIT;
/*
*copa related;

%get_data(firstline=0,grp=mhdiabfn,outds=anycop1,inds=t_14_3_1_4_adae_teae_subg6_2, text=%str(Any copanlisib/placebo-related TEAEs ));
%get_data(firstline=0,second=1,grp=mhdiabfn,outds=anycop2,inds=t_14_3_1_4_adae_teae_subg6_1, text=%str(Any copanlisib/placebo-related TEAEs ));
proc sql noprint;
    create table anycop3 as select a.*,b._t_2,b._t_4 from anycop1 as a left join anycop2 as b on a.text=b.text
           order by _orderN;
QUIT;

*ritux related;

%get_data(firstline=0,grp=mhdiabfn,outds=anyrit1,inds=t_14_3_1_4_adae_teae_subg6_4, text=%str(Any rituximab-related TEAEs ));
%get_data(firstline=0,second=1,grp=mhdiabfn,outds=anyrit2,inds=t_14_3_1_4_adae_teae_subg6_3, text=%str(Any rituximab-related TEAEs ));
proc sql noprint;
    create table anyrit3 as select a.*,b._t_2,b._t_4 from anyrit1 as a left join anyrit2 as b on a.text=b.text
           order by _orderN;
QUIT;
*/
%printline(##Table 10-14);
 %m_itmtitle(mymeta=tl_meta,tableno=9, itdata=t_14_3_1_4_adae_teae_subg1,title=%str(Table 10-14 Overview of TEAEs by history of diabetes (SAF))
           ,foot=%nrbquote(CTCAE = Common Terminology Criteria for Adverse Events; N = Total number of patients (100%); n = Number
           of patients with event; TEAE = Treatment-emergent adverse event; TESAE = Treatment-emergent serious adverse event )
           , foot1=%nrbquote(Source: Table 14.3.1.4/7 and Table 14.3.1.4/15 ),keepftn=N);
 data all;
     set any3 anysae3; /*anycop3 anyrit3;*/
 RUN;


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
     data   = all
   , var    = text ("Copanlisib/@rituximab@History of diabetes" _t_1 _t_2) ("Placebo/@rituxima@History of diabetes" _t_3 _t_4)
   , maxlen = 17
   , label  = no
   ,split='@'
 )
 proc datasets lib=work kill memtype=data nolist;
 quit;

 %endprog;