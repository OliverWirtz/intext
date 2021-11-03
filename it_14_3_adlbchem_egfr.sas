/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_adlbchem_egfr);
/*
 * Purpose          : Table 10-34/10-35 Worst classification during study of renal/hepatic function-(eGFR) (SAF)
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

%macro egfr(data= , tabno=, Title=, foot1=);

proc sql noprint;
    select cat("Copanlisib/rituximab N=", count(subjidn)) into :_mycop from ads.adsl where saffn=1 and trt01an=30 ;
    select cat("Placebo/rituximab N=", count(subjidn)) into :_mypla from ads.adsl where saffn=1 and trt01an=31 ;

QUIT;
data egfr;
   set tlfmeta.&data._&Tabno.;
   format trt $100.;
   if trt01an=30 and _ordern=1 then trt="&_mycop.";
   if trt01an=31 and _ordern=7 then trt="&_mypla.";
RUN;
%printline(##Table %scan(&title.,2, ' '));
%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = &tabno.
  , itdata    = &data.
  , title     =&title.
  , keepftn   = N
  , foot      = %NRBQUOTE(eGFR = estimated glomerular filtration rate ; SAF = Safety analysis set Note: Only patients with valid values at both baseline and after start of treatment are included. )
  , foot1     = &foot1.
  , evaltable =
)
%insertOption(
    namevar   = trt _nwtxt
  , align     =
  , width     = 20
  , other     =
  , charnum   = .
  , keep      = Y
  , overwrite = Y
  , comment   = YES
)
*not all vars in second table;
proc sql noprint;
    select name into :names separated by ' ' from dictionary.columns where upcase(libname)='WORK' and
           upcase(memname)='EGFR' and substr(Upcase(name),1,5)='_V_1_' ;
QUIT;
%datalist(
    data   = egfr
  , var    = trt _nwtxt ("Baseline" &names.)
  , maxlen = 15
  , label  = no
)


%mend egfr;
%egfr(data=t_14_3_5_adlbchem_shift
    ,tabno=1
    ,title= %NRBQUOTE(Table 10-34 Worst classification during study of renal function-eGFR (SAF))
    ,foot1=%NRBQUOTE(Source: Table 14.3.4.2/1 )
    );

%egfr(data=t_14_3_5_adlbchem_shift
,tabno=3
,title= %NRBQUOTE(Table 10-35 Worst classification during study of hepatic function (SAF) )
,foot1=%NRBQUOTE(Source: Table 14.3.4.2/3 )
);

%endprog;