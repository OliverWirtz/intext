/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_adae_mlg);
/*
 * Purpose          : Table 10-32/38 Overview of TEAEs in the MLG for hyperglycemia/hypertension (SAF)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 17AUG2020
 * Reference prog   :
 ******************************************************************************/

%macro mlg(data=t_14_3_5_adae_hyperglycemia
       ,title=%NRBQUOTE(Table 10-32 Overview of TEAEs in the MLG for hyperglycemia (SAF) )
       ,foot1=%NRBQUOTE(Source: Table 14.3.5/7 ));

data mlg;
    set tlfmeta.&data._1;
    where _name_ in('         Worst grade Grade 1'
          '                     Grade 2'
          '                     Grade 3'
          '                     Grade 4'
          '                     Grade 5 (death)'
          '                     Missing') or find(_name_,'Any')>0 ;

RUN;
%m_rename(
    indata  = mlg
  , inarray = %str('_col1_', '_col2_')
  , _split  = "@"
  , type    = 0
)
%printline(##Table %scan(&title.,2,' '))
%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = &data.
  , title     = &title.
  , keepftn   = N
  , foot      = %NRBQUOTE(MLG = Medical labelling group; N = Total number of patients (100%); n = Number of patients with event; SAF
= Safety analysis set; TEAE = Treatment-emergent adverse event; TESAE = Treatment-emergent serious adverse event Notes: Any TEAE
includes patients with grade not available for all adverse events. CTCAE Version 4.03 )
  , foot1     = &foot1.
  , evaltable =
)

%datalist(
    data   = mlg
  , var    = _name_ _col1_ _col2_
  , maxlen = 20
  , label  = no
)



%endprog;
%mend mlg;
%mlg(data=t_14_3_5_adae_hyperglycemia
,title=%NRBQUOTE(Table 10-32 Overview of TEAEs in the MLG for hyperglycemia (SAF) )
,foot1=%NRBQUOTE(Source: Table 14.3.5/7 )
);

%mlg(data=t_14_3_5_adae_hypertension
,title=%NRBQUOTE(Table 10-36 Overview of TEAEs in the MLG for hypertension (SAF) )
,foot1=%NRBQUOTE(Source: Table 14.3.5/22 ))
