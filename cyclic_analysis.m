function [eig_phases, eig_perm, sorted_lead_matrix, eig_vals] = ...
    cyclic_analysis(data_file, norm_method)
% Performs cyclic analysis on data_file using normalization norm_method,
% one of 'z-score' or 'frobenius' (default 'z-score').

norm_methods = {'z-score', 'frobenius'};
switch nargin
    case 1
        norm_method = 'z-score';
    case 2
        validatestring(norm_method, norm_methods);
    otherwise
        error('Wrong number of arguments');
end

data = importdata(data_file);
data = integration_filter(data);

if strcmp(norm_method,'z-score')
    normed_data = z_score_norm(data);
else
    normed_data = frob_norm(data);
end

lead_matrix = create_lead(normed_data);
[eig_phases, eig_perm, sorted_lead_matrix, eig_vals] = ...
    sort_lead(lead_matrix);

end

function [y] = integration_filter(x)
    y = zeros(size(x));
    for i = 1:numel(x(:,1))
        y(i,:) = smooth(x(i,:));
    end
end

function [normed_Z] = frob_norm(Z)
% Normalize vector(s) Z so that the quadratic variation is equal to 1. See
% Frobenius norm

% time_dim = size(Z,2);
z_adjusted = match_ends(Z);
z_diff = (z_adjusted-circshift(z_adjusted,1,2));
normf = sqrt(diag(z_diff*z_diff'));
normed_Z = (z_adjusted'/(diag(normf)))';
normed_Z = mean_center(normed_Z);

end 

function [normed_Z] = z_score_norm(Z)
% Normalize vector(s) Z using Z-score-scaling - ?=0, ?=1.

    time_steps = size(Z,2);
    Z = match_ends(Z);
%     t = linspace(0,1,time_steps);
%     Z=Z-(Z(:,time_steps)-Z(:,1))*t;
    Z = mean_center(Z);
    normed_Z = repmat(var(Z, [], 2).^(-1/2), 1, time_steps) .* Z;
end

function matched_Z = match_ends(Z)
% Linearly adjusts a matrix (set of vectors) Z so that the end points match
% the starting points - Z(:,1) == Z(:,end)
n = size(Z,2);
matched_Z = Z - (Z(:,n) - Z(:,1)) * linspace(0,1,n);
end

function centered_Z = mean_center(Z)
% Shifts vector(s) Z so that mean == 0.
centered_Z = Z - repmat(mean(Z, 2), 1, size(Z, 2));
end

function [lead_matrix] = create_lead(normed_Z)

    [N, time_steps] = size(normed_Z);

    % Create matrix of areas a
    lead_matrix=zeros(N);
    for ii=1:N;
        lead_matrix(ii,ii)=0;
        for jj=ii+1:N;
          x=normed_Z(ii,:); y=normed_Z(jj,:);
          lead_matrix(ii,jj)= time_steps * ... % x * (diff([y(end), y])');
              (x * (diff([y(end),y])') - y * (diff([x(end),x])'));
          lead_matrix(jj,ii)=-lead_matrix(ii,jj);
        end;
    end;
end

function [eig_vect, permutation, sorted_lead_matrix, eig_vals]=sort_lead(a, varargin)
% The first input should be the matrix to be sorted, the second should be
% the title of an ROI to be used as a baseline.
% On July 2 I changed the output so that phases outputs an angle rather
% than the associated complex number and the lowest phase is always zero.
% On July 14 I changed the output so that a chosen ROI can be used as a
% baseline.


   	 [eig_vect,eig_vals]=eig(a);
     eig_vals = diag(eig_vals);
     sorted_ang = sort(mod(angle(eig_vect(:,1)),2*pi));
     [~, shift] = max(abs(diff([sorted_ang; sorted_ang(1) + 2*pi])));
     if shift == numel(eig_vect(:,1))
         shift = 1; 
     else
         shift = shift + 1;
     end
     shift = sorted_ang(shift);
%      shift = pi - median(mod(angle(u(:,1).'), 2*pi));
	 [phases,permutation]=sort(mod(mod(angle(eig_vect(:,1).'), 2*pi) - shift, 2*pi));
          
%      Phase adjust
switch nargin
    case 3
        ROIS = varargin{1};
        baseroi = varargin(2);
        try
            angle_adjust = phases(permutation == find(strcmp([ROIS(:,1)], baseroi)));
        catch ME
            warning('baseroi not found. Input ignored.')
            [phases, permutation, sorted_lead_matrix, eig_vals] = sort_lead(a);
            return
        end
    case 2
        error('Optional arg 1 should be the ROIS; optional arg 2 should be base roi')
    case 1
        angle_adjust = min(phases);
    otherwise
        error('Too many arguments')
end

%      phases = phases - ones(size(phases)) .* angle_adjust;
	 sorted_lead_matrix=a(permutation,permutation);
     eig_vect = eig_vect(:,1);
%      eig_vect = eig_vect(permutation,:);
end
