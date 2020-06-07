% Correspondence to Yeo 17 systems

% set K Range
Krange=2:30;

addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));

SingleParcellation_Folder = '/cbica/projects/pinesParcels/data/SingleParcellation';
YeoAtlasFolder = '/cbica/projects/pinesParcels/data/YeoAtlas';
% Yeo 17 systems
[~, Label_lh, ~] = read_annotation([YeoAtlasFolder '/lh.Yeo2011_17Networks_N1000.annot']);
[~, Label_rh, names_rh] = read_annotation([YeoAtlasFolder '/rh.Yeo2011_17Networks_N1000.annot']);
Yeo_17system_Label = [Label_lh; Label_rh]';
NetworkID = names_rh.table(2:end, 5);
% Yeo 7 Systems
[~, Label_lh7, ~] = read_annotation([YeoAtlasFolder '/lh.Yeo2011_7Networks_N1000.annot']);
[~, Label_rh7, names_rh7] = read_annotation([YeoAtlasFolder '/rh.Yeo2011_7Networks_N1000.annot']);
Yeo_7system_Label= [Label_lh7; Label_rh7]';  
NetworkID7 = names_rh7.table(2:end,5);

NetworkName = {'Visual', 'Visual', 'Motor', 'Motor', 'DA', 'DA', 'VA', 'VA', ...
               'Limbic', 'Limbic', 'FP', 'FP', 'FP', 'DM', 'DM', 'DM', 'DM'};
NetworkNameGranular ={'Visual A', 'Visual B', 'Somatomotor A', 'Somatomotor B', 'DA_A', 'DA_B', 'VA_A', 'VA_B', ...
               'Limbic A', 'Limbic B', 'Control C', 'Control A', 'Control B', 'Temporal Parietal', 'DM_C', 'DM_A', 'DM_B'};
NetworkName7 = {'Visual','Motor','DA','VA','Limbic','FP','DM'};


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
%%% GET BOOLEAN TRANSMODAL VS UNIMODAL VAL FOR ROW 5 IN NEXT ITER
df_corres=cell(4,length(correspondence_over_scales));
%%%%%%%%%%%%%%%%%

for K=Krange

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	K
	% set labels in strings vector
	Kind=Kind_corres{K};
	for N=1:K
		curindex=Kind(N);
		corres_strings(curindex)=strcat('Corres_y7_scores_scale_', num2str(K), '_net', num2str(N));
	end

	% its like boom
	df_corres(2,Kind)=deal(num2cell(K));	
	% put it in the hoop like slam
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

	Correspondence_Parcels_Yeo17Systems = zeros(1, 17);
	Correspondence_Parcels_Yeo7Systems = zeros(1, 7);
	% For all unique labels at this scale % equivalent to N earlier
	for i = 1:length(Unique_LabelID)
    		Index = find(Parcellation_Label == Unique_LabelID(i));
    		% Yeo 17 systems
    		Label_Yeo_System17 = Yeo_17system_Label(Index);
    		Label_Yeo_System17_Unique = unique(Label_Yeo_System17);
    		for j = 1:length(Label_Yeo_System17_Unique)
        		number(j) = length(find(Label_Yeo_System17 == Label_Yeo_System17_Unique(j)));
    		end
    		[~, Max_Index] = max(number);
    		Correspondence_Parcels_Yeo17Systems(Unique_LabelID(i)) = Label_Yeo_System17_Unique(Max_Index);

		% Yeo 7 systems
                Label_Yeo_System7 = Yeo_7system_Label(Index);
                Label_Yeo_System7_Unique = unique(Label_Yeo_System7);
                for j = 1:length(Label_Yeo_System7_Unique)
                        number7(j) = length(find(Label_Yeo_System7 == Label_Yeo_System7_Unique(j)));
                end
                [~, Max_Index7] = max(number7);
                Correspondence_Parcels_Yeo7Systems(Unique_LabelID(i)) = Label_Yeo_System7_Unique(Max_Index7);

    		% display the network name
    		ind = find(NetworkID == Label_Yeo_System17_Unique(Max_Index));
		ind7 = find(NetworkID7 == Label_Yeo_System7_Unique(Max_Index7));
    		disp([num2str(i) ' Coarse maximum yeo alignment:  ' NetworkName{ind}]);
    		disp([num2str(i) ' Direct 7 yeo alignment:  ' NetworkName7{ind7}]);
    		
		% add the major network name to the cell df (use Kind, which starts from sum of all previously needed slots in the df row (for coarser scales))
		df_corres(3,Kind(i))=cellstr(num2str(NetworkName7{ind7}));

		% added to give proportion of yeo alignment with each derived network
    		% gets sum of proprotion for all involved vertices, divides by number of vertices (supposed to be the same as average)
		totverts=sum(number);
    		totverts7=sum(number7);
		prop=number/totverts;
		prop7=number7/totverts7;
		% maximum proportional representation
		df_corres(4,Kind(i))=num2cell((max(number7)/totverts7));
		% index location, turn into logical (binary boolean mask)
    		logicalind=ismember(NetworkID,Label_Yeo_System17_Unique);    
    		logicalind7=ismember(NetworkID7,Label_Yeo_System7_Unique);
		ind2=find(logicalind);
		ind2_7=find(logicalind7);
    		for x = 1:length(ind2)
			subnetind=ind2(x);
			% find where in the proportion vector this subnetwork is represented
			IDind=find(Label_Yeo_System17_Unique==NetworkID(subnetind));
			% only display if poprotion is above 10% for clarity purposes
			if prop(IDind) > 0.1
				disp(['      '  num2str(NetworkNameGranular{subnetind}) ' proportion of total verts ' num2str(prop(IDind))]);
        		else
			end
		end
		% repeat the same shit with 7-net calculations
                for x = 1:length(ind2_7)
                        subnetind=ind2_7(x);
                        % find where in the proportion vector this subnetwork is represented
                        IDind=find(Label_Yeo_System7_Unique==NetworkID7(subnetind));
                        % only display if poprotion is above 10% for clarity purposes
                        if prop7(IDind) > 0.1
                                disp(['    7_NET_SOLU:'  num2str(NetworkName7{subnetind}) ' proportion of total verts ' num2str(prop7(IDind))]);
                        else
                        end
                end
		clear number;
		clear number7;
	end
end
writetable(cell2table(df_corres),'/cbica/projects/pinesParcels/results/aggregated_data/fc/network_yCorrespondence_overscales.csv');
