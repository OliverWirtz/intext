%MACRO _assign_meddralabel(inlib=work, inds=,invar=_levtxt)
/ DES = 'assign meddra label in the variable commited as macro parameter';
/*******************************************************************************
 * Bayer AG
 * Macro rely on: ###choose: TOSCA, initstudy, GMS, GDD, pure SAS###
 *******************************************************************************
 * Purpose          : assign meddra version in in-text tables
 * Programming Spec :
 * Validation Level : 1 - Validation by review
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
 * Author(s)        : gghcj (Oliver Wirtz) / date: 07MAY2020
 *******************************************************************************
 * Change History   :
 ******************************************************************************/

/*******************************************************************************
 * Examples         :
   %_assign_meddralabel();
 ******************************************************************************/



    %LOCAL macro mversion _starttime macro_parameter_error;
    %LET macro    = &sysmacroname.;
    %LET mversion = 1.0;

    %spro_check_param(name=inlib, type=library)
    %spro_check_param(name=inds, type=data)
    %spro_check_param(name=invar, type=variable)

    %IF (%QUOTE(&macro_parameter_error.) EQ %STR(1)) %THEN %RETURN;

    %LET _starttime = %SYSFUNC(datetime());
    %log(
            INFO
          , Version &mversion started
          , addDateTime = Y
          , messageHint = BEGIN)

    %LOCAL l_opts l_notes _meddralabel;
    %LET l_notes = %SYSFUNC(getoption(notes));

    %LET l_opts = %SYSFUNC(getoption(source))
                  %SYSFUNC(getoption(notes))
                  %SYSFUNC(getoption(fmterr))
    ;

    OPTIONS NONOTES NOSOURCE NOFMTERR;


    proc sql noprint;
        select catt(label," (v. &meddrav.)") into: _meddralabel from dictionary.columns where upcase(libname)="%upcase(&inlib.)" and upcase(memname)="%upcase(&inds.)" and upcase(name)="%upcase(&invar.)";
    QUIT;
    data &inds.;
        set &inds.;
        label &invar.="&_meddralabel.";
    RUN;


    OPTIONS &l_notes.;
    %PUT %STR(NO)TE: &macro. - all done;
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

%MEND _assign_meddralabel;
