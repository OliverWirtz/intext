%MACRO m_threshold(
   indata=
   ,lib=tempdata
  , topvar=
  , secvar=_ic_var1
  , outvar=_levtxt
  , renameto=%str(Any TEAE)
  , renamevar=AEBODSYS
  , treat=_t_1
  , datawhere=%str(where _ct1 in(.,7))
  , threshold=1
  , threstyp=percent
  , debug=N)
/ DES = 'to re-arrange AE/MH/CM tables for intext';
/*******************************************************************************
 * Bayer AG
 * Macro rely on: ###choose: TOSCA, initstudy, GMS, GDD, pure SAS###
 *******************************************************************************
 * Purpose          : cut input table by pre-defined threshold and sort by descending target
 * Programming Spec :
 * Validation Level : 1 - Validation by review
 * Parameters       :
 *                    indata : dataset to apply threshold
 *                    lib : librarry
 *                    tovar : first level
 *                    secvar : second level
 *                    outvar : variable in output (text variable, normally)
 *                    renameto: string to be put into first observation of variable renamevar
 *                    renamevar: variable, that needs different ext in first record
 *                    treat: variable or string of variables to apply the threshold on. first variable is used to finally apply the descending sort
 *                    datawhere: where statement to be applied when source data is read in
 *                    threshold: threshold in %, records >= threshold are kept
 *                    debug: If set to Y all intermediate datasets are kept in workl
 * SAS Version      : HP-UX 9.2
 *******************************************************************************
 * Preconditions    :
 *     Macrovar. needed:
 *     Datasets  needed:
 *     Ext.Prg/Mac used:
 * Postconditions   :
 *     Macrovar created:
 *     Output   created:
 *     Datasets created:
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 09NOV2018
 *******************************************************************************
 * Change History   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 06MAY2020
 * Reason           : ###Reason###
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 08MAY2020
 * Reason           : included some code to catch empty soc dataset (happens often depending on input data )
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 12MAY2020
 * Reason           : implemented code to allow for >= x% of _either_ group
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 14MAY2020
 * Reason           : added sort order by first variable in treat
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 25JUN2020
 * Reason           : included option to use counts instead of percentages
 ******************************************************************************/

 * Examples         :
   %*threshold(
 * data=t_14_3_adae_worst_ctcae_1
 * , topvar=AEBODSYS
 * , secvar=_ic_var1
 * , outvar=_levtxt
 * , renamefrom=%str(All system organ classes)
 * , renameto=%str(Any TEAE)
 * , renamevar=AEBODSYS
 * , treat=_t_1
 * , datawhere=%str(where _ct1 in(.,7))
 * , threshold=1
 * , debug=N
 * );
 * %*threshold(
 *           data=t_14_1_3_admh_summary_1
 *           , topvar=MHBODSYS
 *           , secvar=mhhlt
 *           , treat=_t_7
 *           , datawhere=%str(where missing(mhhlt) or ~missing(mhdecod) )
 *           , threshold=1
 *           );

 * %*threshold(
 *           data=t_14_1_4_adcm_med_1
 *           , topvar=_ic_var1
 *           , secvar=_ic_var2
 *           , treat=_t_7
 *           , datawhere=%str()
 *           , threshold=1
 *           );
 ******************************************************************************/;



    %LOCAL macro mversion _starttime macro_parameter_error;
    %LET macro    = &sysmacroname.;
    %LET mversion = 1.0;

    %spro_check_param(name=lib, type=LIBRARY)
    %spro_check_param(name=indata, type=DATA)
    %spro_check_param(name=topvar, type=VARIABLE)
    %spro_check_param(name=secvar, type=VARIABLE)
    %spro_check_param(name=outvar, type=VARIABLE)
    %spro_check_param(name=treat, type=VARIABLE)
    %spro_check_param(name=threshold, type=NUMBER)


    %IF (%QUOTE(&macro_parameter_error.) EQ %STR(1)) %THEN %RETURN;

    %LET _starttime = %SYSFUNC(datetime());
    %log(
            INFO
          , Version &mversion started
          , addDateTime = Y
          , messageHint = BEGIN)

    %LOCAL l_opts l_notes;
    %LET l_notes = %SYSFUNC(getoption(notes));

    %LET l_opts = %SYSFUNC(getoption(source))
                  %SYSFUNC(getoption(notes))
                  %SYSFUNC(getoption(fmterr))
    ;

    OPTIONS NONOTES NOSOURCE NOFMTERR;


    data _tmp0 _ptout _socout _anygrp;
        set &lib..&indata. end=eof;
        retain _flag_for_soc 0;
        &datawhere. ;
        *do renaming of top any group, if requested;
        array treatarr(*) &treat.;
        drop i;
        %if %sysevalf(%superq(renameto)=,boolean)=0 %then %do;
          if _n_=1 then do;
               &topvar.=&renameto;
               &outvar.=&renameto;
               &renamevar.=&renameto;
               _anygrp=1;
               output _anygrp;
           END;
        %END;
        %else %do;
            if _n_=1 then do;
               _anygrp=1;
               output _anygrp;
            END;
        %END;
        *preset percentages to 0;
        _thresperc=0;
        *retrieve data percentages as max of all defined variables;
        do i=1 to hbound(treatarr);
            %if %lowcase(&threstyp.)=%str(percent) %then %do;
                if index(treatarr(i),'(')>0 then do;
                    _thresperc=max(_thresperc,input(compress(substr(treatarr(i),index(treatarr(i),'(')+1,index(treatarr(i),'%')-1-index(treatarr(i),'('))),best.));
                    if i=1 then do;
                        _thresperc_sort=_thresperc;
                    end;
                end;
            %end;
            %else %if %lowcase(&threstyp.)=%str(count) %then %do;
                if anydigit(treatarr(i))>0 then do;
                    _thresperc=scan(treatarr(i),1);
                    if i=1 then do;
                        _thresperc_sort=_thresperc;
                    end;
                end;
            %end;
        end;
        *input(compress(substr(&treat.,index(&treat.,'(')+1,index(&treat.,'%')-1-index(&treat.,'('))),best.)
        *if missing(_thresperc) then _thresperc=0;
        *flag subgroup with threshold=true, keep record for all subjects;
        if (~missing(&secvar.) ) and _thresperc>=&threshold. and _n_>1 then do;
            _flag=1;
            output _ptout;
        END;
        *flag main group with threshold=true;
        if (missing(&secvar.) ) and _thresperc>=&threshold. and _n_>1 then do;
            _flag=1;
            _flag_for_soc=1;
            output _socout;
        END;
        *catch note on empty _socout;
        else if eof and _flag_for_soc=0 then do;
                &secvar="no data for topvar=&topvar.";
                output _socout;
        END;
        output _tmp0;
    RUN;

    *merge back the flag to find related main ANY group which belongs to the subgroup with freq >=threshold;
        proc sql noprint;
            create table _tmp1 as select a.*,b._flag as _keep from _tmp0 as a left join
                   (select distinct &topvar.,_flag from _ptout ) as b on a.&topvar.=b.&topvar. and missing(a.&secvar.)
                   where ~missing(a._flag) or ~missing(b._flag) ;
        QUIT;

    *in order to get the new sort order, find highest freq within the main group (==highest in respective subgroup) and merge to main group;
    proc sql noprint;
        create table _topvar as select distinct &topvar.,_thresperc_sort as _neworder from _ptout group by &topvar. having _thresperc_sort=max(_thresperc_sort);
        create table _tmp2 as select a.*,b._neworder from _tmp1 as a left join _topvar as b on a.&topvar.=b.&topvar. ;
    QUIT;

    *order of main group is now set, keep main/subgroup records that fulfill threshold assumption and re-order main by overall highest occurence, SOC (if equal freqs exists),
    highest occurance of a subgroup within main group and subgroup (if equal freqs exist);
    proc sort data=_tmp2(where=(_flag=1 or _keep=1)) out= _tmp3;
        by descending _neworder &topvar. descending _thresperc_sort &secvar.;
    RUN;

    data comb_&topvar._&secvar.;
        set  _anygrp _tmp3(in=b);
        if b then do;
            if missing(&secvar.) then &outvar.=strip(&topvar.) ;
            else &outvar='  '||Strip(&secvar.);
        end;
    RUN;

    *check if _socout is ok;
    proc sql noprint;
        select _flag_for_soc into :_socoutn from _socout ;
    QUIT;
    %if %eval(&_socoutn.)>0 %then %do;
        *output main group only;
        proc sort data=_socout(where=(_flag=1)) out=_main_&topvar.out  ;
            by descending _thresperc_sort &topvar. ;
        RUN;
        data main_&topvar.out ;
            set _anygrp _main_&topvar.out;
        RUN;
    %end;
    %else %do;*if _socout is empty ddo not set is; ;
        data main_&topvar.out ;
            set _anygrp ;
        RUN;
    %END;
    *output subgroup only;
    proc sort data=_ptout(where=(_flag=1)) out=_sub_&secvar._out ;
        by descending _thresperc_sort &secvar. ;
    RUN;
    data sub_&secvar._out;
        set _anygrp _sub_&secvar._out;
    RUN;
    *cleanup;
    %if &debug.=%str(N) %then %do;
        proc datasets lib=WORK nolist;
            delete _:;
        QUIT;
    %END;

    OPTIONS &l_notes.;
    %PUT %STR(NO)TE: &macro. - All done, thank you for using me;
    OPTIONS NONOTES;

    %end_macro:;

    OPTIONS &l_opts.;
    %log(
            INFO
          , Version &mversion terminated.
          , addDateTime = Y
          , messageHint = END)
    %log(
            INFO
          , Runtime: %SYSFUNC(putn(%SYSFUNC(datetime())-&_starttime., F12.2)) seconds!
          , addDateTime = Y
          , messageHint = END)

%MEND m_threshold;
