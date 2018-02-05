KITTI_PATH = '/home/imagenes/CARS_DATABASES/KITTI_DATABASE/'
KITTI_TRAINING_DIR = fullfile(KITTI_PATH, 'training');
NUM_KITTI_IMGS = 7480;

SAVE_PATH_ROOT = KITTI_TRAINING_DIR;
DST_LABELS_TRAINING_DIR = fullfile(SAVE_PATH_ROOT, 'flipped_enlarged_label_2');
DST_IMGS_TRAINING_DIR = fullfile(SAVE_PATH_ROOT, 'flipped_enlarged_image_2');
mkdir(SAVE_PATH_ROOT);

mkdir(DST_LABELS_TRAINING_DIR);
mkdir(DST_IMGS_TRAINING_DIR);
for i=0:NUM_KITTI_IMGS
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
