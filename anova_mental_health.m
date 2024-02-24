clear
clc

datapath = '/public/home/zhangruohan/ScientificProject/Diet';
load(fullfile(datapath,'new_results/UKB_food_preference_imputed_PCA_clustering.mat'));
metal_health = readtable(fullfile(datapath,'data','mental.csv'));
metal_health = rmmissing(metal_health);
load(fullfile(datapath,'data','UKB_covariates_full.mat'));

cov = table;
cov.SubID = covariates.SubID;
cov.sex = covariates.Sex;
cov.age = covariates.Age;
cov.BMI = covariates.BMI;
cov.qualifications = covariates.Qualifications;
cov.townsend_index = covariates.Townsend_index;
cov = rmmissing(cov);

[mental_cov_SubID,ind_mental,ind_cov] = intersect(metal_health.SubID,cov.SubID);
mental_names = fieldnames(metal_health);
mental_names = mental_names(2:end-3,1);
temp_mental_health = metal_health(ind_mental,:);
temp_cov = table2array(cov(ind_cov,2:end));

[mental_cov_food_SubID,ind_mental_cov,ind_food] = intersect(mental_cov_SubID,food_category_clustering.SubID);
final_mental_health = temp_mental_health(ind_mental_cov,:);
final_cov = temp_cov(ind_mental_cov,:);

Levenetest_results = struct([]);
num_group = 4;
anova_mental_food_group_results.num_group = num_group;
str = strcat('clusters_',num2str(num_group));
temp_group_ind = food_category_clustering.(str);
temp_group_ind = temp_group_ind(ind_food,:);
anova_mental_food_group_results.final_food_group_ind = temp_group_ind;
anova_mental_food_group_results.final_food_SubID = mental_cov_food_SubID;
anova_mental_food_group_results.NumSub = length(mental_cov_food_SubID);

Levenetest_results.num_group = num_group;
Levenetest_pVal = zeros(length(mental_names),1);
Levenetest_FVal = zeros(length(mental_names),1);
tmp_Levenetest = table;
tmp_Levenetest.FieldNames = mental_names;

for j = 1:length(mental_names)
    [b,~,r] = regress(final_mental_health.(mental_names{j,1}),[ones(size(final_cov,1),1) final_cov]);
    regressed_score = b(1) + r;
    anova_mental_food_group_results.(strcat(mental_names{j,1},'_regressed_score')) = regressed_score;
    [Levenetest_pVal(j,1),Levenetest_FVal(j,1)] = Levenetest([regressed_score temp_group_ind]);
    [p,tbl] = anova1(regressed_score, temp_group_ind, 'off');
    Fstat = tbl{2,5};
    anova_mental_food_group_results.(strcat(mental_names{j,1},'_Fstat')) = Fstat;
    anova_mental_food_group_results.(strcat(mental_names{j,1},'_pVal')) = p;
end
tmp_Levenetest.Fval = Levenetest_FVal;
tmp_Levenetest.pVal = Levenetest_pVal;
Levenetest_results.test_results = tmp_Levenetest;


for i = 1:length(anova_mental_food_group_results)
    mental_food_group_scores(i).num_group = anova_mental_food_group_results(i).num_group;
    mental_food_group_scores(i).final_food_group_ind = anova_mental_food_group_results(i).final_food_group_ind;
    for j = 1:length(mental_names)
        temp_mental_score = anova_mental_food_group_results(i).(strcat(mental_names{j,1},'_regressed_score'));
        for k = 1:max(mental_food_group_scores(i).final_food_group_ind)
            temp_tbl(k).group_ind = k;
            temp_tbl(k).(mental_names{j,1}) = mean(temp_mental_score(mental_food_group_scores(i).final_food_group_ind == k));
        end
    end
    mental_food_group_scores(i).final_food_group_average_score = struct2table(temp_tbl);
    temp_scaled_tbl = mental_food_group_scores(i).final_food_group_average_score;
    for j = 1:length(mental_names)
        temp_scaled_tbl.(mental_names{j,1}) = normalization(temp_scaled_tbl.(mental_names{j,1}),1,max(mental_food_group_scores(i).final_food_group_ind));
    end
    mental_food_group_scores(i).final_food_group_average_score_scaled = temp_scaled_tbl;
end
savefile = fullfile(datapath,'new_results/anova_UKB_food_preference_imputed_PCA_clustering_mental_health.mat');
save(savefile,'anova_mental_food_group_results','mental_food_group_scores','Levenetest_results');


