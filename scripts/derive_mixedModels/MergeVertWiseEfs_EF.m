% set effects dir
efdir='/gpfs/fs001/cbica/projects/pinesParcels/results/mixedEffectModels/';
% initiate empty 17734 vectors
ageCoef=zeros(17734,1);
logScaleCoef=zeros(17734,1);
ageScaleIntCoef=zeros(17734,1);
motionCoef=zeros(17734,1);
sexCoef=zeros(17734,1);
EFCoef=zeros(17734,1);
EFScaleIntCoef=zeros(17734,1);

% loop over all vertices outside of SNR mask
for v=1:17734
	v=v
	% read csv
	vfn=[efdir,'Modeled_fSex_fMot_s4fxT_fAgexScale_fEFxScale_raInt_v',string(v),'_bwVals_BoStr_overScales.csv'];
	vfnjoined=join(vfn,'');
	% if file exists (it should!)
	if isfile(vfnjoined)
		vtab=readtable(vfnjoined);
		% get EF coefficients, set to 0 if bootstrapped value span included 0
		EFCoefs=vtab.(3);
		EFScaleIntCoefs=vtab.(5);
		% if upper estimate * lower estimate > 0, that means both have same sign, meaning 0 not included in span
		if (EFCoefs(2)*EFCoefs(3)) > 0
			EFCoef(v)=EFCoefs(1);
		else
			EFCoef(v)=0;
		end
		% same for EF scale interaction
		if (EFScaleIntCoefs(2)*EFScaleIntCoefs(3)) > 0
			EFScaleIntCoef(v)=EFScaleIntCoefs(1);
		else
			EFScaleIntCoef(v)=0;
		end
	% if file does not exist
	else
		disp('Missing vertex:')
		disp(v)
	end
% end the over vertices loop
end

% saved to original model parameters
save('/cbica/projects/pinesParcels/results/EffectVecs/EFCoef.mat','EFCoef');
save('/cbica/projects/pinesParcels/results/EffectVecs/EFScaleIntCoef.mat','EFScaleIntCoef');
