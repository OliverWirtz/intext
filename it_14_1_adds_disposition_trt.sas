/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_1_adds_disposition_trt);
/*
 * Purpose          : generate table 8.1 Patient Disposition from intext table specs
 * Programming Spec :
 * Validation Level : 1 - verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 09APR2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 02JUL2020
 * Reason           : finalised
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 03AUG2020
 * Reason           : adjusted order and table number
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 23SEP2020
 * Reason           : drop disp_: variables
 ******************************************************************************/

**retrieve source tables;
data all;
    retain _name_ _col1_ _col2_ ;

    set tlfmeta.t_14_1_adds_disposition_ove_1 (in=aa drop=disp_: )
        tl_meta.t_14_1_adds_disposition_tre_1 (in=a)
        tl_meta.t_14_1_adds_disposition_saf_1 (in=c)
        tl_meta.t_14_1_adds_disposition_act_1 (in=b)
        tl_meta.t_14_1_adds_disposition_sur_1 (in=d)
        ;
    where _order_>1;
    _myord=_n_;
    if aa then do;
        if _order_=5;
         _myord=0.8;
         _name_='Randomized/assigned to treatment';
    END;
    if a then do;
        if _order_=2 then _myord=0.9;
        if _order_=5 then _myord=13.1;
    END;
    if b then do;
        if _order_=2 then _myord=50.2;
    END;
    if c then do;
        if _order_=31 then _myord=19.2;
    END;
   if d then do;
       if  _order_=2 then _myord=65.2;
   END;
    name1=strip(propcase(_name_,'$'));
    if _myord>0.8 then _name_=substr(_name_,1,anyalpha(_name_)-1)||propcase(strip(_name_),'$');

run;

proc sql noprint;
    insert into all

           set _name_='Study Treatment',
                _myord=1
           set _name_='Safety Follow-up',
               _myord=31.1
           set _name_='Active Follow-up',
               _myord=50.1
            set _name_='Survival Follow-up',
    _myord=65.1;

QUIT;
proc sort data=all;
    by _myord;
RUN;
%m_rename(indata=all, inarray=%str('_col1_', '_col2_'),_split="@")

%printline(##Table 8-1)

%m_itmtitle(mymeta=tl_meta,tableno=1, itdata=t_14_1_adds_disposition_tre,title=%str(Table 8-1 Patient disposition (FAS))
,foot=%nrbquote(FAS = Full analysis set; N=Total number of patients (100%); n=Number of patients with event a. Treatment period: Reason other includes: b. Patients with no active-follow-up information in the eCRF
c. Patients with active follow-up information in the eCRF d. All patients were required to perform a safety follow-up visit per clinical study protocol (Section 16.1.1).)
, foot1=%nrbquote(Source: Table 14.1.1/3, Table 14.1.1/5, Table 14.1.1/6, Table 14.1.1/7 and Table 14.1.1/8  )
, keepftn=N);

%insertOption(
    namevar   = _name_
  , align     =
  , width     = 30
  , other     =
  , charnum   = .
  , keep      = N
  , overwrite = Y
  , comment   = YES
)

%datalist(
    data   = all
  , var    = _name_ _col1_ _col2_
  , maxlen = 60
  , label  = no
  ,split='@'
)

%endprog;
