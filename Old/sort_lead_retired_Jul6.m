function [phases, permutation, sorted_lead_matrix, spectrum]=sort_lead(a)

	 [N,~]=size(a);
	 [u,spectrum]=eig(a);
     spectrum = diag(spectrum);
	 [~,permutation]=sort(angle(u(:,1).'));
% 	 permutation=circshift(permutation,[0,N+1-find(permutation==1)]);
% 				#pm=eye(N)(:,in);
	 
     p1=fliplr(permutation);
%      if sum(abs(p1-(1:N)))<sum(abs(permutation-(1:N)))
     if cyclic_distance_ben(p1,(1:N)) < cyclic_distance_ben(permutation,(1:N))
         permutation=p1;
     end
         
	 phases=u(permutation,1).';
	 sorted_lead_matrix=a(permutation,permutation);
end
