/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin’s lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %LET prog = #runall_prepare_intext_data;
/*
 * Purpose          : prepare all table data
 * Programming Spec :
 * Validation Level : 1 - verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 20OCT2021
 * Reference prog   : /var/swan/root/bhc/1841788/17777/stat/main01/dev/analysis/pgms/#runall_prepare_intext_data.sas (gghcj (Oliver Wirtz) / date: 19OCT2021)
 ******************************************************************************/


%initsystems(initstudy=3, mosto=6, spro=3, adamap=1,  gral=4, eva=1);
%initstudy(iniProgram       =
         , display_formats  = Y
         , inimode          = ANALYSIS
         , includeSPFrom    = main01/prod
         , includeADSFrom   = main01/prod);

libname oad(sp);
libname metadata(spmeta);
libname tlfmeta "&outdir./tlfmeta";
libname tl_meta (tlfmeta);


options fmtsearch=(ads.fmt_disp ads.fmt_ads ads_act.fmt_newads ads_act.fmt_newdisp);

*merge all meta data in case they were done by poster;

data tlfmeta.allmeta;
    set  tlfmeta.t14: ;
    format tabledata $200. value1 temp $256.;
    tabledata=cats(name,'_',seq) ;
    if variable in('BY','VAR') and find(value,'(')>0 then do;
        value=translate(value,"'",'"');
        temp=value;
        value=translate(value,'','()');
        value1="";
        flag=1;
        cnt=0;
        str=0;
        cnt1=0;
        str1=0;
        do k=1 to length(value); *browse labels until second quote, that is one label;
            if substr(value,k,1)='"' or substr(value,k,1)="'" then do;
                cnt=cnt+1;
                if cnt=1 then str=k;
                if cnt=2  then do;
                    value=tranwrd(value,substr(value,str,(k-str)+1),'');
                    k=1;
                    cnt=0;
                    str=0;
                end;
            end;
        end;
        do l=1 to length(temp); *browse labels until second quote, that is one label;
            if substr(temp,l,1)='(' or substr(temp,l,1)=")" then do;
                cnt1=cnt1+1;
                if cnt1=1 then str1=l;
                if cnt1=2  then do;
                    value1=catx(' ',value1,substr(temp,str1,(l-str1)+1));
                    temp=tranwrd(temp,substr(temp,str1,(l-str1)+1),'');
                    l=1;
                    cnt1=0;
                    str1=0;
                end;
            end;
        end;
    END;
    drop temp;
RUN;


%intext_find_source_tables(
    meta_master  = TLFMETA.ALLMETA
  , documDir     =
  , includeFiles =%str(&docdir./17067_ad_hoc_ema120d_datacut_31aug2020_part_1.doc &docdir./17067_ad_hoc_ema120d_datacut_31aug2020_part_2.doc)
  , excludeFiles =
)


*merge table title to metadata;
*create list of table titles;
*merge table title to metadata;
*create list of table titles;
proc sql noprint;
    create table alltit0 as select distinct name, value,variable, seq, tabledata  from tlfmeta.allmeta where find(variable,'TITLE')>0
        order by tabledata, variable;
    create table _temp as select distinct name, value as tablnum ,variable, seq, cats(name,'_',seq) as tabledata format=$200. from tlfmeta.allmeta where find(variable,'FinalEnumeration')>0
        order by tabledata, variable;
    create table alltit1 as select a.*,b.tablnum from alltit0 as a left join _temp as b on a.tabledata=b.tabledata order by tabledata,tablnum, variable;
QUIT;

*concat titles if more than one row;
proc transpose data=alltit1 out=_alltit ;
    by tabledata tablnum ;
    var value;

RUN;
*write titles ;
data _alltit ;
    set _alltit ;
    format tlf_title $1000. dslabel $256.;
    tlf_title=catx(' ',of col:);
    tlf_title=compbl(tranwrd(tlf_title,"<cont>",""));
    tlf_title=compbl(tranwrd(tlf_title,"<key>",""));

    if ~missing(tablnum) then do;
        tlf_title=catx(': ',strip(tablnum),substr(tlf_title,find(tlf_title,':')+1));
    end;
    if length(strip(tlf_title))>256 then dslabel=substr(tlf_title,1,256);
    dslabel=strip(tlf_title);
RUN;

*merge table footnotes to metadata;
*create list of table  footnotes;
proc sql noprint;
    create table allfoot as select distinct name, value,variable, seq, tabledata  from tlfmeta.allmeta where find(variable,'FOOTNOTE')>0
    order by tabledata, variable;
QUIT;
*concat titles if more than one row;
proc transpose data=allfoot  out=_allfoot  ;
    by tabledata;
    var value;
RUN;
*write footer;
data _allfoot  ;
    set _allfoot  ;
    format tlf_foot $10000.;
    retain ;
    tlf_foot=catx('@',of col:);
    tlf_foot=compbl(tranwrd(tlf_foot,"@<cont>"," "));
    tlf_foot=compbl(tranwrd(tlf_foot,'"',"'"));

RUN;
*add footnotes to alltit;
*write all to store;
proc sql noprint;
    create table tlfmeta.alltit as select a.*,b.tlf_foot from _alltit as a left join _allfoot as b on
           a.tabledata=b.tabledata;

QUIT;


*retrieve tlf datasets;
proc sql noprint;
    create table alltit2 as select a.* from tlfmeta.alltit as a
         left join (select memname from dictionary.tables where upcase(libname)='TLFMETA') as b
         on upcase(a.tabledata)=upcase(b.memname) where ~missing(b.memname);
    create table alltit3 as select a.*,b.name from alltit2 as a left join (select memname, name from dictionary.columns  where upcase(libname)='TLFMETA'
           and upcase(name)='TLF_TITLE') as b
     on upcase(a.tabledata)=upcase(b.memname) ;
QUIT;


*main macro to add info to datasets;
%macro _merger;

    %local title_len foot_len counter displayed_vars numfiles displayed_label test sub varlen lbllen page temp_page displayed_page page_len found i k ;
    options nonotes;
    *retrieve max title length for later use;
    proc sql noprint;
        select max(length(tlf_title)) into :title_len from tlfmeta.alltit;
        select max(length(tlf_foot)) into :foot_len from tlfmeta.alltit;
        select count(*) into :numfiles from alltit1;
    QUIT;
    %put %Str(Processing &numfiles. :) ;
    %let title_len=%cmpres(&title_len.);
    %let foot_len=%cmpres(&foot_len.);

    *loop through dataset alltit1;
    %let dsid=%sysfunc(open(alltit3,I));
    %let counter=0;
    %if &dsid>0 %then %do;
    %*convert dataset variables into macro variable;
        %syscall set(dsid);
    %* loop through alltit1 and do the following for each iteration;
        %do %while (%sysfunc(fetch(&dsid)) eq 0);
            %let counter=%eval(&counter.+1);
            %put %str(Processing file &counter of %cmpres(&numfiles.) (%cmpres(&tabledata.)));
            *retrieve displayed variables;
            *retrieve page variable;

            %let page=%str();
            %let temp_page=%str( );
            proc sql noprint;
                select value into :test separated by ' ' from tlfmeta.allmeta(where=(tabledata="&tabledata." and variable in('BY','VAR'))) ;
                select value1 into :value1  from tlfmeta.allmeta(where=(tabledata="&tabledata." and variable in('VAR'))) ;
                select value into :sub separated by ' ' from tlfmeta.allmeta(where=(tabledata="&tabledata." and variable in('ORDER'))) ;
                select value into :page separated by ' ' from tlfmeta.allmeta(where=(tabledata="&tabledata." and variable in('PAGE'))) ;
            QUIT;

            *compare macro strings and keep vars from by/var only if not in order ;
                %let displayed_vars=%str();
                %let displayed_label=%str();
                %let displayed_page=%str();
            *find labels;
                %do i=1 %to %sysfunc(countw(&test.));
                    %let found=0;
                    %if %eval(%length(&sub))>0 %then %do;
                        %do k=1 %to %sysfunc(countw(&sub.));
                            %if %scan(&test.,&i.)=%scan(&sub.,&k.) %then %do;
                                %let found=1;
                            %END;
                        %END;
                    %end;
                    %if %eval(&found.)=0 %then %do;
                        *retrieve labels from displayed variables;
                        proc sql noprint;
                            select cats("'",label,"'") into :mylabel from dictionary.columns
                                   where libname='TLFMETA' and upcase(memname)=upcase("&tabledata.") and upcase(name)=upcase("%scan(&test.,&i.)");
                        QUIT;
                        %let displayed_vars=&displayed_vars. %scan(&test.,&i.);
                        %let displayed_label=&displayed_label. &mylabel. ;
                    %END;
                %END;
                *find pagevar;
                %if %length(&page.)>0 %then %do;
                    %do i=1 %to %sysfunc(countw(&page.));

                        %let found=0;
                        %if %eval(%length(&sub))>0 %then %do;
                            %do k=1 %to %sysfunc(countw(&sub.));
                                %if %scan(&page.,&i.)=%scan(&sub.,&k.) %then %do;
                                    %let found=1;
                                %END;
                            %END;
                        %end;
                        %if %eval(&found.)=0 %then %do;
                            %let temp_page= &temp_page %scan(&page.,&i.);
                        %END;
                    %END;
                    %let page=&temp_page.;

                %END;
            *set length of variables in dataset depending on length of resulting strings;
            *length of titles is already known;
            %let varlen= %length(&displayed_vars.);
            %let lbllen= %length(&displayed_label.);
            %let page_len=%length(&temp_page.);
            %let span_len=%length(&value1.);


            options noquotelenmax;

                data tlfmeta.&tabledata.(label="&dslabel.");
                    length tlf_title  $&title_len.. tlf_foot $&foot_len..  disp_page $&page_len.. disp_var $&varlen.. disp_lbl $&lbllen..
                    %if %eval(&span_len.)>0 %then %do;
                         spanning $&span_len.
                    %end;
                    ;
                    set tlfmeta.&tabledata.;
                    if _ordern=1 then do;
                        tlf_title =strip("&tlf_title.");
                        tlf_foot =strip("&tlf_foot.");
                        disp_var=strip("&displayed_vars.");
                        disp_lbl=strip("&displayed_label.");
                        disp_lbl=translate(disp_lbl,'"',"'");
                        disp_page=strip("&page");
                        %if %eval(&span_len.)>0 %then %do;
                         spanning=strip("&value1.");
                        %end;
                    end;

                RUN;

            options quotelenmax;


        %end;
    %end;
    %let rc=%sysfunc(close(&dsid));
    options notes;
%MEND _merger;
%_merger;

%endprog;