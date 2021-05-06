%classic variables
Krange=2:30;
subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');
ProjectFolder = '/cbica/projects/pinesParcels/data/SingleParcellation';

for K=Krange
K
% for each scale, make a 17734 x 693 x K matrix for each vertex loading for each community for each subject
% dumping it all into one 4D matrix seems too ambitious, seperate file for each scale for now
	BigMat=zeros(17734,693,K);
	
	% fill with each subject
	for s=1:length(subjs);
		K_Folder = [ProjectFolder '/SingleParcel_1by1_kequal_' num2str(K) '/Sub_' num2str(subjs(s))];
		K_part_subj =[K_Folder '/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_1_alphaL10_vxInfo1_ard0_eta0/final_UV.mat'];
		subj_part=load(K_part_subj);
		subj_V=subj_part.V{1};
		BigMat(:,s,:)=subj_V;
	end

	% bigger files need that special matlab format to save (larger than 2GB)	
	BigMatFN=['/cbica/projects/pinesParcels/data/aggregated_data/Scale' num2str(K) '_Topographies.mat']
	save(BigMatFN,'BigMat','-v7.3');
end
