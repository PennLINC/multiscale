% Correspondence to Yeo 17 systems
% run at which scale?
K=16

SingleParcellation_Folder = '/cbica/projects/pinesParcels/multisca/SingleParcellation';
Parcellation_17_Path = [SingleParcellation_Folder '/SingleAtlas_Analysis/Group_AtlasLabel_' num2str(K) '.mat'];
Parcellation_17_Mat = load(Parcellation_17_Path);
Parcellation_17_Label = [Parcellation_17_Mat.sbj_AtlasLabel_lh, Parcellation_17_Mat.sbj_AtlasLabel_rh];
Unique_LabelID = unique(Parcellation_17_Label);
Unique_LabelID = Unique_LabelID(2:end);
YeoAtlasFolder = '/data/jux/BBL/projects/pncSingleFuncParcel/Replication/data/YeoAtlas';
% Yeo 17 systems
[~, Label_lh, ~] = read_annotation([YeoAtlasFolder '/Yeo_17system/lh.Yeo2011_17Networks_N1000.annot']);
[~, Label_rh, names_rh] = read_annotation([YeoAtlasFolder '/Yeo_17system/rh.Yeo2011_17Networks_N1000.annot']);
Yeo_17system_Label = [Label_lh; Label_rh]';

NetworkID = names_rh.table(2:end, 5);
NetworkName = {'Visual', 'Visual', 'Motor', 'Motor', 'DA', 'DA', 'VA', 'VA', ...
               'Limbic', 'Limbic', 'FP', 'FP', 'FP', 'DM', 'DM', 'DM', 'DM'};
NetworkNameGranular ={'Visual A', 'Visual B', 'Somatomotor A', 'Somatomotor B', 'DA_A', 'DA_B', 'VA_A', 'VA_B', ...
               'Limbic A', 'Limbic B', 'Control C', 'Control A', 'Control B', 'Temporal Parietal', 'DM_C', 'DM_A', 'DM_B'};

Correspondence_17Parcels_Yeo17Systems = zeros(1, 17);
for i = 1:length(Unique_LabelID)
    Index = find(Parcellation_17_Label == Unique_LabelID(i));
    % Yeo 17 systems
    Label_Yeo_System17 = Yeo_17system_Label(Index);
    Label_Yeo_System17_Unique = unique(Label_Yeo_System17);
    for j = 1:length(Label_Yeo_System17_Unique)
        number(j) = length(find(Label_Yeo_System17 == Label_Yeo_System17_Unique(j)));
    end
    [~, Max_Index] = max(number);
    Correspondence_17Parcels_Yeo17Systems(Unique_LabelID(i)) = Label_Yeo_System17_Unique(Max_Index);

    % display the network name
    ind = find(NetworkID == Label_Yeo_System17_Unique(Max_Index));
    disp([num2str(i) ' Coarse maximum yeo alignment:  ' num2str(NetworkName{ind})]);
    
    % added to give proportion of yeo alignment with each derived network
    totverts=sum(number);
    prop=number/totverts;
    logicalind=ismember(NetworkID,Label_Yeo_System17_Unique);    
    ind2=find(logicalind);
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

    clear number;
end
