function objects = readKITTILabels(fName)

% parse input file
fid = fopen(fName,'r');
C   = textscan(fid,'%s %f %d %f %f %f %f %f %f %f %f %f %f %f %f','delimiter', ' ');
fclose(fid);

% for all objects do
objects = [];
for o = 1:numel(C{1})

  % extract label, truncation, occlusion
  lbl = C{1}(o);                   % for converting: cell -> string
  objects(o).type       = lbl{1};  % 'Car', 'Pedestrian', ...
  objects(o).truncation = C{2}(o); % truncated pixel ratio ([0..1])
  objects(o).occlusion  = C{3}(o); % 0 = visible, 1 = partly occluded, 2 = fully occluded, 3 = unknown
  objects(o).alpha      = C{4}(o); % object observation angle ([-pi..pi])

  % extract 2D bounding box in 0-based coordinates
  objects(o).x1 = C{5}(o); % left
  objects(o).y1 = C{6}(o); % top
  objects(o).x2 = C{7}(o); % right
  objects(o).y2 = C{8}(o); % bottom

  % Object's difficulty class
  objects(o).difficulty = difficulty_class(objects(o).truncation, objects(o).occlusion); %, objects(o).y2 - objects(o).y1); 

  % extract 3D bounding box information
  objects(o).h    = C{9} (o); % box height
  objects(o).w    = C{10}(o); % box width
  objects(o).l    = C{11}(o); % box length
  objects(o).t(1) = C{12}(o); % location (x)
  objects(o).t(2) = C{13}(o); % location (y)
  objects(o).t(3) = C{14}(o); % location (z)
  objects(o).ry   = C{15}(o); % yaw angle
end

end

function d = difficulty_class(truncation, occlusion) %, height)
%
%  EASY     - d = 1
%  MODERATE - d = 2
%  HARD     - d = 3 

  % From KITTI evaluation sofware (evaluate_object.cpp)
  MIN_HEIGHT = [40, 25, 25]; % minimum height for evaluated groundtruth/detections
  MAX_OCCLUSION = [0, 1, 2]; % maximum occlusion level of the groundtruth used for evaluation
  MAX_TRUNCATION = [0.15, 0.3, 0.5]; % maximum truncation level of the groundtruth used for evaluation

  d = 1;
  index = 1;
  for o=1:length(MAX_OCCLUSION)
    if occlusion<=MAX_OCCLUSION(o)
      d = index;
      break;
    end
    index = index + 1;
  end
end