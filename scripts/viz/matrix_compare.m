% flagged for WTF did I write this script for
function matrix_compare(fn,varagin)
	for i=1:nargin
		mattylight=varagin{i};
		images{i}=imagesc(round(matttylight,4));
	end
montimage=Montage(images);
imwrite(montimage,fn);
