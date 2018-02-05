function filters = computeRotatedFilters(nChns, wFilter, nFilter)
% Compute multiscale filters as done in paper:
%
%  "How far are we from solving pedestrian detection?"
%  S. Zhang, R. Benenson, M. Omran, J. Hosang, B. Schiele
%  CVPR 2016.
%
m=nChns; w=wFilter; %wp=w*2-1;

filters=zeros(w,w,m,nFilter,'single');
nScale=3;
nFilter0=nFilter/nScale;
pad=w;pad2=pad*2;
% 16x16 filters
flt1=ones(w,w);%copy filter
flt2=ones(w+pad2,w+pad2);%horizontal filter
if mod(w,2)==0
    flt2((w+pad2)/2+1:w+pad2,:)=-1*ones((w+pad2)/2,w+pad2);
else
    flt2(round((w+pad2)/2),:)=zeros(1,w+pad2);
    flt2(round((w+pad2)/2)+1:w+pad2,:)=-1*ones(round((w+pad2)/2)-1,w+pad2);
end
flt3=flt2';% a larger horizontal filter to crop from
for i=1:4
    filters(:,:,i,1)=flt1;
    filters(:,:,i,2)=flt2(pad+1:w+pad,pad+1:w+pad);
    filters(:,:,i,3)=flt3(pad+1:w+pad,pad+1:w+pad);
end
 
for i=5:m
    filters(:,:,i,1)=flt1;
    flt_tmp=imrotate(flt2,90-(i-5)*30,'bilinear','crop');
    filters(:,:,i,2)=flt_tmp(pad+1:w+pad,pad+1:w+pad);
    flt_tmp=imrotate(flt3,90-(i-5)*30,'bilinear','crop');
    filters(:,:,i,3)=flt_tmp(pad+1:w+pad,pad+1:w+pad);
end
 
for iscale=2:nScale
    w0=w/(2^(iscale-1));
    border=(w-w0)/2; 
    for i=1:m
        for j=1:nFilter0
            iflt=(iscale-1)*nFilter0+j;
            filters(:,:,i,iflt)=zeros(w,w);
            filters(border+1:w-border,border+1:w-border,i,iflt)=filters(border+1:w-border,border+1:w-border,i,j);
        end
    end
end
