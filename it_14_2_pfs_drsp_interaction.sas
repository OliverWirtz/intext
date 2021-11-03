/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin's lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_2_pfs_drsp_interaction);
/*
 * Purpose          : Table 9-21 Treatment-interaction analyses for PFS - Independent assessments (FAS)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 04AUG2020
 * Reference prog   :
 ******************************************************************************/
%macro inter(tableno=1
       ,data=t_14_2_5_adtte_trt_interact3
       , Title=%nrbquote(Table 9-19 Treatment-interaction analyses for PFS - Independent assessments (FAS) )
       ,foot=%nrbquote(FAS = Full analysis set; PFS = Progression-free survival Note: The p-value for the interaction
 of treatment and subgroup are obtained using a cox proportional hazard
model. Source: Table 14.2.5.2/95 )
);
data int;
    set tlfmeta.&data._&tableno.;
    label subgroup="";
RUN;


%printline(##Table %sysfunc(scan(&title.,2,' ')));
%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = &tableno.
  , itdata    = t_14_2_5_adtte_trt_interact3
  , title     =&title.
  ,foot=&foot.
  ,keepftn=N
  ,evaltable =
)
data work._ittitles2;
    set _ittitles2;
    if variable='FOOTNOTE2' then call missing(value);
RUN;

%datalist(
    data   = int
  , var    = subgroup _pchisq
  , maxlen = 50
  , label  = no
)

proc datasets lib=work kill memtype=data nolist;
quit;
%mend;
%inter(tableno=1
       ,data=t_14_2_5_adtte_trt_interact3
       , Title=%nrbquote(Table 9-19 Treatment-interaction analyses for PFS - Independent assessments (FAS) )
       ,foot=%nrbquote(FAS = Full analysis set; PFS = Progression-free survival Note: The p-value for the interaction
 of treatment and subgroup are obtained using a cox proportional hazard
model. Source: Table 14.2.5.2/95 ))

%inter(tableno=1
       ,data=t_14_2_5_adtte_trt_interact2
       , Title=%nrbquote(Table 9-29 Treatment-interaction analyses for time to deterioration in DRS-P (FAS) )
       ,foot=%nrbquote(DRS-P = Disease-related symptoms - physical (subscale); FAS = Full analysis set
Note: The p-value for the interaction of treatment and subgroup are obtained using a cox proportional hazard
model.
Source: 14.2.5.2/98  ));

%inter(tableno=1
       ,data=t_14_2_5_adtte_trt_interact
       , Title=%nrbquote(Table 9-32 Treatment-interaction analyses for time to improvement in DRS-P (FAS) )
       ,foot=%nrbquote(DRS-P = Disease-related symptoms - physical (subscale); FAS = Full analysis set
Note: The p-value for the interaction of treatment and subgroup are obtained using a cox proportional hazard
model.
Source: 14.2.5.2/97  ))
%endprog;


