% set effects dir
efdir='/gpfs/fs001/cbica/projects/pinesParcels/results/mixedEffectModels/';
% initiate empty 17734 vectors
ageCoef=zeros(17734,1);
scaleCoef=zeros(17734,1);
ageScaleIntCoef=zeros(17734,1);
motionCoef=zeros(17734,1);
sexCoef=zeros(17734,1);

% loop over all vertices outside of SNR mask
for v=1:17734
	v=v
	% read csv
	vfn=[efdir,'Modeled_fSex_fMot_s4fxT_fAgexScale_raInt_v',string(v),'_bwVals_BoStr_overScales.csv'];
	vfnjoined=join(vfn,'');
	% if file exists (it should!)
	if isfile(vfnjoined)
		vtab=readtable(vfnjoined);
		% get Age coefficients, set to 0 if bootstrapped value span included 0
		AgeCoefs=vtab.(1);
		ScaleCoefs=vtab.(2);
		AgeScaleIntCoefs=vtab.(3);
		MotionCoefs=vtab.(4);
		SexCoefs=vtab.(5);
		% if upper estimate * lower estimate > 0, that means both have same sign, meaning 0 not included in span
		if (AgeCoefs(2)*AgeCoefs(3)) > 0
			ageCoef(v)=AgeCoefs(1);
		else
			ageCoef(v)=0;
		end
		% same for Age scale interaction
		if (AgeScaleIntCoefs(2)*AgeScaleIntCoefs(3)) > 0
			ageScaleIntCoef(v)=AgeScaleIntCoefs(1);
		else
			ageScaleIntCoef(v)=0;
		end
                % same for scale
                if (ScaleCoefs(2)*ScaleCoefs(3)) > 0
                        scaleCoef(v)=ScaleCoefs(1);
                else
                        scaleCoef(v)=0;
                end
                % same for motion
                if (MotionCoefs(2)*MotionCoefs(3)) > 0
                        motionCoef(v)=MotionCoefs(1);
                else
                        motionCoef(v)=0;
                end
                % same for sex
                if (SexCoefs(2)*SexCoefs(3)) > 0
                        sexCoef(v)=SexCoefs(1);
                else
                        sexCoef(v)=0;
                end
	% if file does not exist
	else
		disp('Missing vertex:')
		disp(v)
	end
% end the over vertices loop
end
% saved to original model parameters
save('/cbica/projects/pinesParcels/results/EffectVecs/ageCoef.mat','ageCoef');
save('/cbica/projects/pinesParcels/results/EffectVecs/scaleCoef.mat','scaleCoef');
save('/cbica/projects/pinesParcels/results/EffectVecs/ageScaleIntCoef.mat','ageScaleIntCoef');
save('/cbica/projects/pinesParcels/results/EffectVecs/motionCoef.mat','motionCoef');
save('/cbica/projects/pinesParcels/results/EffectVecs/sexCoef.mat','sexCoef');
