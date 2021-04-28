%add needed paths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));

Krange=2:30;

% get surf, patch, and functional net info
mastersurf=load('/cbica/projects/pinesParcels/data/aggregated_data/surfNlabs.mat');
mastersurf=mastersurf.surfNLabels;
surfNlabsL=mastersurf(1:10242,:,:);
surfNlabsR=mastersurf(10243:20484,:,:);

% import connectome-workbench-generated geodesic distance matrices (calc on fsaverage5.surf.gii)
lhfile=ciftiopen('/cbica/projects/pinesParcels/data/lh_GeoDist.dconn.nii','/cbica/software/external/connectome_workbench/1.4.2/bin/wb_command');
rhfile=ciftiopen('/cbica/projects/pinesParcels/data/rh_GeoDist.dconn.nii','/cbica/software/external/connectome_workbench/1.4.2/bin/wb_command');

lhGeoDmat=lhfile.cdata;
rhGeoDmat=rhfile.cdata;


% get in euclid's children
eucl_l=load('/cbica/projects/pinesParcels/data/aggregated_data/euclidean_distance_left_fsaverage5.mat');
eucl_r=load('/cbica/projects/pinesParcels/data/aggregated_data/euclidean_distance_right_fsaverage5.mat');
eucl_l=eucl_l.bdsml;
eucl_r=eucl_r.bdsmr;


% Make a DF for euclidean distance and for geodesic, distance vectors set to length of N networks at K scales
nwise_eucs=zeros((length(Krange)*((min(Krange)+max(Krange))/2)),1);
nwise_geods=zeros((length(Krange)*((min(Krange)+max(Krange))/2)),1);

% Make my cell struct with scalewise sequential vector matching indices at each K
for K=Krange
	K_start=((K-1)*(K))/2;
	K_end=(((K-1)*(K))/2)+K-1;
	Kind_w{K}=K_start:K_end;
end

% For each scale K
for K=Krange;

	%%%%%%% for each b/w feature from r vec (off diagonal of FC matrix, one sided)
		
	% read in b/w colnames (of master R df) at this scale, corresponding distance to be added to column below
	colnamesnames=strcat('/cbica/projects/pinesParcels/results/aggregated_data/Scale',string(K),'_Ind_bwColnames.csv')  
	fid=fopen(colnamesnames);
	bwcolstruct = textscan(fid,'%s');
	fclose(fid)
	bwcolnames=bwcolstruct{:}

	% make cell array to stuff colnames and values in
	bwcolscell=cell(length(bwcolnames),2);
	bwcolscell(:,1)=bwcolnames;

	% initialize vector to hold average b/w net distances
	distances=cell(length(bwcolnames),1);


	% for B in bwcolnames
	for b=1:length(bwcolnames)
		% pull in column names from R, parse them into both networks involved with as much specificity in keyphrase as possible
		bwcolcell=bwcolnames(b);
		bwcolname=strsplit(string(bwcolcell),'_nets')
		bwnets=bwcolname(2);
		netsInvolved=strsplit(bwnets,'_and_');
		net1=str2num(netsInvolved(1));
		net2=str2num(netsInvolved(2));
		
		% get indices of these networks (4th column is network membership)
		net1IndexL=find(surfNlabsL(:,4,(K-1))==net1);
		net1IndexR=find(surfNlabsR(:,4,(K-1))==net1);
                net2IndexL=find(surfNlabsL(:,4,(K-1))==net2);
                net2IndexR=find(surfNlabsR(:,4,(K-1))==net2);

		% index out 2-network intersection in the 10242x10242 distance marices
		N_EucDistmat_L=eucl_l(net1IndexL,net2IndexL);
                N_EucDistmat_R=eucl_r(net1IndexR,net2IndexR);
		N_GeoDistmat_L=lhGeoDmat(net1IndexL,net1IndexL);
		N_GeoDistmat_R=rhGeoDmat(net2IndexR,net2IndexR);

		% get average distances of all vertex pairs
                N_avg_edist_L=mean(mean(N_EucDistmat_L));
                N_avg_edist_R=mean(mean(N_EucDistmat_R));
		N_avg_gdist_L=mean(mean(N_GeoDistmat_L));
		N_avg_gdist_R=mean(mean(N_GeoDistmat_R));	
	
		% JUST EUC FOR NOW
		% distances set to within hemi avg for L + R 
		distances(b)=num2cell(nansum([N_avg_edist_L N_avg_edist_R]));
		

		end
		bwcolscell(:,2)=distances

	writetable(table(bwcolscell),strcat('/cbica/projects/pinesParcels/results/aggregated_data/Scale',string(K),'_Ind_bwColnames_andDist.csv'))
end
