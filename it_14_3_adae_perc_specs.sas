/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_adae_perc_specs);
/*
 * Purpose          : AE Incidence PT threshold intext table
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
/* Changed by       : gghcj (Oliver Wirtz) / date: 07JUL2020
 * Reason           : included counts option in TESAE and printline
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 31JUL2020
 * Reason           : edit of source tables
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 04AUG2020
 * Reason           : changed numbering
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 10AUG2020
 * Reason           : change naming of grading variable result
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 17AUG2020
 * Reason           : changed sort variables and meddrav
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 07OCT2020
 * Reason           : added code to avoid note for missing records in mzl
 ******************************************************************************/

%macro aegrade(
       totds=t_14_3_1_1_adae_teae1_1,
       flds=t_14_3_1_1_adae_teae_subg1_1,
       mzlds=t_14_3_1_1_adae_teae_subg1_2,
       _levtxt=%str(Any TEAE),
       where=%str(where _ct1='Total' and ~missing(aebodsys)),
       tableno=1,
       itdata=t_14_3_1_1_adae_teae_1_,
       thres=1,
       threstyp=percent,
       title=%str(Incidence of TEAEs by worst Grade occurring in >=&thres.% of the patients in either treatment arm by MedDRA PT (safety analysis set)),
       foot1=
       );


*do thresholds in total iNHL for Copanlisib ;
%m_threshold(
        indata=&totds.
      , lib=tlfmeta
      , topvar=aebodsys
      , secvar=_ic_var1
      , outvar=_levtxt
      , renameto="&_levtxt."
      , renamevar=_levtxt
      , treat=_t_1 _t_2
      , datawhere=&where.
      , threshold=&thres.
      , threstyp=&threstyp.
      , debug=N
  );
  data tot;
      set sub__ic_var1_out;
      %_get_it_label(inds=tot,invar=_t_3, debug=n);
      if _levtxt="&_levtxt." then _thresperc_sort=999;
      drop _t_3;
  RUN;

  %_assign_meddralabel(
    inlib = work
  , inds  = tot
  , invar = _levtxt
  )

data fl;
    set tlfmeta.&flds.;
    %_get_it_label(inds=FL,invar=_t_3, debug=n);
    &where.;
    if aebodsys='All system organ classes' then _levtxt="&_levtxt.";

RUN;
*for grade 5 we run out of observations;
*check if there is something in mzl data;
proc sql noprint;
    select count(*) into :mzlcounts from tlfmeta.&mzlds. &where.;
QUIT;

*Output selection if it has counts, otherwise output all but with invalid key, so that nothing is merged;
    data mzl;
        set tlfmeta.&mzlds.;
        %_get_it_label(inds=MZL,invar=_t_3, debug=n);
        %if %eval(&mzlcounts.)>0 %then %do;
            &where.;
            if aebodsys='All system organ classes' then _levtxt="&_levtxt.";
        %end;

        %else %do;
            _levtxt="no observations";
        %END;

    RUN;

proc sql noprint;
    create table all0 as select a.*, b._t_3,b._t_4
           from  tot as a
                    left join fl(keep=_t_1 _t_2  _levtxt _ct1 rename=(_t_1=_t_3 _t_2=_t_4)) as b
                    on a._levtxt=b._levtxt and a._ct1=b._ct1;
    create table all1 as select a.*,b._t_5,b._t_6 from all0 as a
                left join  mzl(keep=_t_1 _t_2 _levtxt _ct1 rename=(_t_1=_t_5 _t_2=_t_6)) as b
            on a._levtxt=b._levtxt and a._ct1=b._ct1;
QUIT;

proc sort data= all1;
    by descending _thresperc_sort _levtxt;
RUN;
*Get number of blanks for table if missings;
data all2;
    set all1 ;
    retain _t_11 - _t_16 0;
    array my(*) _t_1 - _t_6;
    if _n_=1 then do;
        do i=1 to 6;
            if find(my(i),'(')>0 then call symput(vname(my(i)),compress(put(find(my(i),'(')-3,8.)));
            else call symput(vname(my(i)),compress(put(find(my(i),'0')-1,8.)));
        end;
    END;
run;
*add zeros;
data all2;
    set all2;
    label _levtxt="MedDRA PT version &meddra.";
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

%m_rename(indata=all2, inarray=%str('_t_1', '_t_2', '_t_3', '_t_4', '_t_5', '_t_6'));

%printline(##Table %sysfunc(scan(&title.,2,' ')));

%m_itmtitle(mymeta=tl_meta,tableno=&tableno., itdata=&itdata.,title=&title.
,foot=%nrbquote(
          FL = Follicular lymphoma; iNHL = Indolent NHL; LPL = Lymphoplasmacytoid lymphoma; MedDRA = Medical
          Dictionary for Regulatory Activities; MZL = Marginal zone lymphoma; N = Total number of patients (100%);
          n = Number of patients with event; NHL = Non-Hodgkin%str(%')s lymphoma; SAF = Safety analysis set; SLL = Small
          lymphocytic lymphoma; PT = Preferred term; TEAE = Treatment-emergent adverse event; WM = Waldenstroem
          macroglobulinemia a. Number (%) of patients with the specified event starting or worsening between start of treatment and 30 days
          after end of treatment. )
, foot1=&foot1.
, keepftn=N);
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
/*proc datasets lib=work kill memtype=data nolist;*/
/*quit;*/

%mend aegrade;

*TEAE;
%aegrade(where=%str(where _ct1='Total' and ~missing(aebodsys)),
         thres=1,
         tableno=1,
         itdata=t_14_3_1_1_adae_teae1,
         title=%nrstr(Table 10-6 Most common TEAEs by MedDRA PT (any grade) occurring in >=&thres.% of patients in either treatment arm of the iNHL population (SAF)),
         foot1=%nrbquote(Source: Table 14.3.1.1/1 and Table 14.3.1.1/3 )
         );


%aegrade(where=%str(where _ct1='Grade 3' and ~missing(aebodsys)),
         thres=1,
         tableno=1,
         itdata=t_14_3_1_1_adae_teae1,
         title=%nrstr(Table 10-7 Incidence of worst grade 3 TEAEs by MedDRA PT occurring in >=&thres.% of patients in either treatment arm of the iNHL population (SAF) ),
         foot1=%nrbquote(Source: Table 14.3.1.1/1 and Table 14.3.1.1/3 )
         );

%aegrade(where=%str(where _ct1='Grade 4' and ~missing(aebodsys)),
         thres=1,
         tableno=1,
         itdata=t_14_3_1_1_adae_teae1,
         title=%nrstr(Table 10-8 Incidence of worst grade 4 TEAEs by MedDRA PT occurring in >=&thres.% of patients in either treatment arm of the iNHL population (SAF) ),
         foot1=%nrbquote(Source: Table 14.3.1.1/1 and Table 14.3.1.1/3 )
          );

%aegrade(where=%str(where _ct1='Grade 5' and ~missing(aebodsys)),
          thres=0,
          tableno=1,
          itdata=t_14_3_1_1_adae_teae1,
          title=%nrstr(Table 10-9 Incidence of worst grade 5 TEAEs by MedDRA PT (SAF) ),
           foot1=%nrbquote(Source: Table 14.3.1.1/1, Table 14.3.1.1/3 and Table 14.3.1.1/9  )
           );




*TESAE;
*exception: here threshold is by subject count!!!;
%aegrade(
    totds=t_14_3_1_1_adae_teae2_4,
    flds=t_14_3_1_1_adae_teae_subg2_1,
    mzlds=t_14_3_1_1_adae_teae_subg2_2,
    where=%str(where _ct1='Total' and ~missing(aebodsys)),
     thres=2,
      threstyp=count,
     _levtxt=%str(Any TESAE),
     tableno=4,
     itdata=t_14_3_1_1_adae_teae2,
     title=%nrstr(Table 10-17 Incidence of TESAEs (any grade) by MedDRA PT occurring in >=&thres. patients in either treatment arm of the iNHL population (SAF))
     ,
     foot1=%nrbquote(Source: Table 14.3.1.1/7 and Table 14.3.1.1/8 ));

*copa related TESAE;


 %aegrade(
     totds=t_14_3_1_2_adae_teae3_5,
     flds=t_14_3_1_2_adae_teae_subg2_1,
     mzlds=t_14_3_1_2_adae_teae_subg2_2,
     where=%str(where _ct1='Total' and ~missing(aebodsys)),
      thres=0,
      _levtxt=%str(Any TESAE),
      tableno=5,
      itdata=t_14_3_1_2_adae_teae3,
      title=%nrstr(Table 10-18 Incidence of copanlisib/placebo-related TESAEs (any grade) by MedDRA PT (SAF))
       ,
       foot1=%nrbquote(Source: Table 14.3.1.2/11 and Table 14.3.1.2/13 )

      );

*ritux related TESAE;

%aegrade(
 totds=t_14_3_1_2_adae_teae3_6,
 flds=t_14_3_1_2_adae_teae_subg2_3,
 mzlds=t_14_3_1_2_adae_teae_subg2_4,
 where=%str(where _ct1='Total' and ~missing(aebodsys)),
  thres=0,
  _levtxt=%str(Any TESAE),
  tableno=6,
  itdata=t_14_3_1_2_adae_teae3,
  title=%nrstr(Table 10-19 Incidence of rituximab-related TESAEs (any grade) by MedDRA PT (SAF))
  ,
  foot1=%nrbquote(Source: Table 14.3.1.2/12 and Table 14.3.1.2/14)
  );

  %endprog;
