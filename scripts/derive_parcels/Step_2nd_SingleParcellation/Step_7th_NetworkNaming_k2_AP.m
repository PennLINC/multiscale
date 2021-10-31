% Correspondence to coarsest partition

% set K Range (ignoring self-referential k=2)
Krange=3:30;

addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));

SingleParcellation_Folder = '/cbica/projects/pinesParcels/data/SingleParcellation';


YeoAtlasFolder = '/cbica/projects/pinesParcels/data/YeoAtlas';


%%% Load in K=2 partition as reference for other scales
Parcellation_Path_2 = [SingleParcellation_Folder '/SingleAtlas_Analysis/Group_AtlasLabel_2.mat'];
Parcellation_Mat_2 = load(Parcellation_Path_2);
% both hemispheres
Parcellation_Label_2 = [Parcellation_Mat_2.sbj_AtlasLabel_lh, Parcellation_Mat_2.sbj_AtlasLabel_rh];
% find all unique labels at this partition at this scale
Unique_LabelID_2 = unique(Parcellation_Label_2);
Unique_LabelID_2 = Unique_LabelID_2(2:end);
CoarseNetName={'Transmodal','Unimodal'};

%%% Make the big cell array for colnames, scale, majority net name, majority net prop %%%%%%%%
% create a vector that spans all K's, length should be sum of all Ks (2+3+4...+30)
correspondence_over_scales=zeros((length(Krange)*((min(Krange)+max(Krange))/2)),1);
% Make and index of where each scale should go in transmodality vector (largely just to confirm everything is in its right place, in its right place, in its right place, right place)
Kind_corres={};
% make an index of which places in feature vec align with which scale
for K=Krange
	K_start=((K-1)*(K))/2;
	K_end=(((K-1)*(K))/2)+K-1;
	Kind_corres{K}=K_start:K_end;
end
% make strings vector for colnames
corres_strings=strings(length(correspondence_over_scales),1);
% make a cell dataframe (unfortunately) to keep colnames and values together (rows for colnames, scales, maj net name, and maj net prop)
%%% transmodality binning to be done in R to reduce matlab usage
df_corres=cell(4,length(correspondence_over_scales));
%%%%%%%%%%%%%%%%%
for K=Krange
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	K
	% set labels in strings vector
	Kind=Kind_corres{K};
	for N=1:K
		curindex=Kind(N);
		corres_strings(curindex)=strcat('Corres_k2_scores_scale_', num2str(K), '_net', num2str(N));
	end

	% its like boom
	df_corres(2,Kind)=deal(num2cell(K));	
	% put it in the df like slam
	df_corres(1,Kind)=cellstr(corres_strings(Kind));
	K
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% get in parcellation for this scale (meaning start the K-loop above here)
	Parcellation_Path = [SingleParcellation_Folder '/SingleAtlas_Analysis/Group_AtlasLabel_' num2str(K) '.mat'];
	Parcellation_Mat = load(Parcellation_Path);
	% both hemispheres
	Parcellation_Label = [Parcellation_Mat.sbj_AtlasLabel_lh, Parcellation_Mat.sbj_AtlasLabel_rh];
	% find all unique labels at this partition at this scale
	Unique_LabelID = unique(Parcellation_Label);
	Unique_LabelID = Unique_LabelID(2:end);
	% Correspondence among 2 parcels instead, as k=2 is reference
	Correspondence_Parcels_k2Systems = zeros(1, 2);
	% For all unique labels at this scale % equivalent to N earlier
	for i = 1:length(Unique_LabelID)
    		Index = find(Parcellation_Label == Unique_LabelID(i));
		% Extract corresponding k=2 labels for this network
		k2labs=Parcellation_Label_2(Index);
		% Extract all unique k=2 labels overlapping with this network (max of 2)
		k2labs_unique=unique(k2labs); 
		%%%%%%% Index K=2 partition instead of yeo reference
                for j = 1:length(k2labs_unique)
                        numberk2(j) = length(find(k2labs == k2labs_unique(j)));
                end
		% get index of which reference network has the most vertices within network i
                [~, Max_Index] = max(numberk2);
		% record which reference network has most vertices w/in network i in Correspondence_Parcels
                Correspondence_Parcels_k2Systems(Unique_LabelID(i)) = k2labs_unique(Max_Index);
    		% display the network name
		ind = find(Unique_LabelID_2 == k2labs_unique(Max_Index));
    		disp([num2str(i) ' Coarse Category for this network:  ' CoarseNetName{ind}]);
		% add the major network name to the cell df (use Kind, which starts from sum of all previously needed slots in the df row (for coarser scales))
		df_corres(3,Kind(i))=cellstr(num2str(CoarseNetName{ind}));
		% added to give proportion of yeo alignment with each derived network
    		% gets sum of proprotion for all involved vertices, divides by number of vertices (supposed to be the same as average)
    		totverts=sum(numberk2);
		prop=numberk2/totverts
		% maximum proportional representation
		df_corres(4,Kind(i))=num2cell((max(numberk2)/totverts));
		clear numberk2;
	end
end
writetable(cell2table(df_corres),'/cbica/projects/pinesParcels/results/aggregated_data/fc/network_k2Correspondence_overscales.csv');
