% subject = '100307';

files = dir('*.nii.gz');

for file = files'
	subject = file.name(1:6);
    fprintf('Subject: %s\n',subject);
	if exist(['subject_',subject,'.mat'],'file')
%	if str2num(subject) < 177747
%		fileID = fopen('converted_subjects.txt','a');
%		fprintf(fileID,'%s\n',subject);
%		fclose(fileID);
		continue
	end
	try
		nii = load_nii([subject,'.nii.gz']);
		dims = nii.hdr.dime.dim(2:5);
		img = nii.img;
		[x,y,z] = ndgrid(1:dims(1),1:dims(2),1:dims(3));
		S = [nii.hdr.hist.srow_x;nii.hdr.hist.srow_y;nii.hdr.hist.srow_z];
		xyz = [x(:) y(:) z(:)];
		xyz = (S(:,1:3)*xyz' + repmat(S(:,4),1,length(xyz)))';
		out_mtx = [xyz reshape(img, prod(dims(1:3)),dims(4))];
		save(['subject_',subject],'out_mtx','-v7.3');
		fileID = fopen('converted_subjects.txt','a');
		fprintf(fileID, '%s\n',subject);
		fclose(fileID);
		clear
	catch ME
		warning(['Subject ', subject, ' could not be converted.']);
		fileID = fopen('error_subjects.txt','a');
		fprintf(fileID, '%s\n',subject);
		fclose(fileID);
	end
end
