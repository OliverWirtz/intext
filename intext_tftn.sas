%MACRO intext_tftn(instr=%str(&table1.)
       ,tit1='NO'
       ,tit2='NO'
       ,metadat=allmeta
       , debug=N)
/ DES = '###Set titles and populate footnotes from source tables as well as enumeration from startmostometadata###';
/*******************************************************************************
 * Bayer AG
 * Macro rely on:  proper setup of metadata from %startmostometadata
 *******************************************************************************
 * Purpose          : Set titles and populate footnotes from source tables as well as enumeration in an extra footnote
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * Parameters       :
 *                   instr  :string with all source table dataset names as _library.dataset_ format
 *                   tit1   :Title1 as needed in the output
                     tit2   :Title2 as needed in the output'

 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Preconditions    :
 *     Macrovar. needed:   dataset table name(s) as retrieved by  %intext_find_metadata(), table enumeration as retrieved by %intext_get_enumeration()
 *     Datasets  needed:   tlf metadataset from startmostometadata
 *     Ext.Prg/Mac used:
 * Postconditions   :
 *     Macrovar created:
 *     Output   created:  macro creates a macro call for %set_titles_footnotes
 *     Datasets created:
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 21OCT2021
 *******************************************************************************
 * Change History   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 02NOV2021
 * Reason           : removed the num parameter and used %intext_get_enumeration instead
 ******************************************************************************/

/*******************************************************************************
 * Examples         :
 * %intext_tftn(instr=%str(&table1. &table2. &table3. &table4. &table5.)
 *        ,tit1="Table: Patient disposition (FAS)"
 *        );
 ******************************************************************************/



    %LOCAL macro mversion _starttime macro_parameter_error err_msg;
    %LET macro    = &sysmacroname.;
    %LET mversion = 1.0;
    %LET err_msg=;
    %_eva_support_macros()
    %_eva_spro_check_param(name=metadat, type=LIBRARY);

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

    OPTIONS  NOSOURCE NOFMTERR;



    %local i cnt all_meta_dat source found meta_lib meta_dat ftcnt num;
    *retrieve number of tables;
    *remove training blanks, if any;
    %let instr=%trim(&instr.);
     %let cnt=%sysfunc(countw("&instr.",' '));

     *initialize vars;
     %let all_meta_dat=%str();
     %*let source=%str(Source: );

        %do i=1 %to %eval(&cnt.);
            *retrieve nth libname.dataset string from input string;
            %let found=%scan(&instr.,&i.,' ');
             %let num= %intext_get_enumeration(
                 meta_file   = &found.
               , meta_lib    = TLFMETA
               , meta_master = TLFMETA.ALLMETA
             );
            *extract lib;
            %let meta_lib=%scan(&found.,1);
            %if %SYSFUNC(libref(&meta_lib.)) %THEN %DO;
                %LET err_msg = &meta_lib. as found in parameter instr=&instr. is not a valid library !;
                %GOTO OUTPUT_ERROR_MSG;
            %END;

            *extract table;
            %let meta_dat=%scan(&found.,2);
            %LOCAL _id;
            %LET _id = %SYSFUNC(open(&found.));
            %IF (&_id. NE 0)
            %THEN %DO;
                %LET _id = %SYSFUNC(close(&_id.));
            %END;
            %ELSE %DO;
                %LET err_msg = &found. is not a valid data set!;
                %GOTO OUTPUT_ERROR_MSG;
            %END;

            %*setup search string with table names to look for in tlfmeta.metadata;
             %let all_meta_dat=&all_meta_dat. "&meta_dat.";
             *setup last footnote with source table numbers;
             %if %eval(&i.)=1 %then %do;

                data _temp_ftn;
                    format value  $1000.;
                    value=resolve("&num");

                RUN;
             %end;
             %else %if %eval(&i.)<= %eval(&cnt.) %then %do;
                data _temp_ftn;
                    set _temp_ftn;
                     output;
                     value=resolve("&num");
                     output;
                RUN;

             %end;


        %end;
        proc sort data=_temp_ftn nodupkey;
            by value;
        RUN;
        data _temp_ftn;
            set _temp_ftn end=eof;
            format source  $256.;

            retain source;
            if _n_=1 then do;
                source=catx(' Table ', "Source:", compress(tranwrd(value,'Table','')));

            END;
            else if not eof then do;
                source=catx(', Table ',source, compress(tranwrd(value,'Table','')));

            END;
            else do;
                source=catx(' and Table ',source, compress(tranwrd(value,'Table','')));

            END;
            if eof then do;
                call symput('source',source);
            END;
        RUN;
        %put &source;
        *lookup all footnotes from metadata, omit empty lines;
        proc sql noprint;
            create table _temp as select name,seq, variable,value from &meta_lib..&metadat.
                   where cats(lowcase(name),'_',seq) in(%lowcase(&all_meta_dat.)) and (find(variable,'FOOTNOTE')>0 and  ~missing(value));

        QUIT;

        *define index to preserve order;
        data _temp ;
            set _temp ;
            idx=_n_;
        RUN;
        *remove duplicates;
        proc sort data=_temp nodupkey;
            by value;
        RUN;
        *restore order;
        proc sort data=_temp nodupkey;
            by idx;
        RUN;
        *check if there is a footnote available at all that is not a folderpath;
        proc sql noprint;
          select count(*) into :ftcnt from _temp(where=(find(value,'Bayer:')=0)) ;
        QUIT;
        *ok, there is at least one footnote to be used later;
        %if %eval(&ftcnt.)>0 %then %do;
            data _temp;
                set _temp;
                where find(value,'Bayer:')=0; *drop program paths;
                if _n_<9 then output;       *output up to 8 footnotes, this leaves enough space for Source: and the path of the program;

                if _n_>=9 then do;          *inform the user about footnotes that cannot be output;
                    put "Footnote will not be output: " value ;
                END;
            RUN;
            *set ftn for set_titles_footnotes;
            data _temp ;
                set _temp end=eof;

                flag=0;
                variable=cats('FTN',put(_n_,8.));
                if eof then do;
                    *at eof output another record with the source text;
                    output;
                    variable=cats('FTN',put(_n_+1,8.));
                    value="&source.";
                    flag=1;
                    output;
                END;
                else output;
            RUN;
        %end;
        %else %do;
            *no footnotes to be kept, create source only;

            data _temp;
                variable='FTN1';
                value="&source.";
                flag=1;
                output;
            run;
        %END;


        options noquotelenmax;
        %let dsid=%sysfunc(open(_temp,I));
        %if &dsid>0 %then %do;
        %*convert record parameters into macro variable;
            %syscall set(dsid);
        %*call titles footnotes macro and set titles;
        %*after that loop through _temp and set footnotes;
        %set_titles_footnotes(
             handleLinesize = No,
            tit1=&tit1.,
            tit2=&tit2.,

            %do %while (%sysfunc(fetch(&dsid)) eq 0);
                %let _temp ="%sysfunc(strip(%nrbquote(&value.)))";
                %cmpres(&variable.) = &_temp.
                %if %eval(&flag.)=0 %then %do;
                    ,
                %END;
            %end;
            );
        %end;
        %let rc=%sysfunc(close(&dsid));
        options quotelenmax;

        %if %upcase(%substr(&debug.,1,1)) eq N %then %do;
            proc datasets lib=work nolist;
                delete _temp _temp_ftn ;
            QUIT;
        %end;



    OPTIONS &l_notes.;
    %PUT %STR(NO)TE: &macro. - that was it;
    OPTIONS NONOTES;
%RETURN;
%OUTPUT_ERROR_MSG:;
     %_eva_log(E, &err_msg., _macro=&macro.);
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

%MEND intext_tftn;
