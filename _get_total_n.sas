%MACRO _get_total_n(pop=%str(saffn=1))
/ DES = 'retrieve big N if totals missing';
/*******************************************************************************
 * Bayer AG
 * Macro rely on: ###choose: TOSCA, initstudy, GMS, GDD, pure SAS###
 *******************************************************************************
 * Purpose          : retrieve big N if totals missing
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * Parameters       :
 *                    param1 :
 *                    param1 :
 * SAS Version      : Linux 9.4
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
 * Author(s)        : gghcj (Oliver Wirtz) / date: 07JUL2020
 *******************************************************************************
 * Change History   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 14AUG2020
 * Reason           : addded hist subgroups
 ******************************************************************************/

/*******************************************************************************
 * Examples         :
   %macro();
 ******************************************************************************/



    %LOCAL macro mversion _starttime macro_parameter_error;
    %LET macro    = &sysmacroname.;
    %LET mversion = 1.0;

    %spro_check_param(name=pop, type=TEXT)


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
    %global _mytot _myfl _mymzl _myflcop _myflpla _mymzlcop _mymzlpla;

        proc sql noprint;
            select cat("Total iNHL@(FL,MZL,SLL,LPL/WM)@N= ", count(subjidn)," (100%)") into :_mytot from ads.adsl where &pop. ;
            select cat("FL@N= ", count(subjidn)," (100%)")  into :_myfl from ads.adsl where histgrp= 'FL' and &pop.;
            select cat("MZL@N= ", count(subjidn)," (100%)")  into :_mymzl from ads.adsl where histgrp= 'MZL' and &pop.;
            select cat("Copanlisib/@rituximab@N= ", count(subjidn))  into :_myflcop from ads.adsl where histgrp= 'FL' and trt01pn=30 and &pop.;
            select cat("Placebo/@rituximab@N=  ", count(subjidn))  into :_myflpla from ads.adsl where histgrp= 'FL' and trt01pn=31 and &pop.;
            select cat("Copanlisib/@rituximab@N= ", count(subjidn))  into :_mymzlcop from ads.adsl where histgrp= 'MZL' and trt01pn=30 and &pop.;
            select cat("Placebo/@rituximab@N=  ", count(subjidn))  into :_mymzlpla from ads.adsl where histgrp= 'MZL' and trt01pn=31 and &pop.;
        QUIT;


    OPTIONS &l_notes.;

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

%MEND _get_total_n;
