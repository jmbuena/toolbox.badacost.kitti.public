function train_badacost_detector(dataDir, dataOutputDir, D, T, N, NA, ...
    useSAMME, costsAlpha, costsBeta, costsGamma, shrinkage, fracFtrs, useFilters, aspectRatio, filters)
% dataDir - Path of the directory with the prepared KITTI data.
% dataOutputDir - Path to store trained detector and detection results in. 
% D - max depth of the tree weak learners
% T - max number of tree weak learners.
% N - number of hard negatives to add per round
% NA - total number of hard negatives to add in 4 rounds of mining.
% 
% Cost related parameters are:
% useSAMME - wether cost matrix is 0-1 one.
% if useSAMME = 0, 
%   costsAlpha, costsBetha, costsGamma are used as in the paper to set
%   costs (weighting up errors of car orientation car).

if (nargin < 11)
  shrinkage = 0.1;
end

if (nargin < 12)
  fracFtrs = 1/16;
end

if (nargin < 13)
  useFilters = 'LDCF';
end

if (nargin < 14)
  aspectRatio = 1.75;
end

if (nargin < 15)
  filters = [5, 4];
end

mkdir(dataOutputDir);

exp_name='KITTI';

NICE_VISUALISATION = false;
  NICE_VISUALISATION_SCORE_THRESHOLD = 10;

% Size of the search window
MIN_HEIGHT = 48;
 SQUARIFY_TYPE = 3;
  
A_RATIO_TYPE = 'mean';  
STRIDE = 4;
N_PER_OCT = 10; % Better detection.
N_OCT_UP = 1;
N_APPROX = 9;

BEST_ASPECT_RATIO  = aspectRatio;
BEST_PADDING_RATIO = 1/8;
CHNS_SHRINK = 2;
MAX_DEPTH = D;
MIN_DEPTH = 1;
VARIABLE_DEPTH = 0;
N_ACC_NEG = NA;
N_NEG = N;
N_WEAK = [32 128 256 T]; 

% Regularisation
RESAMPLING = 1;
SHRINKAGE  = shrinkage;
FRAC_FTRS  = fracFtrs;

% Cascade calibration
USE_CALIBRATION = 1
CALIBRATION_THR_FRACTION = 1;

% For testing
OVERLAPING_TP = 0.7; % As needed in KITTI benchmark

% set up opts for training detector (see acfTrainBadacostTrees)
opts=acfTrainBadacostTrees(); 
opts.savePath = dataOutputDir;
opts.cascCal = 0.0;

if strcmp(useFilters, 'ROTATED')
  % Filtered channels features
  opts.filters = computeRotatedFilters(10,16,9);
elseif strcmp(useFilters, 'CHECKER')
  % Filtered channels features
  opts.filters = computeCheckerboardFilters(10,5,4);
elseif strcmp(useFilters, 'SQUARES')
  % Filtered channels features
  opts.filters = computeSquaresFilters(10,5,4);
else % if strcmp(useFilters, 'LDCF')
  % NIPS 2014 P.Dollar paper.
  opts.filters=filters;     
end

% SubCat paper parameters
opts.pPyramid.pChns.pColor.smooth=0;
opts.pPyramid.pChns.pGradHist.softBin=1;
opts.pPyramid.pChns.shrink=CHNS_SHRINK; 

% Our parameters
imgTestDir = fullfile(dataDir, 'CROSS_VAL_10_FOLD_SPLITS/fold_10_test_from_training/image_2');
lbsTestDir = fullfile(dataDir, 'CROSS_VAL_10_FOLD_SPLITS/fold_10_test_from_training/label_2');
opts.posGtDir = fullfile(dataDir, 'CROSS_VAL_10_FOLD_SPLITS_WITH_ALL_FLIPPED_IMAGES/fold_10_train_from_training/label_2');
opts.posImgDir = fullfile(dataDir, 'CROSS_VAL_10_FOLD_SPLITS_WITH_ALL_FLIPPED_IMAGES/fold_10_train_from_training/image_2');
opts.nWeak=N_WEAK;

opts.pNms = {'type','maxg','overlap',.3,'ovrDnm','union'};
opts.nAccNeg = N_ACC_NEG;
opts.nNeg = N_NEG;
opts.aRatioType = A_RATIO_TYPE;
opts.stride = STRIDE;

% Trams, Truck and Vans can be similar to cars, so we want them ignored but
% present in the bounding boxes. This way the negative windows are not
% extracted from them.
pLoad={'lbls',{'Car'},'ilbls',{'DontCare', 'Truck', 'Van', 'Tram'}}; 
pLoad = {pLoad{:} 'hRng',[25 inf]}; % 25 pixels minimum height

% THIS FORMAT (38) IS MULTICLASS IN CAR ORIENTATION ALL OCCLUSSIONS
% (KITTI alpha angle quantized in 25 orientations)
pLoad = {pLoad{:} 'format', 38, 'nOrient', 20, 'hMin', 25, 'occlMax', 1, 'truncMax', 0.3}; 
num_classes = 20+1; % 20 orientations + background

% Compute costs matrix from the parameters already set:
Cost = compute_cost_matrix(num_classes, useSAMME, costsAlpha, costsBeta, costsGamma);
%Cost = compute_cost_matrix_new1(num_classes, useSAMME, costsAlpha, costsBeta, costsGamma);
disp(Cost);

% Set the BAdaCost paramenters.
opts.pBoost = struct('Cost', Cost, 'shrinkage', SHRINKAGE, 'resampling', RESAMPLING, ...
                     'minDepth', MIN_DEPTH, ...
                     'maxDepth', MAX_DEPTH, ...
                     'variable_depth', VARIABLE_DEPTH, ...
                     'verbose',1, 'fracFtrs', FRAC_FTRS, ...
                     'quantized', 1);

opts.modelDs=round([MIN_HEIGHT MIN_HEIGHT*BEST_ASPECT_RATIO]); 
opts.modelDsPad=round(opts.modelDs .* (1.0 + BEST_PADDING_RATIO));
opts.name = [exp_name ...
             sprintf('_SHRINKAGE_%f_RESAMPLING_%f_ASPECT_RATIO_%f', ...
                     opts.pBoost.shrinkage, ...                     
                     opts.pBoost.resampling, BEST_ASPECT_RATIO) '_'];
opts.pLoad = {pLoad{:} 'squarify', {3, BEST_ASPECT_RATIO}}; 

%--------------------------------------------------------------------------
% Now, train the BAdaCost based detector
%--------------------------------------------------------------------------
detectorFile = fullfile(dataOutputDir, [opts.name 'Detector.mat']);
if ~exist(detectorFile, 'file')
  % train detector (see acfTrainBadacostTrees)
  detector = acfTrainBadacostTrees( opts );
  if USE_CALIBRATION
    % Watch out!!! This is faster but you can miss detections!!
    detector.opts.cascThr=detector.opts.cascThr*CALIBRATION_THR_FRACTION;
  end
  detector.opts.pPyramid.nPerOct=N_PER_OCT; % Better detection.
  detector.opts.pPyramid.nOctUp=N_OCT_UP; % Better detection.
  detector.opts.pPyramid.nApprox=N_APPROX; % Better detection.
  save(detectorFile, 'detector');
end; 

%--------------------------------------------------------------------------
% Plot the selected features by the detector
%--------------------------------------------------------------------------
detector = load(detectorFile);
detector = detector.detector;
[featMap, featChnMaps, nFilters] = computeSelectedFeaturesMap(detector);

plotSelectedFeaturesMap(exp_name, dataOutputDir, featMap, featChnMaps, nFilters);

%--------------------------------------------------------------------------
% test detector and plot roc (see acfTest)
%--------------------------------------------------------------------------
%pLoad2 = {pLoad{:} 'format', 38, 'nOrient', 20, 'hMin', 25, 'occlMax', 1, 'truncMax', 0.3}; 
pLoad2=pLoad;
if iscell(pLoad)
  index = find(strcmp(pLoad2, 'hMin'));
  if ~isempty(index)
    pLoad2{index+1} = 25; % It is the lower height value
  end
  index = find(strcmp(pLoad2, 'truncMax'));
  if ~isempty(index)
    pLoad2{index+1} = 0.5; % Maximum trunc level
  end
  index = find(strcmp(pLoad2, 'occlMax'));
  if ~isempty(index)
    pLoad2{index+1} = 2; % Maximum occl level
  end
elseif isstruct(pLoad2)
  if isfield(pLoad2, 'format')
    pLoad2.hMin = 25; 
    pLoad2.truncMax = 0.5; 
    pLoad2.occlMax = 2; 
  end
end
pLoadTest = {pLoad2{:}}; 

[miss,roc,gt,dt]=acfTestBadacost('name',opts.name,...
   'imgDir',imgTestDir,...
   'gtDir',lbsTestDir,...
   'pLoad',pLoadTest,... 
   'show',1, ...
   'thr', OVERLAPING_TP, ...
   'numClasses', num_classes, ...
   'savePath', dataOutputDir);  % Overlaping threshold for a BoundingBox as TP
save(fullfile(dataOutputDir, [exp_name '_TEST_RESULTS.mat']), 'miss', 'roc', 'gt', 'dt');

h = figure;
ref   = 10.^(-2:.25:0);
lims = [3.1e-3 1e1 .05 1];
color = {'r', 'g', 'b', 'k', 'm', 'c', 'y'};
lineSt = {'-', ':', '--', '.', '-', ':', '--'};

[fp,tp,score,miss_test] = bbGt('compRoc',gt,dt,1,ref);
[hs,~,~] =plotRoc([fp tp],'logx',1,'logy',0, 'xLbl', 'fppi',...
            'lims', lims, 'color', color{1}, 'lineSt', lineSt{1}, 'smooth', 1, 'fpTarget', ref);
legend_string = sprintf('asp.ratio=%2.2f, pad.ratio=%2.2f, recall (at 1FFPI)=%.2f%%', ...
                        BEST_ASPECT_RATIO, BEST_PADDING_RATIO, ...
                        miss_test(end)*100);
legend(hs, legend_string, 'Location', 'Best');
hold off;
saveas(gcf, fullfile(dataOutputDir, [exp_name '_Roc.eps']), 'epsc');
saveas(gcf, fullfile(dataOutputDir, [exp_name '_Roc.png']), 'png');

h = figure;
ref   = 10.^(-2:.25:0);
lims = [3.1e-3 1e1 .05 1];
color = {'r', 'g', 'b', 'k', 'm', 'c', 'y'};
lineSt = {'-', ':', '--', '.', '-', ':', '--'};

[fp,tp,score,miss_test] = bbGt('compRoc',gt,dt,1,ref);
[hs,~,~] = plotRoc([fp tp],'logx',1,'logy',0, 'xLbl', 'fppi',...
            'lims', lims, 'color', color{1}, 'lineSt', lineSt{1}, 'smooth', 1, 'fpTarget', ref);
legend_string = sprintf('asp.ratio=%2.2f, pad.ratio=%2.2f, recall (at 0.1 FFPI)=%.2f%%', ...
                        BEST_ASPECT_RATIO, BEST_PADDING_RATIO, ...
                        miss_test(5)*100);
legend(hs, legend_string, 'Location', 'Best');
hold off;
saveas(gcf, fullfile(dataOutputDir, [exp_name '_Roc2.eps']), 'epsc');
saveas(gcf, fullfile(dataOutputDir, [exp_name '_Roc2.png']), 'png');


%--------------------------------------------------------------------------
% Plot results over images.
%--------------------------------------------------------------------------
figure; 
IMG_RESULTS_PATH = fullfile(dataOutputDir, 'IMG_RESULTS');
mkdir(IMG_RESULTS_PATH);
LABELS_RESULTS_PATH = fullfile(dataOutputDir, 'LABELS_RESULTS');
mkdir(LABELS_RESULTS_PATH);
%showResOpts ={'evShow',1,'gtShow',1, 'dtShow',1, 'isMulticlass', 1}; 
imgNms = bbGt('getFiles',{imgTestDir});

if (~exist('NICE_VISUALISATION', 'var'))
  NICE_VISUALISATION = false;
end

if (~exist('NICE_VISUALISATION_SCORE_THRESHOLD', 'var'))
  NICE_VISUALISATION = false;
end

for i=1:length(imgNms)
  file_name = strsplit(imgNms{i}, '/');
  file_name = file_name{end};
  I = imread(fullfile(imgTestDir, file_name));
  dt_i = dt{i};
  gt_i = gt{i};
  
  dt_i(:,6) = ones(size(dt_i, 1), 1);
  dt_i(:,7) = dt_i(:,7)-ones(size(dt_i, 1), 1);  
  if NICE_VISUALISATION
    % Show results with nice visualization (removed score < NICE_VISUALIZATION_SCORE_THRESHOLD detections)
    showResOpts ={'evShow',0,'gtShow',0, 'dtShow',1, 'isMulticlass', 1, 'dtLs', '-'};
    dt_i_nice = dt_i(dt_i(:,5)>=NICE_VISUALISATION_SCORE_THRESHOLD, :);
    iptsetpref('imshowBorder', 'tight');
    imshow(I, 'Border', 'tight');
    %[hs,hImg] = bbGt('showRes', [], gt_i, dt_i_nice, showResOpts); % multiClass = 1
    hs = bbGt('showRes', [], gt_i, dt_i_nice, showResOpts); % multiClass = 1
    set(gca, 'LooseInset', get(gca, 'TightInset'));
    set(gca, 'position', [0 0 1 1], 'units', 'normalized'); 
    saveas(gcf, fullfile(IMG_RESULTS_PATH, ['NICE_VISUALISATION_' file_name]), 'png');
  else
     % Show full results and comparison with ground thruth
    showResOpts ={'evShow',1,'gtShow',1, 'dtShow',1, 'isMulticlass', 1};
   
    [hs,hImg] = bbGt('showRes', I, gt_i, dt_i, showResOpts); % multiClass = 1
    disp(file_name);
    saveas(gcf, fullfile(IMG_RESULTS_PATH, file_name), 'png');  
  
    % Write the KITTI format for detections
    objects = [];
    for j=1:size(dt_i,1)
      objects(j).type = 'Car';
      objects(j).alpha = quantized2angleKITTI(dt_i(j,7), num_classes-1);
      objects(j).x1 = dt_i(j,1);
      objects(j).y1 = dt_i(j,2);
      objects(j).x2 = dt_i(j,1) + dt_i(j,3) - 1;
      objects(j).y2 = dt_i(j,2) + dt_i(j,4) - 1;
      objects(j).score = dt{i}(j,5);
    end  
    image_number = str2num(file_name(1:end-4));
    writeKITTILabels(objects,LABELS_RESULTS_PATH,image_number)
  end
end
