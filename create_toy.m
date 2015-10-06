function [toy_data, ss] = create_toy(type, varargin)
% Makes sample data. Choose what type of function to look at. Options are
% 'sines', 'gaussian', 'data'. Additionally, enter options as you would for
% plotting.

p = inputParser;
    p.CaseSensitive = 0;
    defaultType = 'sines';
    expectedTypes = {'sines', 'data', 'gaussian'};
    defaultRois = 9;
    defaultLoops = 10;
    defaultTime = 100;
    defaultNoiseMag = 0;
    defaultShift = 'a';
    defaultPeaks = 7;


    addOptional(p,'type',defaultType,...
       @(x) any(validatestring(x, expectedTypes)));
    addParameter(p,'rois',defaultRois, @isnumeric);
    addParameter(p,'loops',defaultLoops);
    addParameter(p, 'time', defaultTime);
    addParameter(p, 'NoiseMag', defaultNoiseMag);
    addParameter(p, 'shift', defaultShift, @(x) isnumeric(x));
    addParameter(p, 'peaks', defaultPeaks, @isnumeric);

    parse(p,type,varargin{:});
    
if ischar(p.Results.shift)
%     Default to all rois shifted within two time units
    shift = 2 .* rand(p.Results.rois,1);
else 
    shift = p.Results.shift;
end

switch p.Results.type
    case 'sines'
        t = (1:p.Results.time)/p.Results.time;
        line = rand * 100 * sin(2*pi * p.Results.loops * t) + 500;
    case 'data'
        roi_line; 
%         h = normcdf(linspace(-2.5, 2.5, 10)) - .5 * ones(1, 10);
%         mean_centered = data_line1 - repmat(mean(data_line1), 1, length(data_line1));
%         line = data_line1;
%         line = smooth(conv(mean_centered, h, 'same')) + 500;
        line = smooth(smooth(data_line1));
    case 'gaussian'
        t = (1:p.Results.time);
        line = 30 .* normpdf(t, p.Results.time/2, 1) + 500;
        for i = 1:p.Results.peaks - 1
            line = line + 100 * rand .* ...
                normpdf(t, ...
                randi([2, p.Results.peaks*2 - 2])/(p.Results.peaks*2 - 1) *...
                p.Results.time, randi([1 3]));
        end
%         line = circshift(line', floor(mean(shift)));
end

f = fit(p.Results.time/numel(line) .* (1:numel(line)).', ...
    reshape(line, [], 1), 'linear');
x = repmat((1:p.Results.time), p.Results.rois, 1) + ...
    repmat(shift, 1, p.Results.time);
lines = reshape(f(x), size(x));
lines = power(lines, repmat(rand(p.Results.rois,1) + ...
    ones(p.Results.rois,1), 1, p.Results.time));
if strcmp(p.Results.type, 'sines')
    tt = max(shift).*repmat((1:p.Results.rois).',1, p.Results.time) + ...
        repmat((1:p.Results.time), p.Results.rois,1)./p.Results.time;
    lines = sin(2*pi * p.Results.loops * tt);
end
toy_data = lines + p.Results.NoiseMag .* ...
    repmat(std(lines, [], 2), 1, p.Results.time) .* randn(size(lines));

[~, ss] = sort(shift, 'descend'); 

% if Display_; display(ss); end
