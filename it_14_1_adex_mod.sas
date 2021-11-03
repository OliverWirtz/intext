/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_1_adex_mod);
/*
 * Purpose          : Intext Exposure
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 08MAY2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 02JUL2020
 * Reason           : added printline and table number
 ******************************************************************************/

%macro _exmod(
       inds=t_14_1_adex_mod_trt,tabno=1
       , _title=%str(Copanlisib/Placebo - Summary of dose modifications (safety analysis set))
       , type=type
       );

data all0;
    set tlfmeta.&inds._1;
    format text1 $300.;
    by &type. _ord type2;
    *delete repeats;
    if ~first.type2 then do;
        call missing(type2);
        if ~missing(column) then do;
            type2='    '||column;
            call missing(column);
        END;
    end;
    else if ~first.&type. and ~missing(column) then do;
        text1='    '||column;
        Type2='  '||type2;
        call missing(column);
        output;
        type2='  '||text1;
        output;
    END;
    *populate section heading;
    if first.&type. then do;
        text1=type2;
        type2=type;
        output;
        type2='  '||text1;
        output;
    END;
    else if missing(text1) then do;
        type2='  '||type2;
        output;
    end;
RUN;

proc sort data=all0;
    by _ordern;
RUN;
data all1;
    set all0;
    by  _ordern ;
    *set columns to missing for section headings;
    if first._ordern and not last._ordern then do;
        call missing(_3,_2,_1);
    END;

RUN;
%printline(##Table %sysfunc(scan(&_title.,2,' ')));
  %m_itmtitle(
      mymeta    = tlfmeta
    , tableno   = &tabno.
    , itdata    = &inds.
    , title     = &_title.
    , foot      = %nrbquote(Max = Maximum, Min = Minimum; N = Total number of patients (100%); StD = Standard deviation a. Dose interruptions: infusion(s) stopped earlier than specified in the protocol or stopped and re-started
(scheduled drug holidays are not dose interruptions). Dose delay: infusion(s) given later than the planned schedule or the drug holiday was longer than planned. It was not applicable for the first administration of study drug at
the start of the study. b. Patients which had a dose reduction of copanlisib/placebo were allowed to re-escalate. Note: Interruptions becoming permanent study treatment discontinuation before resumption of study treatment were not
accounted as an interruption. Source: Table 14.1.6/5 )
    , foot1     =
    , evaltable =
  )
  %datalist(
      data            = all1
    , var             = type2 _1 _2 _3
    , split           = '/ * @'
    , optimal=yes
    , maxlen=40
)

%mend _exmod;
%_exmod(inds=t_14_1_adex_mod_trt,tabno=1, _title=%str(Table 10-3 Copanlisib/placebo - Summary of dose modifications (SAF)), type=_ord3);
%_exmod(inds=t_14_1_adex_mod_ritux,tabno=1, _title=%str(Table 10-4 Rituximab - Summary of dose modifications (SAF)));
