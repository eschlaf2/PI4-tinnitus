% # number of iterations
T=1000;

% # strength of the perturbations
eps=.1;

% # create random starting collection of N unit vectors
ang=sort(rand(1,N))*2*pi;
rb=exp(1i*ang); 
subplot(2,1,1)
plot(rb)

% # initialize the lead matrix
ar=imag(rb./conj(rb)); % = sin(2*ang)
subplot(2,1,2)
plot(ang, ar,'g')

% # r is the current collection of vectors. 
% We want ar to be close to a.
r=rb;

% # iterative search
figure()
for k=1:T;

% # pick random vector;
  n=randi(N);  
% # perturb it (rt - perturbed collection)
  rt=r;
  rt(n)=r(n)*exp(1i*eps*(randn(1)));

% # create the lead matrix at for rt;
  at=imag(rt./conj(rt));
  plot(real(r), imag(r),real(rt),imag(rt)); hold on
  plot(exp(1i*ang_mesh(:,1)),'r')

% # if it approximates a better, choose it.
  if sum(sum(meshgrid(ar-at,ones(N,1))'.*a))>0; ar=at; r=rt; end;
end;

% # sort the resulting collection of vectors by its argument
% # "is" is the order of vectors on the circle
arg_r = imag(log(r));
[~,is]=sort(arg_r);

% ars=ar(is,is);

% # "as" is the original lead matrix in this natural order 
as=a(is,:);

% # rs - the sorted collection
rs=r(is);

% # "in" is the cyclic permutation normalized so 
% that 1 is at 1st position
shift = find(is == 1);
in=circshift(is,[0,1-shift]);

% # pm is the corresponding normalized permutation.
pm=eye(N);
pm = pm(:,in);
disp(pm)
