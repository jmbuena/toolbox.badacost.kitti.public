function filters = computeSquaresChnFilters(nChns, wFilter, nFilter)
% Compute multiscale filters as done in paper:
%
%  "How far are we from solving pedestrian detection?"
%  S. Zhang, R. Benenson, M. Omran, J. Hosang, B. Schiele
%  CVPR 2016.
%
m = nChns; w=wFilter; 

filters=zeros(64,64,m,16,'single');
load('SquaresChnFtrs_filters.mat');
for i=1:m
  filters(:,:,i,:)=SquaresChnFtrs_filters(:,:,:);
end
