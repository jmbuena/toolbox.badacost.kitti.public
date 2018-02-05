function alpha = quantized2angleKITTI(quantized_angle, num_bins)

  % View angle quantization stuff
  if (nargin < 2)
    num_bins = 16;
  end
  angle_div = (2.0 * pi)/num_bins;
  limits = [0, angle_div/2.0:angle_div:2.0*pi, 2.0*pi];
  
  qangle = 1:length(limits)-1; %range(len(limits)-1) % [0.0, X] and [Y, 2*pi] are the same interval
  qangle(length(qangle)) = 1;
            
  for i=1:(length(limits)-1)
    if (quantized_angle == qangle(i))
      alpha = (limits(i) + limits(i+1))*0.5;
      break;
    end
  end
  
  if (alpha > pi)
    alpha = 2.0*pi - alpha; 
  else 
    alpha = -alpha;
  end
  
end