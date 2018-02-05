function filters = computeCheckerboardsChnFilters(nChns, wFilter, nFilter)
% Compute multiscale filters as done in paper:
%
%  "How far are we from solving pedestrian detection?"
%  S. Zhang, R. Benenson, M. Omran, J. Hosang, B. Schiele
%  CVPR 2016.
%
m=nChns; w=wFilter; 

%% Checkerboards filters
filters=zeros(4,3,m,39,'single');
load('Checkerboards_filters_4x3.mat');
for i=1:m
  filters(:,:,i,:)=Checkerboards_filters(:,:,:);
end
