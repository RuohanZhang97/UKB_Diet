clear
clc

load('anova_UKB_food_preference_imputed_PCA_clustering_mental_health.mat');
FieldNames = fieldnames(mental_food_group_scores(2).final_food_group_average_score_scaled);
FieldNames = FieldNames(2:end-3,1);

tbl_savefile = 'ttest_UKB_food_preference_mental_health_S123vsS4.xlsx';
for group_ind = 1:3
    ttest_mental_food_group_results(group_ind).Groups = strcat(num2str(group_ind),'_vs_4');
    
    tbl = table;
    tbl.Field_Descrip = FieldNames;
    tbl.(strcat('Group_',num2str(group_ind))) = table2array(mental_food_group_scores(2).final_food_group_average_score(group_ind,2:end))';
    tbl.Group_4 = table2array(mental_food_group_scores(2).final_food_group_average_score(4,2:end))';
    pVal = zeros(length(FieldNames),1);
    tVal = zeros(length(FieldNames),1);
    Group_NumSub = zeros(length(FieldNames),1);
    G4_NumSub = zeros(length(FieldNames),1);
    
    for i = 1:length(FieldNames)
        tmp_regressed_data = anova_mental_food_group_results(2).(strcat(FieldNames{i,1},'_regressed_score'));
        tmp_group_id = anova_mental_food_group_results(2).final_food_group_ind;
        [~,p,~,stats] = ttest2(tmp_regressed_data(tmp_group_id == group_ind),tmp_regressed_data(tmp_group_id == 4));
        pVal(i,1) = p;
        tVal(i,1) = stats.tstat;
        ttest_mental_food_group_results(group_ind).(strcat(FieldNames{i,1},'_tVal')) = stats.tstat;
        ttest_mental_food_group_results(group_ind).(strcat(FieldNames{i,1},'_pVal')) = p;
        ttest_mental_food_group_results(group_ind).(strcat(FieldNames{i,1},'_Group_NumSub')) = sum(tmp_group_id == group_ind);
        ttest_mental_food_group_results(group_ind).(strcat(FieldNames{i,1},'_G4_NumSub')) = sum(tmp_group_id == 4);
        Group_NumSub(i,1) = sum(tmp_group_id == group_ind);
        G4_NumSub(i,1) = sum(tmp_group_id == 4);
    end
    tbl.tVal = tVal;
    tbl.pVal = pVal;
    tbl.Group_NumSub = Group_NumSub;
    tbl.G4_NumSub = G4_NumSub;
    tbl = sortrows(tbl,'pVal');
    writetable(tbl,tbl_savefile,'Sheet',ttest_mental_food_group_results(group_ind).Groups);
end

