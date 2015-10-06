function [] = ts_plot(data, varargin) %highlight, subplot_dim, ttle, lgnd)
% Data should be input as a matrix with dimensions (subject, roi, time)
regions_of_interest; GROUPS;
    
data = squeeze(data);
if numel(size(data)) < 3
    data = reshape(data, [1 size(data)]);
elseif numel(size(data)) > 3
    error('Input data should have 3 or fewer dimensions');
end

p = inputParser;
    p.CaseSensitive = 0;
    defaultTitle = num2cell((1:size(data,1)).');
    defaultLegend = ['Music On', ROIS((1:9))];
    defaultSubplot_dim = [1 size(data,1)];
    
    addRequired(p, 'data')
    addOptional(p, 'highlight', zeros(size(data(1,1,:))));
    addOptional(p, 'subplot_dim', defaultSubplot_dim, ...
        @(x) prod(x) == size(data,1));
    addOptional(p, 'ttle', defaultTitle);
    addOptional(p, 'lgnd', defaultLegend);
    
parse(p, data, varargin{:});
        
colorset = [lines(7);cool(2)];
spread = 5;
set(gcf,'DefaultAxesColorOrder',colorset)   
set(gcf, 'DefaultAxesPosition', [.2 .1 .6 .8]);
x = zeros(1, 10 * size(p.Results.data, 3)); x(p.Results.highlight) = 1;
colr = .9 * [1 1 1];

for i = 1:prod(p.Results.subplot_dim)
    subplot(p.Results.subplot_dim(1), p.Results.subplot_dim(2), i);
    area((.1:.1:size(p.Results.data,3)), 3 * spread * size(p.Results.data,2) .* x, ...
        'FaceColor', colr, 'EdgeColor', colr); hold on;
    spread_ts = squeeze(p.Results.data(i,:,:)) + ...
        repmat(spread*(1:numel(p.Results.data(i,:,1))).', 1, size(p.Results.data,3));
    plot(spread_ts.', 'LineWidth', 2);
    if i == 1
        h1leg = legend(p.Results.lgnd);
        set(h1leg, 'Position', [.07, .85, 0.01, 0.01]);
    end
    ylim([0, max(spread_ts(end,:)) + 1]);
    if i <= length(p.Results.ttle)
        title(p.Results.ttle{i});
    end  
end    

xlabel('Time');
    
    
    