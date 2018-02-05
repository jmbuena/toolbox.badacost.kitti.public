# toolbox.badacost.kitti

This repo has the auxiliary Matlab and C++ code in order to replicate the experiments we made for car detection in our paper:
  
     BAdaCost: Multi-class Boosting with Costs
     Antonio Fernández-Baldera, José M. Buenaposada, and Luis Baumela

## Requirements

* Clone BAdaCost detection Matlab toolbox repository: badacost.toolbox.public. 
* Clone toolbox.badacost.kitti, a set of tools and code to perform the car detection experiments with the KITTI database.
* From the [object detection part](http://www.cvlibs.net/datasets/kitti/eval_object.php) of the KITTI database download:
  * The [training images](http://www.cvlibs.net/download.php?file=data_object_image_2.zip). 
  * The [training image labels](http://www.cvlibs.net/download.php?file=data_object_label_2.zip). 
  
  by decompressing the images file *data_object_image_2.zip* and the labels file *data_object_label_2.zip* we will get the following directory structure:
  
  ```
     kitti_database
      |
      +---training
      |      |
      |      +--- image_2 (png files for training)
      |      |
      |      +--- label_2 (txt files with ground truth)
      |             
      +---testing
             |
             +--- image_2 (png files fir testing and upload results to KITTI server)             
  ```
  The path, kitti_database in the example, with the KITTI training dir (with images and labels) will be refered as *KITTI_PATH* from now on.
  
## Execution of the training scripts
  
  There are two important scripts in the root of toolbox.badacost.kitti repository:
  
* **main.m** allows to prepare training data from *KITTI_PATH*, train a car detector with the best params and then test it on a set of a driving car images taken from KITTI server. Important variables to set in this script are:
  * *TOOLBOX_BADACOST_PATH*, path to the toolbox.badacost.public Matlab toolbox.
  * *KITTI_PATH*, path to the KITTI dataset.
  * *PREPARE_DATA*, set it to 1 to prepare KITTI data for BAdaCost training and execute main.m. Once prepared first time, you can set it to 0.
  * *DO_TRAINING*, set it to 1 to train the best parameters BAdaCost detector. Once trained first time, you can set it to 0.
  * *FAST_DETECTION*, set it to 1 in order to make faster detection but with less accuracy. Set it to 0 when you want improved accuracy as the cost of more execution time.
  * *SAVE_RESULTS*, set it to 1 in order to save processed images to disk (in the path given by *IMG_RESULTS_PATH*).
  * *NICE_VISUALIZATION_SCORE_THRESHOLD*, set it to the score value above detections are shown in results.
  * *VIDEO_FILES_PATH*, *FIRST_IMAGE*, *IMG_EXT*, are variables to point to the images over to execute the trained detector.

* **main_paper_experiments.m** allows to train SAMME and BAdaCost detectors with different parameters in bach.
* **main_paper_experiments_SubCat.m** allows to train SubCat detectors with different parameters in bach.
* **main_kitti_test_best_detector.m** allows to test the best SubCat, SAMME or BAdaCost best detector over the KITTI testing images.

