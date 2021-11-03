%MACRO _get_it_label(inds=tot,invar=col3,type=0, debug=n)
/ DES = 'create label for spanning headers';
/*******************************************************************************
 * Bayer AG
 * Macro rely on: pure SAS
 *******************************************************************************
 * Purpose          : create label for spanning headers
 * Programming Spec :
 * Validation Level : 1 - Verification by review
 * Parameters       :
 *                    param1 : dataset name
 *                    param1 : target column
 * SAS Version      : Linux 9.4
 *******************************************************************************
 * Preconditions    :
 *     Macrovar. needed:
 *     Datasets  needed:
 *     Ext.Prg/Mac used:
 * Postconditions   :
 *     Macrovar created:
 *     Output   created:
 *     Datasets created:
 * Comments         : a very simple inline macro to produce the code needed to get
 *                     the spanning header label for outputs from the target column
 *******************************************************************************
 * Author(s)        : gghcj (Oliver Wirtz) / date: 23APR2020
 *******************************************************************************
 * Change History   :
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 05MAY2020
 * Reason           : reversed LPL/WM
 ******************************************************************************/
/* Changed by       : gghcj (Oliver Wirtz) / date: 18MAY2020
 * Reason           : translate # to @
 ******************************************************************************/

/*******************************************************************************
 * Examples         :
   %_get_it_label();
 ******************************************************************************/





        format _myl $100.;


        _myl=vlabel(&invar.);
        _myl=translate(_myl,'@','#');
        %if %eval(&type)=0 %then %do;
            _myl=substr(_myl,1,find(_myl,'(')-1);
            _myl=substr(_myl,find(_myl,'@')+1);
        %end;
        %else %do;
            _myl=substr(_myl,find(_myl,'(')+1,find(_myl,')')-find(_myl,'(')-1);
        %end;
        %if &inds=tot %then %do;
            %if %eval(&type)=0 %then %do;
                _myl=cats("Total iNHL@(FL,MZL,SLL,LPL/WM)","@",_myl);
            %end;
            %else %do;
                _myl=cats("Total iNHL@(FL,MZL,SLL,LPL,WM)","@",_myl);
            %end;
        %END;
        %else %do;
            _myl=cats("&inds.","@",_myl);
        %END;

        call symput("_my&inds.",_myl);
        %if %upcase(&debug.)=N %then %do;
            drop _myl;
        %END;



%MEND _get_it_label;
