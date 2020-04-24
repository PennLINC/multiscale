
% clear removed so K can penetrate
%clear

ProjectFolder = '/cbica/projects/pinesParcels/data/SingleParcellation';
mkdir(ProjectFolder);

SubjectsFolder = '/cbica/software/external/freesurfer/centos7/5.3.0/subjects/fsaverage5';
% for surface data
surfL = [SubjectsFolder '/surf/lh.pial'];
surfR = [SubjectsFolder '/surf/rh.pial'];

surfML = '/cbica/projects/pinesParcels/data/H_SNR_masks/lh.Mask_SNR.label';
surfMR = '/cbica/projects/pinesParcels/data/H_SNR_masks/rh.Mask_SNR.label';

[surfStru, surfMask] = getFsSurf(surfL, surfR, surfML, surfMR);

% uncomment to implement without SNR mask.
%surfMask.l=ones(length(surfMask.l),1);
%surfMask.r=ones(length(surfMask.r),1);

gNb = createPrepData('surface', surfStru, 1, surfMask);

% save gNb into file for later use
prepDataName = [ProjectFolder '/CreatePrepData.mat'];
save(prepDataName, 'gNb');
