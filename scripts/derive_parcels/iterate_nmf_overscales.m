% add in all supporter functions
addpath(genpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Toolbox'));
addpath('/cbica/projects/pinesParcels/multiscale/scripts/derive_parcels/Step_2nd_SingleParcellation');
for K=15:30
%%for K=2
% %call in steps 1-4, filepath adapted versions
%Step_1st_CreatePrepData_AP
K
%Step_2nd_ParcellationInitialize_AP

% calc pS and pL for resFile_path localization
%pS=round((alpha*tNum*SubjectsQuantity)/K);

%%%% will need to make step 1-2 one script on it's own... 2 takes 6 hours + to proc.


%Step_3rd_SelRobustInit_AP
%K
Step_4th_IndividualParcel_AP
end

