/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_adae_discont);
/*
 * Purpose          : copa/ritux disconituation
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 06JUL2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 31JUL2020
 * Reason           : changed source table
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 04AUG2020
 * Reason           : changed numbering
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 18AUG2020
 * Reason           : added infusion related TEAE
 ******************************************************************************/

%macro aegrade(
       totds=t_14_3_1_1_adae_teae_1_1,
       where=%str(where _ct1='Total' and ~missing(aebodsys)),
       grade=%str(any grade),
       tableno=1,
       itdata=t_14_3_1_1_adae_teae_1_,
       thres=1,
       _levtxt=%str(Any TEAE leading to permanent copanlisib/placebo discontinuation),
       rename=%nrstr("TEAEs (any grade) occurring in >=&thres.% of patients in either treatment arm by MedDRA PT (v. &meddrav.) "),
       title=%nrstr(Incidence of TEAEs by worst Grade occurring in >=&thres.% of the patients in either treatment arm by MedDRA PT (safety analysis set))
       ,foot=
       ,foot1=
       );

*do thresholds in total iNHL for Copanlisib ;
%m_threshold(
        indata=&totds.
      , lib=tlfmeta
      , topvar=aebodsys
      , secvar=_ic_var1
      , outvar=_levtxt
      , renameto="TEAEs (any grade) occurring in >=&thres.% of patients in either treatment arm by MedDRA PT (v. &meddrav.) "
      , renamevar=_levtxt
      , treat=_t_1 _t_2
      , datawhere=&where.
      , threshold=&thres.
      , debug=N
  );
  data tot;
      set sub__ic_var1_out;
      %_get_it_label(inds=tot,invar=_t_3, debug=n);
      if _levtxt="TEAEs (any grade) occurring in >=&thres.% of patients in either treatment arm by MedDRA PT (v. &meddrav.) " then do;
          call missing(_t_1, _t_2);
          _thresperc=999;
      end;
      drop _t_3;
  RUN;

  %_assign_meddralabel(
  inlib = work
  , inds  = tot
  , invar = _levtxt
  )

proc sort data= tot;
    by descending _thresperc _levtxt;
RUN;
%printline(##Table %scan(&title., 2,' '));
%m_itmtitle(mymeta=tl_meta,tableno=&tableno., itdata=&itdata.,title=&title.
,foot= &foot.
,foot1= &foot1.
,keepftn=N
);


*retrieve the data for any group;
data any0;
    set tlfmeta.&totds. end=eof;
    where  aebodsys='All system organ classes' and  upcase(_levtxt) in("ANY");
    if eof then _orderN=0;

    drop _t_3;
RUN;

data any3;
    set any0;
    if _orderN=0 then _levtxt="&_levtxt.";
    else if _ct1='Grade 1' then _levtxt='Worst CTCAE grade '||compress(_ct1);
    else                        _levtxt='                  '||compress(_ct1);
    if _ct1='Grade 5' then _levtxt=trim(_levtxt)||" (death)" ;
RUN;
proc sort data=any3;
    by _orderN;
RUN;

data out;
    set any3 tot;
RUN;
%m_rename(
    indata  = out
  , inarray = %str('_t_1', '_t_2')
  , _split  = "@"
  , type    = 0
)

%insertOption(
    namevar   = _levtxt
  , align     =
  , width     = 40
  , other     =
  , charnum   = .
  , keep      = N
  , overwrite = Y
  , comment   = YES
)

%datalist(
    data   = out
  , var    = _levtxt _t_1 _t_2
  , maxlen = 40
  , label  = no
  ,split='@'
)

/*proc datasets lib=work kill memtype=data nolist;*/
/*quit;*/
%mend ;

*copanlisib;
*caution!;

*Discontinuation cop;
%aegrade(totds=t_14_3_1_3_adae_teae1_1,
    where=%str(where _ct1='Total' and ~missing(aebodsys)),
    grade=%str(any grade),
    tableno=1,
    itdata=t_14_3_1_3_adae_teae1,
    thres=2,
    _levtxt=%str(Any TEAE leading to permanent discontinuation of copanlisib/placebo),
    title=%nrstr(Table 10-20 Incidence of TEAEs leading to permanent copanlisib/placebo discontinuation by MedDRA PT (SAF) )
    ,foot=%nrbquote(FL = Follicular lymphoma; iNHL = Indolent NHL; LPL = Lymphoplasmacytoid lymphoma; MedDRA = Medical Dictionary for Regulatory Activities; MZL = Marginal zone lymphoma; N = Total number of patients (100%); n =
Number of patients with event; NHL = Non-Hodgkin%str(%')s lymphoma; SAF = Safety analysis set; SLL = Small lymphocytic lymphoma; PT = Preferred term; TESAE = Treatment-emergent serious adverse event;
WM = Waldenstroem macroglobulinemia a. Number (%) of patients with the specified event starting or worsening between start of treatment and 30 days
after end of treatment. CTCAE version 4.03.  )
    ,foot1=%nrbquote(Source: Table 14.3.1.3/1 )
);

   *Discontinuation rit;
%aegrade(totds=t_14_3_1_3_adae_teae1_2,
    where=%str(where _ct1='Total' and ~missing(aebodsys)),
    grade=%str(any grade),
    tableno=2,
    itdata=t_14_3_1_3_adae_teae1,
    thres=1,
    _levtxt=%str(Any TEAE leading to permanent discontinuation of rituximab),
    title=%nrstr(Table 10-21 Incidence of TEAEs leading to permanent rituximab discontinuation by MedDRA PT (SAF) )
   , foot=%nrbquote(FL = Follicular lymphoma; iNHL = Indolent NHL; LPL = Lymphoplasmacytoid lymphoma; MedDRA = Medical Dictionary for Regulatory Activities; MZL = Marginal zone lymphoma; N = Total number of patients (100%); n =
    Number of patients with event; NHL = Non-Hodgkin%str(%')s lymphoma; SAF = Safety analysis set; SLL = Small lymphocytic lymphoma; PT = Preferred term; TESAE = Treatment-emergent serious adverse event;
    WM = Waldenstroem macroglobulinemia a. Number (%) of patients with the specified event starting or worsening between start of treatment and 30 days
    after end of treatment. CTCAE version 4.03. )
    ,foot1=%nrbquote(Source: Table 14.3.1.3/2 )
   );


   *Interruption cop;
%aegrade(totds=t_14_3_1_3_adae_teae1_3,
    where=%str(where _ct1='Total' and ~missing(aebodsys)),
    grade=%str(any grade),
    tableno=3,
    itdata=t_14_3_1_3_adae_teae1,
    thres=1,
    _levtxt=%str(Any TEAE leading to interruption of copanlisib/placebo),
    title=%nrstr(Table 10-22 Incidence of TEAEs leading to interruption of copanlisib/placebo by MedDRA PT (SAF) )
    , foot=%nrbquote(FL = Follicular lymphoma; iNHL = Indolent NHL; LPL = Lymphoplasmacytoid lymphoma; MedDRA = Medical Dictionary for Regulatory Activities; MZL = Marginal zone lymphoma; N = Total number of patients (100%); n =
    Number of patients with event; NHL = Non-Hodgkin%str(%')s lymphoma; SAF = Safety analysis set; SLL = Small lymphocytic lymphoma; PT = Preferred term; TESAE = Treatment-emergent serious adverse event;
    WM = Waldenstroem macroglobulinemia a. Number (%) of patients with the specified event starting or worsening between start of treatment and 30 days
    after end of treatment. CTCAE version 4.03. )
    ,foot1=%nrbquote(Source: Table 14.3.1.3/2 )
   );

    *Interruption rit;
%aegrade(totds=t_14_3_1_3_adae_teae1_4,
    where=%str(where _ct1='Total' and ~missing(aebodsys)),
    grade=%str(any grade),
    tableno=4,
    itdata=t_14_3_1_3_adae_teae1,
    thres=1,
    _levtxt=%str(Any TEAE leading to interruption of rituximab),
    title=%nrstr(Table 10-23 Incidence of TEAEs leading to interruption of rituximab by MedDRA PT (SAF) )
    , foot=%nrbquote(FL = Follicular lymphoma; iNHL = Indolent NHL; LPL = Lymphoplasmacytoid lymphoma; MedDRA = Medical Dictionary for Regulatory Activities; MZL = Marginal zone lymphoma; N = Total number of patients (100%); n =
    Number of patients with event; NHL = Non-Hodgkin%str(%')s lymphoma; SAF = Safety analysis set; SLL = Small lymphocytic lymphoma; PT = Preferred term; TESAE = Treatment-emergent serious adverse event;
    WM = Waldenstroem macroglobulinemia a. Number (%) of patients with the specified event starting or worsening between start of treatment and 30 days
    after end of treatment. CTCAE version 4.03. )
    ,foot1=%nrbquote(Source: Table 14.3.1.3/4 )
    );

*reduction cop (no rit needed);
%aegrade(totds=t_14_3_1_3_adae_teae1_5,
    where=%str(where _ct1='Total' and ~missing(aebodsys)),
    grade=%str(any grade),
    tableno=5,
    itdata=t_14_3_1_3_adae_teae1,
    thres=1,
    _levtxt=%str(Any TEAE leading to dose reduction of copanlisib/placebo),
    title=%nrstr(Table 10-24 Incidence of TEAEs leading to dose reduction of copanlisib/placebo by MedDRA PT (SAF) )
    , foot=%nrbquote(FL = Follicular lymphoma; iNHL = Indolent NHL; LPL = Lymphoplasmacytoid lymphoma; MedDRA = Medical Dictionary for Regulatory Activities; MZL = Marginal zone lymphoma; N = Total number of patients (100%); n =
    Number of patients with event; NHL = Non-Hodgkin%str(%')s lymphoma; SAF = Safety analysis set; SLL = Small lymphocytic lymphoma; PT = Preferred term; TESAE = Treatment-emergent serious adverse event;
    WM = Waldenstroem macroglobulinemia a. Number (%) of patients with the specified event starting or worsening between start of treatment and 30 days
    after end of treatment. CTCAE version 4.03. )
    ,foot1=%nrbquote(Source: Table 14.3.1.3/5 )
    );

*incidence of infusion related TEAE;
%aegrade(totds=t_14_3_1_5_adae_teae_inf_1,
    where=%str(where _ct1='Total' and ~missing(aebodsys)),
    grade=%str(any grade),
    tableno=1,
    itdata=t_14_3_1_5_adae_teae_inf,
    thres=1,
    _levtxt=%str(Any infusion-related TEAE),
    title=%nrstr(Table 10-25 Incidence of infusion-related TEAEs by MedDRA PT (SAF) )
    , foot=%nrbquote(FL = Follicular lymphoma; iNHL = Indolent NHL; LPL = Lymphoplasmacytoid lymphoma; MedDRA = Medical Dictionary for Regulatory Activities; MZL = Marginal zone lymphoma; N = Total number of patients (100%); n =
    Number of patients with event; NHL = Non-Hodgkin%str(%')s lymphoma; SAF = Safety analysis set; SLL = Small lymphocytic lymphoma; PT = Preferred term; TESAE = Treatment-emergent serious adverse event;
    WM = Waldenstroem macroglobulinemia a. Number (%) of patients with the specified event starting or worsening between start of treatment and 30 days
    after end of treatment. CTCAE version 4.03. )
    ,foot1=%nrbquote(Source: Table 14.3.1.3/x )
    );

%endprog;
