function apply_detector_to_imgs(badacost_detector, imgs_path, imgs_ext, first_image_index, ...
                                min_score_shown, fast_detection, ...
                                save_results, save_path)

if (fast_detection)
  save_path = [save_path '_Faster'];

  % Much faster detections.
  if iscell(badacost_detector)
    for i=1:length(badacost_detector)
      badacost_detector{i}.opts.cascThr = badacost_detector{i}.opts.cascThr * 0.1;
      badacost_detector{i}.opts.pPyramid.nApprox = 7;
      badacost_detector{i}.opts.pPyramid.nPerOct = 8;
      badacost_detector{i}.opts.pPyramid.nOctUp = 0; % Loose too small detections.
    end
  else
    badacost_detector.opts.cascThr = badacost_detector.opts.cascThr * 0.1;
    badacost_detector.opts.pPyramid.nApprox = 7;
    badacost_detector.opts.pPyramid.nPerOct = 8;
    badacost_detector.opts.pPyramid.nOctUp = 0; % Loose too small detections.
  end
else 
  if iscell(badacost_detector)
    for i=1:length(badacost_detector)
      badacost_detector{i}.opts.cascThr = badacost_detector{i}.opts.cascThr * 0.1;
      badacost_detector{i}.opts.pPyramid.nApprox = 9;
      badacost_detector{i}.opts.pPyramid.nPerOct = 10;
      badacost_detector{i}.opts.pPyramid.nOctUp = 1; % Loose too small detections.
    end
  else
    badacost_detector.opts.cascThr = badacost_detector.opts.cascThr * 0.1;
    badacost_detector.opts.pPyramid.nApprox = 9;
    badacost_detector.opts.pPyramid.nPerOct = 10;
    badacost_detector.opts.pPyramid.nOctUp = 1; % Loose too small detections.    
  end
end

if save_results
  mkdir(save_path);
end

i = first_image_index; 
h = figure;
while (true)
  file_name = sprintf(['%010d.' imgs_ext], i);
  file_path = fullfile(imgs_path, file_name);
%  try
    I = imread(file_path);
    
    % Display badacost results.
    showResOpts ={'evShow',0,'gtShow',0, 'dtShow',1, 'isMulticlass', 1, 'dtLs', '-', 'cols', 'krg'}; 
    if iscell(badacost_detector)
      tic;
      bbs = acfDetect(I, badacost_detector);
      toc
    else
      tic;
      [bbs, labels] = acfDetectBadacost(I, badacost_detector);
      toc
    end
    if (save_results)
      save(fullfile(save_path, sprintf('BADACOST_%05d.mat', i)), 'bbs');
    end
    bbs_nice = bbs(bbs(:,5)>=min_score_shown, :);
    if ~iscell(badacost_detector)
      if ~isempty(bbs_nice)
         bbs_nice(:,6) = bbs_nice(:,6)-ones(size(bbs_nice, 1), 1);
      end
    end
    imshow(I, 'Border', 'tight');
    hs = bbGt('showRes', [], [], bbs_nice, showResOpts);
    hold off;
    drawnow;
    set(gca, 'XLim', [1, size(I,2)]);
    set(gca, 'YLim', [1, size(I,1)])
    if (imgs_path)
      saveas(gca, fullfile(save_path,  file_name), imgs_ext);  
    end
%   catch 
%     warning('File does not exists');
%     break;
%  end
  i = i + 1;
end
