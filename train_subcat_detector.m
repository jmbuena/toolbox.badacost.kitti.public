function train_subcat_detector(dataDir, dataOutputDir, D, T)
% dataDir - Path of the directory with the prepared KITTI data.
% dataOutputDir - Path to store trained detector and detection results in. 
% D - max depth of the tree weak learners
% N - number of hard negatives to add per round
% NA - total number of hard negatives to add in 4 rounds of mining.
% 
% Cost related parameters are:
% useSAMME - wether cost matrix is 0-1 one.
% if useSAMME = 0, 
%   costsAlpha, costsBetha, costsGamma are used as in the paper to set
%   costs (weighting up errors of car orientation car).

if (nargin < 4)
  T = 2048;  
end 

mkdir(dataOutputDir);

exp_name='KITTI';

NICE_VISUALISATION = false;
  NICE_VISUALISATION_SCORE_THRESHOLD = 10;

% Size of the search window
MIN_HEIGHTS = [26, 32 48];
 SQUARIFY_TYPE = 3;
  
STRIDE = 4;
N_PER_OCT = 10; % Better detection.
N_OCT_UP = 1;
N_APPROX = 9;

% From SubCat paper code:
CHNS_SHRINK = 2;
N_ACC_NEG = 10000;
N_NEG = 5000;
N_WEAK = [32 128 512 T]; 

% Regularisation
RESAMPLING = 1;
SHRINKAGE  = 0.1;
FRAC_FTRS  = 1/16;

% For testing
OVERLAPING_TP = 0.7; % As needed in KITTI benchmark

imgTestDir = fullfile(dataDir, 'CROSS_VAL_10_FOLD_SPLITS/fold_10_test_from_training/image_2');
lbsTestDir = fullfile(dataDir, 'CROSS_VAL_10_FOLD_SPLITS/fold_10_test_from_training/label_2');

% ------------------------------------------------------------------------
% get model dimensions from training data.
posGtDir = fullfile(dataDir, 'CROSS_VAL_10_FOLD_SPLITS/fold_10_train_from_training/label_2');
posImgDir = fullfile(dataDir, 'CROSS_VAL_10_FOLD_SPLITS/fold_10_train_from_training/image_2');

pLoad = {'lbls',{'Car'},'ilbls',{'DontCare', 'Truck', 'Van', 'Tram'}}; 
pLoad = {pLoad{:} 'hRng',[25 inf]}; % 25 pixels minimum height
pLoad = {pLoad{:} 'format', 38, 'nOrient', 20, 'hMin', 25, 'occlMax', 1, 'truncMax', 0.3}; 
aRatios = computePerClassAspectRatios(posImgDir, posGtDir, pLoad, 'median');
B = length(aRatios);

% ------------------------------------------------------------------------
% SuCat 0.2 code: Step 4: Train
resHgt = [48];
for res = 1:length(resHgt);
    xx=resHgt(res);
    for ori_i = 1:B
        yy = round(xx*aRatios(ori_i));
        opts=acfTrain();
        
        opts.pBoost.discrete = 0;
        opts.name=[dataOutputDir '/model' sprintf('%02d',ori_i + (res-1)*B)];
        opts.posGtDir = fullfile(dataDir,'SUBCAT_DATA','train','annotations');
        opts.posImgDir =  fullfile(dataDir,'SUBCAT_DATA','train','images');
       
        opts.modelDs=[xx yy];
        opts.modelDsPad = round(opts.modelDs+opts.modelDs/8);
        
        % NIPS 2014 P.Dollar paper.
        opts.filters=[5 4]; 
      
        opts.nWeak=N_WEAK; 
        opts.pBoost.pTree.fracFtrs=FRAC_FTRS;
        opts.pNms.overlap = 0.3;
        %%
        inclustlabels = [];
        for k=ori_i
            inclustlabels{end+1} = sprintf('car%02d',mod(k-1,B)+1);
        end

        allBs = 1:B;  allBs(ori_i) = [];
        outclustlabels = [];
        for j_B = 1:length(allBs); outclustlabels{j_B} = sprintf('car%02d',allBs(j_B)); end;
        outclustlabels{end+1} = 'ig';
        opts.pLoad={ 'lbls', inclustlabels,'ilbls',outclustlabels,'squarify',[]};
        %%
        opts.pJitter=struct('flip',0); opts.pNms.ovrDnm = 'union';
        opts.pPyramid.pChns.pGradHist.softBin=0;
        opts.pPyramid.pChns.pColor.smooth=0;
        opts.pBoost.pTree.maxDepth=D;
        opts.pPyramid.pChns.shrink=CHNS_SHRINK; %2 or 4. 2 gives better accuracy. 4 is fast.
        opts.nNeg = N_NEG; opts.nAccNeg = N_ACC_NEG; opts.nPerNeg = 25;
        
%         [gt,~] = bbGt('loadAll',opts.posGtDir,[],opts.pLoad);
%         imgNms = bbGt('getFiles',{opts.posImgDir});
        
        detector = acfTrain(opts);
    end
end

%% Load trained detectors.
clear detector;
opts = []; opts.pNms.type  = 'maxg'; opts.pNms.ovrDnm  = 'union';  opts.pNms.overlap = 0.3;
for ori_i = 1:length(resHgt)*B
    currname=[dataOutputDir '/model' sprintf('%02d',ori_i)];
    currdet = load([currname 'Detector.mat']);
    currdet = currdet.detector;
    %currdet = acfModify(currdet.detector,'cascThr',-10,'pNms', opts.pNms);
    currdet.opts.pPyramid.nApprox = N_APPROX;
    currdet.opts.pPyramid.nPerOct = N_PER_OCT;
    currdet.opts.pPyramid.nOctUp = N_OCT_UP;
    detector{ori_i} = currdet;
end
detNamePrefix =fullfile(dataOutputDir, sprintf('SUBCAT_D_%d_',D));
detName =[detNamePrefix 'Detector.mat'];
save(detName,'detector');

%--------------------------------------------------------------------------
% test detector and plot roc (see acfTest)
%--------------------------------------------------------------------------
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

[miss,roc,gt,dt]=acfTest('name',detNamePrefix,...
   'imgDir',imgTestDir,...
   'gtDir',lbsTestDir,...
   'pLoad',pLoadTest,... 
   'show',1, ...
   'thr', OVERLAPING_TP);  % Overlaping threshold for a BoundingBox as TP
save(fullfile(dataOutputDir, [exp_name '_TEST_RESULTS.mat']), 'miss', 'roc', 'gt', 'dt');

h = figure;
ref   = 10.^(-2:.25:0);
lims = [3.1e-3 1e1 .05 1];
color = {'r', 'g', 'b', 'k', 'm', 'c', 'y'};
lineSt = {'-', ':', '--', '.', '-', ':', '--'};

[fp,tp,score,miss_test] = bbGt('compRoc',gt,dt,1,ref);
[hs,~,~] =plotRoc([fp tp],'logx',1,'logy',0, 'xLbl', 'fppi',...
            'lims', lims, 'color', color{1}, 'lineSt', lineSt{1}, 'smooth', 1, 'fpTarget', ref);
legend_string = sprintf('D=%d, recall (at 1FFPI)=%.2f%%', ...
                        D, ...
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
legend_string = sprintf('D=%d, recall (at 0.1 FFPI)=%.2f%%', ...
                        D, ...
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
  
  if NICE_VISUALISATION
    % Show results with nice visualization (removed score < NICE_VISUALIZATION_SCORE_THRESHOLD detections)
    showResOpts ={'evShow',0,'gtShow',0, 'dtShow',1, 'isMulticlass', 0, 'dtLs', '-'};
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
    showResOpts ={'evShow',1,'gtShow',1, 'dtShow',1, 'isMulticlass', 0};
    
    [hs,hImg] = bbGt('showRes', I, gt_i, dt_i, showResOpts); % multiClass = 1
    disp(file_name);
    saveas(gcf, fullfile(IMG_RESULTS_PATH, file_name), 'png');  
  
    % Write the KITTI format for detections
    objects = [];
    for j=1:size(dt_i,1)
      objects(j).type = 'Car';
      objects(j).alpha = 0.0; %quantized2angleKITTI(dt_i(j,7), num_classes-1);
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
