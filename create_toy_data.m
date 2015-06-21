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
    [~,ss] = sort(ang, 'descend'); ss = keep_one_first(ss); 
    if display_; display(ss); end
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
    toy_data=exp(-(time_mesh-5*ang_mesh).^2) + noise_magnitude*randn(rois,time);
    % ss shows the permutation that we should get from the analysis
    [~,ss] = sort(ang); ss = keep_one_first(ss); 
    if display_; display(ss); end
end

if strcmp(type, 'data')
% alter one line of data from an actual roi
    roi_line;
    lines = meshgrid(data_line, (1:rois));
    horiz_shift = [zeros(rois,1),randi(length(data_line), rois, 1)];
    [~, vert_shift] = meshgrid((1:length(data_line)), 50 .* randi(6,1,rois));
    stretch = meshgrid(3 * rand(rois, 1) + .5,(1:length(data_line))).';
    lines = stretch .* lines - vert_shift;
    for i = 1:rois
        lines(i,:) = circshift(lines(i,:),horiz_shift(i,:));
    end
    toy_data = lines + noise_magnitude * randn(size(lines));
    [~, ss] = sort(horiz_shift(:,2)); ss = keep_one_first(ss); 
    if display_; display(ss); end
    
    
end

