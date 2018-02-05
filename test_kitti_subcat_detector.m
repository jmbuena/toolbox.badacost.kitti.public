function test_kitti_subcat_detector(dataDir, dataOutputDir, D)
% dataDir - Path of the directory with the prepared KITTI data.
% dataOutputDir - Path to store trained detector and detection results in. 
%

if (nargin < 5)
  D = 4;
end

mkdir(dataOutputDir);

%exp_name='KITTI_TEST';
BEST_ASPECT_RATIO  = 1.75;
CROP_BB_TO_IMAGE = true;
NICE_VISUALISATION = true;
NICE_VISUALISATION_SCORE_THRESHOLD = 5;

% Our parameters
imgTestDir = fullfile(dataDir, 'testing/image_2');

detectorPrefix = [sprintf('SUBCAT_D_%d', D) '_'];

%--------------------------------------------------------------------------
% Now, test the BAdaCost based detector
%--------------------------------------------------------------------------
detectorFile = fullfile(dataOutputDir, [detectorPrefix 'Detector.mat']);
dect = load(detectorFile);  
detector = dect.detector;
detector{1}.opts.name = ['KITTI_TESTING_' detectorPrefix '_'];
opts = detector{1}.opts;
detectorFile = fullfile(dataOutputDir, [opts.name 'Detector.mat']);

%% Plot the selected features ... from the detector
save(detectorFile, 'detector');

detectionsFile = fullfile(dataOutputDir, [opts.name 'Dets.txt']);
if(~exist(detectionsFile,'file'))
  imgNms = bbGt('getFiles',{imgTestDir});
  acfDetect( imgNms, detector, detectionsFile );  
end

% Load the detections from file ...
dimMax = 5;
dt1=load(detectionsFile,'-ascii'); if(numel(dt1)==0), dt1=zeros(0,dimMax+1); end
ids=dt1(:,1);
n=max(ids); 
dt=cell(1,n); for i=1:n, dt{i}=dt1(ids==i,2:dimMax+1); end

%--------------------------------------------------------------------------
% Plot results over images.
%--------------------------------------------------------------------------
if (~exist('CROP_BB_TO_IMAGE', 'var'))
  CROP_BB_TO_IMAGE = false;
end

figure; 
IMG_RESULTS_PATH = fullfile(dataOutputDir, 'IMG_RESULTS_KITTI_TEST');
if (CROP_BB_TO_IMAGE)
  IMG_RESULTS_PATH = [IMG_RESULTS_PATH '_CROPPED'];
end
mkdir(IMG_RESULTS_PATH);
LABELS_RESULTS_PATH = fullfile(dataOutputDir, 'LABELS_RESULTS_KITTI_TEST');
if (CROP_BB_TO_IMAGE)
  LABELS_RESULTS_PATH = [LABELS_RESULTS_PATH '_CROPPED'];
end
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
  gt_i = [];
  
%   dt_i(:,7) = dt_i(:,6)-ones(size(dt_i, 1), 1);
%   dt_i(:,6) = ones(size(dt_i, 1), 1);
  
  if (CROP_BB_TO_IMAGE) % Crop windows to image.
    left = dt_i(:,1);
    top = dt_i(:,2);
    width = dt_i(:,3);
    height = dt_i(:,4);
    bottom = top + height - 1;
    right = left + width - 1;
    
    % within image boundaries coordinates.
    left2 = max(1, left);
    right2 = min(size(I,2), right);
    top2 = max(1, top);
    bottom2 = min(size(I,1), bottom);
    
    dt_i(:,1) = left2;
    dt_i(:,2) = top2;
    dt_i(:,3) = right2 - left2 + 1;
    dt_i(:,4) = bottom2 - top2 + 1;
  end

  if (~NICE_VISUALISATION)
    % Show results with nice visualization (removed score < NICE_VISUALIZATION_SCORE_THRESHOLD detections)
    showResOpts ={'evShow',0,'gtShow',0, 'dtShow',1, 'isMulticlass', 1, 'dtLs', '-'};
    iptsetpref('imshowBorder', 'tight');
    imshow(I, 'Border', 'tight');
    hs = bbGt('showRes', [], gt_i, dt_i, showResOpts); % multiClass = 1
    saveas(gcf, fullfile(IMG_RESULTS_PATH, file_name), 'png');      
  else
    % Show results with nice visualization (removed score < NICE_VISUALIZATION_SCORE_THRESHOLD detections)
    showResOpts ={'evShow',0,'gtShow',0, 'dtShow',1, 'isMulticlass', 1, 'dtLs', '-'};
    dt_i_nice = dt_i(dt_i(:,5)>=NICE_VISUALISATION_SCORE_THRESHOLD, :);
    iptsetpref('imshowBorder', 'tight');
    imshow(I, 'Border', 'tight');
    hs = bbGt('showRes', [], gt_i, dt_i_nice, showResOpts); % multiClass = 1
    saveas(gcf, fullfile(IMG_RESULTS_PATH, ['NICE_VISUALISATION_' file_name]), 'png');  
  end
      
  % Write the KITTI format for detections
  objects = [];
  for j=1:size(dt_i,1)
    objects(j).type = 'Car';
%    objects(j).alpha = quantized2angleKITTI(dt_i(j,7), detector.clf.num_classes-1);
    objects(j).alpha = 0;
    objects(j).x1 = dt_i(j,1);
    objects(j).y1 = dt_i(j,2);
    objects(j).x2 = dt_i(j,1) + dt_i(j,3) - 1;
    objects(j).y2 = dt_i(j,2) + dt_i(j,4) - 1;
    objects(j).score = dt{i}(j,5);
  end  
  image_number = str2num(file_name(1:end-4));
  writeKITTILabels(objects,LABELS_RESULTS_PATH,image_number)
end

