
% load big matrix that other script did the heavy lifting on
f=load('/cbica/projects/pinesParcels/data/aggregated_data/numPatches_AllSubjs_AllScales_bothHemis.mat');
f=f.BigPatchMat; 

% initialize desired shape of output csv ([subjs + 1 for colnames] [all networks at all scales + 1 for bblid column])
a=cell(694,465);

% for loop to throw everything in because matlab is weird
for i=1:693
	for j=1:464
		leftHemNum=f{j,i,1};
		rightHemNum=f{j,i,2};
		totPatch=leftHemNum+rightHemNum;
		% skip the first row and col (allocated for labeling as stated above)
		a{i+1,j+1}=totPatch;
		% if statement this to avoid redudancy
		% third column here containts colname
		if i==1
			a{1,j+1}=f{j,i,3};
		end
	end
end

%add BBLID exactly as they appeared in script calculating
subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');
% and get it to the dataframe
for s=1:length(subjs);
	a{s+1,1}=subjs(s);
end
a{1,1}='bblid';
at=cell2table(a);
writetable(at,'/cbica/projects/pinesParcels/results/aggregated_data/SubjPatchNums.csv');
