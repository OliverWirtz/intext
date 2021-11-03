/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_adae_perc);
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
 * Author(s)        : gghcj (Oliver Wirtz) / date: 07MAY2020
 * Reference prog   :
 ******************************************************************************/

*threshold in a macro variable ;
%let thres=1;
*do thresholds for both groups and find all affected cats;
%m_threshold(
        indata=t_14_3_1_1_adae_teae_1_1
      , lib=tlfmeta
      , topvar=aebodsys
      , secvar=_ic_var1
      , outvar=_levtxt
      , renameto=
      , renamevar=
      , treat=_t_1
      , datawhere=%str(where _ct1='Total' and ~missing(aebodsys))
      , threshold=&thres.
      , debug=N
  );
data fl;
    set sub__ic_var1_out;
RUN;
  %m_threshold(
          indata=t_14_3_1_1_adae_teae_1_1
        , lib=tlfmeta
        , topvar=aebodsys
        , secvar=_ic_var1
        , outvar=_levtxt
        , renameto=
        , renamevar=
        , treat=_t_2
        , datawhere=%str(where _ct1='Total' and ~missing(aebodsys))
        , threshold=&thres.
        , debug=N
    );

data all;
    set fl sub__ic_var1_out;
RUN;

proc sql noprint;
    create table cats as select distinct _levtxt from all where ~missing(_levtxt);
QUIT;

*do the same for all subjects but no cutoff to get sorting by totals;
%m_threshold(
      indata=t_14_3_1_1_adae_teae_1_1
    , lib=tlfmeta
    , topvar=aebodsys
    , secvar=_ic_var1
    , outvar=_levtxt
    , renameto='Any TEAE'
    , renamevar=_levtxt
    , treat=_t_3
    , datawhere=%str(where _ct1='Total' and ~missing(aebodsys))
    , threshold=0
    , debug=N
);
proc sql noprint;
    create table tot0 as select a.* from sub__ic_var1_out as a left join cats as b on a._levtxt=b._levtxt where ~missing(b._levtxt) or a._sort1=0
          order by a._flag ;

QUIT;
proc sort data= tot0;
    by _flag descending _thresperc ;
RUN;

*now retrieve the subgroups;
data tot;
    set tot0;
    %_get_it_label(inds=tot,invar=_t_3, debug=n);
    taborder=_n_;
    drop _t_3;
RUN;

data fl;
    set tlfmeta.t_14_3_1_1_adae_teae_1_2;
    %_get_it_label(inds=FL,invar=_t_3, debug=n);
    where _ct1='Total' and ~missing(aebodsys);
    if aebodsys='All system organ classes' then _levtxt='Any TEAE';
RUN;

data mzl;
    set tlfmeta.t_14_3_1_1_adae_teae_1_3;
    %_get_it_label(inds=MZL,invar=_t_3, debug=n);
    where _ct1='Total' and ~missing(aebodsys);
    if aebodsys='All system organ classes' then _levtxt='Any TEAE';
RUN;

proc sql noprint;
    create table all0 as select a.*, b._t_3,b._t_4
           from  tot as a
                    left join fl(keep=_t_1 _t_2  _levtxt rename=(_t_1=_t_3 _t_2=_t_4)) as b
                    on a._levtxt=b._levtxt;
    create table all1 as select a.*,b._t_5,b._t_6 from all0 as a
                left join  mzl(keep=_t_1 _t_2 _levtxt rename=(_t_1=_t_5 _t_2=_t_6)) as b
            on a._levtxt=b._levtxt order by a.taborder;
QUIT;

data all2;
    set all1;
    array my(*) _t_1 - _t_6;
    do i=1 to 6;
        if missing(my(i)) then do;
            if i in (1,2,3,5) then my(i)='  0';
            else my(i)=' 0';
        end;
    END;
RUN;

%m_rename(indata=all2, inarray=%str('_t_1', '_t_2', '_t_3', '_t_4', '_t_5', '_t_6'))



%m_itmtitle(mymeta=tl_meta,tableno=1, itdata=t_14_3_1_1_adae_teae_1,title=%str(Incidence of TEAEs by worst Grade occurring in >=&thres.% of the patients in either treatment arm by MedDRA PT (SAF))
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

%endprog(
    cleanWork       = y
  , cleanTitlesFoot = y
  , verbose         = Y
)