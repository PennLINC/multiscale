% derive gradient values for each network at each scale
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));

ProjectFolder = '/cbica/projects/pinesParcels/data/princ_gradients';

% get gradients
pgl = gifti([ProjectFolder '/Gradients.lh.fsaverage5.func.gii']);
pgr = gifti([ProjectFolder '/Gradients.rh.fsaverage5.func.gii']);

% extract unimodal-transmodal gradient
grad_lh = pgl.cdata(:,1);
grad_rh = pgr.cdata(:,1);

% get group atlases from here
atlasdir='/cbica/projects/pinesParcels/data/YeoAtlas/Schaef/';

% load in schaef annotations (from CBIG)
[v,schaef200L,ct2L]=read_annotation([atlasdir 'lh.Schaefer2018_200Parcels_7Networks_order.annot']);
[v,schaef400L,ct4L]=read_annotation([atlasdir 'lh.Schaefer2018_400Parcels_7Networks_order.annot']);
[v,schaef200R,ct2R]=read_annotation([atlasdir 'rh.Schaefer2018_200Parcels_7Networks_order.annot']);
[v,schaef400R,ct4R]=read_annotation([atlasdir 'rh.Schaefer2018_400Parcels_7Networks_order.annot']);

% initialize blank struct for names and PG vals
LH200=cell(length(ct2L.struct_names),2);
LH400=cell(length(ct4L.struct_names),2);
RH200=cell(length(ct2R.struct_names),2);
RH400=cell(length(ct4R.struct_names),2);

% initialize blank vertex list to map parcellated PG values onto
LH200V=zeros(10242,1);
LH400V=zeros(10242,1);
RH200V=zeros(10242,1);
RH400V=zeros(10242,1);

% get avg. PG1 val for each ROI in schaef 200 (Simult. hemis)
for N=1:length(unique(schaef200L))
	% fifth row is identifying number to get vertices in this ROI from
	ROIverts_l=find(schaef200L==(ct2L.table(N,5)));
	ROIverts_r=find(schaef200R==(ct2R.table(N,5)));
	% mean pg val in these vertices
	meanpg1val_l=mean(grad_lh(ROIverts_l));
	meanpg1val_r=mean(grad_rh(ROIverts_r));
	% Add PG vals to table
	LH200(N,1)=ct2L.struct_names(N)
	RH200(N,1)=ct2R.struct_names(N)
	LH200(N,2)=num2cell(meanpg1val_l)
	RH200(N,2)=num2cell(meanpg1val_r)
	% and vis verts
	LH200V(ROIverts_l)=meanpg1val_l;
	RH200V(ROIverts_r)=meanpg1val_r;
end	


% get avg. PG1 val for each ROI in schaef 400 (Simult. hemis)
for N=1:length(unique(schaef400L))
        % fifth row is identifying number to get vertices in this ROI from
        ROIverts_l=find(schaef400L==(ct4L.table(N,5)));
        ROIverts_r=find(schaef400R==(ct4R.table(N,5)));
        % mean pg val in these vertices
        meanpg1val_l=mean(grad_lh(ROIverts_l));
        meanpg1val_r=mean(grad_rh(ROIverts_r));
        % Add PG vals to table
        LH400(N,1)=ct4L.struct_names(N)
        RH400(N,1)=ct4R.struct_names(N)
        LH400(N,2)=num2cell(meanpg1val_l)
        RH400(N,2)=num2cell(meanpg1val_r)
	% and vis verts
        LH400V(ROIverts_l)=meanpg1val_l;
        RH400V(ROIverts_r)=meanpg1val_r;
end

writetable(cell2table(LH200),'/cbica/projects/pinesParcels/data/SchaefLH200_transmodality7.csv');
writetable(cell2table(RH200),'/cbica/projects/pinesParcels/data/SchaefRH200_transmodality7.csv');
writetable(cell2table(LH400),'/cbica/projects/pinesParcels/data/SchaefLH400_transmodality7.csv');
writetable(cell2table(RH400),'/cbica/projects/pinesParcels/data/SchaefRH400_transmodality7.csv');


%% write out vectors of schaef parcellated values
save('/gpfs/fs001/cbica/projects/pinesParcels/results/viz/Schaef200_TM_L.mat','LH200V');
save('/gpfs/fs001/cbica/projects/pinesParcels/results/viz/Schaef200_TM_R.mat','RH200V');
save('/gpfs/fs001/cbica/projects/pinesParcels/results/viz/Schaef400_TM_L.mat','LH400V');
save('/gpfs/fs001/cbica/projects/pinesParcels/results/viz/Schaef400_TM_R.mat','RH400V');
