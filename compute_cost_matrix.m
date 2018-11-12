function Cost = compute_cost_matrix(num_classes, useSAMME, costsAlpha, costsBeta, costsGamma)

if useSAMME
  Cost = ones(num_classes,num_classes) - diag(ones(num_classes,1));
else
  n = ceil((num_classes-1)/2);
  factor = 10; 
  max_ = costsGamma; 
  min_ = max_ / factor;
  inc_ = (max_ - min_) / (n - 1);
  costs_vector = [min_:inc_:max_, (max_-inc_):-inc_:min_];
  costs_vector = [0, costs_vector];
  PosCosts = zeros(num_classes-1,num_classes-1);
  for i=1:num_classes-1
    indices = mod((-i+1):num_classes-1-i, num_classes-1)+1;
    PosCosts(i,:) = costs_vector(indices);
  end          
  Cost = [[0             costsAlpha*ones(1,num_classes-1)]; ...
         [costsBeta*ones(num_classes-1,1)  PosCosts]];
end
