/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_1_adcm_prior_ther_ov);
/*
 * Purpose          : Table 8-1ß Prior systemic anti-cancer therapy - Overview (FAS)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 25MAY2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 03JUL2020
 * Reason           : changed in dataset name
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 13AUG2020
 * Reason           : changed numbering
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 14AUG2020
 * Reason           : added subgroups as per updated mock csr
 ******************************************************************************/

*retrieve data and sort for any type ;
%m_threshold(
    indata    = t_14_1_adcm_type_sys_anti_c_1
  , lib       = tlfmeta
  , topvar    = _varl_
  , secvar    = _varl_
  , outvar    = _varl_
  , renameto  =
  , renamevar =
  , treat     = _cptog2
  , datawhere = %str(where _varl_='Any')
  , threshold = 0
  , debug     = N
);
*add prior ac drug;
data tot;
    set sub__varl__out tlfmeta.t_14_1_adcm_prior_anti_canc_1(in=b);

   if b then do;
       _cptog2=col1;
       _cptog3=col2;
   end;
   else do;
       text=propcase(put(cmscatn,_cmscat.),'$');
   END;
    drop _cptog1;
    n1=_n_; *add sorter variable;
RUN;

*prepare subgroups;
data fl(rename=(_cptog2=_cptog4 _cptog3=_cptog5 )) mzl(rename=(_cptog2=_cptog6 _cptog3=_cptog7 ));
    set tlfmeta.t_14_1_adcm_type_sys_anti_c_2(in=a)
        tlfmeta.t_14_1_adcm_prior_anti_canc_2(in=b);
    if a then do;
        if _varl_='Any';
        text=propcase(put(cmscatn,_cmscat.),'$');
    end;
    if b then do;
        _cptog2=col1;
        _cptog3=col2;
    END;
    drop _cptog1;
    if histgrpn=1 then output fl;
    if histgrpn=2 then output mzl;

RUN;


*merge;
proc sql noprint;
    create table all as select a.*, b._cptog4, b._cptog5 from tot(drop=col:) as a
           left join fl as b on a.text=b.text and a._posi_=b._posi_;
    create table all1 as select a.*, b._cptog6, b._cptog7 from all as a
    left join mzl as b on a.text=b.text and a._posi_=b._posi_ order by n1;
QUIT;

*get labels for spanning header and N in subgroups;
*get N in label for tratement groups of histology subgroups;
*Unfortunately analysis was not done in proper page groups;
%_get_total_n(pop = %str(fasfn=1));

*include new label and add freeline with text;
data all2;
    set all1;
    label _cptog4="&_myflcop."
    _cptog5="&_myflpla."
            _cptog6="&_mymzlcop."
            _cptog7="&_mymzlpla.";
RUN;

proc sql;
    insert into all2 set text="Type of therapy, n (%)", n1=0 ;
quit;

*fill empty cells with 0, simply hardcoded here ;
data all3;
    set all2;
   if n1=7 and cmiss(_cptog6, _cptog7)=2 then do;
    _cptog6='  0' ;
    _cptog7=' 0' ;
   end;
RUN;

proc sort data=all3;
    by n1;
RUN;
*remove 100% from total;
%m_rename(
    indata  = all3
  , inarray = %str('_cptog2', '_cptog3')
  , _split  = "@"
  , type=1
)
%printline(##Table 8-10);
%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = t_14_1_adcm_type_sys_anti_c
  , title     = %str(Table 8-10 Prior systemic anti-cancer therapy - Overview (FAS))
  , foot      =%nrbquote(FAS = Full analysis set; Max = Maximum, Min = Minimum; N = Total number of patients (100%%);
n = Number of patients with event; PD = Progressive disease; StD = Standard deviation;
a. Time between the start day of last course of systemic anti-cancer therapy and the day of confirmation of the most recent progression)
  , foot1     = %nrbquote(Source: Table 14.1.4/3, Table 14.1.4/5, Table 14.1.4/6 and Table 14.1.4/7)
  , keepftn=N
  , evaltable =
)

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
    data = all3
  , var  = text ("&_mytot." _cptog2 _cptog3) ("&_myfl." _cptog4 _cptog5) ("&_mymzl." _cptog6 _cptog7)
  ,maxlen= 15
  ,label=n
)
%endprog;