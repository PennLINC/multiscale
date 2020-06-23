% add needed paths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
% Read in subjects list
subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');
% initialize subject ID and correlation cols
spatcordf=zeros(length(subjs),2);
% for each subject, read in pg1 and dmn(k3) and run spatial correlation
for s=1:length(subjs)
	subject=subjs(s)	
	k3_Folder = ['/cbica/projects/pinesParcels/data/SingleParcellation/SingleParcel_1by1_kequal_3/Sub_' num2str(subjs(s))];
	k3_file= [k3_Folder '/IndividualParcel_Final_sbj1_comp3_alphaS21_1_alphaL10_vxInfo1_ard0_eta0/final_UV.mat'];
	subj_part=load(k3_file);
	subj_V=subj_part.V{1};
	% second column should be DMN (this script should confirm)
	dmn=subj_V(:,2);
	% now get dat pg1
	pgfp=['/cbica/projects/pinesParcels/data/CombinedData/' num2str(subjs(s)) '/vertexwise_emb.npy'];
	pg1f=readNPY(pgfp);
	pg1=pg1f(:,1);
	spatcordf(s,1)=subjs(s);
	[spatcor, ~] =corrcoef(dmn,pg1);
	% why does matlab insist on giving me a correlation matrix for two variables?
	spatcordf(s,2)=abs(spatcor(2));
end

