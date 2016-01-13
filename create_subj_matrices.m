% subject = '100307';

nii = load_nii([subject,'.nii.gz']);
dims = nii.hdr.dime.dim(2:5);
img = nii.img;
[x,y,z] = ndgrid(1:dims(1),1:dims(2),1:dims(3));
S = [nii.hdr.hist.srow_x;nii.hdr.hist.srow_y;nii.hdr.hist.srow_z];
xyz = [x(:) y(:) z(:)];
xyz = (S(:,1:3)*xyz' + repmat(S(:,4),1,length(xyz)))';
out_mtx = [xyz reshape(img, prod(dims(1:3)),dims(4))];
save(subject,'out_mtx','-v7.3');
clear