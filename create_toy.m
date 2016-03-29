function [toy_data, ss] = create_toy(data_type, varargin)
% Makes sample data. Choose what type of function to look at from
% 'sines', 'gaussian', 'data'. Default 'sines'. Optional arguments:
%     rois:       number of time series. default = 9
%     loops:      number of periods for 'sines' type. default = 5
%     time:       number of time points. default = 100
%     noisemag:   standard deviation of noise with respect to standard 
%                 deviation of signal.signal to noise ratio 
%                 (e.g. noisemag=0.25 means signal to noise ratio 
%                 ((?_signal/?_noise)^2) is (1/0.25)^2.
%                 default = 0
%     shift:      maximum time steps between between signals.
%                 default = 5
%     peaks:      number of peaks for 'gaussian' type. default = 7

p = inputParser;
    p.CaseSensitive = 0;
    defaultType = 'sines';
    expectedTypes = {'sines', 'data', 'gaussian'};
    defaultRois = 9;
    defaultLoops = 5;
    defaultTime = 100;
    defaultNoiseMag = 0;
    defaultShift = 5;
    defaultPeaks = 7;


    addOptional(p,'type',defaultType,...
       @(x) any(validatestring(x, expectedTypes)));
    addParameter(p,'rois',defaultRois, @isnumeric);
    addParameter(p,'loops',defaultLoops);
    addParameter(p, 'time', defaultTime);
    addParameter(p, 'NoiseMag', defaultNoiseMag);
    addParameter(p, 'shift', defaultShift, @(x) isnumeric(x));
    addParameter(p, 'peaks', defaultPeaks, @isnumeric);

    parse(p,data_type,varargin{:});
    
    shift = p.Results.shift .* rand(p.Results.rois,1);
    
% if ischar(p.Results.shift)
% %     Default to all rois shifted within two time units
%     shift = 2 .* rand(p.Results.rois,1);
% else 
%     shift = p.Results.shift;
% end

data_type = validatestring(p.Results.type, expectedTypes);

switch data_type
    case 'sines'
        t = (1:p.Results.time)/p.Results.time;
        shift = shift./p.Results.time;
        line = rand * 100 * sin(2*pi * p.Results.loops * t) + 500;
    case 'data'
        roi_line; 
%         h = normcdf(linspace(-2.5, 2.5, 10)) - .5 * ones(1, 10);
%         mean_centered = data_line1 - repmat(mean(data_line1), 1, length(data_line1));
%         line = data_line1;
%         line = smooth(conv(mean_centered, h, 'same')) + 500;
        line = smooth(smooth(data_line1));
%         line = data_line1;
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
if strcmp(data_type, 'sines')
    tt = repmat(linspace(0, 1, p.Results.time), p.Results.rois, 1) + ...
        repmat(shift, 1, p.Results.time);
%     max(shift).*repmat((1:p.Results.rois).',1, p.Results.time) + ...
%         repmat((1:p.Results.time), p.Results.rois,1)./p.Results.time;
    lines = sin(2*pi * p.Results.loops * tt);
end
toy_data = lines + p.Results.NoiseMag .* ...
    repmat(std(lines, [], 2), 1, p.Results.time) .* randn(size(lines));

[~, ss] = sort(shift, 'descend'); 

% if Display_; display(ss); end
