function plot_result_fig_kitti(prepared_data_path, output_data_path, results_dirs, legend_text, fig_filename)

KITTI_BENCH_EXE = fullfile('kitti_cpp_evaluation_code', 'evaluate_kitti_object');
KITTI_GT_TEST_DIR = fullfile(prepared_data_path, ['CROSS_VAL_10_FOLD_SPLITS/fold_10_test_from_training/label_2']);
FIRST_TEST_IMG_INDEX = 6733;
LAST_TEST_IMG_INDEX = 7480;
FONT_SIZE = 30;

% FIXME: Change this code in order to work on other platforms or just
%        compile KITTI evaluation code by other means.
if ~exist(KITTI_BENCH_EXE)
  old_dir = cd('kitti_cpp_evaluation_code');
  unix('cmake .');  
  unix('make');  
  cd(old_dir);
end

% Evaluate the KITTI benchmark  
for i=1:length(results_dirs)
   DT_DIR = fullfile('.', results_dirs{i}, 'LABELS_RESULTS');
   KITTI_BENCH_OUTPUT_PATH = fullfile('.', 'results', results_dirs{i});
   if ~exist(KITTI_BENCH_OUTPUT_PATH, 'dir')
     command_ = [KITTI_BENCH_EXE ' ' results_dirs{i} ' ' KITTI_GT_TEST_DIR ' ' DT_DIR sprintf(' %d %d', FIRST_TEST_IMG_INDEX, LAST_TEST_IMG_INDEX)];
     disp(command_);
     MatlabPath = getenv('LD_LIBRARY_PATH');
     setenv('LD_LIBRARY_PATH', '/usr/lib/');     
     unix(command_);
     setenv('LD_LIBRARY_PATH', MatlabPath);     
   end
end

% plot results figures:
EXPERIMENTS = {'Easy', 'Moderate', 'Hard'};
for i=1:length(EXPERIMENTS)
  h_figs(i) = figure;
  h = axes;
  set(h, 'FontSize', FONT_SIZE);
  xlabel('Recall');
  ylabel('Precision');
  title(sprintf('''%s'' results', EXPERIMENTS{i}));
end

colors = [...
          %
%           0 0 0; ...
%           1 0.9 0; ...
%           1 0 0; ...
          %
          0 1 0; ...
          0 0 1; ...
          1 0 1; ...
          0 1 1; ...
          0.5 0.5 0; ...
          %
          0 0 0; ...
          1 0.9 0; ...
          1 0 0; ...
          %
          1 0.5 0.5; ...
          0.6 1 0.25;...
          0.75 0.4 0.5; ...
          0.25, 0.8, 0.5; ...
          0.645, 0.13, 0.85; ...
          0.63, 0.82, 0.958; ...
          1 1 0];
%lines_styles = {'-','--', ':', '-.', '-','--', ':', '-.',};
markers = {'+','o', 'd', '.', 'x','s', 'd', '^','v','>','<','p', 'h','+','o', '*', '.'};

% AP is computed as average precision at 11 recall points [0, 0.1, 0.2, 0.3, ..., 0.9, 1]
AP_PASCAL_VOC_POINTS = [1, 5, 9, 13, 17, 21, 25, 29, 33, 37, 41];
for j=1:3
  figure(h_figs(j));
  % -------- Maximize the figure.
  frame_h = get(handle(gcf),'JavaFrame');
  set(frame_h,'Maximized',1); 
  % --------
  hold on;
  for i=1:length(results_dirs)
    KITTI_BENCH_OUTPUT_PATH = fullfile('.', 'results', results_dirs{i});
  
    % curves(:,1) - are the recall levels
    % curves(:,2) - are the EASY examples precision for given recall levels
    % curves(:,3) - are the MODERATE examples precision for given recall levels
    % curves(:,4) - are the HARD examples precision for given recall levels
    curves = load(fullfile(KITTI_BENCH_OUTPUT_PATH, 'plot', 'car_detection.txt'));
  
    % Average precision.
    AP = (sum(curves(AP_PASCAL_VOC_POINTS,j+1))/length(AP_PASCAL_VOC_POINTS))*100;
    plot(curves(:,1), curves(:,j+1), 'color', colors(i,:), 'marker', markers{i}, 'LineWidth', 4);
    legends{j,i} = sprintf('%s (AP %3.1f)', legend_text{i}, AP);
  end
  legend(legends(j,:), 'Location', 'SouthWest', 'FontSize', FONT_SIZE);
  grid on;
  hold off;
  
  ax = gca;
  ax.XAxis.FontSize = FONT_SIZE;
  ax.YAxis.FontSize = FONT_SIZE;
%  set(gca, 'FontSize', FONT_SIZE);
end

mkdir(fullfile(output_data_path, 'results_figures'));
for i=1:length(h_figs)
  figure(h_figs(i));
  saveas(gcf, fullfile(output_data_path, 'results_figures', [fig_filename, sprintf('_%s.eps', EXPERIMENTS{i})]), 'epsc');
%  saveas(gcf, fullfile(output_data_path, 'results_figures', [fig_filename, sprintf('_%s.fig', EXPERIMENTS{i})]), 'fig');
  saveas(gcf, fullfile(output_data_path, 'results_figures', [fig_filename, sprintf('_%s.png', EXPERIMENTS{i})]), 'png');
end




