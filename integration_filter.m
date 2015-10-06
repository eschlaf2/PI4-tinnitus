function [y] = integration_filter(x)

points = 5;
y = zeros(size(x));
% ff = designfilt('lowpassfir', 'PassbandFrequency', .3, ...
%     'StopbandFrequency', .35, 'PassbandRipple', 60, 'StopbandAttenuation', 40);
%     y = filtfilt(ff, x.').';
for i = 1:numel(x(:,1))
%     h = normcdf(linspace(-2.5, 2.5, points)) - .5 * ones(1, points); % set points = 10 here
% %     h = 1/points * ones(1,points); % set points = 5 here
% %     h = [ 0 0 1 5 8 9.2 9 7 4 2 0 -1 -1 -0.8 -0.7 -0.5 -0.3 -0.1 0 ];

%     h = 2.0263 * normpdf(linspace(-2.5, 0, points));
%     y(i,:) = conv(x(i,:) - mean(x(i,:)), h, 'same'); 
    y(i,:) = smooth(x(i,:));
%     y(i, :) = smooth(smooth(x(i,:)));
end
% y = y + m;
end
