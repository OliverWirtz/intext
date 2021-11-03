%MACRO m_rename(indata=comb_aebodsys_aedecod, inarray=%str('_t_1', '_t_2', '_t_3'),_split="@",type=0 )
/ DES = 'rename labels to match CSR needs';
/*******************************************************************************
 * Bayer AG
 * Macro rely on: ###choose: TOSCA, initstudy, GMS, GDD, pure SAS###
 *******************************************************************************
 * Purpose          : Rename labels according to MW needs
 * Programming Spec :
 * Validation Level : 1 - Validation by review
 * Parameters       :
 *                    param1 :
 *                    param1 :
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
 * Author(s)        : gghcj (Oliver Wirtz) / date: 23APR2020
 *******************************************************************************
 * Change History   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 30APR2020
 * Reason           : include line break after / in label
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 07MAY2020
 * Reason           : added uppercase to input to get all variables if casing differs
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 15MAY2020
 * Reason           : incldued  n (%) in label
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 02JUL2020
 * Reason           : included type for PFS
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 06JUL2020
 * Reason           : added type 2 for shift
 ******************************************************************************/

/*******************************************************************************
 * Examples         :
   %m_rename();
 ******************************************************************************/



    %LOCAL macro mversion _starttime macro_parameter_error;
    %LET macro    = &sysmacroname.;
    %LET mversion = 1.0;

    %spro_check_param(name=indata, type=DATA)


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



       proc sql noprint;
           create table _label as select name, label from dictionary.columns  where libname='WORK' and memname=upcase("&indata") and upcase(name) in(%upcase(&inarray.)) ;
       QUIT;
       data _label1;
           set _label;
           format newlabel $200.;

           if find(label,"/")>0 then do;
               %If %eval(&type.)=0 %then %do;
                    newlabel= "label "||name|| "= '"||strip(tranwrd(label,'/ r','/@r'))||"@n (%)'";
               %end;
               %Else %if %eval(&type.)=1 %then %do;
                   newlabel= "label "||name|| "= '"||strip(tranwrd(translate(label,'@','#'),'/ r','/@r'))||"'";
                   newlabel=tranwrd(newlabel,'(100%)','');
                   newlabel=compress(newlabel,'()');
               %END;

           end;
           %if %eval(&type.)=2 %then %do;
             newlabel= "label "||name|| "= '"||substr(label,1,find(label,'(')-1)||"n(%)'";

           %END;

       RUN;





       %let dsid=%sysfunc(open(_label1,I)); *_label1 is a dataset with all parameters needed later on in SAS code;
       %put &dsid;
       %if &dsid>0 %then %do;
       %*convert record parameters into macro variable;
       	%syscall set(dsid);
       %* loop through temp and do the following for each iteration;
       	%do %while (%sysfunc(fetch(&dsid)) eq 0);

       data &indata.;
           set &indata.;
           &newlabel.;
       RUN;

       	%end;
       %end;
       %let rc=%sysfunc(close(&dsid));


    OPTIONS &l_notes.;
    %PUT %STR(NO)TE: &macro. - Done;
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

%MEND m_rename;
