*here is the data
use "C:\Users\LeeGr\OneDrive\Documents\Spring 2017\587\Homework\personal paper model\GSS_pane1208123_R1_V1.dta", clear

*setting up panel data 
xtset idnum panelwave
svyset wtpannr123

*recoding and creation of new vars
 
gen joblose_dum = (joblose == 1 | joblose== 2) if joblose<.
gen union_dum = (union== 1 | union ==3) if union <.
gen female = (sex ==2) if sex <.
gen married = (marital == 1) if marital <.
gen white= (race ==1) if race <.
gen black= (race==2) if race <.
gen otherrace= (race==3) if race <.
gen parttime = (partfull == 2) if partfull<.
gen no_childern= (child==0) if childs<.
gen immigrant = (born == 2) if born<.
gen incomehigh_dum = (realinc > 119606) if realinc <.
gen govwork = (wrkgov == 1) if wrkgov <.
gen age_sq = age^2 if age <.
gen exp = age - educ - 6 if age <.
gen exp_sq = exp^2
gen lninc = ln(realinc) if realinc <.


*Hausman Test (random or fixed effects) --> random 
xtlogit joblose_dum union_dum realinc age educ married childs parttime,fe 
estimates store fixed
xtlogit joblose_dum union_dum realinc age educ married childs parttime ///
 white black female,re
*should add a regional varible to the random effects 
estimates store random
hausman fixed random
*yeah cannot do fixed effects sample is too small and union membership does not change that often 


*other models 
xtprobit joblose_dum union_dum realinc age educ married childs parttime,re
estat ic 
xtologit joblose union_dum realinc age educ married white black parttime, vce(robust)
estat ic 
xtlogit joblose_dum union_dum realinc incomehigh_dum age educ i.marital childs parttime ///
 i.race female immigrant, re
estat ic 
 
 
 
*2.0 workfile 
xtprobit joblose_dum union_dum realinc age age_sq educ married childs ///
 parttime white black female immigrant govwork,re
estat ic 
*you know or this one 
xtlogit joblose_dum union_dum realinc age age_sq educ married childs ///
 parttime white black female immigrant govwork,re 
estat ic 
*need to include the class varible into my regression... self reported cannot use 

*do not want to run every time (curses stata IC)
*keep joblose_dum union_dum realinc age educ marital married childs parttime race female immigrant sex union joblose married white black otherrace govwork exp age_sq exp_sq lninc idnum panelwave

*In case I want a Baseline --> nevermind it is not significant
xtlogit joblose_dum union_dum 
xtlogit joblose_dum union_dum, re

*BIC test
quietly xtlogit joblose_dum union_dum lninc age age_sq educ married childs ///
 parttime i.race female immigrant govwork, re vce(robust)
estat ic
quietly xtlogit joblose_dum union_dum lninc age age_sq educ married childs ///
 parttime i.race female immigrant govwork, re
estat ic
 
*summary stats 
quietly logit joblose_dum union_dum realinc age educ married childs ///
 year parttime black otherrace female immigrant govwork
estat sum

*final logit model model (for now)
xtlogit joblose_dum union_dum lninc age age_sq educ married childs ///
 parttime i.race female immigrant govwork, re
*outreg2 using table1.doc, replace ctitle (Logit)


*odds-ratios
xtlogit joblose_dum union_dum lninc age age_sq educ married childs ///
 parttime i.race female immigrant govwork, re or
*outreg2 using table1.doc, append ctitle(odds ratio) eform

*At mean margins 
quietly xtlogit joblose_dum union_dum lninc age age_sq educ married childs ///
 parttime i.race female immigrant govwork, re
margins, predict(pu0) dydx(*)
*outreg2 using table1.doc, append ctitle(margins)
