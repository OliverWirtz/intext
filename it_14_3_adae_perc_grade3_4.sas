/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_adae_perc_grade3_4);
/*
 * Purpose          : AE overview intext table
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 06MAY2020
 * Reference prog   :
 ******************************************************************************/
%macro aegrade(
       totds=t_14_3_1_1_adae_teae_1_1,
       flds=t_14_3_1_1_adae_teae_1_1,
       mzlds=t_14_3_1_1_adae_teae_1_1,
       where=%str(where _ct1='Total' and ~missing(aebodsys)),
       thres=1,
       title=%str(Incidence of TEAEs by worst Grade occurring in >=&thres.% of the patients in either treatment arm by MedDRA PT (SAF))
       );

*do thresholds in total ds for both treatment groups and find all affected categories;
%m_threshold(
        indata=&totds.
      , lib=tlfmeta
      , topvar=aebodsys
      , secvar=_ic_var1
      , outvar=_levtxt
      , renameto='Any TEAE'
      , renamevar=_levtxt
      , treat=_t_1
      , datawhere=&where.
      , threshold=&thres.
      , debug=N
  );
  data cop;
      set sub__ic_var1_out;
      rename _thresperc=copaperc;
      if _levtxt='Any TEAE' then _thresperc=999;
  RUN;
  %m_threshold(
          indata=&totds.
        , lib=tlfmeta
        , topvar=aebodsys
        , secvar=_ic_var1
        , outvar=_levtxt
        , renameto='Any TEAE'
        , renamevar=_levtxt
        , treat=_t_2
        , datawhere=&where.
        , threshold=&thres.
        , debug=N
    );

    data rit;
        set sub__ic_var1_out;
        rename _thresperc=ritperc;
        if _levtxt='Any TEAE' then _thresperc=999;
    RUN;
    proc sql noprint;
    /*    create table cats as select distinct _levtxt from all where ~missing(_levtxt);*/
        create table tot(rename= levtxt=_levtxt) as select  coalesce( a._levtxt,  b._levtxt) as levtxt,
               a._t_1, b._t_2, a._t_2 as a_t_2,b._t_1 as a_t_1,
               a.copaperc, b.ritperc from cop as a
               full outer join rit as b
               on a._levtxt=b._levtxt
               ;
    QUIT;
    proc sort data=tot;
        by descending copaperc descending ritperc _levtxt;
    RUN;
/**/
/**do the same for all subjects but no cutoff to get sorting by totals;*/
/*%m_threshold(*/
/*      indata=&totds.*/
/*    , lib=tlfmeta*/
/*    , topvar=aebodsys*/
/*    , secvar=_ic_var1*/
/*    , outvar=_levtxt*/
/*    , renameto='Any TEAE'*/
/*    , renamevar=_levtxt*/
/*    , treat=_t_3*/
/*    , datawhere=&where.*/
/*    , threshold=0*/
/*    , debug=N*/
/*);*/
/**keep all cats where either trt1 or trt2 have a cat >= threshold, keep sorting by overall;*/
/*proc sql noprint;*/
/*    create table tot0 as select a.* from sub__ic_var1_out as a left join cats as b on a._levtxt=b._levtxt where ~missing(b._levtxt) or a._sort1=0*/
/*          order by a._flag ;*/
/**/
/*QUIT;*/
/*proc sort data= tot0;*/
/*    by _flag descending _thresperc ;*/
/*RUN;*/

*now retrieve the subgroups;
/*data tot;*/
/*    set tot0;*/
/*    %_get_it_label(inds=tot,invar=_t_3, debug=n);*/
/*    taborder=_n_;*/
/*    drop _t_3;*/
/*RUN;*/

data fl;
    set tlfmeta.t_14_3_1_1_adae_teae_1_2;
    %_get_it_label(inds=FL,invar=_t_3, debug=n);
    &where.;
    if aebodsys='All system organ classes' then _levtxt='Any TEAE';
   * if _levtxt not in ('ANY');
RUN;

data mzl;
    set tlfmeta.t_14_3_1_1_adae_teae_1_3;
    %_get_it_label(inds=MZL,invar=_t_3, debug=n);
    &where.;
    if aebodsys='All system organ classes' then _levtxt='Any TEAE';
   * if _levtxt not in ('ANY');
RUN;

proc sql noprint;
    create table all0 as select a.*, b._t_3,b._t_4
           from  tot as a
                    left join fl(keep=_t_1 _t_2  _levtxt rename=(_t_1=_t_3 _t_2=_t_4)) as b
                    on a._levtxt=b._levtxt;
    create table all1 as select a.*,b._t_5,b._t_6 from all0 as a
                left join  mzl(keep=_t_1 _t_2 _levtxt rename=(_t_1=_t_5 _t_2=_t_6)) as b
            on a._levtxt=b._levtxt ;
QUIT;
proc sort data= all1;
    by descending copaperc descending ritperc _levtxt;
RUN;
data all2;
    set all1 end=eof;

    retain _t_11 - _t_16 0;
    array my(*) _t_1 - _t_6;
    array myl(*) _t_11 - _t_16;

    do i=1 to 6;
        if compress(my(i))='0' then do;
            call symput(vname(my(i)),compress(put(find(my(i),'0')-1,8.)));
            myl(i)=1;
        END;
        else if eof and myl(i)=0 then do;
            call symput(vname(my(i)),'0');
        END;
    END;
   drop  _t_11 - _t_16;
run;
data all2;
    set all2;
    array my(*) _t_1 - _t_6;
    array myl(6) _temporary_ (&_t_1. &_t_2. &_t_3. &_t_4. &_t_5. &_t_6 );
    do i=1 to 6;
/*        if missing(my(i)) then do;*/
/*            my(i)='0';*/
/*            do k=1 to myl(i);*/
/*                   my(i)=' '||trim(my(i));*/
/*            END;*/
/*        end;*/
    END;
RUN;

%m_rename(indata=all2, inarray=%str('_t_1', '_t_2', '_t_3', '_t_4', '_t_5', '_t_6'))



%m_itmtitle(mymeta=tl_meta,tableno=1, itdata=t_14_3_1_1_adae_teae_1,title=&title.
,foot=%nrbquote(MedDRA = Medical Dictionary for Regulatory Activities; N = Total number of patients (100%); n = Number of patients with event; PT = Preferred term; TEAE = Treatment-emergent adverse event));

%insertOption(
    namevar   = _levtxt
  , align     =
  , width     = 20
  , other     =
  , charnum   = .
  , keep      = N
  , overwrite = Y
  , comment   = YES
)

%datalist(
    data   = all2
  , var    = _levtxt ("&_mytot." _t_1 _t_2) ("&_myfl." _t_3 _t_4) ("&_mymzl." _t_5 _t_6)
  , maxlen = 17
  , label  = no
  ,split='@'
)

%mend aegrade;
%aegrade(where=%str(where _ct1='Total' and ~missing(aebodsys)), thres=1, title=%str(Incidence of TEAEs by worst Grade occurring in >=&thres.% of the patients in either treatment arm by MedDRA PT (SAF)));
%aegrade(where=%str(where _ct1='3' and ~missing(aebodsys)), thres=1, title=%str(Incidence of TEAEs by worst Grade 3 occurring in >=&thres.% of the patients in either treatment arm by MedDRA PT (SAF)));
%aegrade(where=%str(where _ct1='4' and ~missing(aebodsys)), thres=1, title=%str(Incidence of TEAEs by worst Grade 4 occurring in >=&thres.% of the patients in either treatment arm by MedDRA PT (SAF)));
