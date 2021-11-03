%MACRO _strip_num(invar=, formtype=1)
/ DES = 'strips numbers from character variables formatted as xx.xxx (zzz.zzz)';
/*******************************************************************************
 * Bayer AG
 * Macro rely on: ###choose: TOSCA, initstudy, GMS, GDD, pure SAS###
 *******************************************************************************
 * Purpose          : strips numbers from char variables
 * Programming Spec :
 * Validation Level : 1 - verification by review
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
 * Author(s)        : gghcj (Oliver Wirtz) / date: 03AUG2020
 *******************************************************************************
 * Change History   :
 ******************************************************************************/

/*******************************************************************************
 * Examples         :
   %_strip_num();
 ******************************************************************************/



    %LOCAL macro mversion _starttime macro_parameter_error;
    %LET macro    = &sysmacroname.;
    %LET mversion = 1.0;

    %spro_check_param(name=invar, type=VARIABLE)



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

    %* Put your macro code here!;

    OPTIONS &l_notes.;
    %if %eval(&formtype.)=1 %then %do;
        &invar.=substr( &invar.,1,prxmatch('/\[|\(/', &invar.)-1);
    %end;
    %else %if %eval(&formtype.)=2 %then %do;
        &invar.=substr( &invar.,1,prxmatch('/\[/', &invar.)-1);
    %end;
    %else %if %eval(&formtype.)=3 %then %do;
        &invar.=substr( &invar.,1,prxmatch('/\(/', &invar.)-1);
    %end;
    OPTIONS NONOTES;

    %end_macro:;

    OPTIONS &l_opts.;


%MEND _strip_num;
