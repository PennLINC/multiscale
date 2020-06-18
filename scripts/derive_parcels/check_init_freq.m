% Set K to check
Krange=2:30;

%%% the rest
projectFolder = '/cbica/projects/pinesParcels/data/SingleParcellation';  
for K=Krange
initName = [projectFolder '/RobustInitialization_' num2str(K) '/init.mat']; 
ResultantFolder = [projectFolder '/SingleParcel_1by1_kequal_' num2str(K)];
gro=load(initName);
gro_initv=gro.initV;
% load in subjects
subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');
% make V x K x N matrix (unfortunately)
% V = Vertices
% K = scale
% N = subjs +1 for group
VxK=size(gro_initv);
bigmat=zeros(VxK(1),VxK(2),(length(subjs)+1));
bigmat(:,:,1)=gro_initv;
for s=1:length(subjs)
	ResultantFolder_I = [ResultantFolder '/Sub_' num2str(subjs(s))];
	subjinitmat_fp=[ResultantFolder_I '/IndividualParcel_Final_sbj1_comp' num2str(K) '_alphaS21_1_alphaL10_vxInfo1_ard0_eta0/init_UV.mat'];
	subj_initmat=load(subjinitmat_fp);
	bigmat(:,:,1+s)=subj_initmat.V{:};
end
K
unique(bigmat(1,:,:))
length(unique(bigmat(1,:,:)))
unique(bigmat(1000,:,:))
length(unique(bigmat(1000,:,:)))
end
