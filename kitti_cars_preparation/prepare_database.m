

% Split training data in 10 subsets for cross validation.
% In this case, the split is not at random but just by 
% indices of training images: first 10% of indices are going to 
% the first fold, and so on. 
% The following script also make folders with test fold
% and train folds for the 10 cross validation experiments.
% NOTE: **images are not copied** the script makes just a soft link.
kitti_split_crossval_training_set_for_test;

% Just flip car images horizontally to double the dataset images
% but taking care of the change in car orientation class in labels.
kitti_flip_images_and_labels;

% Split training data PLUS FLIPPED IMAGES in 10 subsets for cross validation.
% In this case, the split is not at random but just by 
% indices of training images: first 10% of indices are going to 
% the first fold, and so on. 
% The following script also make folders with test fold
% NOTE: **images are not copied** the script makes just a soft link.
kitti_split_crossval_training_with_flipped_images_for_test



