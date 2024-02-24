clear
clc

datapath = '/public/home/zhangruohan/ScientificProject/Diet';
load(fullfile(datapath,'data','UKB_food_preference_with0.3NaN_imputed_K7.mat'));
load(fullfile(datapath,'data','UKB_food_preference_category_fields_V2.mat'));
cd(fullfile(datapath,'code'))

normalize_food_preference = food_preference_imputed;
temp_data = table2array(normalize_food_preference(:,2:end));
temp_data = temp_data ./ sum(temp_data);
normalize_food_preference(:,2:end) = array2table(temp_data);

TableVars = fieldnames(normalize_food_preference);
food_CateNames = fieldnames(food_preference_category);
food_preference_SubID = food_preference_imputed.eid;

%% PCA on each category of the food liking data
for i = 1:length(food_CateNames)
    disp(i)
    food_category_data(i).food_name = food_CateNames{i,1};
    food_cate_fields = cellstr(strcat('x',num2str(food_preference_category.(food_CateNames{i,1})),'_0_0'));
    [lia,locb] = ismember(food_cate_fields,TableVars);
    if all(lia)
        food_category_data(i).data = food_preference_imputed(:,[1;locb]);
        food_category_data(i).normalize_data = normalize_food_preference(:,[1;locb]);
        
        data = table2array(food_category_data(i).normalize_data(:,2:end));
        data = zscore(data);
        [~,score,~,~,explained] = pca(data);
        explained = explained ./ 100;
        for num_pc = 1:size(data,2) 
            if sum(explained(1:num_pc)) >= 0.8 % Variance explained rate
                break;
            end
        end
        food_category_data(i).optimal_num_pc = num_pc;
        food_category_data(i).sub_top_pc_scores = score(:,1:num_pc);
        food_category_data(i).contribute_rate = explained(1:num_pc)';
        food_category_data(i).cum_contribute_rate = sum(food_category_data(i).contribute_rate);
        food_category_data(i).sub_total_top_pc_score = food_category_data(i).sub_top_pc_scores * food_category_data(i).contribute_rate';
    else
        continue;
    end
end

%% Hierarchical clustering to identify subtypes
allsub_top_pc_scores = [];
for i = 1:length(food_category_data)
    allsub_top_pc_scores = [allsub_top_pc_scores food_category_data(i).sub_top_pc_scores];
end
Z = linkage(allsub_top_pc_scores,'ward');
food_category_clustering.SubID = food_preference_SubID;
food_category_clustering.cluster_results = Z;
for num_group = 3:5
    T = cluster(Z,'maxclust',num_group);
    str = strcat('clusters_',num2str(num_group));
    food_category_clustering.(str) = T; 
end

savefile = fullfile(datapath,'new_results','UKB_food_preference_imputed_PCA_clustering_V2.mat');
save(savefile,'food_category_data','food_category_clustering');

