library(readxl)
filepath = "E:\\scientific_project\\Diet\\UKB_food_preference_data_SEM_VBM_DTI_G123vsG4_ttest_post_hoc.xlsx"
data = read_excel(filepath,sheet = 'G3_vs_G4')

library(lavaan)
sem_model <- '
# measurement model

mentalL =~ depressnew + anxiety + selfharm + trauma + wellbeing
cognitionL =~ Symbol_digit_substitution + Fluid_intelligence + reaction_time
brainL =~ Postcentral_L + Caudate_R + ParaHippocampal_L + Putamen_L + Putamen_R + Fusiform_L + Rolandic_Oper_R + ParaHippocampal_R + Parietal_Inf_R + SupraMarginal_R + FA01 + FA02 + FA03 + FA04 + FA05 + FA06 + FA07 + MD01 + MD02 + MD03 + MD04 + MD05 + MD06 + MD07 + MD08 + MD09 + MD10

# structural model

mentalL ~ group_ID + brainL
cognitionL ~ group_ID + brainL + mentalL
brainL ~ group_ID

'

sem_fit <- sem(sem_model, data = data, check.gradient = FALSE)
summary(sem_fit, fit.measures=TRUE, standard=TRUE)
