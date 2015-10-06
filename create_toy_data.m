function [toy_data, ss] = create_toy_data(rois, loops, time, noise_magnitude, type, display_)

% This script makes sample data to see how the different analysis methods
% turn out. The variable toy_data is the z matrix that we created
% originally. The rest of the stuff is to look at how the methods perform
% with different types of data. One thing that I like about the eigenvalue
% method is that the lead matrix can give us an idea how strong the
% cyclicity was. 

% Choose what type of function to look at. Options are 'sines',
% 'altered_sines', 'non-cyclic','step','gaussian', 'data'

ang=rand(1,rois)*2*pi;  %generate random starting angles

t=(1:time)/time;
[time_mesh, ang_mesh] = meshgrid(loops*2*pi.*t,ang);

not_sine_data = {'gaussian', 'non-cyclic', 'data'};
if not(sum(strncmp(type,not_sine_data,4)))
% Sine functions
    toy_data=sin(ang_mesh + time_mesh) + noise_magnitude*randn(rois,time);
    % ss shows the permutation that we should get from the analysis
    [~,ss] = sort(ang, 'descend'); %ss = keep_one_first(ss); 
    if display_; display(ss,'permutation'); display(ang(ss),'ang'); end
end

if strcmp(type, 'altered_sines')
% Altered Sines
    z2 = sin(2*(ang_mesh + time_mesh));
    toy_data(2:3,:) = z2(2:3,:);
end

if strcmp(type, 'non-cyclic')
% non-cyclic functions
    toy_data = ang_mesh + time_mesh;
    toy_data(2,:) = ang_mesh(2,:) + time_mesh(2,:);
    toy_data(2,:) = 2 * toy_data(2,:);
    toy_data(3,:) = 2*ang_mesh(3,:) + time_mesh(3,:);
    [~,ss] = sort(ang, 'descend'); ss = keep_one_first(ss); 
    if display_; display(ss); end
end

if strcmp(type, 'step')
% Step functions
    step_test = toy_data > .5;
    toy_data(2:3,:) = step_test(2:3,:);
end

if strcmp(type, 'gaussian')
% Gaussian functions
    m = rand(rois,1) + time/2 .* ones(rois,1);
    x = meshgrid((1:time),(1:rois));
    toy_data = zeros(size(x));
    for i = 1:rois
        toy_data(i,:) = normpdf(x(i,:), m(i), 1);
    end
    toy_data = toy_data + noise_magnitude * randn(size(x));
    % ss shows the permutation that we should get from the analysis
    [~,ss] = sort(m); %ss = keep_one_first(ss); 
    if display_; display(ss,'perm'); end
end

if strcmp(type, 'data')
% alter one line of data from an actual roi
    roi_line;
    p = fit(time/numel(data_line1) .* (1:numel(data_line1)).', ...
        reshape(smooth(data_line1), [], 1), 'cubicspline');
    m = 2.*rand(rois, 1);
    x = meshgrid((1:time), (1:rois)) + meshgrid(m, (1:time)).';
    lines = reshape(p(x), size(x));
    lines = power(lines, meshgrid(rand(rois,1) + ones(rois,1), (1:time)).');
    toy_data = lines + noise_magnitude * randn(size(lines));
    [~, ss] = sort(m, 'descend'); % ss = keep_one_first(ss); 
    if display_; display(ss); end
    
end

