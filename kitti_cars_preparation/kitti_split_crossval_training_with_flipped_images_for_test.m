KITTI_TRAINING_DIR = fullfile(KITTI_PATH, 'training');
NUM_FOLDS = 10;
NUM_KITTI_IMGS = 7480;
NUM_FOLD_IMGS = round(7480/10);

%SAVE_PATH_ROOT = fullfile(KITTI_PATH, sprintf('CROSS_VAL_%d_FOLD_SPLITS_WITH_ALL_FLIPPED_IMAGES', NUM_FOLDS));
SAVE_PATH_ROOT = fullfile(PREPARED_DATA_PATH, sprintf('CROSS_VAL_%d_FOLD_SPLITS_WITH_ALL_FLIPPED_IMAGES', NUM_FOLDS));
mkdir(SAVE_PATH_ROOT);

img_indices = cell(1,NUM_FOLDS);
for f=1:NUM_FOLDS
  img_indices{f} = (f-1)*NUM_FOLD_IMGS+1:f*NUM_FOLD_IMGS;
end

for f=10 % By now only 10th fold data is needed %f=1:NUM_FOLDS
  test_imgs_indices = img_indices{f};
  train_imgs_indices = cell2mat(img_indices([1:f-1,f+1:end]));
    
  DST_LABELS_TRAINING_DIR = fullfile(SAVE_PATH_ROOT, sprintf('fold_%d_train_from_training/label_2', f));
  DST_IMGS_TRAINING_DIR = fullfile(SAVE_PATH_ROOT, sprintf('fold_%d_train_from_training/image_2', f));
  mkdir(DST_LABELS_TRAINING_DIR);
  mkdir(DST_IMGS_TRAINING_DIR);
  for i=train_imgs_indices
     file_name = sprintf('%06d',i),
     src_lbl_file = fullfile(KITTI_TRAINING_DIR, 'label_2', [file_name '.txt']);
     unix(['ln -s ' src_lbl_file ' ' fullfile(DST_LABELS_TRAINING_DIR, [file_name '.txt'])]);  

     src_img_file = fullfile(KITTI_TRAINING_DIR, 'image_2', [file_name '.png']);
     unix(['ln -s ' src_img_file ' ' fullfile(DST_IMGS_TRAINING_DIR, [file_name '.png'])]);        

     src_lbl_file = fullfile(KITTI_TRAINING_DIR, 'flipped_label_2', [file_name '.txt']);
     unix(['ln -s ' src_lbl_file ' ' fullfile(DST_LABELS_TRAINING_DIR, [file_name '_flipped.txt'])]);  

     src_img_file = fullfile(KITTI_TRAINING_DIR, 'flipped_image_2', [file_name '.png']);
     unix(['ln -s ' src_img_file ' ' fullfile(DST_IMGS_TRAINING_DIR, [file_name '_flipped.png'])]);        
  end
  
  
  DST_LABELS_TESTING_DIR = fullfile(SAVE_PATH_ROOT, sprintf('fold_%d_test_from_training/label_2', f));
  DST_IMGS_TESTING_DIR = fullfile(SAVE_PATH_ROOT, sprintf('fold_%d_test_from_training/image_2', f));
  mkdir(DST_LABELS_TESTING_DIR);
  mkdir(DST_IMGS_TESTING_DIR);
  for i=test_imgs_indices
    file_name = sprintf('%06d',i),
     src_lbl_file = fullfile(KITTI_TRAINING_DIR, 'label_2', [file_name '.txt']);
     unix(['ln -s ' src_lbl_file ' ' fullfile(DST_LABELS_TESTING_DIR, [file_name '.txt'])]);  

     src_img_file = fullfile(KITTI_TRAINING_DIR, 'image_2', [file_name '.png']);
     unix(['ln -s ' src_img_file ' ' fullfile(DST_IMGS_TESTING_DIR, [file_name '.png'])]);         

     src_lbl_file = fullfile(KITTI_TRAINING_DIR, 'flipped_label_2', [file_name '.txt']);
     unix(['ln -s ' src_lbl_file ' ' fullfile(DST_LABELS_TESTING_DIR, [file_name '_flipped.txt'])]);  

     src_img_file = fullfile(KITTI_TRAINING_DIR, 'flipped_image_2', [file_name '.png']);
     unix(['ln -s ' src_img_file ' ' fullfile(DST_IMGS_TESTING_DIR, [file_name '_flipped.png'])]);         
  end  
end
