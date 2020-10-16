% calculate gradient 1 change over fsaverage5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% addpaths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));

% set paths
ProjectFolder = '/cbica/projects/pinesParcels/data/princ_gradients';

% get gradients
pgl = gifti([ProjectFolder '/Gradients.lh.fsaverage5.func.gii']);
pgr = gifti([ProjectFolder '/Gradients.rh.fsaverage5.func.gii']);

% extract unimodal-transmodal gradient
grad_lh = pgl.cdata(:,1)';
grad_rh = pgr.cdata(:,1)';

%surfML = '/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label';
%mwIndVec_l = read_medial_wall_label(surfML);
%Index_l = setdiff([1:10242], mwIndVec_l);
%surfMR = '/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label';
%mwIndVec_r = read_medial_wall_label(surfMR);
%Index_r = setdiff([1:10242], mwIndVec_r);
%loadings_lh = zeros(K, 10242);
%loadings_lh(1:K,Index_l) = loadings(1:length(Index_l),1:K)';
%loadings_rh = zeros(K, 10242);
%loadings_rh(1:K,Index_r)=loadings((length(Index_l) + 1:end),1:K)';

% load surface
surfL=read_surf('/cbica/software/external/freesurfer/centos7/6.0.0/subjects/fsaverage5/surf/lh.sphere');
surfR=read_surf('/cbica/software/external/freesurfer/centos7/6.0.0/subjects/fsaverage5/surf/rh.sphere');


% tack on xyz coords as 3 more rows
grad_lh(2,:)=surfL(:,1);
grad_lh(3,:)=surfL(:,2);
grad_lh(4,:)=surfL(:,3);

grad_rh(2,:)=surfR(:,1);
grad_rh(3,:)=surfR(:,2);
grad_rh(4,:)=surfR(:,3);

% for both hemis
hemilist=["L", "R"];
for h=1:2;
	
	% lateralize selection
	if (h==1)
		% Say it loud, say it proud
		hemilist(h)
		%%% Both is legacy name %%% for xyz merged w/ loadings. was also transposed in old code	
		both=grad_lh';
	elseif (h==2)
		hemilist(h)
		both=grad_rh';
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
		if length(initVert)~=(sizesurfL(2))+1;
			disp('You fucked up big time, chief')
		end
		% will need xyz coords for distance eval
		xi=initVert(2);
		yi=initVert(3);
		zi=initVert(4);
		% to be booleaned
		neighbvec=zeros(1,length(both));
		% to be the bearer of change scores, juxtaposeable to boolean vec
		changeVtoN=zeros(1,length(both));
		% to be used for comparing grad. values
		Gradvec=initVert(1);
	
		% iteratively find neighbors in same patch via euclidean distance
		for N=1:length(both)
			x=both(N,2);
			y=both(N,3);
			z=both(N,4);
			% distance based off of initial xyz and possible neighb xyz
			eucld=sqrt((x-xi)^2+(y-yi)^2+(z-zi)^2);
			% this was apparently the distance range for which this is feasible in sphere
			if (eucld < 5)  && (eucld > 0);
    				% extract gradient values
				neighbGrads=both(N,1);
                                % flag 0-loading neighbors like the medial wall for elimination (inflates spatial change)
                                if (sum(neighbGrads)==0);
                                        neighbvec(N)=999;
                                else
                                        neighbvec(N)=1;
                                end
				neighbvec(N)=1;
				% subtract a 1 x K array of all loadings for V from the same for N
				difvec=Gradvec-neighbGrads;
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
	fn=strcat('/cbica/projects/pinesParcels/results/aggregated_data/changeVec_PG1_',hemilist(h),'.mat');
	save(fn,'VertexChange');
	ExcluFn=strcat('/cbica/projects/pinesParcels/results/aggregated_data/Border_excludeVec_PG1_',hemilist(h),'.mat');
        save(ExcluFn,'VertexExclude');
end

