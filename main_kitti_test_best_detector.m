
% Set here the BAdaCost matlab toolbox for detection (modification from P.Dollar's one):
TOOLBOX_BADACOST_PATH = '/home/jmbuena/matlab/toolbox.badacost';
KITTI_PATH = '/home/imagenes/CARS_DATABASES/KITTI_DATABASE/';
OUTPUT_DATA_PATH =  'KITTI_CARS_DETECTION_EXPERIMENTS';
PREPARED_DATA_PATH =  'KITTI_TRAINING_DATA';

SHRINKAGE = 0.05; %0.05; % 0.1
FRAC_FEATURES = 1/32; % 1/16

% Change to 1 to prepare the data from KITTI downloaded files.
PREPARE_DATA = 0; 

% Add BAdaCost toolbox to the path
addpath(genpath(TOOLBOX_BADACOST_PATH));
addpath(genpath(fullfile('.', 'kitti_cars_preparation')));
addpath(genpath(fullfile('.', 'kitti_labels')));

% ------------------------------------------------------------------------
% Now we call the script to train BAdaCost detector with different parameters:
%   3) Finally we train BAdaCost detector with first 90% of training imasges and we test in the last 10%. 
dataDir = PREPARED_DATA_PATH; 

D = 8;
T = 1024;
N = 7500;
NA = 30000;
DETECTOR_STRING = sprintf('D_%d_T_%d_N_%d_NA_%d_S_%1.4f_F_%1.4f', D, T, N, NA, SHRINKAGE, FRAC_FEATURES);
useSAMME = 0;
costsAlpha = 1;
costsBeta = 3;
costsGamma = 3;
dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('BADACOST_%d_%d_%d_%s', ...
                           costsAlpha, costsBeta, costsGamma, ...
                           DETECTOR_STRING))
                       
%dataOutputDir = fullfile(OUTPUT_DATA_PATH, 'SAMME_D_8_T_1024_N_7500_NA_30000');
%test_kitti_badacost_detector(KITTI_PATH, dataOutputDir, SHRINKAGE);

%dataOutputDir = fullfile(OUTPUT_DATA_PATH, 'SUBCAT_D_4');                      
%test_kitti_subcat_detector(KITTI_PATH, dataOutputDir, D);

