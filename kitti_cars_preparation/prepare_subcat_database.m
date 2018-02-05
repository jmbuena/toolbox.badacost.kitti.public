
% ------------------------------------------------------------------------
% get model dimensions from training data.
TRAINING_DATA_PATH = fullfile(PREPARED_DATA_PATH, 'CROSS_VAL_10_FOLD_SPLITS_WITH_ALL_FLIPPED_IMAGES', 'fold_10_train_from_training/');
posGtDir = fullfile(TRAINING_DATA_PATH, 'label_2');
posImgDir = fullfile(TRAINING_DATA_PATH, 'image_2');

pLoad = {'lbls',{'Car'},'ilbls',{'DontCare', 'Truck', 'Van', 'Tram'}}; 
pLoad = {pLoad{:} 'hRng',[25 inf]}; % 25 pixels minimum height
pLoad = {pLoad{:} 'format', 38, 'nOrient', 20, 'hMin', 25, 'occlMax', 1, 'truncMax', 0.3}; 
% aRatios = computePerClassAspectRatios(posImgDir, posGtDir, pLoad, 'median');
% B = length(aRatios);

mkdir(fullfile(PREPARED_DATA_PATH,'SUBCAT_DATA','train','images'));
mkdir(fullfile(PREPARED_DATA_PATH,'SUBCAT_DATA','train','annotations'));
%mkdir(fullfile(PREPARED_DATA_PATH,'SUBCAT_DATA','test','images'));
%mkdir(fullfile(PREPARED_DATA_PATH,'SUBCAT_DATA','test','annotations'));

%% Construct training set
fs={posImgDir,posGtDir};
fs=bbGt('getFiles',fs); nImg=size(fs,2); assert(nImg>0);
gt   = cell(nImg,1);
lbls = cell(nImg,1);

for i=1:nImg
  [objs_,gt_] = bbGt('bbLoad',fs{2,i},pLoad);
  indices = gt_(:,5)==0;
  if (sum(indices)>0)
    lbls{i} = [objs_(indices).subclass]';
    gt{i}   = gt_(indices,:);
  end
end
%gt = cell2mat(gt);
%lbls = cell2mat(lbls);
B = length(unique(cell2mat(lbls)));

parfor i=1:nImg
%for i=1:nImg
  gt_i = gt{i};
  lbls_i = lbls{i};
  
  % For each object in the image, determine ignore or not and orientation cluster
  Ilabs = []; Ibbs = [];
  for obj_i = 1:length(lbls{i});
    currbb = gt_i(obj_i,:); 
    Ilabs{obj_i} = sprintf('car%02d',lbls_i(obj_i));
    Ibbs(obj_i,:) = currbb;
  end
  % Link Image
  [pathstr, name, ext] = fileparts(fs{1,i});
  inImg = fullfile(pwd(), TRAINING_DATA_PATH, 'image_2', [name ext]);
  outImg = fullfile(pwd(), PREPARED_DATA_PATH,'SUBCAT_DATA','train','images', [name ext]);
  if ispc()
    system(['mklink', ' ', '"', outImg, '"', ' ', '"', inImg, '"' ' >NUL 2>NUL']);
  elseif isunix()
    system(sprintf('ln -s %s %s',inImg,outImg));
  end
  
  % Write Annotation
  fileID = fopen(fullfile(pwd(), PREPARED_DATA_PATH,'SUBCAT_DATA','train','annotations',[name '.txt']),'w+');
  fprintf(fileID, '%% bbGt version=3\n');
  for j_a = 1:size(Ibbs,1)
    if (isempty(Ilabs{j_a}))
      disp('warning: empty label'); pause
    else
      fprintf(fileID, '%s %d %d %d %d 0 0 0 0 0 0 0\n',Ilabs{j_a},Ibbs(j_a,1),Ibbs(j_a,2),Ibbs(j_a,3),Ibbs(j_a,4));
    end
  end
  fclose(fileID);
end
 
 
% %% Construct validation set 
% N = length(testIdx);
% for i=1:N
%     
%     objects = readLabels(fullfile(kittiRoot,'label_2'),testIdx(i));
%  
%     %For each object in the image, determine ignore or not and orientation cluster
%     Ilabs = []; Ibbs = [];
%     for obj_i = 1:length(objects);
%         currbb = [objects(obj_i).x1 objects(obj_i).y1 objects(obj_i).x2 objects(obj_i).y2];
%         currbb(currbb<1)=1;
%         currbb = bbox_to_xywh(currbb); 
%         
%         if(sum(strcmp(objects(obj_i).type,labels))>0 ...
%                 && currbb(1,4)>minboxheight ...
%                 && sum(objects(obj_i).occlusion==occlusionLevel)>0 ...
%                 &&  objects(obj_i).truncation <= Maxtruncation)
%             
%             %Determine label cluster
%             alpha = double(objects(obj_i).alpha);
%             while alpha <= -pi, alpha = alpha + 2*pi;end
%             while alpha > pi, alpha = alpha - 2*pi;end
%             [labelsquant,~] = quantizeAngles(alpha,B);
%              Ilabs{obj_i} = sprintf('car%02d',labelsquant);
%         else
%             %Ignore label
%             Ilabs{obj_i} = 'ig';
%         end
%         Ibbs(obj_i,:) = currbb;
%     end
%     
%     %Link Image
%     inImg = fullfile(kittiRoot,'image_2',sprintf('%06d.png',testIdx(i)));
%     outImg = fullfile(dataRoot,'test','images',sprintf('%06d.png',testIdx(i)));
%     if ispc()
%         system(['mklink', ' ', '"', outImg, '"', ' ', '"', inImg, '"' ' >NUL 2>NUL']);
%     elseif isunix()
%         system(sprintf('ln -s %s %s',inImg,outImg));
%     end
%     
%     %Write Annotation
%     fileID = fopen(fullfile(dataRoot,'test','annotations',sprintf('%06d.txt',testIdx(i))),'w+');
%     fprintf(fileID, '%% bbGt version=3\n');
%     for j_a = 1:size(Ibbs,1)
%         if(isempty(Ilabs{j_a}))
%             disp('warning: empty label'); pause
%         else
%         fprintf(fileID, '%s %d %d %d %d 0 0 0 0 0 0 0\n',Ilabs{j_a},Ibbs(j_a,1),Ibbs(j_a,2),Ibbs(j_a,3),Ibbs(j_a,4));
%         end
%     end
%     fclose(fileID);
% end