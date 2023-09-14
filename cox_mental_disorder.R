datapath <- "E:\\scientific_project\\Diet\\UKB_food_group_mental_disorder_survival_data.csv"
food_group_survival_data <- read.csv(datapath)

library("survival")
library("survminer")
library("nnet")

group = class.ind(food_group_survival_data$clusters_4)
food_group_survival_data$group_ID_1 = group[,1]
food_group_survival_data$group_ID_2 = group[,2]
food_group_survival_data$group_ID_3 = group[,3]

results1 <- coxph(Surv(anxiety_days_ins0,anxiety_status==1) ~ group_ID_1 + group_ID_2 + group_ID_3 + sex + age + BMI + 
                    qualifications + townsend_index, data = food_group_survival_data)

results2 <- coxph(Surv(depression_days_ins0,depression_status==1) ~ group_ID_1 + group_ID_2 + group_ID_3 + sex + age + BMI + 
                    qualifications + townsend_index, data = food_group_survival_data)

results3 <- coxph(Surv(eating_disorder_days,eating_disorder_status==1) ~ group_ID_1 + group_ID_2 + group_ID_3 + sex + age + BMI + 
                     qualifications + townsend_index, data = food_group_survival_data)

results4 <- coxph(Surv(stroke_days_ins0,stroke_status==1) ~ group_ID_1 + group_ID_2 + group_ID_3 + sex + age + BMI + 
                    qualifications + townsend_index, data = food_group_survival_data)





