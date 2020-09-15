% derive gradient values for each network at each scale
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));

ProjectFolder = '/cbica/projects/pinesParcels/data/princ_gradients';

% set K Range
Krange=2:30;

% get gradients
pgl = gifti([ProjectFolder '/Gradients.lh.fsaverage5.func.gii']);
pgr = gifti([ProjectFolder '/Gradients.rh.fsaverage5.func.gii']);

% extract occipital-origin gradient
grad_lh = pgl.cdata(:,2);
grad_rh = pgr.cdata(:,2);

% get group atlases from here
atlasdir='/cbica/projects/pinesParcels/data/SingleParcellation/SingleAtlas_Analysis';

% create a vector that spans all K's, length should be sum of all Ks (2+3+4...+30)
transmodality_over_scales=zeros((length(Krange)*((min(Krange)+max(Krange))/2)),1);

% Make and index of where each scale should go in transmodality vector (largely just to confirm everything is in its right place, in its right place, in its right place, right place)
Kind_trans={};

% make an index of which places in feature vec align with which scale
for K=Krange
	K_start=((K-1)*(K))/2;
	K_end=(((K-1)*(K))/2)+K-1;
	Kind_trans{K}=K_start:K_end;
end

% make strings vector for colnames
trans_strings=strings(length(transmodality_over_scales),1);

% make a cell dataframe (unfortunately) to keep colnames and values together
df_trans=cell(2,length(transmodality_over_scales));

% df solely for visualization (includes K and N for matching according to groupcons)
df_viz=zeros(464,3);

% iterate over scales
for K=Krange

	% get index relevant to this scale
	Kind=Kind_trans{K};
	
	% set labels in strings vector
	for N=1:K
		curindex=Kind(N);
		trans_strings(curindex)=strcat('Transmodal_scores_scale_', num2str(K), '_net', num2str(N));
	end
	
	% get to tha choppa	
	df_trans(1,Kind)=cellstr(trans_strings(Kind));

	% add K to viz df in second column
	df_viz(Kind,2)=K;

	% load in group consensus at this scale
	K_lab=load([atlasdir '/Group_AtlasLabel_' num2str(K) '.mat']);
	K_lab_l=K_lab.sbj_AtlasLabel_lh';
	K_lab_r=K_lab.sbj_AtlasLabel_rh';

	% get avg. PC1 val for each network
	for N=1:K
		curindex=Kind(N);
		groupconverts_l=find(K_lab_l==N);
		groupconverts_r=find(K_lab_r==N);
		% sum instead of mean so lateralized networks are weighted more
		sumpc1val_l=sum(grad_lh(groupconverts_l));
		sumpc1val_r=sum(grad_rh(groupconverts_r));
		% weighted average, if one hemi has more that is reflected	
		meanpc1val=(sumpc1val_l+sumpc1val_r)/(length(groupconverts_l)+length(groupconverts_r));
		df_trans(2,curindex)=num2cell(meanpc1val);
		% add in visualization df
		df_viz(curindex,3)=N;
		df_viz(curindex,1)=meanpc1val;
	end	
end
writetable(cell2table(df_trans),'/cbica/projects/pinesParcels/results/aggregated_data/fc/network_grad2_overscales.csv');
csvwrite('/cbica/projects/pinesParcels/results/aggregated_data/fc/network_grad2_overscales_forviz.csv',df_viz);
