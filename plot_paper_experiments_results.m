
% Set here the BAdaCost matlab toolbox for detection (modification from P.Dollar's one):
TOOLBOX_BADACOST_PATH = '/home/jmbuena/matlab/toolbox.badacost';
KITTI_PATH = '/home/imagenes/CARS_DATABASES/KITTI_DATABASE/';
OUTPUT_DATA_PATH =  'KITTI_CARS_DETECTION_EXPERIMENTS';
PREPARED_DATA_PATH =  'KITTI_TRAINING_DATA';

addpath(genpath('kitti_plot_results'));

% ------------------------------------------------------------------------
% Plot experiments on SAMME: nNeg and nAccNeg
clear results_dirs;
clear legend_text;
results_dirs{1} = fullfile(OUTPUT_DATA_PATH, 'SAMME_D_7_T_1024_N_5000_NA_20000');
legend_text{1} = 'SAMME, N=5k, NA=20k';
results_dirs{2} = fullfile(OUTPUT_DATA_PATH, 'SAMME_D_7_T_1024_N_7500_NA_30000');
legend_text{2} = 'SAMME, N=7.5k, NA=30k';
results_dirs{3} = fullfile(OUTPUT_DATA_PATH, 'SAMME_D_7_T_1024_N_10000_NA_40000');
legend_text{3} = 'SAMME, N=10k, NA=40k';
fig_filename = 'FIGURES_LDCF_SAMME_nNeg_nAccNeg';
plot_result_fig_kitti(PREPARED_DATA_PATH, OUTPUT_DATA_PATH, results_dirs, legend_text, fig_filename);

BEST_N = 7500;
BEST_NA = 30000;
 
% ------------------------------------------------------------------------
% Plot experiments on SAMME: Tree depth
clear results_dirs;
clear legend_text;
results_dirs{1} = fullfile(OUTPUT_DATA_PATH, 'SAMME_D_6_T_1024_N_7500_NA_30000');
legend_text{1} =  'SAMME, D=6';
results_dirs{2} = fullfile(OUTPUT_DATA_PATH, 'SAMME_D_7_T_1024_N_7500_NA_30000');
legend_text{2} =  'SAMME, D=7';
results_dirs{3} = fullfile(OUTPUT_DATA_PATH, 'SAMME_D_8_T_1024_N_7500_NA_30000');
legend_text{3} =  'SAMME, D=8';
results_dirs{4} = fullfile(OUTPUT_DATA_PATH, 'SAMME_D_9_T_1024_N_7500_NA_30000');
legend_text{4} =  'SAMME, D=9';
fig_filename = 'FIGURES_LDCF_SAMME_TREE_DEPTH';
plot_result_fig_kitti(PREPARED_DATA_PATH, OUTPUT_DATA_PATH, results_dirs, legend_text, fig_filename);
 

% ------------------------------------------------------------------------
% Plot experiments on SAMME vs BAdaCost
clear results_dirs;
clear legend_text;
i=1;
results_dirs{i} = fullfile(OUTPUT_DATA_PATH, 'BADACOST_1_1_1_D_7_T_1024_N_7500_NA_30000');
legend_text{i} =  'BAdaCost, 1-1-1, D=7';
i=i+1;
results_dirs{i} = fullfile(OUTPUT_DATA_PATH, 'BADACOST_1_2_2_D_7_T_1024_N_7500_NA_30000');
legend_text{i} =  'BAdaCost, 1-2-2, D=7';
i=i+1;
results_dirs{i} = fullfile(OUTPUT_DATA_PATH, 'BADACOST_1_3_2.750000e+00_D_7_T_1024_N_7500_NA_30000');
legend_text{i} =  'BAdaCost, 1-3-2.75, D=7';
i=i+1;
results_dirs{i} = fullfile(OUTPUT_DATA_PATH, 'BADACOST_1_3_3_D_7_T_1024_N_7500_NA_30000');
legend_text{i} =  'BAdaCost, 1-3-3, D=7';
i=i+1;
results_dirs{i} = fullfile(OUTPUT_DATA_PATH, 'BADACOST_1_3_3.250000e+00_D_7_T_1024_N_7500_NA_30000');
legend_text{i} =  'BAdaCost, 1-3-3.25, D=7';
i=i+1;
results_dirs{i} = fullfile(OUTPUT_DATA_PATH, 'BADACOST_1_4_4_D_7_T_1024_N_7500_NA_30000');
legend_text{i} =  'BAdaCost, 1-4-4, D=7';
i=i+1;
%results_dirs{i} = fullfile(OUTPUT_DATA_PATH, 'BADACOST_1_5_5_D_7_T_1024_N_7500_NA_30000');
%legend_text{i} =  'BAdaCost, 1-5-5, D=7';
%i=i+1;
results_dirs{i} = fullfile(OUTPUT_DATA_PATH, 'SAMME_D_7_T_1024_N_7500_NA_30000');
legend_text{i} =  'SAMME, D=7';
%i=i+1;
fig_filename = 'FIGURES_LDCF_SAMME_VS_BADACOST';
plot_result_fig_kitti(PREPARED_DATA_PATH, OUTPUT_DATA_PATH, results_dirs, legend_text, fig_filename);
 
 
% ------------------------------------------------------------------------
% Plot experiments on BAdaCost Tree Depth
clear results_dirs;
clear legend_text;
results_dirs{1} = fullfile(OUTPUT_DATA_PATH, 'BADACOST_1_3_3_D_6_T_1024_N_7500_NA_30000');
legend_text{1} =  'BAdaCost, 1-3-3, D=6';
results_dirs{2} = fullfile(OUTPUT_DATA_PATH, 'BADACOST_1_3_3_D_7_T_1024_N_7500_NA_30000');
legend_text{2} =  'BAdaCost, 1-3-3, D=7';
results_dirs{3} = fullfile(OUTPUT_DATA_PATH, 'BADACOST_1_3_3_D_8_T_1024_N_7500_NA_30000');
legend_text{3} =  'BAdaCost, 1-3-3, D=8';
results_dirs{4} = fullfile(OUTPUT_DATA_PATH, 'BADACOST_1_3_3_D_9_T_1024_N_7500_NA_30000');
legend_text{4} =  'BAdaCost, 1-3-3, D=9';
fig_filename = 'FIGURES_LDCF_BADACOST_TREE_DEPTH';
plot_result_fig_kitti(PREPARED_DATA_PATH, OUTPUT_DATA_PATH, results_dirs, legend_text, fig_filename);
 
% ------------------------------------------------------------------------
% Plot experiments on SubCat
clear results_dirs;
clear legend_text;
results_dirs{1} = fullfile(OUTPUT_DATA_PATH, 'SUBCAT_D_2');
legend_text{1} =  'SubCat, D=2';
results_dirs{2} = fullfile(OUTPUT_DATA_PATH, 'SUBCAT_D_3');
legend_text{2} =  'SubCat, D=3';
results_dirs{3} = fullfile(OUTPUT_DATA_PATH, 'SUBCAT_D_4');
legend_text{3} =  'SubCat, D=4';
results_dirs{4} = fullfile(OUTPUT_DATA_PATH, 'SUBCAT_D_5');
legend_text{4} =  'SubCat, D=5';
results_dirs{5} = fullfile(OUTPUT_DATA_PATH, 'SUBCAT_D_6');
legend_text{5} =  'SubCat, D=6';
fig_filename = 'FIGURES_LDCF_SUBCAT';
plot_result_fig_kitti(PREPARED_DATA_PATH, OUTPUT_DATA_PATH, results_dirs, legend_text, fig_filename);


% ------------------------------------------------------------------------
% Plot experiments on SAMME vs BAdaCost vs SubCat
clear results_dirs;
clear legend_text;
i = 1;
results_dirs{i} = fullfile(OUTPUT_DATA_PATH, 'BADACOST_1_3_3_D_8_T_1024_N_7500_NA_30000');
legend_text{i} =  'BAdaCost, 1-3-3, D=8';
i = i + 1;
results_dirs{i} = fullfile(OUTPUT_DATA_PATH, 'SAMME_D_8_T_1024_N_7500_NA_30000');
legend_text{i} =  'SAMME, D=8';
i = i + 1;
results_dirs{i} = fullfile(OUTPUT_DATA_PATH, 'SUBCAT_D_4');
legend_text{i} =  'SubCat, D=4';
i = i + 1;
fig_filename = 'FIGURES_LDCF_SAMME_VS_BADACOST_VS_SUBCAT';
plot_result_fig_kitti(PREPARED_DATA_PATH, OUTPUT_DATA_PATH, results_dirs, legend_text, fig_filename);
 
 
% % ------------------------------------------------------------------------
% % Plot experiments BAdaCost All
% clear results_dirs;
% clear legend_text;
% Ds = [6, 7, 8, 9];
% Ts = [750, 1024, 1500]; % 256, 512
% N = 7500;
% NA = 30000;
% useSAMME = 0;
% costsAlpha = 1;
% costsBeta = 3;
% costsGamma = 3;
% k = 1;
% for i=1:length(Ds)
%   D = Ds(i);
%   for j=1:length(Ts)
%     T = Ts(j);
%     results_dirs{k} = fullfile(OUTPUT_DATA_PATH, sprintf('BADACOST_%d_%d_%d_D_%d_T_%d_N_%d_NA_%d', costsAlpha, costsBeta, costsGamma, D, T, N, NA));
%     legend_text{k} =  sprintf('BAdaCost, %d-%d-%d, D=%d, T=%d', costsAlpha, costsBeta, costsGamma, D, T);
%     k = k + 1;
%   end
% end
% fig_filename = 'FIGURES_LDCF_BADACOST_ALL';
% plot_result_fig_kitti(PREPARED_DATA_PATH, OUTPUT_DATA_PATH, results_dirs, legend_text, fig_filename);
% 
 
 
% ------------------------------------------------------------------------
% Plot experiments on Regularization
clear results_dirs;
clear legend_text;
i=1;
results_dirs{i} = fullfile(OUTPUT_DATA_PATH, 'BADACOST_1_3_3_D_8_T_1024_N_7500_NA_30000_S_0.0500_F_0.0312');
%legend_text{i} =  'BAdaCost, 1-3-3, D=8, S=0.05, fracFtrs=1/32, N=7.5K, NA=30K';
legend_text{i} =  'BAdaCost, S=0.05, fracFtrs=1/32';
i = i+1;
results_dirs{i} = fullfile(OUTPUT_DATA_PATH, 'BADACOST_1_3_3_D_8_T_1024_N_7500_NA_30000_S_0.0500_F_0.0625');
%legend_text{i} =  'BAdaCost, 1-3-3, D=8, S=0.05, fracFtrs=1/16, N=7.5K, NA=30K';
legend_text{i} =  'BAdaCost, S=0.05, fracFtrs=1/16';
i = i+1;
results_dirs{i} = fullfile(OUTPUT_DATA_PATH, 'BADACOST_1_3_3_D_8_T_1024_N_7500_NA_30000');
%legend_text{i} =  'BAdaCost, 1-3-3, D=8, S=0.1, fracFtrs=1/16, N=7.5K, NA=30K';
legend_text{i} =  'BAdaCost, S=0.1, fracFtrs=1/16';
i = i+1;
results_dirs{i} = fullfile(OUTPUT_DATA_PATH, 'BADACOST_1_3_3_D_8_T_1024_N_7500_NA_30000_S_0.5000_F_0.0625');
%legend_text{i} =  'BAdaCost, 1-3-3, D=8, S=0.5, fracFtrs=1/16, N=7.5K, NA=30K';
legend_text{i} =  'BAdaCost, S=0.5, fracFtrs=1/16';
i = i+1;
results_dirs{i} = fullfile(OUTPUT_DATA_PATH, 'BADACOST_1_3_3_D_8_T_1024_N_7500_NA_30000_S_1.0000_F_0.0625');
%legend_text{i} =  'BAdaCost, 1-3-3, D=8, S=1.0, fracFtrs=1/16, N=7.5K, NA=30K';
legend_text{i} =  'BAdaCost, S=1.0, fracFtrs=1/16';
i = i+1;
fig_filename = 'FIGURES_LDCF_BADACOST_REGULARIZATION';
plot_result_fig_kitti(PREPARED_DATA_PATH, OUTPUT_DATA_PATH, results_dirs, legend_text, fig_filename);
 
