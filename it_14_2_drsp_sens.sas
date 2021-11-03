/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin’s lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_2_drsp_sens);
/*
 * Purpose          : Table 9 13 Time to deterioration in DRS-P of at least 3 points - Sensitivity analysis (FAS)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 26JUN2020
 * Reference prog   :
 ******************************************************************************/

data sen;
    set tlfmeta.t_14_2_adtte_drspd_sa_1;
    format text $200.;

    if _orderN=1 then do;
        text='Number (%) of patients';
        call missing(of ttt:);
    end;
    else If _orderN=2 then text='  With event';
    else If _orderN=3 then text='  Censored';
    else if _orderN=4 then do;
        Text="Time to deterioration in DRS-P of at least 3 points (month)";
        call missing(of ttt:);
    end;

    else if _orderN=6 then delete;

    else if _orderN in(7,8) then do;
        text='  '||strip(translate(_label_,'','(','',')'));
    end;

    else if _orderN in(9,10) then do;
        delete;
    end;
    else if _orderN=11 then do;
        text="Deterioration-free rate at";
        _orderN=13.1;
        call missing(of ttt:);
    end;
    else if 13.1<_orderN<18 then do;
        text=cat('  ',substr(_name_,anydigit(_name_),find(_name_,'[')-anydigit(_name_)),'months [95% CI]');
    end;
    else if _orderN=18 then do;
        text='Hazard ratio [95% CI]';
        if find(_label_,'Progression')>0 then put "ERR" "OR: Check output" ;
    end;
    else if _orderN=19 then text='  One-sided p-value';
    else do;
        text=cat('  ',strip(_label_));
    END;


RUN;
%m_rename(
    indata  = sen
  , inarray = %str('ttt30' 'ttt31')
  , _split  = "@"
  , type    = 1
)

%printline(##Table 9-13);
%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = t_14_2_adtte_drspd_sa
  , title     = %nrbquote(Table 9-13 Time to deterioration in DRS-P of at least 3 points - Sensitivity analysis (FAS))
  , keepftn   = Y
  , foot      = %nrbquote(CI = Confidence interval; DRS-P = Disease-related symptoms - physical (subscale); FAS = Full analysis set; N = Total number of patients (100%); NHL = Non-Hodgkin's lymphoma; PD = Progressive disease
Note:)
  , foot1     =
  , evaltable =
)

*minor adaptions;
data _ittitles3;
    set _ittitles2;
    if variable="FOOTNOTE8" then do;
        value=catt(value, ' Source: Table 14.2.2.2/1');
    end;
RUN;
*put tit foot from adaptions;
%m_itmtitle(mymeta=tl_meta,tableno=1, itdata=t_14_2_adtte_drspd_sa,
evaltable=_ittitles3  )



%datalist(
    data   = sen
  , var    = text ttt30 ttt31
  , maxlen = 30
  , label  = no
  ,split='@'
)

%endprog(
    cleanWork       = y
  , cleanTitlesFoot = y
  , verbose         = Y
)
