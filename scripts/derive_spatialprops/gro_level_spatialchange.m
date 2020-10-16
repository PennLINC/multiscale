function change_over_surface(K)
% summarize K-dimensional change in component loadings across fsurface
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% addpaths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));

% set paths
Folder = '/cbica/projects/pinesParcels/data/SingleParcellation';
GroupAtlasLoading_Mat = load([Folder '/RobustInitialization_' num2str(K) '/init.mat']);

% load atlas K
loadings=GroupAtlasLoading_Mat.initV;

% convert loadings to unmasked and hemispherectomied versions
surfML = '/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label';
mwIndVec_l = read_medial_wall_label(surfML);
Index_l = setdiff([1:10242], mwIndVec_l);
surfMR = '/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label';
mwIndVec_r = read_medial_wall_label(surfMR);
Index_r = setdiff([1:10242], mwIndVec_r);
loadings_lh = zeros(K, 10242);
loadings_lh(1:K,Index_l) = loadings(1:length(Index_l),1:K)';
loadings_rh = zeros(K, 10242);
loadings_rh(1:K,Index_r)=loadings((length(Index_l) + 1:end),1:K)';

% load surface
surfL=read_surf('/cbica/software/external/freesurfer/centos7/6.0.0/subjects/fsaverage5/surf/lh.sphere');
surfR=read_surf('/cbica/software/external/freesurfer/centos7/6.0.0/subjects/fsaverage5/surf/rh.sphere');


% tack on xyz coords as 3 more rows
loadings_lh(K+1,:)=surfL(:,1);
loadings_lh(K+2,:)=surfL(:,2);
loadings_lh(K+3,:)=surfL(:,3);

loadings_rh(K+1,:)=surfR(:,1);
loadings_rh(K+2,:)=surfR(:,2);
loadings_rh(K+3,:)=surfR(:,3);


% convert surf and labels to table for merging
%surfLt=table(surfL(:,1),surfL(:,2),surfL(:,3));
%LoadLt=table(loadings_lh);
%LoadRt=table(loadings_rh);

% merge
%both_L=join(LoadLt,surfLt);
%both_R=join(LoadRt,surfRt);

% back to array for ease later
%both=table2array(both);

% for both hemis
hemilist=["L", "R"];
for h=1:2;
	
	% lateralize selection
	if (h==1)
		% Say it loud, say it proud
		hemilist(h)
		%%% Both is legacy name %%% for xyz merged w/ loadings. was also transposed in old code	
		both=loadings_lh';
	elseif (h==2)
		hemilist(h)
		both=loadings_rh';
	end

	% create change summary vec
	VertexChange=zeros(1, length(both));
	% create exclusion vector for vertices on borders of mask or medial wall
	VertexExclude=zeros(1, length(both));
	% for each vertex
	for V=1:length(both);
	%%%%%%%%%% Neighbor-hunting chunk %%%%%%%%%%%%%%
		% initialize
		initVert=both(V,:);
		% check that length lines up
		sizesurfL=size(surfL);
		if length(initVert)~=(sizesurfL(2))+K;
			disp('You fucked up big time, chief')
		end
		% will need xyz coords for distance eval
		xi=initVert(K+1);
		yi=initVert(K+2);
		zi=initVert(K+3);
		% to be booleaned
		neighbvec=zeros(1,length(both));
		% to be the bearer of change scores, juxtaposeable to boolean vec
		changeVtoN=zeros(1,length(both));
		% to be used for comparing loadings
		loadingsvec=initVert(1:K);
	
		% iteratively find neighbors in same patch via euclidean distance
		for N=1:length(both)
			x=both(N,K+1);
			y=both(N,K+2);
			z=both(N,K+3);
			% distance based off of initial xyz and possible neighb xyz
			eucld=sqrt((x-xi)^2+(y-yi)^2+(z-zi)^2);
			% this was apparently the distance range for which this is feasible in sphere
			if (eucld < 5)  && (eucld > 0);
    				% extract loadings
				neighbLoads=both(N,1:K);
				% flag 0-loading neighbors like the medial wall for elimination (inflates spatial change)
				if (sum(neighbLoads)==0);
					neighbvec(N)=999;
				else
					neighbvec(N)=1;	
				end
				% subtract a 1 x K array of all loadings for V from the same for N
				difvec=loadingsvec-neighbLoads;
				% square all for sensitivity to big changes (esp. for averaging over high Ks)
				sqvec=difvec.^2;
				% average square change across component loadings for this vertices N neighbor
				avgsqch=mean(sqvec);
				changeVtoN(N)=avgsqch;
			else
    				neighbvec(N)=0;
			end
		end
		% pull out vertices with 0-loading neighbs (mask boders, MW borders)
		if (sum(neighbvec) > 100)
			VertexExclude(V)=1;
		else
			neighbindex=find(neighbvec==1);
			localChangeScores=changeVtoN(neighbindex);
			VertexChange(V)=mean(localChangeScores);
		end
	end
	fn=strcat('/cbica/projects/pinesParcels/results/aggregated_data/changeVec_',num2str(K),'_',hemilist(h),'.mat');
	save(fn,'VertexChange');
	ExcluFn=strcat('/cbica/projects/pinesParcels/results/aggregated_data/Border_excludeVec_',num2str(K),'_',hemilist(h),'.mat');
	save(ExcluFn,'VertexExclude');
end

