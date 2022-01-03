% calculate the distance of each network from primary cortices

addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
fsdir='/cbica/software/external/freesurfer/centos7/7.2.0/subjects/fsaverage5'

Krange=2:30;

% get surf, patch, and functional net info
[verticesL, labelL, colortableL] = read_annotation([fsdir '/label/lh.aparc.a2009s.annot']);
[verticesR, labelR, colortableR] = read_annotation([fsdir '/label/rh.aparc.a2009s.annot']);

% get ID # of calc and c sulc
lCalcID=colortableL.table(46,5);
lSulcID=colortableL.table(47,5);
rCalcID=colortableR.table(46,5);
rSulcID=colortableR.table(47,5);

l_ttID=colortableL.table(76,5);
r_ttID=colortableR.table(76,5);

% grab vertex indices of these ROIs
lCalcV=find(labelL==lCalcID);
lSulcV=find(labelL==lSulcID);
rCalcV=find(labelR==rCalcID);
rSulcV=find(labelR==rSulcID);

l_ttV=find(labelL==l_ttID);
r_ttV=find(labelR==r_ttID);

% load in network data
mastersurf=load('/cbica/projects/pinesParcels/data/aggregated_data/surfNlabs.mat');
mastersurf=mastersurf.surfNLabels;
surfNlabsL=mastersurf(1:10242,:,:);
surfNlabsR=mastersurf(10243:20484,:,:);


% get in euclid's children
eucl_l=load('/cbica/projects/pinesParcels/data/aggregated_data/euclidean_distance_left_fsaverage5.mat');
eucl_r=load('/cbica/projects/pinesParcels/data/aggregated_data/euclidean_distance_right_fsaverage5.mat');
eucl_l=eucl_l.bdsml;
eucl_r=eucl_r.bdsmr;

% create matrix of distance from S1
Sulc_Dist_L=eucl_l(lSulcV,:);
Sulc_Dist_R=eucl_r(rSulcV,:);
% create matrix of distance from V1
Calc_Dist_L=eucl_l(lCalcV,:);
Calc_Dist_R=eucl_r(rCalcV,:);

% Make a DF for euclidean distance vectors set to length of N networks at K scales
nwise_eucs=zeros((length(Krange)*((min(Krange)+max(Krange))/2)),2);

% Make my cell struct with scalewise sequential vector matching indices at each K
for K=Krange
	K_start=((K-1)*(K))/2;
	K_end=(((K-1)*(K))/2)+K-1;
	Kind_w{K}=K_start:K_end;
end

for K=Krange;
	Kind=Kind_w{K};
	%% For each Network N (can adapt to make patch-wise metrics for column 5 instead of 4 if needed)
		for N=1:K;
			% get index of this network (4th column is network membership)
			netIndexL=find(surfNlabsL(:,4,(K-1))==N);
			netIndexR=find(surfNlabsR(:,4,(K-1))==N);
			
			% index out the distance between this networks vertices and primary cortex vertices
			N_SulcDistmat_L=eucl_l(netIndexL,lSulcV);
                        N_CalcDistmat_L=eucl_l(netIndexL,lCalcV);
                        N_SulcDistmat_R=eucl_r(netIndexR,rSulcV);
                        N_CalcDistmat_R=eucl_r(netIndexR,rCalcV);
			
			N_ttDistmat_L=eucl_l(netIndexL,l_ttV);
			N_ttDistmat_R=eucl_r(netIndexR,r_ttV);
	
			% average distance
                        N_SulcDist_L=mean(mean(N_SulcDistmat_L));
			N_CalcDist_L=mean(mean(N_CalcDistmat_L));
			N_SulcDist_R=mean(mean(N_SulcDistmat_R));
			N_CalcDist_R=mean(mean(N_CalcDistmat_R));

			tt_dist_L=mean(mean(N_ttDistmat_L));
			tt_dist_R=mean(mean(N_ttDistmat_R));
	
			% current index in the broader scale-specific index list
			curindex=Kind(N);
			K
			N
			nwise_eucs(curindex,1)=nansum([N_SulcDist_L N_SulcDist_R]);
			nwise_eucs(curindex,2)=nansum([N_CalcDist_L N_CalcDist_R]);	
			nwise_eucs(curindex,3)=nansum([tt_dist_L tt_dist_R]);
		end
end

% save out
table_eucs=table(nwise_eucs);
writetable(table_eucs,'/cbica/projects/pinesParcels/results/aggregated_data/NetworkPrimariesDist.csv');
