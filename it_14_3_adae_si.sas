/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_adae_si);
/*
 * Purpose          : Table 10-26 Incidence of TEAEs of special interest by MedDRA PT (SAF)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 07JUL2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 04AUG2020
 * Reason           : changd source
 ******************************************************************************/

*do sort (thres=0) in total iNHL for Copanlisib/PLacebo ;
%m_threshold(
        indata=t_14_3_1_5_adae_teae4_1
      , lib=tlfmeta
      , topvar=aebodsys
      , secvar=_ic_var1
      , outvar=_levtxt
      , renameto="TEAEs (any grade) by MedDRA PT (v. &meddrav.) "
      , renamevar=_levtxt
      , treat=_t_1 _t_2
      , datawhere=%str(where (_ct1='Total' and ~missing(aebodsys)) )
      , threshold=0
      , debug=N
  );
  data tot;
      set tlfmeta.t_14_3_1_5_adae_teae4_1(in=a where=(Aebodsys='All system organ classes'))
          sub__ic_var1_out;
      %_get_it_label(inds=tot,invar=_t_3, debug=n);
      if _levtxt="TEAEs (any grade) by MedDRA PT (v. 23.0)" then do;
          call missing(_t_1, _t_2);
          _thresperc=999;
      end;

      if a then do;
          if _ct1='Total' then do;
              _ordern=0 ;
              _levtxt='Any TEAE of special interest';
          end;
          else do;
             _levtxt=_ct1;
             if _ct1='Grade 1' then _levtxt="Worst CTCAE grade "||strip(_levtxt);
             else if _ct1='Grade 5' then _levtxt=strip(_levtxt)||" (death)";
             else _levtxt="                    "||strip(_levtxt);
          END;

      end;

      drop _t_3;

  RUN;
*retrieve subgroups and total number from subgroup;
data fl;
    set tlfmeta.t_14_3_1_5_adae_teae_subg1_1;
    %_get_it_label(inds=FL,invar=_t_3, debug=n);
    if Aebodsys='All system organ classes' and _ct1='Total' then _ordern=0 ;
    if _n_>1;
RUN;

data mzl;
    set tlfmeta.t_14_3_1_5_adae_teae_subg1_2;
    %_get_it_label(inds=MZL,invar=_t_3, debug=n);
    if Aebodsys='All system organ classes' and _ct1='Total' then _ordern=0 ;
    if _n_>1;
RUN;

*merge groups;
proc sql noprint;
    create table all0 as select a.*, b._t_3,b._t_4
           from  tot as a
                    left join fl(keep=_t_1 _t_2 aebodsys _levtxt _ct1 rename=(_t_1=_t_3 _t_2=_t_4)) as b
                    on (a.aebodsys=b.aebodsys and a._levtxt=b._levtxt and a._ct1=b._ct1)
                    or (a.Aebodsys='All system organ classes' and a.aebodsys=b.aebodsys and a._ct1=b._ct1);
    create table all1 as select a.*,b._t_5,b._t_6 from all0 as a
                left join  mzl(keep=_t_1 _t_2 aebodsys _levtxt _ct1 rename=(_t_1=_t_5 _t_2=_t_6)) as b
                on (a.aebodsys=b.aebodsys and a._levtxt=b._levtxt and a._ct1=b._ct1)
                or (a.Aebodsys='All system organ classes' and a.aebodsys=b.aebodsys and a._ct1=b._ct1) order by a._ordern;
QUIT;

data all2;
    set all1;
    array my(*) _t_1 - _t_6;
    do i=1 to 6;
        if missing(my(i)) then do;
            if i in (1,3,5) then my(i)=' 0';
            else my(i)='0';
        end;
    END;
RUN;

%m_rename(indata=all2, inarray=%str('_t_1', '_t_2', '_t_3', '_t_4', '_t_5', '_t_6'))

%printline(##Table 10-26)

%m_itmtitle(mymeta=tl_meta,tableno=1, itdata=t_14_3_1_5_adae_teae4
          ,title=%str(Table 10-26 Incidence of TEAEs of special interest by MedDRA PT (SAF) )
,foot=%nrbquote(CTCAE = Common Terminology Criteria for Adverse Events; FL = Follicular lymphoma; iNHL = Indolent
NHL; LPL = Lymphoplasmacytoid lymphoma; Max = Maximum; Min = Minimum; MZL = Marginal zone
lymphoma; N = Total number of patients (100%); n = Number of patients with event; NHL = Non-
Hodgkin's lymphoma; SAF = Safety analysis set; SLL = Small lymphocytic lymphoma; StD = Standard
deviation; TEAE = Treatment-emergent adverse event; TESAE = Treatment-emergent serious adverse
event; WM = Waldenstroem macroglobulinemia a. Number (%) of patients with the specified event starting or worsening between start of treatment and 30
days after end of treatment. )
, foot1=%nrbquote(Source: Table 14.3.1.5/8 and Table 14.3.1.5/9  )
,keepftn=N);

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
%endprog;
