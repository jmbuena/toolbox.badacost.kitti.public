
% Set here the BAdaCost matlab toolbox for detection (modification from P.Dollar's one):
TOOLBOX_BADACOST_PATH = '/home/jmbuena/matlab/toolbox.badacost';
KITTI_PATH = '/home/imagenes/CARS_DATABASES/KITTI_DATABASE/';
OUTPUT_DATA_PATH =  'KITTI_CARS_DETECTION_EXPERIMENTS';
PREPARED_DATA_PATH =  'KITTI_TRAINING_DATA';

% Change to 1 to prepare the data from KITTI downloaded files.
PREPARE_DATA = 0; 

% Add BAdaCost toolbox to the path
addpath(genpath(TOOLBOX_BADACOST_PATH));
addpath(genpath(fullfile('.', 'kitti_labels')));
if PREPARE_DATA 

  % First we prepare KITTI database for training:
  %   1) We add flipped images horizontally (and modify labels accordingly) 
  %     in order to double training images set.
  %   2) We split images in 10 folds by training image index (e.g. first 
  %      10% indices go into first fold).
  addpath(genpath(fullfile('.', 'kitti_cars_preparation')));

  % Uncomment "prepare_database" if you first try to train the SubCat 
  % detector instead of the BAdaCost detector.
  %prepare_database;
  prepare_subcat_database;
end

% ------------------------------------------------------------------------
% Now we call the script to train BAdaCost detector with different parameters:
%   3) Finally we train BAdaCost detector with first 90% of training images and we test in the last 10%. 
dataDir = PREPARED_DATA_PATH; 

% ------------------------------------------------------------------------
% 3.2 Experiments over SubCat and tree depth
Ds = [2, 3, 4, 5, 6];
for i=1:length(Ds)
  D = Ds(i);
  dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SUBCAT_D_%d', D));
  train_subcat_detector(dataDir, dataOutputDir, D);
  close all;
end

