/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_2_drsp_subgrp);
/*
 * Purpose          : Table 9-30 Other subgroup analysis of time to deterioration in DRS-P by independent assessment (FAS)

 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 02JUL2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 04AUG2020
 * Reason           : stripped brackets
 ******************************************************************************/

%macro drsp(case=drspd, title=, table=);
data main;
    set tlfmeta.t_14_2_adtte_&case._nhlhist_1      (in=a)     /*FL*/
        tlfmeta.t_14_2_adtte_&case._nhlhist_2      (in=a)     /*other iNHL*/
        tlfmeta.t_14_2_adtte_&case._entrycri_1    (in=b)     /*entry crit*/
        tlfmeta.t_14_2_adtte_&case._entrycri_2    (in=b)
        tlfmeta.t_14_2_adtte_&case._bulkydis_1     (in=c)     /*bulky*/
        tlfmeta.t_14_2_adtte_&case._bulkydis_2     (in=c)
        tlfmeta.t_14_2_adtte_&case._pi3k_1         (in=d)     /*pi3k*/
        tlfmeta.t_14_2_adtte_&case._pi3k_2         (in=d)
        tlfmeta.t_14_2_adtte_&case._cntygr1_1      (in=e)/*country 1*/
        tlfmeta.t_14_2_adtte_&case._cntygr1_2      (in=e)
        tlfmeta.t_14_2_adtte_&case._cntygr1_3      (in=e)
        tlfmeta.t_14_2_adtte_&case._cntygr2_1      (in=f)/*country 2*/
        tlfmeta.t_14_2_adtte_&case._cntygr2_2      (in=f)
        tlfmeta.t_14_2_adtte_&case._cntygr2_3      (in=f)
        tlfmeta.t_14_2_adtte_&case._agegrp_1       (in=g)/*age*/
        tlfmeta.t_14_2_adtte_&case._agegrp_2       (in=g)
        tlfmeta.t_14_2_adtte_&case._ecog_1         (in=h)/*ecog*/
        tlfmeta.t_14_2_adtte_&case._ecog_2         (in=h)
        tlfmeta.t_14_2_adtte_&case._ecog_3         (in=h)
        tlfmeta.t_14_2_adtte_&case._race_1         (in=k)/*race*/
        tlfmeta.t_14_2_adtte_&case._race_2         (in=k)
        tlfmeta.t_14_2_adtte_&case._race_3         (in=k)
        tlfmeta.t_14_2_adtte_&case._race_4         (in=k)
        tlfmeta.t_14_2_adtte_&case._race_5         (in=k)
        tlfmeta.t_14_2_adtte_&case._ethnic_1       (in=l)/*Ethnicity*/
        tlfmeta.t_14_2_adtte_&case._ethnic_2       (in=l)
        tlfmeta.t_14_2_adtte_&case._ethnic_3       (in=l)


     ;

    where _orderN in(1,2,3,5,18);
    format text vartxt grptext $200.;
    label grptext="Variable@  Subgroup";
    if a then do;
        grptext=put(HISTGR2N,z_inhlgr.);
        grptxtn=10;
        subtxtn=HISTGR2N;
    end;
    else if b then do;
        grptext=put(strat2vn,z_st2v.);
        grptxtn=20;
        subtxtn=strat2vn;
    end;
    else if c then do;
        grptext=put(strat3vn,z_st3v.);
        grptxtn=30;
        subtxtn=strat3vn;
    end;
    else if d then do;
        grptext=put(strat4vn,z_st4v.);
        grptxtn=40;
        subtxtn=strat4vn;
    end;
    else if e then do;
        grptext=put(CNTYGR1N,z_cntry.);
        grptxtn=50;
        subtxtn=CNTYGR1N;
    end;
    else if f then do;
        grptext=put(CNTYGR2N,z_cntry.);
        grptxtn=60;
        subtxtn=CNTYGR2N;
    end;
    else if g then do;
        grptext=put(AGEGR01N,z_agegrp.);
        grptxtn=70;
        subtxtn=AGEGR01N;
    end;
    else if h then do;
        grptext=propcase(put(BASECOGN,xqsecog.),'$');
        grptxtn=80;
        subtxtn=BASECOGN;
    end;

    else if k then do;
        grptext=propcase(put(racen,race.),'$');
        grptxtn=100;
        subtxtn=racen;
    end;
    else if l then do;
        grptext=propcase(put(ethnicn,ethnic.),'$');
        grptxtn=110;
        subtxtn=ethnicn;
    end;



    grptext='  '||strip(grptext);

    if _orderN=1 then do;
        text='n';
        vartxt='N';
    end;
    else if _orderN=2 then do;
        text='n with events';
        vartxt='nev';
    end;
    else if _orderN=3 then do;
        text='n censored';
        vartxt='cens';
    end;
    else if _orderN=5 then do;
        text='Median (months)';
        vartxt='median';
    end;
    if _orderN=18 then do;
        text='Hazard ratio@Estimate [95% CI]';
        vartxt='HR';
    end;
    else do;
        %_strip_num(invar=ttt30);
        %_strip_num(invar=ttt31);
    END;
    call symput('cop', translate(vlabel(ttt30),'@','#'));
    call symput('pla',translate(vlabel(ttt31),'@','#'));

RUN;

proc sort data=main;
    by grptxtn subtxtn grptext ;
RUN;
*transpose all but median;
proc transpose data=main out=_main;
    by grptxtn subtxtn grptext  ;
    var ttt30;
    id vartxt;
    idlabel text;
RUN;
proc transpose data=main(where=(_orderN not in(18))) prefix=pla_ out=_main1;
    by grptxtn subtxtn grptext ;
    var ttt31;
    id vartxt;
    idlabel text;
RUN;
proc sql noprint;
    create table _main2 as select a.*,b.pla_n,b.pla_nev, b.pla_cens,b.pla_median from _main as a left join _main1 as b on
            a.grptxtn=b.grptxtn and a.subtxtn =b.subtxtn and a.grptext =b.grptext ;
QUIT;
/**merge median;*/
/*proc sql noprint;*/
/*    create table all0 as select a.*,b.ttt30, b.ttt31 from _main2 as a left join main(where=(_orderN=5)) as b on*/
/*           a.grptxtn=b.grptxtn and a.subtxtn=b.subtxtn and a.grptext=b.grptext ;*/
/*QUIT;*/

*final formatting;
*add free lines with variable descrption;
proc sql noprint;
    insert into _main2/*all0*/
           set grptxtn=9,
               grptext='NHL histology (FL vs. other iNHL histology)'
           set grptxtn=19,
               grptext='Entry criterion '
           set grptxtn=29,
               grptext='Presence of bulky disease '
           set grptxtn=39,
               grptext='Previous treatment with PI3K inhibitors'
           set grptxtn=49,
               grptext='Geographic regions 1 '
           set grptxtn=59,
               grptext='Geographic regions 2'
           set grptxtn=69,
               grptext='Age group '
           set grptxtn=79,
               grptext='ECOG performance status '

           set grptxtn=99,
               grptext='Race'
           set grptxtn=109,
               grptext='Ethnicity'

;
QUIT;

proc sort data=_main2;
    by grptxtn ;
RUN;

%printline(&table.);
%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = t_14_2_adtte_&case._nhlhist
  , title     =&title.
  ,keepftn=N
  ,evaltable =
)

%insertOption(
    namevar   = HR grptext
  , align     =
  , width     = 25
  , other     =
  , charnum   = .
  , keep      = N
  , overwrite = Y
  , comment   = YES
)
%datalist(
    data   = _main2
  , var    = grptext ("&cop" N nev cens median) ("&pla" pla_N pla_nev pla_cens pla_median) HR
  , maxlen = 10
  , label  = no
)


%mend drsp;
%drsp(case=drspd
    , title=%str(Table 9-28 Other subgroup analysis of time to deterioration in DRS-P by investigator pathology (FAS) )
    , table=%str(##Table 9-28))
%drsp(case=drspi
, title=%str(Table 9-31 Other subgroup analysis of time to improvement in DRS-P by investigator pathology (FAS) )
, table=%str(##Table 9-31))
%endprog;

