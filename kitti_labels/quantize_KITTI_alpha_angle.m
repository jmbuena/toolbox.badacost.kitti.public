function quantized_angle = quantize_KITTI_alpha_angle(alpha, num_bins)

  % View angle quantization stuff
  if (nargin < 2)
    num_bins = 16;
  end
  angle_div = (2.0 * pi)/num_bins;
  limits = [0, angle_div/2.0:angle_div:2.0*pi, 2.0*pi];
  
  qangle = 1:length(limits)-1; %range(len(limits)-1) % [0.0, X] and [Y, 2*pi] are the same interval
  qangle(length(qangle)) = 1;
    
  if (alpha > 0.0)
    angle = 2.0*pi - alpha; % + pi/2.0;
  else
    angle = -alpha; % + pi/2.0;             
  end
       
  if (angle > 2.0*pi)
    angle = angle - 2.0*pi;
  end
        
  for i=1:length(limits)-1
    if (limits(i) <= angle) && (angle < limits(i+1))
      quantized_angle = qangle(i);
    end
  end
  
end