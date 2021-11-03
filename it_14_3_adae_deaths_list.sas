/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_3_adae_deaths_list);
/*
 * Purpose          : Table 10-17 Summary of deaths during study treatment or within 30 days after permanent discontinuation of study treatment (SAF)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 06JUL2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 13AUG2020
 * Reason           : changed source table
 ******************************************************************************/

data death;
    set tlfmeta.t_14_3_2_death_list_1;
    by trt01an;
    label _aeterm="MedDRA PT (v. &meddrav.)"
          subj="Patient ID";
    format subj $200.;
    subj=put(subjidn,9.);
    if first.trt01an then do;
        output;
        call missing(AESPID , ASR , DSDCAUSE , dthdtl , HISTGRPN , SUBJIDN , tlf_title ,  _1_b1 , _1_b2 , _1_b3 , _1_b4 , _1_b5 , _1_b6 , _1_b7 , _aeterm , _cr1 , _n_free , _n_freeR , _n_tog , _n_togR , _n_tog_uni , _obsid_ , _orderN , _rel , _time , _time_l
);
        subj=compress(put(trt01an,z_trt.));
        output;
    end;
    else output;
RUN;
proc sort data=death;
    by trt01an subjidn;
RUN;
%printline(##Table 10-16);

%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = t_14_3_2_death_list
  , title     = %nrbquote(Table 10-16 Summary of deaths during study treatment or within 30 days after permanent discontinuation of study treatment (SAF) )
  , keepftn   = N
  , foot      = %nrbquote(ID = Identification; MedDRA = Medical Dictionary for Regulatory Activities; SAF = Safety analysis set; PT = Preferred term
Notes:@Race: A: Asian, B: Black or African American, W: White; Sex: F: Female, M: Male@The unit of 'Age' is years. Relative Day is the day relative to the start or end of study drug.
)
  , foot1     = %nrbquote(Source: Table 14.3.2/1 )
  , evaltable =
)


%datalist(
    data   = death
  , var    = subj asr _time_l dsdcause _aeterm _rel
  , maxlen = 20
  , label  = no
  ,split='#'
)

%endprog(
    cleanWork       = y
  , cleanTitlesFoot = y
  , verbose         = Y
)