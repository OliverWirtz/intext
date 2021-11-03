/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_adae_perc_specs_rel);
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
 * Author(s)        : gghcj (Oliver Wirtz) / date: 08MAY2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 03JUL2020
 * Reason           : removed tables by grade since not part of csr, added printline
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 31JUL2020
 * Reason           : changed source tables
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 04AUG2020
 * Reason           : changed numbering added extra tables
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 10AUG2020
 * Reason           : edit in grade to match changed tlf layout
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 17AUG2020
 * Reason           : changed sort variable to _thresperc_sort
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 07OCT2020
 * Reason           : added code to avoid not if MZL runs out of observations
 ******************************************************************************/

%macro aegrade(
       totds=t_14_3_1_1_adae_teae1_1,
       flds=t_14_3_1_1_adae_teae_subg1_1,
       mzlds=t_14_3_1_1_adae_teae_subg1_2,
       where=%str(where _ct1='Total' and ~missing(aebodsys)),
       grade=%str(any grade),
       tableno=1,
       itdata=t_14_3_1_1_adae_teae1,
       thres=1,
       title=%str(Incidence of TEAEs by worst Grade occurring in >=&thres.% of the patients in either treatment arm by MedDRA PT (SAF)),
       foot=,
       foot1=,
       pretext=);

*do thresholds in total iNHL for Copanlisib ;
%m_threshold(
        indata=&totds.
      , lib=tlfmeta
      , topvar=aebodsys
      , secvar=_ic_var1
      , outvar=_levtxt
      , renameto='Any TEAE'
      , renamevar=_levtxt
      , treat=_t_1 _t_2
      , datawhere=&where.
      , threshold=&thres.
      , debug=Y
  );
  data tot;
      set sub__ic_var1_out;
      %_get_it_label(inds=tot,invar=_t_3, debug=n);
      if _levtxt='Any TEAE' then _thresperc_sort=999;
      drop _t_3;
  RUN;


data fl;
    set tlfmeta.&flds.;
    %_get_it_label(inds=FL,invar=_t_3, debug=n);
    &where.;
    if aebodsys='All system organ classes' then _levtxt='Any TEAE';

RUN;
*account for missing observations in MZL for subgroups;
proc sql noprint;
    select count(*) into :cntmzl from tlfmeta.&mzlds. &where;
QUIT;

*dataset needs at least one observation for macro to work;
*the code below includes all observations if no applies;
*this produces the label macro variable but no observations are output;
data mzl;
    set tlfmeta.&mzlds.;
    %_get_it_label(inds=MZL,invar=_t_3, debug=n);
    %if %eval(&cntmzl.)>0 %then %do;
        &where.;
        if aebodsys='All system organ classes' then _levtxt='Any TEAE';
    %end;
   %else %do;
       _levtxt='no observations' ;
   %end;
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
*Get number of blanks for table if missings, to align 0 with all other numbers in table;
data all2;
    set all1 ;
    retain _t_11 - _t_16 0;
    array my(*) _t_1 - _t_6;
    if _n_=2 then do;
        do i=1 to 6;
            if find(my(i),'(')>0 then call symput(vname(my(i)),compress(put(find(my(i),'(')-3,8.)));
            else call symput(vname(my(i)),compress(put(find(my(i),'0')-1,8.)));
        end;
    END;
run;
*add zeros;
data all2;
    set all2;
    if _n_=1 then _levtxt="&pretext. TEAEs (&grade) occurring in >=&thres.% of the patients in either treatment arm by MedDRA PT (v. &meddrav.)";
   else do;
       _levtxt='  '||_levtxt;
   END;
   array my(*) _t_1 - _t_6;
    array myl(6) _temporary_ (&_t_1. &_t_2. &_t_3. &_t_4. &_t_5. &_t_6 );
    do i=1 to 6;
        if missing(my(i)) and _n_>1 then do;
            my(i)='0';
            do k=1 to myl(i);
                   my(i)=' '||trim(my(i));
            END;
        end;
    END;
RUN;


%m_rename(indata=all2, inarray=%str('_t_1', '_t_2', '_t_3', '_t_4', '_t_5', '_t_6'))

%printline(##Table %sysfunc(scan(&title.,2,' ')));

%m_itmtitle(mymeta=tl_meta,tableno=&tableno., itdata=&itdata.,title=&title.
,foot=&foot.
,foot1=&foot1.
, keepftn=N
);



*retrieve the data for any group;
data any0;
    set tlfmeta.&totds. end=eof;
    where  aebodsys='All system organ classes' and  upcase(_levtxt) in("ANY");
    if eof then _orderN=0;
    drop _t_3;
RUN;
data anyfl;
    set tlfmeta.&flds. end=eof;
    where  aebodsys='All system organ classes' and  upcase(_levtxt) in("ANY");
    if eof then _orderN=0;
RUN;
data anymzl;
    set tlfmeta.&mzlds. end=eof;
    where  aebodsys='All system organ classes' and  upcase(_levtxt) in("ANY");
    if eof then _orderN=0;
RUN;
proc sql noprint;
    create table any1 as select a.*, b._t_3,b._t_4
           from  any0 as a
                    left join anyfl(keep=_t_1 _t_2  _levtxt _ct1 rename=(_t_1=_t_3 _t_2=_t_4)) as b
                    on a._levtxt=b._levtxt and a._ct1=b._ct1;
    create table any2 as select a.*,b._t_5,b._t_6 from any1 as a
                left join  anymzl(keep=_t_1 _t_2 _levtxt _ct1 rename=(_t_1=_t_5 _t_2=_t_6)) as b
            on a._levtxt=b._levtxt and a._ct1=b._ct1;
QUIT;
data any3;
    set any2;
    if _orderN=0 then _levtxt="Any study %lowcase(&pretext.) TEAE";
    else                  _levtxt='                   '||_ct1;
    if _ct1='Grade 5' then _levtxt=trim(_levtxt)||" (death)" ;
RUN;

proc sql noprint;
    insert into any3 set _ordern=0.5,  _levtxt='  Worst CTCAE Grade      ' ;
QUIT;
proc sort data=any3;
    by _orderN;
RUN;
*Get number of blanks for table if missings, to align 0 with all other numbers in table;
data any4;
    set any3;
    retain _t_11 - _t_16 0;
    array my(*) _t_1 - _t_6;
    if _n_=1 then do;
        do i=1 to 6;
            if find(my(i),'(')>0 then call symput(vname(my(i)),compress(put(find(my(i),'(')-3,8.)));
            else call symput(vname(my(i)),compress(put(find(my(i),'0')-1,8.)));
        end;
    END;
run;


%_assign_meddralabel(
inlib = work
, inds  = any3
, invar = _levtxt
)
*fill 0 in first part;
data out;
    set any4(in =a) all2;
    array my(*) _t_1 - _t_6;
    array myl(6) _temporary_ (&_t_1. &_t_2. &_t_3. &_t_4. &_t_5. &_t_6 );
    if a then do;
        do i=1 to 6;
            if missing(my(i)) and _n_~in(2) then do;
                my(i)='0';
                do k=1 to myl(i);
                       my(i)=' '||trim(my(i));
                END;
            end;
        END;
    end;
RUN;

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
    data   = out
  , var    = _levtxt ("&_mytot." _t_1 _t_2) ("&_myfl." _t_3 _t_4) ("&_mymzl." _t_5 _t_6)
  , maxlen = 17
  , label  = no
  ,split='@'
)

proc datasets lib=work kill memtype=data nolist;
quit;
%mend ;
*copanlisib;
*caution!;
%aegrade(totds=t_14_3_1_2_adae_teae1_1,
        flds=t_14_3_1_2_adae_teae_subg1_1,
        mzlds=t_14_3_1_2_adae_teae_subg1_2,
        where=
        %str( where ~missing(aebodsys) and  _levtxt~in("ANY") and (_ct1='Total' or aebodsys='Number (%) of subjects')),
        thres=1,
        tableno=1,
        grade=%str(any grade),
        itdata=t_14_3_1_2_adae_teae1,
        title=%nrstr(Table 10-10 Incidence of Copanlisib/placebo-related TEAEs by MedDRA PT (SAF)),
        foot=%nrbquote(CTCAE = Common Terminology Criteria for Adverse Events; FL = Follicular lymphoma; iNHL = Indolent NHL;
LPL = Lymphoplasmacytoid lymphoma; MedDRA = Medical Dictionary for Regulatory Activities; MZL = Marginal zone
lymphoma; N = Total number of patients (100%); n = Number of patients with event; NHL = Non-Hodgkin's lymphoma;
SAF = Safety analysis set; SLL = Small lymphocytic lymphoma; PT = Preferred term; TEAE = Treatment-emergent
adverse event; WM = Waldenstroem macroglobulinemia a. Number (%) of patients with the specified event starting or worsening
between start of treatment and 30 days after end of treatment. ),
        foot1=%nrbquote(Source: Table 14.3.1.2/1 and Table 14.3.1.2/3 ),
        pretext= Copanlisib/placebo-related

        );



*rituximab;;
%aegrade(totds=t_14_3_1_2_adae_teae1_2,
        flds=t_14_3_1_2_adae_teae_subg1_3,
        mzlds=t_14_3_1_2_adae_teae_subg1_4,
        where=
        %str( where ~missing(aebodsys) and  _levtxt~in("ANY") and (_ct1='Total' or aebodsys='Number (%) of subjects')),
        thres=1,
        tableno=2,
        grade=%str(any grade),
        itdata=t_14_3_1_2_adae_teae1,
        title=%nrstr(Table 10-11 Incidence of rituximab-related TEAEs by MedDRA PT (SAF)),
        pretext=Rituximab-related,

        foot=%nrbquote(CTCAE = Common Terminology Criteria for Adverse Events; FL = Follicular lymphoma; iNHL = Indolent NHL;
        LPL = Lymphoplasmacytoid lymphoma; MedDRA = Medical Dictionary for Regulatory Activities; MZL = Marginal zone
        lymphoma; N = Total number of patients (100%); n = Number of patients with event; NHL = Non-Hodgkin's lymphoma;
        SAF = Safety analysis set; SLL = Small lymphocytic lymphoma; PT = Preferred term; TEAE = Treatment-emergent
        adverse event; WM = Waldenstroem macroglobulinemia a. Number (%) of patients with the specified event starting or worsening
        between start of treatment and 30 days after end of treatment. ),

        foot1=%nrbquote(Source: Table 14.3.1.2/1 and Table 14.3.1.2/3 )
        );

******extra tables *******;
**copa related grade 3;
%aegrade(totds=t_14_3_1_2_adae_teae1_1,
        flds=t_14_3_1_2_adae_teae_subg1_1,
        mzlds=t_14_3_1_2_adae_teae_subg1_2,
        where=
        %str( where _ct1='Grade 3' and ~missing(aebodsys) ),
        thres=1,
        tableno=1,
        grade=%str(any grade),
        itdata=t_14_3_1_2_adae_teae1,
        title=%nrstr(Table 999-1 Most common copanlisib/placebo-related TEAEs of worst grade 3 occurring in >= &thres.% of patients (SAF)),
        foot=%nrbquote(CTCAE = Common Terminology Criteria for Adverse Events; FL = Follicular lymphoma; iNHL = Indolent NHL;
LPL = Lymphoplasmacytoid lymphoma; MedDRA = Medical Dictionary for Regulatory Activities; MZL = Marginal zone
lymphoma; N = Total number of patients (100%); n = Number of patients with event; NHL = Non-Hodgkin's lymphoma;
SAF = Safety analysis set; SLL = Small lymphocytic lymphoma; PT = Preferred term; TEAE = Treatment-emergent
adverse event; WM = Waldenstroem macroglobulinemia a. Number (%) of patients with the specified event starting or worsening
between start of treatment and 30 days after end of treatment. ),
        foot1=%nrbquote(Source: Table 14.3.1.2/1 and Table 14.3.1.2/3 ),
        pretext= Copanlisib/placebo-related

        );


**copa related grade 4;
%aegrade(totds=t_14_3_1_2_adae_teae1_1,
        flds=t_14_3_1_2_adae_teae_subg1_1,
        mzlds=t_14_3_1_2_adae_teae_subg1_2,
        where=
        %str( where _ct1='Grade 4' and ~missing(aebodsys) ),
        thres=1,
        tableno=1,
        grade=%str(any grade),
        itdata=t_14_3_1_2_adae_teae1,
        title=%nrstr(Table 999-2 Most common copanlisib/placebo-related TEAEs of worst grade 4 occurring in >= &thres.% of patients (SAF)),
        foot=%nrbquote(CTCAE = Common Terminology Criteria for Adverse Events; FL = Follicular lymphoma; iNHL = Indolent NHL;
LPL = Lymphoplasmacytoid lymphoma; MedDRA = Medical Dictionary for Regulatory Activities; MZL = Marginal zone
lymphoma; N = Total number of patients (100%); n = Number of patients with event; NHL = Non-Hodgkin's lymphoma;
SAF = Safety analysis set; SLL = Small lymphocytic lymphoma; PT = Preferred term; TEAE = Treatment-emergent
adverse event; WM = Waldenstroem macroglobulinemia a. Number (%) of patients with the specified event starting or worsening
between start of treatment and 30 days after end of treatment. ),
        foot1=%nrbquote(Source: Table 14.3.1.2/1 and Table 14.3.1.2/3 ),
        pretext= Copanlisib/placebo-related

        );


**copa related grade 5;
%aegrade(totds=t_14_3_1_2_adae_teae1_1,
        flds=t_14_3_1_2_adae_teae_subg1_1,
        mzlds=t_14_3_1_2_adae_teae_subg1_2,
        where=
        %str( where _ct1='Grade 5' and ~missing(aebodsys) ),
        thres=0.1,
        tableno=1,
        grade=%str(any grade),
        itdata=t_14_3_1_2_adae_teae1,
        title=%nrstr(Table 999-3 Most common copanlisib/placebo-related TEAEs of worst grade 5 occurring in >= &thres.% of patients (SAF)),
        foot=%nrbquote(CTCAE = Common Terminology Criteria for Adverse Events; FL = Follicular lymphoma; iNHL = Indolent NHL;
LPL = Lymphoplasmacytoid lymphoma; MedDRA = Medical Dictionary for Regulatory Activities; MZL = Marginal zone
lymphoma; N = Total number of patients (100%); n = Number of patients with event; NHL = Non-Hodgkin's lymphoma;
SAF = Safety analysis set; SLL = Small lymphocytic lymphoma; PT = Preferred term; TEAE = Treatment-emergent
adverse event; WM = Waldenstroem macroglobulinemia a. Number (%) of patients with the specified event starting or worsening
between start of treatment and 30 days after end of treatment. ),
        foot1=%nrbquote(Source: Table 14.3.1.2/1 and Table 14.3.1.2/3 ),
        pretext= Copanlisib/placebo-related

        );




*rituximab related grade 3;
%aegrade(totds=t_14_3_1_2_adae_teae1_2,
        flds=t_14_3_1_2_adae_teae_subg1_3,
        mzlds=t_14_3_1_2_adae_teae_subg1_4,
        where=
        %str( where _ct1='Grade 3' and ~missing(aebodsys) ),
        thres=1,
        tableno=2,
        grade=%str(any grade),
        itdata=t_14_3_1_2_adae_teae1,
        title=%nrstr(Table 999-4 Most common rituximab-related TEAEs of worst grade 3 occurring in >= &thres.% of patients (SAF)),
        pretext=Rituximab-related,

        foot=%nrbquote(CTCAE = Common Terminology Criteria for Adverse Events; FL = Follicular lymphoma; iNHL = Indolent NHL;
        LPL = Lymphoplasmacytoid lymphoma; MedDRA = Medical Dictionary for Regulatory Activities; MZL = Marginal zone
        lymphoma; N = Total number of patients (100%); n = Number of patients with event; NHL = Non-Hodgkin's lymphoma;
        SAF = Safety analysis set; SLL = Small lymphocytic lymphoma; PT = Preferred term; TEAE = Treatment-emergent
        adverse event; WM = Waldenstroem macroglobulinemia a. Number (%) of patients with the specified event starting or worsening
        between start of treatment and 30 days after end of treatment. ),

        foot1=%nrbquote(Source: Table 14.3.1.2/1 and Table 14.3.1.2/3 )
        );


*rituximab related grade 4;

%aegrade(totds=t_14_3_1_2_adae_teae1_2,
flds=t_14_3_1_2_adae_teae_subg1_3,
mzlds=t_14_3_1_2_adae_teae_subg1_4,
where=
%str( where _ct1='Grade 4' and ~missing(aebodsys) ),
thres=1,
tableno=2,
grade=%str(any grade),
itdata=t_14_3_1_2_adae_teae1,
title=%nrstr(Table 999-5 Most common rituximab-related TEAEs of worst grade 4 occurring in >= &thres.% of patients (SAF)),
pretext=Rituximab-related,

foot=%nrbquote(CTCAE = Common Terminology Criteria for Adverse Events; FL = Follicular lymphoma; iNHL = Indolent NHL;
LPL = Lymphoplasmacytoid lymphoma; MedDRA = Medical Dictionary for Regulatory Activities; MZL = Marginal zone
lymphoma; N = Total number of patients (100%); n = Number of patients with event; NHL = Non-Hodgkin's lymphoma;
SAF = Safety analysis set; SLL = Small lymphocytic lymphoma; PT = Preferred term; TEAE = Treatment-emergent
adverse event; WM = Waldenstroem macroglobulinemia a. Number (%) of patients with the specified event starting or worsening
between start of treatment and 30 days after end of treatment. ),

foot1=%nrbquote(Source: Table 14.3.1.2/1 and Table 14.3.1.2/3 )
);




*rituximab related grade 5;

%aegrade(totds=t_14_3_1_2_adae_teae1_2,
flds=t_14_3_1_2_adae_teae_subg1_3,
mzlds=t_14_3_1_2_adae_teae_subg1_4,
where=
%str( where _ct1='Grade 5' and ~missing(aebodsys) ),
thres=0.1,
tableno=2,
grade=%str(any grade),
itdata=t_14_3_1_2_adae_teae1,
title=%nrstr(Table 999-6 Most common rituximab-related TEAEs of worst grade 5 occurring in >= &thres.% of patients (SAF)),
pretext=Rituximab-related,

foot=%nrbquote(CTCAE = Common Terminology Criteria for Adverse Events; FL = Follicular lymphoma; iNHL = Indolent NHL;
LPL = Lymphoplasmacytoid lymphoma; MedDRA = Medical Dictionary for Regulatory Activities; MZL = Marginal zone
lymphoma; N = Total number of patients (100%); n = Number of patients with event; NHL = Non-Hodgkin's lymphoma;
SAF = Safety analysis set; SLL = Small lymphocytic lymphoma; PT = Preferred term; TEAE = Treatment-emergent
adverse event; WM = Waldenstroem macroglobulinemia a. Number (%) of patients with the specified event starting or worsening
between start of treatment and 30 days after end of treatment. ),

foot1=%nrbquote(Source: Table 14.3.1.2/1 and Table 14.3.1.2/3 )
);


