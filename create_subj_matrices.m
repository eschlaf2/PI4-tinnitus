nii = load_nii('rfMRI_REST1_LR.nii.gz');
dims = nii.hdr.dime.dim(2:5);
pixdim = nii.hdr.dime.pixdim(2:5);
img = nii.img;
[x,y,z] = ndgrid(1:dims(1),1:dims(2),1:dims(3));
xyz = ([x(:) y(:) z(:)] - 1 - repmat(floor(dims(1:3)./2),length(x(:)),1))...
    .* repmat(pixdim(1:3),length(x(:)),1);
out_mtx = [x(:) y(:) z(:) reshape(img, prod(dims(1:3)),dims(4))];