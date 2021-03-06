clc
clear 
close all

addpath('utils/')

% all of the data sets that have been tested. all of the data sets are
% saved in a private repo. 
all_datas_2 = {
  'bank';
  'blood';
  'breast-cancer-wisc-diag';
  'breast-cancer-wisc-prog';
  'breast-cancer-wisc';
  'breast-cancer';
  'congressional-voting';
  'conn-bench-sonar-mines-rocks';
  'credit-approval';
  'cylinder-bands';
  'echocardiogram';
  %'fertility';
  'haberman-survival';
  'heart-hungarian';
  'hepatitis';
  'ionosphere';
  'mammographic';
  'molec-biol-promoter';
  'musk-1';
  'oocytes_merluccius_nucleus_4d';
  'oocytes_trisopterus_nucleus_2f';
  'ozone';
  'parkinsons';
  'pima';
  %'pittsburg-bridges-T-OR-D';
  'planning';
  'ringnorm';
  'spambase';
  'spectf_train';
  'statlog-australian-credit';
  'statlog-german-credit';
  'statlog-heart';
  'titanic';
  'twonorm';
  'vertebral-column-2clases'};

n_data = length(all_datas_2);
all_parameters = cell(n_data, 5);
all_errors = zeros(n_data, 5);

% delete(gcp('nocreate'));
% parpool(4);

% loop over all of the data sets
for nn = 1:n_data
  data_tr = load(['~/Git/ClassificationDatasets/csv/', all_datas_2{nn}, '_train.csv']);
  data_te = load(['~/Git/ClassificationDatasets/csv/', all_datas_2{nn}, '_test.csv']);
  str = [all_datas_2{nn}, ' & '];
  
  for ee = 1:4
    % load the result file that contains the parameters of the classifier
    % then load the data set 
    load(['outputs/result_', all_datas_2{nn}, '_moo_exp0', num2str(ee), '.mat']);
    
    % find the number of parameters that were on the pareto front and
    % search for the parameters that give use the smallest cross validation
    % error. 
    nn_params = size(x, 1);
    err = 100000000000;
    min_param = [];
    for np = 1:nn_params
      % measure the error for the `np-th` parameter then check if is the
      % smallest we've come across 
      %current_err = run_cv(data, x(np, 1), x(np, 2));
      current_err = run_alg_params(data_tr, data_te, x(np, 1), x(np, 2));
      if current_err<err
        err = current_err;
        min_param = x(np, :);
      end
    end
    
    % save off the best parameters 
    str = [str, num2str(err), ' & '];
    all_errors(nn, ee) = err;
    all_parameters{nn, ee} = min_param;
  end
  
  load(['outputs/result_', all_datas_2{nn}, '_matlab.mat']);
  %current_err = run_cv(data, x(1), x(2));
  current_err = run_alg_params(data_tr, data_te, x(1), x(2));
  str = [str, num2str(current_err), ' & '];
  all_errors(nn, 5) = current_err;
  all_parameters{nn, 5} = x;
    
  str = [str(1:end-2), '\\'];
  disp(str);
  
end

% delete(gcp);
clearvars -except all_datas_2 all_errors all_parameters
save('outputs/cross_validation_tables.mat');

