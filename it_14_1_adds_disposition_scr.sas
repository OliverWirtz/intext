/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_1_adds_disposition_scr);
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
/* Changed by       : gghcj (Oliver Wirtz) / date: 11MAY2020
 * Reason           : finalised
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 02JUL2020
 * Reason           : added footnotes
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 03AUG2020
 * Reason           : adapted to meet final mock csr
 ******************************************************************************/

**retrieve source tables;
data all;
    retain _name_ _col4_ ;
    set tl_meta.t_14_1_adds_disposition_ove_1(in=a)
        tl_meta.t_14_1_adds_disposition_scr_1 (in=b);
    if a and _order_=2  then do;
        _name_='Enrolled (signed ICF)';

    END;
    else if b then do;
        if _order_=1 then _name_='Screening';
        else if _orderN>4 then do;
            _name_='      '||propcase(strip(_name_),'$');
        END;
        if _name_='      Primary reason' then delete;
         _col4_= _col2_;
    END;
    else delete;
RUN;

***this table will be merged manually with 8-1;
%printline(##Table 8-0)

%m_itmtitle(mymeta=tl_meta,tableno=1, itdata=t_14_1_adds_disposition_scr,title=Table 8-0 Patient disposition - Screening (all enrolled)
,foot=%nrbquote(ICF=Informed consent form; N=Total number of patients (100%); n=Number of patients with event Enrolled = informed consent
              Notes:
              Number of patients enrolled is the number of patients who signed informed consent.)
, foot1=%nrbquote(Source: Table 14.1.1/3 and Table 14.1.1/4  )
,keepftn=N
);

%insertOption(
    namevar   = _name_
  , align     =
  , width     = 25
  , other     =
  , charnum   = .
  , keep      = N
  , overwrite = Y
  , comment   = YES
)

%datalist(
    data   = all
  , var    = _name_ _col4_
  , maxlen = 50
  , label  = no
  ,split='@'
)

%endprog(
    cleanWork       = y
  , cleanTitlesFoot = y
  , verbose         = Y
)
