/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_2_drsp_mzl_subgrp);
/*
 * Purpose          : Subgroup analysis of time to improvement/deterioration in DRS-P by histology according to investigator pathology (FAS)
 * Programming Spec :
 * Validation Level : 1 - Verificatioon by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 02JUL2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 04AUG2020
 * Reason           : changed layout
 ******************************************************************************/

data mzl;
    set tlfmeta.t_14_2_adtte_drspd_hist_1
        tlfmeta.t_14_2_adtte_drspd_hist_2
        tlfmeta.t_14_2_adtte_drspd_hist_3
        tlfmeta.t_14_2_adtte_drspd_hist_4
        tlfmeta.t_14_2_adtte_drspd_submzl_1 (in=a)
        tlfmeta.t_14_2_adtte_drspd_submzl_2 (in=a)
        tlfmeta.t_14_2_adtte_drspd_submzl_3 (in=a);
    format text vartxt  varl chck $200. ;
    label text='Variable@  Subgroup';
    where _ordern in(1,2,3,5,18);
    if ~missing(histgrpn) then text=put(histgrpn,z_hist.);
    if a then do;
        _order=((2)+histgr3n/10);
         text=put(histgr3n,z_mzlsgr.);
        text='  '||strip(text);
    end;
    else _order=histgrpn;

    if _ordern=1 then do;
        vartxt='n';
        varl='n';
    end;

    else if _ordern=2 then do;
        vartxt='n with events';
        varl='nev';
    end;

    else if _ordern=3 then do;
        vartxt='n censored';
        varl='cens';
    end;

    else if _ordern=5 then do;
        vartxt='Median (months)';
        varl='median';
    end;

    if _ordern=18 then do;
        vartxt='Hazard ratio@Estimate [95% CI]';
        varl='HR';
    end;
    else do;
        %_strip_num(invar=ttt30);
        %_strip_num(invar=ttt31);
    END;



    chck=translate(vlabel(ttt30),'@',' ');
    call symput('cop', translate(chck,'@','# '));

    chck=translate(vlabel(ttt31),'@',' ');
    call symput('pla',translate(chck,'@','# '));

RUN;
proc sort data=mzl;
    by _order text ;
RUN;
*cop;
proc transpose data=mzl out=_mzl ;
    by _order text ;
    var ttt30;
    id varl;
    idlabel vartxt;
RUN;
*pla;

proc transpose data=mzl out=_mzl1 prefix=pla_;
    by _order text ;
    var ttt31;
    id varl;
    idlabel vartxt;
RUN;
proc sql noprint;
    create table mzl1 as select a.*,b.pla_n,b.pla_nev,b.pla_cens,b.pla_median from _mzl as a left join _mzl1 as b
           on a.text=b.text and a._order=b._order order by _order;
QUIT;

%printline(##Table 9-23);
%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = t_14_2_adtte_drspd_hist
  , title     =%nrbquote(Table 9-23 Subgroup analysis of time to improvement in DRS-P by histology according to investigator pathology (FAS))
  ,keepftn=Y
  ,evaltable =
)


%datalist(
    data   = mzl1
  , var    = text ("&cop." n nev cens median ) ("&pla." pla_n pla_nev pla_cens pla_median ) HR
  , maxlen = 10
  , label  = no
)
%endprog;