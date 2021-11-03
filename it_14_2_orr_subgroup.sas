/*******************************************************************************
 * Bayer AG
 * Study            : 17067 A Phase III, randomized, double-blind,
 *   placebo-controlled study evaluating the efficacy and safety of copanlisib
 *   in combination with rituximab in patients with relapsed indolent B-cell
 *   non-Hodgkin’s lymphoma (iNHL)
 * Proj/Subst/Pool  : 806946 / Aliqopa BAY 80-6946, ICPP, General
 *******************************************************************************
 *Name of program**************************************************************/
   %iniprog(name = it_14_2_orr_subgroup);
/*
 * Purpose          : Table 9-23 Other subgroup analysis of ORR by independent assessment (FAS)
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Pre-conditions   :
 * Post-conditions  :
 * Comments         :
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 30JUN2020
 * Reference prog   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 04AUG2020
 * Reason           : changed table number
 ******************************************************************************/

data in(keep=subgroup text ttt30 ttt31 _ordern ord)
     smalln(keep=subgroup text ttt30a ttt31a _ordern )
     header(keep= subgroup _ordern text ord);
    set tlfmeta.t_14_2_5_adrs_onccat_5_4_su_1
        tlfmeta.t_14_2_5_adrs_onccat_5_4_su_3
        tlfmeta.t_14_2_5_adrs_onccat_5_4_su_5
        tlfmeta.t_14_2_5_adrs_onccat_5_4_su_7
        tlfmeta.t_14_2_5_adrs_onccat_5_4_su_9
        tlfmeta.t_14_2_5_adrs_onccat_5_4_su_11
        tlfmeta.t_14_2_5_adrs_onccat_5_4_su_13
        tlfmeta.t_14_2_5_adrs_onccat_5_4_su_15
        tlfmeta.t_14_2_5_adrs_onccat_5_4_su_17
        tlfmeta.t_14_2_5_adrs_onccat_5_4_su_19
        tlfmeta.t_14_2_5_adrs_onccat_5_4_su_21;
    by seq;
    where find(lowcase(_label_),'objective')>0 or _label_='Best overall response' ;
    ord=_n_;
    format ttt30a ttt31a $100.;
    label ttt30a='n'
          ttt31a='n'
          ttt30='ORR@n (%)'
          ttt31='ORR@n (%)'
          subgroup='Variable@  Subgroup'
          ;

    if _label_='Best overall response'  then do;
        *extract n;
        ttt30a=substr(scan(ttt30,1),anydigit(ttt30));
        ttt31a=substr(scan(ttt31,1),anydigit(ttt31));
        output smalln;
    END;
    else do;
        ttt30=substr(ttt30,1,find(ttt30,'[')-1);
        ttt31=substr(ttt31,1,find(ttt31,'[')-1);
        text=substr(subgroup,find(subgroup,':')+1);
        output in;
        if _ordern=29 then do;
            _ordern=28;
            text=substr(subgroup,1,find(subgroup,':')-1);

            output header;
        END;
    end;
RUN;

*merge n;
proc sql noprint;
    create table in1 as select a.*, b.ttt30a, b.ttt31a from in as a left join smalln as b on a.subgroup=b.subgroup;
QUIT;

*addd header lines;
data in2;
    set in1 header;

RUN;
proc sort data= in2;
    by ord _ordern ;
RUN;
%printline(##Table 9-21);
%m_itmtitle(
    mymeta    = tlfmeta
  , mymetadat = allmeta
  , tableno   = 1
  , itdata    = t_14_2_5_adrs_onccat_5_4_su
  , title     = %nrbquote(Table 9-21 Other subgroup analysis of ORR by independent assessment (FAS) )
  , keepftn   = N
  , foot      = %nrbquote(BMI = Body mass index; ECOG = Eastern Cooperative Oncology Group; FAS = Full analysis set; FL =
Follicular lymphoma; ; iNHL = Indolent non-Hodgkin's lymphoma; LPL = Lymphoplasmacytoid lymphoma;
MZL = Marginal-zone lymphoma; N = Total number of patients (100%); n = number of patients with event;
ORR = Objective response rate; PI3K = Phosphatidylinositol-3-kinase; SLL = Small lymphocytic
lymphoma; WM = Waldenstroem macroglobulinemia )
  , foot1     = %str(Source: Tables 14.2.5.2/29, 14.2.5.2/31, 14.2.5.2/33, 14.2.5.2/35, 14.2.5.2/39, 14.2.5.2/41, 14.2.5.2/43,
14.2.5.2/45, 14.2.5.2/47, 14.2.5.2/49 )
  , evaltable =
)

%datalist(
    data   = in2
  , var    = text ('Copanlisib/rituximab' ttt30a ttt30) ('Placebo/rituximab' ttt31a ttt31 )
  , maxlen = 40
  , label  = no
)

%endprog;
