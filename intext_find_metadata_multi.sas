%MACRO intext_find_metadata_multi(
       meta_lib      = TLFMETA                     /*@type LIBRARY*/
     , meta_master   = &meta_lib..META             /*@type DATA*/
     , title1        =                             /*@type TEXT*/
     , title2        =                             /*@type TEXT*/
)/ DES = 'Macro returning metadata set for table by title';
/*******************************************************************************
 * Bayer AG
 * Macro rely on: SWAN, SAS
 *******************************************************************************
 * Purpose          : This macro searches and returns the Mosto metadata file of the table that matches a certain title.
 * Programming Spec :
 * Validation Level : 1 - Verification by Review
 * Parameters       :
 *            meta_lib : Library that Mosto metadata is stored
 *         meta_master : Master metadata file
 *              title1 : Title1 attribute of the table
 *              title2 : Title2 attribute of the table
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Preconditions    :
 *     Macrovar. needed: None
 *     Datasets  needed: &meta_master.
 *     Ext.Prg/Mac used: %_eva_spro_check_param, %_eva_log, %_eva_getDataValue
 * Postconditions   :
 *     Macrovar created: None
 *     Output   created: None
 *     Datasets created: None
 * Comments         : Inline macro that returns one or more dataset filename(s).
 *                    Preferred use to fill macro variable, especially when one title
 *                    is tied to multiple data files
 *******************************************************************************
 * Author(s)        : gfeqr (Dominik Habel) / date: 20APR2020
 *******************************************************************************
 * Change History   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 20OCT2021
 * Reason           : enable
 ******************************************************************************/

/*******************************************************************************
 * Examples         :
 * %let table= %intext_find_metadata(
 *     meta_lib    = TLFMETA
 *   , meta_master = &meta_lib..META
 *   , title1        = Table: <key> Demographics  (full analysis set - dummy assignment)
 *   , title2        =
 * )
 ******************************************************************************/
    %LOCAL macro mversion _starttime macro_parameter_error metadata_cols;
    %LET macro    = &sysmacroname.;
    %LET mversion = 1.0;

    %_eva_support_macros()

    %LET _starttime = %SYSFUNC(datetime());
    %_eva_log(
        INFO
      , Version &mversion started
      , addDateTime = Y
      , messageHint = BEGIN
    )

    %***************************************************************************;
    %*<** check of input parameters ;
    %***************************************************************************;

     %_eva_spro_check_param(
       name      = meta_lib
     , type      = LIBRARY
     , mustExist = Y)

    %IF (%QUOTE(&macro_parameter_error.) EQ %STR(1)) %THEN %DO;
         %GOTO END_MACRO;
    %END;

     %_eva_spro_check_param(
       name      = meta_master
     , type      = DATA
     , mustExist = Y)

     %IF (%QUOTE(&macro_parameter_error.) EQ %STR(1)) %THEN %DO;
          %GOTO END_MACRO;
     %END;

     %let metadata_cols = %_eva_getVarlist(&meta_master., NAME SEQ TYPE VARIABLE VALUE, mode = IN);
     %IF  %sysfunc(countw(&metadata_cols.)) NE 5 %THEN %DO;
         %_eva_log(E, The data set &meta_master. is not a valid Mosto metadata master file. It must contain the variables: NAME SEQ TYPE VARIABLE VALUE!);
         %GOTO END_MACRO;
     %END;



     %_eva_spro_check_param(
       name      = title1
     , type      = TEXT
     , mustExist = Y)

      %IF (%QUOTE(&macro_parameter_error.) EQ %STR(1)) %THEN %DO;
           %GOTO END_MACRO;
      %END;

      %***************************************************************************;
      %*<** MAIN PROCESSING ;
      %***************************************************************************;
      %local metadataset seq _id _id2 return;
    %LET _id = %SYSFUNC(OPEN(&meta_master.(WHERE=(variable EQ "TITLE1" and value EQ "&title1"))));

%let return=;

    %DO %WHILE (NOT %SYSFUNC(fetch(&_id.)));

        %LET metadataset = %_eva_getDataValue(&_id., name);
        %LET seq         = %_eva_getDataValue(&_id., seq);

        %if %length(&title2) GT 0
        %then %do;
            %LET _id2 = %SYSFUNC(OPEN(&meta_master.(WHERE=(variable EQ "TITLE2" and value EQ "&title2" AND name EQ "&metadataset." AND seq EQ &seq.))));
            %IF NOT %SYSFUNC(fetch(&_id2.))
            %THEN %DO;

                %IF %length(&return.) GT 0 AND
                    &return. NE &metadataset._&seq.
                %THEN %DO;
                    %* second matching data set;

/*                    %_eva_log(E, Multiple matching metadata sets found for combination of title1 and title2 parameters.)*/

                    %let return =&return. &meta_lib..&metadataset._&seq.;

                %END;
                %else %do;
                    %let return = &meta_lib..&metadataset._&seq.;
                %end;
            %END;
            %LET _id2 = %SYSFUNC(close(&_id2.));
        %END;
        %ELSE %DO;

            %IF %length(&return.) GT 0 AND
                &return. NE &metadataset._&seq.
            %THEN %DO;

/*                %_eva_log(E, Multiple matching metadata sets found for parameter title1.)*/


                %let return =&return. &meta_lib..&metadataset._&seq.;

            %END;
            %else %do;

                %let return =&meta_lib..&metadataset._&seq.;

            %END;

        %END;

    %END;

    %AFTER_LOOP:
    %LET _id=%SYSFUNC(close(&_id.));

    %if %length(&return) EQ 0 %then %do;
        %_eva_log(E, Did not find any metadata sets for parameters.)
    %END;

    &return.
    %put &return. ;

    %end_macro:

    %_eva_log(
        INFO
      , Version &mversion terminated.
      , addDateTime = Y
      , messageHint = END
    )
    %_eva_log(
        INFO
      , Runtime: %SYSFUNC(putn(%SYSFUNC(datetime())-&_starttime., F12.2)) seconds!
      , addDateTime = Y
      , messageHint = END
    )
%MEND intext_find_metadata_multi;
