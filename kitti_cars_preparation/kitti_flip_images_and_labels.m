
KITTI_TRAINING_DIR = fullfile(KITTI_PATH, 'training');
%DST_IMGS_TRAINING_DIR = fullfile(KITTI_TRAINING_DIR, 'flipped_image_2');
%DST_LBLS_TRAINING_DIR = fullfile(KITTI_TRAINING_DIR, 'flipped_label_2');
DST_IMGS_TRAINING_DIR = fullfile(PREPARED_DATA_PATH, 'flipped_image_2');
DST_LBLS_TRAINING_DIR = fullfile(PREPARED_DATA_PATH, 'flipped_label_2');

mkdir(DST_IMGS_TRAINING_DIR);
mkdir(DST_LBLS_TRAINING_DIR);

figure;
for i=0:7480
   file_name = sprintf('%06d',i),
   src_img_file = fullfile(KITTI_TRAINING_DIR, 'image_2', [file_name '.png'])
   src_lbl_file = fullfile(KITTI_TRAINING_DIR, 'label_2', [file_name '.txt']);
   dst_img_file = fullfile(DST_IMGS_TRAINING_DIR, [file_name '.png']);
   dst_lbl_file = fullfile(DST_LBLS_TRAINING_DIR, [file_name '.txt']);

   % read labels and flip them
   objects = readKITTILabels(src_lbl_file);
   
   % Flip image horizontally
   I = imread(src_img_file);
   I2 = flipdim(I,2);
   imwrite(I2, dst_img_file);

   subplot(2,1,1);   
   imshow(I);
   title('Original');
   for j=1:length(objects)     
     % Draw boxes on I
     bb = [objects(j).x1, objects(j).y1 objects(j).x2-objects(j).x1+1 objects(j).y2-objects(j).y1+1];
     rectangle('Position', bb, 'LineWidth', 2, 'LineStyle', '-', 'EdgeColor', 'r'); 
     text(bb(1),bb(2)+bb(4),num2str(quantize_KITTI_alpha_angle(objects(j).alpha, 20)), ...
         'FontSize',20,'color','y','FontWeight','bold',...
          'VerticalAlignment','bottom'); 
   end

   subplot(2,1,2);   
   imshow(I2);
   hold on;
   title('flipped left-right');

   fields =  {'h', 'w', 'l', 't', 'ry'}; % We don't flip 3D info (only 2D)
   for j=1:length(objects)     
     % Remove 3D info fields.
     S = rmfield(objects(j), fields); 
     
     % Flip 2D box and draw on I2
     S.x1 = size(I,2) - objects(j).x2 + 1;
     S.x2 = size(I,2) - objects(j).x1 + 1;
     
     bb = [S.x1, S.y1 S.x2-S.x1+1 S.y2-S.y1+1];
     hs(j)=rectangle('Position', bb, 'LineWidth', 2, 'LineStyle', '-', 'EdgeColor', 'r'); 
     
     % Flip alpha 
     alpha = objects(j).alpha;
     if (alpha > 0.0)
       alpha2 = pi - alpha; 
     else
       alpha2 = -(pi + alpha); 
     end
     S.alpha = alpha2;     
     objects2(j) = S;
     
     if (strcmp(objects2(j).type, 'Car')==1)
       text(bb(1),bb(2)+bb(4),num2str(quantize_KITTI_alpha_angle(objects2(j).alpha, 20)), ...
           'FontSize',20,'color','y','FontWeight','bold',...
            'VerticalAlignment','bottom');      
     end
   end
   
   writeKITTILabels(objects2,DST_LBLS_TRAINING_DIR,i);
   clear objects2;
%   pause;
end

