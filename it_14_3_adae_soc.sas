/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_adae_soc);
/*
 * Purpose          : incidence of TEAE by SOC
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 08MAY2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 03JUL2020
 * Reason           : added printline
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 31JUL2020
 * Reason           : source datasets were re-named
 ******************************************************************************/


*do thresholds =0 to get all soc but use sort functionality;

%m_threshold(
        indata=t_14_3_1_1_adae_teae1_1
      , lib=tlfmeta
      , topvar=aebodsys
      , secvar=_ic_var1
      , outvar=aebodsys
      , renameto='Any TEAE'
      , renamevar=aebodsys
      , treat=_t_1 _t_2
      , datawhere=%str(where _ct1='Total' and ~missing(aebodsys))
      , threshold=0
      , debug=N
  );
  data tot;
      set main_aebodsysout;
      %_get_it_label(inds=tot,invar=_t_3, debug=n);

      if aebodsys='Any TEAE' then _thresperc=999;
      drop _t_3;
  RUN;

  %_assign_meddralabel(
      inlib = work
    , inds  = tot
    , invar = aebodsys
  )

data fl;
    set tlfmeta.t_14_3_1_1_adae_teae_subg1_1;
    %_get_it_label(inds=FL,invar=_t_3, debug=n);
    where _ct1='Total' and ~missing(aebodsys) and _levtxt='ANY';
    if aebodsys='All system organ classes' then aebodsys='Any TEAE';
RUN;

data mzl;
    set tlfmeta.t_14_3_1_1_adae_teae_subg1_2;
    %_get_it_label(inds=MZL,invar=_t_3, debug=n);
    where _ct1='Total' and ~missing(aebodsys) and _levtxt='ANY';
    if aebodsys='All system organ classes' then aebodsys='Any TEAE';
RUN;

proc sql noprint;
    create table all0 as select a.*, b._t_3,b._t_4
           from  tot as a
                    left join fl(keep=_t_1 _t_2  aebodsys _ct1 rename=(_t_1=_t_3 _t_2=_t_4)) as b
                    on a.aebodsys=b.aebodsys and a._ct1=b._ct1;
    create table all1 as select a.*,b._t_5,b._t_6 from all0 as a
                left join  mzl(keep=_t_1 _t_2 aebodsys _ct1 rename=(_t_1=_t_5 _t_2=_t_6)) as b
            on a.aebodsys=b.aebodsys and a._ct1=b._ct1;
QUIT;

proc sort data= all1;
    by descending _thresperc aebodsys;
RUN;
*Get number of blanks for table if missings;
data all2;
    set all1 ;
    retain _t_11 - _t_16 0;
    array my(*) _t_1 - _t_6;
    if _n_=1 then do;
        do i=1 to 6;
            call symput(vname(my(i)),compress(put(find(my(i),'(')-3,8.)));
        end;
    END;
run;
*add zeros;
data all2;
    set all2;
    label aebodsys="MedDRA SOC version &meddrav.";
    array my(*) _t_1 - _t_6;
    array myl(6) _temporary_ (&_t_1. &_t_2. &_t_3. &_t_4. &_t_5. &_t_6 );
    do i=1 to 6;
        if missing(my(i)) then do;
            my(i)='0';
            do k=1 to myl(i);
                   my(i)=' '||trim(my(i));
            END;
        end;
    END;
RUN;

%m_rename(indata=all2, inarray=%str('_t_1', '_t_2', '_t_3', '_t_4', '_t_5', '_t_6'))

%printline(##Table 10-6);

%m_itmtitle(mymeta=tl_meta,tableno=1
          , itdata=t_14_3_1_1_adae_teae1
          ,title=%str(Table 10-6 Incidence of TEAEs by MedDRA SOC (any grade)(SAF))
          ,foot=%nrbquote(FL = Follicular lymphoma; iNHL = Indolent NHL; LPL = Lymphoplasmacytoid lymphoma; MedDRA = Medical
Dictionary for Regulatory Activities; MZL = Marginal zone lymphoma; N = Total number of patients (100%); n =Number of patients with event; NHL = Non-Hodgkin's lymphoma; SAF = Safety analysis set; SLL = Small
lymphocytic lymphoma; SOC = System organ class; TEAE = Treatment-emergent adverse event; WM = Waldenstroem macroglobulinemia
a. Number (%) of patients with the specified event starting or worsening between start of study treatment and 30
days after end of study treatment.)
          ,foot1=%nrbquote(Source: Table 14.3.1.1/1 and Table 14.3.1.1/3 )
         ,keepftn=N );

%insertOption(
    namevar   = aebodsys
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
  , var    = aebodsys ("&_mytot." _t_1 _t_2) ("&_myfl." _t_3 _t_4) ("&_mymzl." _t_5 _t_6)
  , maxlen = 17
  , label  = no
  ,split='@'
)
%endprog;