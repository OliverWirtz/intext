/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_teae_perc_point_higher);
/*
 * Purpose          : extra table for MW
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 13AUG2020
 * Reference prog   :
 ******************************************************************************/
*retrieve data for iNHL;
*strip numbers from text ;
%let thres=1;
data ae;
    set tlfmeta.t_14_3_1_1_adae_teae1_1;
    where (_levtxt not in ('Any') and _ct1='Total') or ~missing(tlf_title);
    format cop pla  8.1;
    array trt(2) _t_1 _t_2;
    array trtn(2) cop pla;
    do i=1 to 2;
        if countw(trt(i))>1 then do;
            *xxx ( xxx.xx%);
            *compress text xxx(xxx.xx%), with ( as delimiter you get xxx.xx%) as second word. Use then % as delimiter you get xxx.xx as first word.;
            trtn(i)=input(scan(scan(compress(trt(i)),2,'('),1,'%'),8.1);
        end;
        else if trt(i)='0' then trtn(i)=0;
    end;
    if nmiss(cop, pla)=0 then do;
        if cop>=pla+&thres. then output;
    end;
    else if missing(_levtxt) then output;

RUN;


*do descending sorting;
    %m_threshold(
            indata=ae
          , lib=work
          , topvar=aebodsys
          , secvar=_ic_var1
          , outvar=_levtxt
          , renameto=
          , renamevar=
          , treat=_t_1 _t_2
          , datawhere=
          , threshold=0
          , debug=Y
      );
      data tot;
          set sub__ic_var1_out;
          %_get_it_label(inds=tot,invar=_t_3, debug=n);
          if ~missing(_levtxt);
          drop _t_3;
      RUN;


    data fl;
        set tlfmeta.t_14_3_1_1_adae_teae_subg1_1;
        where _levtxt not in (' ','ANY');
        %_get_it_label(inds=FL,invar=_t_3, debug=n);


    RUN;

    data mzl;
        set  tlfmeta.t_14_3_1_1_adae_teae_subg1_2;
  where _levtxt not in (' ','ANY');

  %_get_it_label(inds=MZL,invar=_t_3, debug=n);

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
        by descending _thresperc _levtxt;
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
       label _levtxt='MedDRA PT ';
           _levtxt='  '||_levtxt;

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


    %m_rename(indata=all2,type=0, inarray=%str('_t_1', '_t_2', '_t_3', '_t_4', '_t_5', '_t_6'))

    %printline(##Help Table 999-0 );

    %m_itmtitle(mymeta=tl_meta,tableno=1, itdata=t_14_3_1_1_adae_teae1
              ,title=%str(Most common TEAE by MedDRA PT (any grade) reported with a >= &thres.
 percentage point higher incidence in the copanlsib/rituximab arm compared to the placebo/rituximab arm of
 the iNHL population (SAF))
    ,foot=%str( )
    ,foot1=%str( )
    , keepftn=N
    );


%symdel thres;



%_assign_meddralabel(
inlib = work
, inds  = all2
, invar = _levtxt
)

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