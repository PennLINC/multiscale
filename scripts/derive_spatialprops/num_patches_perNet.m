%add needed paths
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));

% load surface (sphere for well-behaved neighbor distances)
surfL=read_surf('/cbica/software/external/freesurfer/centos7/6.0.0/subjects/fsaverage5/surf/lh.sphere');
surfR=read_surf('/cbica/software/external/freesurfer/centos7/6.0.0/subjects/fsaverage5/surf/rh.sphere');
% make an array of L and R xyz with an extra column to be populated with loadings, extra column for patch ID
% 20484 for fsaverage5
surfNLabels=zeros(20484,5);
surfNLabels(1:10242,1:3)=surfL;
surfNLabels(10243:20484,1:3)=surfR;

% load group partitions (labels) to start, can run this over individs to get a distribution of patches per subj
gro_partfp=['/cbica/projects/pinesParcels/data/SingleParcellation/SingleAtlas_Analysis/group_all_Ks.mat'];
gro_part=load(gro_partfp);

Krange=2:30;

% for each scale
for K=Krange;

	% corresponding group_partition (K-1 because array starts at 1, K starts at 2)
	gro_partK_affils=gro_part.affils(:,K-1);
	% get it into the x y z df
	surfNLabels(:,4)=gro_partK_affils;
	% split into L and R because XYZ coords only work w/r/t those in same hemisphere
	surfNlabsL=surfNLabels(1:10242,:);
	surfNlabsR=surfNLabels(10243:20484,:);	
	
	
	% vertices-to-test vectors
	% will help to proceed from established patch vertices outwards 
	% instead of initializing multiple times in the same patch
	testvec=zeros(1,length(surfNlabsL));
	testvec(1)=1;
	testedvec=[];
	totestvec=[];
	totestvec_adds=[];
	new_totestvec_adds=[];
		
	% initial patch label, to be updated as needed
	patchindex=1;	
	
	% for each vertex (using V index for left hemi)
	for V=1:length(testvec);

		vertIndL=testvec(V);
		% vertex props (x,y,z coords)
		initVertL=surfNlabsL(vertIndL,:);
		xVL=initVertL(1);
		yVL=initVertL(2);
		zVL=initVertL(3);

		% neighbor vector, to become index of neighbors (vast majority 0s as only touching vertices become neighbs)
		neighbvecL=zeros(1,length(surfNlabsL));
	
		% iteratively find neighbors in same patch via euclidean distance
		% search through all of them as it don't take long	
		for i=1:length(surfNlabsL);
			xL=surfNlabsL(i,1);
			yL=surfNlabsL(i,2);
			zL=surfNlabsL(i,3);
			eucld_L=sqrt((xL-xVL)^2+(yL-yVL)^2+(zL-zVL)^2);
			% spherical neighbors are less than 5 units away, > 0 thresholds out self as neigh
			if (eucld_L < 5)  && (eucld_L > 0);
			    neighbvecL(i)=1;
			else
			    neighbvecL(i)=0;
			end
						
		end	

		% assign vertices that are both neighbors and carry the same label the same patchID
                neighbindexL=find(neighbvecL==1);

		% should only apply on first V of each patch
		if initVertL(5)==0;
                        surfNlabsL(testvec(V),5)=patchindex;
			%disp('setting init patchval')
			%V
		end
		% make a vector of neighbors in same network to be added
		sameNneighbs=[];
		% left hemi - assign neighbors of same network the same patch ID
                for L=1:length(neighbindexL);
                        if surfNlabsL(neighbindexL(L),4)==surfNlabsL(vertIndL,4) && surfNlabsL(neighbindexL(L),5)==0
                                surfNlabsL(neighbindexL(L),5)=surfNlabsL(vertIndL,5);
                        	% add neighbors in same network to be tested next
				sameNneighbs=[sameNneighbs;neighbindexL(L)];
			end     
                end  	
		% throw this V into the "tested" vector now that it has run its course and had its day
		testedvec=[testedvec;vertIndL];
		% make next elements in testvec the neighbors that have not had their own neighbs evaluated yet
		totestvec_adds=setdiff(sameNneighbs,testedvec); 
		% but don't forget about vertibois who are in queue!
		new_totestvec_adds=setdiff(totestvec_adds,totestvec);
		totestvec=[totestvec;new_totestvec_adds];
		% & explicitly remove tested from to test
		totestvec=setdiff(totestvec,testedvec);
		
		% once we have indexed this patch exhaustively, totestvec should reach a length of 0
		% V < 10242 so it doesn't keep looking for untouched verts once it hits em all
                if length(totestvec)==0 && V < 10242
                        % intialize it on an untouched vertex for the next patch
                        untouchedverts=setdiff((1:10242),testedvec);
                        totestvec(1)=untouchedverts(1);
			% when this event happens, we want to update the patch index
			patchindex=patchindex+1;
                end


		testvec=[testedvec;totestvec];
		
	end
	
	% get number of patches per network
	for N=1:K
		Ndf=surfNlabsL(surfNlabsL(:,4)==N,:);
		['For Network ' num2str(N) ' at scale ' num2str(K) ',there are ' num2str(length(unique(Ndf(:,5)))) ' unique patches in the left hemisphere']
	end

	%%%%%%%%%%%%
	% slide to the right
	%%%%%%%%%%%%

	% note patch index is not reset- this way LH and RH will have unique patch IDs
	testvec=zeros(1,length(surfNlabsR));
        testvec(1)=1;
        testedvec=[];
        totestvec=[];
        totestvec_adds=[];
        new_totestvec_adds=[];


        % for each vertex (using V index for left hemi)
        for V=1:length(testvec);

                vertIndR=testvec(V);
                % vertex props (x,y,z coords)
                initVertR=surfNlabsR(vertIndR,:);
                xVR=initVertR(1);
                yVR=initVertR(2);
                zVR=initVertR(3);

                % neighbor vector, to become index of neighbors (vast majority 0s as only touching vertices become neighbs)
                neighbvecR=zeros(1,length(surfNlabsR));

                % iteratively find neighbors in same patch via euclidean distance
                % search through all of them as it don't take long
                for i=1:length(surfNlabsR);
                        xR=surfNlabsR(i,1);
                        yR=surfNlabsR(i,2);
                        zR=surfNlabsR(i,3);
                        eucld_R=sqrt((xR-xVR)^2+(yR-yVR)^2+(zR-zVR)^2);
                        % spherical neighbors are less than 5 units away, > 0 thresholds out self as neigh
                        if (eucld_R < 5)  && (eucld_R > 0);
                            neighbvecR(i)=1;
                        else
                            neighbvecR(i)=0;
                        end

                end

                % assign vertices that are both neighbors and carry the same label the same patchID
                neighbindexR=find(neighbvecR==1);

                % should only apply on first V of each patch
                if initVertR(5)==0;
                        surfNlabsR(testvec(V),5)=patchindex;
                        %disp('setting init patchval')
                        %V
                end
                % make a vector of neighbors in same network to be added
                sameNneighbs=[];
                % right hemi - assign neighbors of same network the same patch ID
                for R=1:length(neighbindexR);
                        if surfNlabsR(neighbindexR(R),4)==surfNlabsR(vertIndR,4) && surfNlabsR(neighbindexR(R),5)==0
                                surfNlabsR(neighbindexR(R),5)=surfNlabsR(vertIndR,5);
                                % add neighbors in same network to be tested next
                                sameNneighbs=[sameNneighbs;neighbindexR(R)];
                        end
                end
                % throw this V into the "tested" vector now that it has run its course and had its day
                testedvec=[testedvec;vertIndR];
                % make next elements in testvec the neighbors that have not had their own neighbs evaluated yet
                totestvec_adds=setdiff(sameNneighbs,testedvec);
                % but don't forget about vertibois who are in queue!
                new_totestvec_adds=setdiff(totestvec_adds,totestvec);
                totestvec=[totestvec;new_totestvec_adds];
                % & explicitly remove tested from to test
                totestvec=setdiff(totestvec,testedvec);

                % once we have indexed this patch exhaustively, totestvec should reach a length of 0
                % V < 10242 so it doesn't keep looking for untouched verts once it hits em all
                if length(totestvec)==0 && V < 10242
                        % intialize it on an untouched vertex for the next patch
                        untouchedverts=setdiff((1:10242),testedvec);
                        totestvec(1)=untouchedverts(1);
                        % when this event happens, we want to update the patch index
                        patchindex=patchindex+1;
                end


                testvec=[testedvec;totestvec];

        end

        % get number of patches per network
        for N=1:K
                Ndf=surfNlabsR(surfNlabsR(:,4)==N,:);
                ['For Network ' num2str(N) ' at scale ' num2str(K) ',there are ' num2str(length(unique(Ndf(:,5)))) ' unique patches in the right hemisphere']
        end

end
