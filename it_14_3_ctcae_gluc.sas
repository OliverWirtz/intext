/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin’s lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_ctcae_gluc);
/*
 * Purpose          : Table 10-30 Blood glucose according grades of CTCAE term %str(%')hyperglycemia%str(%') on Day 1 of Cycles 1 to 12 (SAF)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 07JUL2020
 * Reference prog   :
 ******************************************************************************/
*retrieve data, format visit;
data glu;
    set tlfmeta.t_14_3_5_adxt_glucose_1;
    format vis tim $100.;
    label vis = 'Visit'
          tim='Time point'
          _varl_='Grade'
          ;
    where _varl_ in('Grade 1' 'Grade 2' 'Grade 3' 'Grade 4' 'Grade 1-4')
         and avisitn <13 and find(put(avisitn,z_avisit.),'DAY 1 ')>0;
    by avisitn _timepoint ;
    if first.avisitn then do;
    vis=put(avisitn,z_avisit.);
    vis=tranwrd(vis,'CYCLE','C');
    vis=tranwrd(vis,'DAY','D');
    vis=compress(vis,' ,');
    end;
    if first._timepoint then do;
    tim=put(_timepoint,_atpt.);
    tim=tranwrd(tim,'of','');
    tim=tranwrd(tim,'copanlisib/placebo','');
    end;

RUN;

%m_rename(
    indata  = glu
  , inarray = %str('_cptog1', '_cptog2', '_cptog3')
  , _split  = "@"
  , type    = 0
)
%printline(##Table 10-30);

%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = t_14_3_5_adxt_glucose
  , title     = %nrbquote(Table 10-30 Blood glucose according grades of CTCAE term %str(%')hyperglycemia%str(%') on Day 1 of Cycles 1 to 12 (SAF) )
  , keepftn   = N
  , foot      = %nrbquote(CTCAE = Common Terminology Criteria for Adverse Events; EOT = End of treatment; N = Total number of
patients (100%); n = Number of patients with event; SAF = Safety analysis set a. On C1D1 patients were to be fasting for 8 h before the copanlisib/placebo infusion.
Note: Table includes both plasma and capillary blood non-missing measurements. Patients who were not fasting could not be graded for Grade 1 and Grade 2. These patients are included in the
category 'Not graded'. Total includes all patients in the categories of grades 1-4. CTCAE Version 4.03
The post infusion timings shown in the table are all related to post end of infusion. )
, foot1     = %nrbquote(Source: Table 14.3.5/8 )
  , evaltable =
)


%datalist(
    data   = glu
  , var    = vis tim _varl_ _cptog2 _cptog3
  , maxlen = 20
  , label  = no
)

%endprog;