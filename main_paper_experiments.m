
% Set here the BAdaCost matlab toolbox for detection (modification from P.Dollar's one):
TOOLBOX_BADACOST_PATH = '/home/jmbuena/matlab/toolbox.badacost';
KITTI_PATH = '/home/imagenes/CARS_DATABASES/KITTI_DATABASE/';
OUTPUT_DATA_PATH =  'KITTI_CARS_DETECTION_EXPERIMENTS';
PREPARED_DATA_PATH =  'KITTI_TRAINING_DATA';

SHRINKAGE = 0.1; %0.05; 
FRAC_FEATURES = 1/16; %1/32; 

% Change to 1 to prepare the data from KITTI downloaded files.
PREPARE_DATA = 1; 

addpath(genpath(fullfile('.', 'kitti_labels')));
if PREPARE_DATA 
  % Add BAdaCost toolbox to the path
  addpath(genpath(TOOLBOX_BADACOST_PATH));

  % First we prepare KITTI database for training:
  %   1) We add flipped images horizontally (and modify labels accordingly) 
  %     in order to double training images set.
  %   2) We split images in 10 folds by training image index (e.g. first 
  %      10% indices go into first fold).
  addpath(genpath(fullfile('.', 'kitti_cars_preparation')));

  prepare_database;
end

% ------------------------------------------------------------------------
% Now we call the script to train BAdaCost detector with different parameters:
%   3) Finally we train BAdaCost detector with first 90% of training images and we test in the last 10%. 
dataDir = PREPARED_DATA_PATH; 

% ------------------------------------------------------------------------
% 3.1 Experiments over SAMME and number of hard negatives
Ns = [5000, 7500, 10000];
NAs = [20000, 30000, 40000];
D = 7;
T = 1024;
useSAMME = 1;
costsAlpha = 1;
costsBeta = 1;
costsGamma = 1;
for i=1:length(Ns)
  N = Ns(i);
  NA = NAs(i);
  dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SAMME_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
  train_badacost_detector(dataDir, dataOutputDir, D, T, N, NA, useSAMME, costsAlpha, costsBeta, costsGamma);
  close all;
end

% ------------------------------------------------------------------------
% 3.2 Experiments over SAMME and tree depth
Ds = [6, 7, 8, 9]; 
T = 1024;
N = 7500;
NA = 30000;
useSAMME = 1;
costsAlpha = 1;
costsBeta = 1;
costsGamma = 1;
for i=1:length(Ds)
  D = Ds(i);
  dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('SAMME_D_%d_T_%d_N_%d_NA_%d', D, T, N, NA));
  train_badacost_detector(dataDir, dataOutputDir, D, T, N, NA, useSAMME, costsAlpha, costsBeta, costsGamma);
  close all;
end
 
% ------------------------------------------------------------------------
% 3.3 Experiments over BAdaCost and alpha, beta and gamma values for costs.
alphaBetaGamma = [1, 1, 1; ...
                  1, 2, 2; ...
                  1, 3, 2.75; ...
                  1, 3, 3; ...
                  1, 3, 3.25; ...
                  1, 4, 4; ...
                  1, 5, 5
                  ];                  
D = 8;
T = 1024;
N = 7500;
NA = 30000;
useSAMME = 0;
for i=1:size(alphaBetaGamma,1)
  costsAlpha = alphaBetaGamma(i, 1);
  costsBeta = alphaBetaGamma(i, 2);
  costsGamma = alphaBetaGamma(i, 3);
  dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('BADACOST_%d_%d_%d_D_%d_T_%d_N_%d_NA_%d', costsAlpha, costsBeta, costsGamma, D, T, N, NA));
  if (SHRINKAGE ~= 0.1)
    dataOutputDir = [dataOutputDir sprintf('_S_%1.4f',SHRINKAGE)];
  end
  if (FRAC_FEATURES ~= 1/16)
    dataOutputDir = [dataOutputDir sprintf('_F_%1.4f',FRAC_FEATURES)];
  end
  train_badacost_detector(dataDir, dataOutputDir, D, T, N, NA, ...
      useSAMME, costsAlpha, costsBeta, costsGamma, SHRINKAGE, FRAC_FEATURES);
  close all;
end
  
% % ------------------------------------------------------------------------
% % 3.4 Experiments over BAdaCost and number of trees and depths
% Ds = [6, 7, 8, 9];
% Ts = [256, 512, 750, 1024, 1500];
% N = 7500;
% NA = 30000;
% useSAMME = 0;
% costsAlpha = 1;
% costsBeta = 3;
% costsGamma = 3;
% for i=1:length(Ds)
%   D = Ds(i);
%   for j=1:length(Ts)
%     T = Ts(j);
%     dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('BADACOST_%d_%d_%d_D_%d_T_%d_N_%d_NA_%d', costsAlpha, costsBeta, costsGamma, D, T, N, NA));
%     train_badacost_detector(dataDir, dataOutputDir, D, T, N, NA, useSAMME, costsAlpha, costsBeta, costsGamma);
%     close all;
%   end
% end

% ------------------------------------------------------------------------
% Experiments about regularization
D = 8;
T = 1024;
N = 7500;
NA = 30000;
Ss = [1,    0.5,  0.05, 0.05];
Fs = [1/16, 1/16, 1/16, 1/32];
useSAMME = 0;
costsAlpha = 1;
costsBeta = 3;
costsGamma = 3;
for i=1:length(Ss)
  S = Ss(i);
  F = Fs(i);
  dataOutputDir = fullfile(OUTPUT_DATA_PATH, sprintf('BADACOST_%d_%d_%d_D_%d_T_%d_N_%d_NA_%d', costsAlpha, costsBeta, costsGamma, D, T, N, NA));
  dataOutputDir = [dataOutputDir sprintf('_S_%1.4f', S)];  
  dataOutputDir = [dataOutputDir sprintf('_F_%1.4f', F)];  
  train_badacost_detector(dataDir, dataOutputDir, D, T, N, NA, useSAMME, costsAlpha, costsBeta, costsGamma, S, F);
  close all;
end
