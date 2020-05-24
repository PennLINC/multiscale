% Merge group consensus parcels into one .mat file for easier access
atlasdir='/cbica/projects/pinesParcels/data/SingleParcellation/SingleAtlas_Analysis'

% insert desired K range here
Krange=2:30

% empty matrix to house all affils
affils=zeros(20484,length(Krange));
for i=2:max(Krange);
	K_lab=load([atlasdir '/Group_AtlasLabel_' num2str(i) '.mat']);
	K_lab_l=K_lab.sbj_AtlasLabel_lh;
	K_lab_r=K_lab.sbj_AtlasLabel_rh;
	K_lab_both=[K_lab_l K_lab_r];
	% i-1 because K starts at 2 but life starts at 1
	affils(:,i-1)=K_lab_both;
end
fn=[atlasdir '/group_all_Ks.mat']
save(fn, 'affils');
