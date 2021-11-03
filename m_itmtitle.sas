%MACRO m_itmtitle(mymeta=tlfmeta,mymetadat=allmeta,tableno=1, itdata=,title=,keepftn=N,foot=,foot1=,evaltable=)
/ DES = 'Create titles and footnotes for in-text tables';

/*******************************************************************************
 * Bayer AG
 * Macro rely on: ###choose: TOSCA, initstudy, GMS, GDD, pure SAS###
 *******************************************************************************
 * Purpose          : read in titles footnotes from dataset meta
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
 * Author(s)        : gghcj (Oliver Wirtz) / date: 09APR2020
  ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 23APR2020
 * Reason           : changed tlfmeta libname
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 15MAY2020
 * Reason           : changed destination to allmeta
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 25MAY2020
 * Reason           : added code to split foot1 if longer than 250
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 08JUL2020
 * Reason           : included code to really remove initial footnotes, if requested
 ******************************************************************************/


    %LOCAL macro mversion _starttime macro_parameter_error;
    %LET macro    = &sysmacroname.;
    %LET mversion = 1.0;

    %spro_check_param(name=tableno, type=NUMBER);

    %IF (%QUOTE(&macro_parameter_error.) EQ %STR(1)) %THEN %RETURN;

    %LET _starttime = %SYSFUNC(floor(%SYSFUNC(datetime())));
    %PUT - &macro.: Version &mversion started %SYSFUNC(date(),worddate.) %SYSFUNC(time(),hhmm.);

    %LOCAL l_opts l_notes;
   %LET l_notes = %SYSFUNC(getoption(notes,keyword));

   %LET l_opts = %SYSFUNC(getoption(source,keyword))
                 %SYSFUNC(getoption(notes,keyword))
                 %SYSFUNC(getoption(fmterr,keyword))
   ;

   OPTIONS NONOTES NOSOURCE NOFMTERR ;


    ***************************************************************************;
    *** Start of titles and footnotes ;
    ***************************************************************************;

    ***************************************************************************;
    *** Tables;
    ***************************************************************************;
    %* do the following if no external footnotes etc needs to be evaluated;
    %* the following part reads in titles and footnotes and re-arranges them;
    %if %sysevalf(%superq(evaltable)=,boolean)=1 %then %do;

        %spro_check_param(name=itdata, type=TEXT,mustExist=Y);
        proc sql noprint;
            create table _ittitles as select name,seq, variable,value format=$2000. length=2000 from &mymeta..&mymetadat.
                   where name="%lowcase(&itdata.)" and type="Title/Footnote" and seq=&tableno. ;
            select value into :_footno from _ittitles where variable="NumberOfFootnotes";
        QUIT;
        %macro CheckOpenFiles(inds=, inlib=WORK);
        %local inds;
        %local dsid;
        %local p;

        %if  %sysfunc(exist(&inlib..&inds)) %then %do;
            %let dsid=%sysfunc(open(&inds,I));

            %if &dsid>1 %then %do;
                %put Dataset &inds is still open. ;
                %put Initialising closing procedure...;
                %do p=1 %to &dsid;
                    %put Message: closing dataset instance: &p of &inds;
                    %let rc=%sysfunc(close(&p));
                %end;
            %end;
            %if &dsid=1 %then %do;
                %let rc=%sysfunc(close(&dsid));
            %end;
        %end;
        %mend;
        %CheckOpenFiles(inds=_ittitles1);
        data _ittitles1;
            set _ittitles;
            if substr(variable,1,5)="TITLE" or (substr(variable,1,8)="FOOTNOTE");
            if substr(variable,1,5)="TITLE" then do;
                if variable="TITLE1" then  put "Title of %lowcase(&itdata.)_&tableno. is: " value;
                else put value;
            end;
            source='1';
            retain footnonum 0;
            *delete initial titles if provided as parameter;
            %if %sysevalf(%superq(title)=,boolean)=0 %then %do;
                if substr(variable,1,5)="TITLE" then do;
                    if variable="TITLE1" then do;
                        value="&title";
                        output;
                    end;
                    else delete;
                END;
            %end;
            %else %do;
                if substr(variable,1,5)="TITLE" then output;
            %END;

            %if %sysevalf(%superq(foot)=,boolean)=0 %then %do;
                if substr(variable,1,8)="FOOTNOTE" then do;

                    l=substr(variable,9,length(variable)-8);
                    footnonum=l+1;
                    %if %sysevalf(%superq(foot1)=,boolean)=0 %then %do;
                        footnonum=l+2;
                    %END;
                    variable=compress(cat("FOOTNOTE",put(footnonum,8.)));
                    %*output footnotes with n+1 scheme;
                    %if %sysevalf(%superq(foot1)=,boolean)=1 %then %do;
                        If input(substr(variable,9,length(variable)-8),8.)<&_footno.+1 then output;
                    %end;
                    %*output footnotes with n+2 scheme;
                    %if %sysevalf(%superq(foot1)=,boolean)=0 %then %do;
                        If input(substr(variable,9,length(variable)-8),8.)<&_footno.+2 then output;
                    %end;
                    %*output extra footnotes with n+1 scheme;
                    %if %sysevalf(%superq(foot1)=,boolean)=1 %then %do;
                        if  input(substr(variable,9,length(variable)-8),8.)=&_footno.+1 then do;
                    %end;
                    %*output extra footnotes with n+2 scheme;
                    %if %sysevalf(%superq(foot1)=,boolean)=0 %then %do;
                        if  input(substr(variable,9,length(variable)-8),8.)=&_footno.+2 then do;
                    %end;
                        value="&idfoot.";
                        programID=1;
                        output;
                        programID=0;
                        variable="FOOTNOTE1";
                        value="&foot.";
                        footnonum=1;
                        output;
                        %*output extra footnotes with n+2 scheme;
                        %if %sysevalf(%superq(foot1)=,boolean)=0 %then %do;
                           variable="FOOTNOTE2";
                           value="&foot1.";
                           output;
                        %end;


                    END;
                end;
            %end;
            %else %do;
                if substr(variable,1,8)="FOOTNOTE" then do;
                    If input(substr(variable,9,length(variable)-8),8.)<&_footno. then do;
                        call missing(programID);
                        output;
                    end;
                    else if  input(substr(variable,9,length(variable)-8),8.)=&_footno. then do;
                        value="&idfoot.";
                        programID=1;
                        output;
                    END;
                end;
            %END;

        RUN;
        *remove quotes;
        data _ittitles1;
            set _ittitles1;
            if substr(value,1,1) in("'",'"') and substr(value,length(value),1) in("'",'"') then do;
                value=substr(value,2,length(value)-2);
            END;
        RUN;
        proc sort data=_ittitles1;
            by footnonum;
        RUN;
        *prepare all footnotes;
        data _ittitles2;
            set _ittitles1;
            format _ft1-_ft8 _temp $400.;
            array ft(8) _ft1-_ft8;
            k=0;
            call symput('cntk',k);
            call missing(_temp);
            if length(strip(value))>250 and find(variable,'FOOTNOTE')>0 then do;


/*                if variable="FOOTNOTE1" then Put "NOTE: Footnote1 too long use parameter foot1 from 250 chars onwards.";*/
/**/
/*                else do;*/
                    k=1;
                    u=countw(value,' ');
                    v=countw(value);
                    do i=1 to countw(value,' ');
                        if length(strip(_temp)||' '||scan(value,i,' '))<=243 then do;
                            _temp=strip(_temp)||' '||scan(value,i,' ');

                            if i=countw(value,' ') then ft(k)=_temp;
                        end;
                        else do;
                            ft(k)=_temp;
                            call missing(_temp);
                            k=k+1;
                            i=i-1;
                        END;

                    END;
/*                END;*/
            END;
            %if %Upcase(&keepftn.)=N %then %do;%*delete footnotes from source table*;
                if find(variable,'FOOTNOTE')>0 and ~missing(value) and missing(programID) then do;
                    delete;
                END;

            %END;
        RUN;
        *renumber footnotes just to be sure that all are numbered alright;

        data _ittitles2 ;
            set _ittitles2;
            retain _n 1;
            if find(variable,'FOOTNOTE')>0 then do;
                 variable=cats('FOOTNOTE',put(_n,8.));
                _n=_n+1;
            end;
        RUN;
        *Check the number of footnotes;
        proc sql noprint;
            select count(variable) into :cntft from _ittitles2 where find(variable,'FOOTNOTE')>0 and ~missing(value);
            select sum(k) into :cntk from _ittitles2  ;
        QUIT;
        %if %eval(&cntk.)>0 %then %do;
            %if %eval(&cntft.+&cntk.)<=8 %then %do;
                data _ittitles3;
                    set _ittitles2;
                    retain ftn 0;
                    array ft(8) _ft1-_ft8;
                        if ~missing(_ft1) then do;
                            do i=1 to 8;
                                if ~missing(ft(i));
                                variable=compress('FOOTNOTE'||put(i,8.)); *keep in mind there is footnote1;
                                if i=1 then value=ft(i);
                                else value='<cont> '||ft(i);
                                ftn=i+1;
                                output;
                            END;
                        END;
                        else if ftn>0 then do; *renumber trailing footnotes;
                            variable=compress('FOOTNOTE'||put(ftn,8.));
                            ftn=ftn+1;
                            output;
                        end;
                        else if ~missing(value) then output;
                run;
                %let _eval=_ittitles3;
            %END;
            %else %do;
                %put %str(WAR)NING: Text in foot1 is too long. Not enough footnotes available. Foot1 is ignored;
                %let _eval=_ittitles2;
            %END;

        %END;
        %else %do;
            %let _eval=_ittitles2;
        %END;

    %END;

    %else %do;
        *if table is handed over;
        %spro_check_param(name=evaltable, type=DATA,mustExist=Y);
        %let _eval=&evaltable.;
    %end;

    %let dsid=%sysfunc(open(&_eval.,I)); *mygroups is a dataset with all parameters needed later on in SAS code;
    %put &dsid;
    %if &dsid>0 %then %do;
    %*convert record parameters into macro variable;
        %syscall set(dsid);
    %* loop through temp and do the following for each iteration;
        %do %while (%sysfunc(fetch(&dsid)) eq 0);
            %put %cmpres(&variable.) %sysfunc(compbl("&value"));
            &variable. %sysfunc(compbl("&value.")) ;

        %end;
    %end;
    %let rc=%sysfunc(close(&dsid));



    OPTIONS &l_notes.;

    OPTIONS NONOTES;


    %* restore options;
    OPTIONS &l_opts.;
    %PUT - &macro.: version &mversion terminated. Runtime: %EVAL(%SYSFUNC(floor(%SYSFUNC(datetime()))) - &_starttime.)seconds!;

%MEND m_itmtitle ;
