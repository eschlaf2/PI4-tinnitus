function n = cyclic_distance_ben(p,q)  
p = reshape(p, 1, []); q = reshape(q, 1,[]);
N = length(p);  
distances = zeros(1,N);  
for ii = 1:N;  
    d = mod(circshift(p',ii)'-q,N);  
    d = min(d, N-d);  
    distances(ii) = sum(d);  
end;  
n = 0.5*min(distances); 
end