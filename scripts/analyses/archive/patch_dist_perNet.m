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
	Kind=Kind_w{K};
	%% For each Network N (can adapt to make patch-wise metrics for column 5 instead of 4 if needed)
		for N=1:K;
			% get index of this network (4th column is network membership)
			netIndexL=find(surfNlabsL(:,4,(K-1))==N);
			netIndexR=find(surfNlabsR(:,4,(K-1))==N);
			
			% index out the same-network vertices from eucl and geodist matrices
			N_EucDistmat_L=eucl_l(netIndexL,netIndexL);
                        N_EucDistmat_R=eucl_r(netIndexR,netIndexR);
			N_GeoDistmat_L=lhGeoDmat(netIndexL,netIndexL);
			N_GeoDistmat_R=rhGeoDmat(netIndexR,netIndexR);

			% average non-diagonals (non 0's)
                        N_avg_edist_L=mean(mean(N_EucDistmat_L(N_EucDistmat_L~=0)));
                        N_avg_edist_R=mean(mean(N_EucDistmat_R(N_EucDistmat_R~=0)));
			N_avg_gdist_L=mean(mean(N_GeoDistmat_L(N_GeoDistmat_L~=0)));
			N_avg_gdist_R=mean(mean(N_GeoDistmat_R(N_GeoDistmat_R~=0)));	
	
			% current index in the broader scale-specific index list
			curindex=Kind(N);
			K
			N
			nwise_geods(curindex)=nansum([N_avg_gdist_L N_avg_gdist_R])
			nwise_eucs(curindex)=nansum([N_avg_edist_L N_avg_edist_R])
		end
end


table_geods=table(nwise_geods);
table_eucs=table(nwise_eucs);
writetable(table_geods,'/cbica/projects/pinesParcels/results/aggregated_data/NetworkGeoDistr.csv');
writetable(table_eucs,'/cbica/projects/pinesParcels/results/aggregated_data/NetworkEucDistr.csv');


