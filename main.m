
% Set here the BAdaCost matlab toolbox for detection (modification from P.Dollar's one):
TOOLBOX_BADACOST_PATH = '/home/jmbuena/matlab/toolbox.badacost';
KITTI_PATH = '/home/imagenes/CARS_DATABASES/KITTI_DATABASE/';
OUTPUT_DATA_PATH =  'KITTI_CARS_DETECTION_EXPERIMENTS';
PREPARED_DATA_PATH =  'KITTI_TRAINING_DATA';

SHRINKAGE = 0.05;
FRAC_FEATURES = 1/32;

% Change to 1 to prepare the data from KITTI downloaded files.
PREPARE_DATA = 0; 

% Change to 1 in order to train the car detector over KITTI 
% (otherwise it would use the already trained one for test).
DO_TRAINING = 0; 

% Variables for testing trained detector on real images.
FAST_DETECTION = 0; % if 1 less accurate but faster, if 0 better detection (slower).
SAVE_RESULTS = 1; 
NICE_VISUALIZATION_SCORE_THRESHOLD = 10; % Set it to 0 if you want to see all detections.

%VIDEO_FILES_PATH = 'KITTI_FULL_SEQUENCES/2011_09_26_drive_0019_sync_image_03_datas'
%IMG_RESULTS_PATH = 'KITTI_FULL_SEQUENCES_EXPERIMENTS/2011_09_26_drive_0019_sync_image03_data'
%FIRST_IMAGE = 330; % first_image_index
%IMG_EXT = 'jpg';
 
VIDEO_FILES_PATH = 'KITTI_FULL_SEQUENCES/2011_09_26_drive_0036_sync_image_03_data'
IMG_RESULTS_PATH = 'KITTI_FULL_SEQUENCES_EXPERIMENTS/2011_09_26_drive_0036_sync_image_03_data'
FIRST_IMAGE = 50; % first_image_index
IMG_EXT = 'jpg';


% -----------------------------------------------------------------------------
if PREPARE_DATA 
  % Add BAdaCost toolbox to the path
  addpath(genpath(TOOLBOX_BADACOST_PATH))

  % First we prepare KITTI database for training:
  %   1) We add flipped images horizontally (and modify labels accordingly) 
  %     in order to double training images set.
  %   2) We split images in 10 folds by training image index (e.g. first 10% indices go into first fold).
  addpath(genpath(fullfile('.', 'kitti_cars_preparation')));
  addpath(genpath(fullfile('.', 'kitti_labels')));

  prepare_database;
end

% -----------------------------------------------------------------------------
dataDir = PREPARED_DATA_PATH; 

D = 8;
T = 1024;
N = 7500;
NA = 30000;
useSAMME = 0;
costsAlpha = 1;
costsBeta = 3;
costsGamma = 3;
if DO_TRAINING
  % Now we call the script to train BAdaCost detector with different parameters:
  %   3) Finally we train BAdaCost detector with first 90% of training images and we test in the last 10%. 
  addpath(genpath('kitti_labels'));

  if useSAMME
    dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SAMME_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
  else
    dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('BADACOST_%d_%d_%d_D_%d_T_%d_N_%d_NA_%d', costsAlpha, costsBeta, costsGamma, D, T, N, NA));
  end
  train_badacost_detector(dataDir, dataOutputDir, D, T, N, NA, useSAMME, costsAlpha, costsBeta, costsGamma);
end

% -----------------------------------------------------------------------------
% 4) Now we use the trained car detector in the images given in a directory:

% TRAINED_DETECTOR_FILE = fullfile(OUTPUT_DATA_PATH, ...
%                                  'KITTI_SHRINKAGE_0.050000_RESAMPLING_1.000000_ASPECT_RATIO_1.750000_Detector.mat');

% The already trained detector file:
TRAINED_DETECTOR_FILE = fullfile(OUTPUT_DATA_PATH, ...
                                 sprintf('BADACOST_%d_%d_%d_D_%d_T_%d_N_%d_NA_%d_S_%4.4f_F_%4.4f', costsAlpha, costsBeta, costsGamma, D, T, N, NA, SHRINKAGE, FRAC_FEATURES), ...
                                 'KITTI_SHRINKAGE_0.050000_RESAMPLING_1.000000_ASPECT_RATIO_1.750000_Detector.mat');

% % The already trained detector file:
% TRAINED_DETECTOR_FILE = fullfile(OUTPUT_DATA_PATH, ...
%                                  'SUBCAT_D_4', ...
%                                  'SUBCAT_D_4_Detector.mat');

det = load(TRAINED_DETECTOR_FILE);
badacost_detector = det.detector;


apply_detector_to_imgs(badacost_detector, ...
                       VIDEO_FILES_PATH, ... 
                       IMG_EXT, ...
                       FIRST_IMAGE, ...
                       NICE_VISUALIZATION_SCORE_THRESHOLD, ...
                       FAST_DETECTION, ...
                       SAVE_RESULTS, ...
                       IMG_RESULTS_PATH);


