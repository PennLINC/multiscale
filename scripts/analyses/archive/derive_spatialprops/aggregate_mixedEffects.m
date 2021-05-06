%%% aggregate mixed effect coefficients from vertex-specific .csvs
% initialize empty vectors
s_Age=zeros(17734,1);
s_Scale=zeros(17734,1);
AgeXScale=zeros(17734,1);
Motion=zeros(17734,1);
Sex=zeros(17734,1);
% for each vertex
for i=1:17734
	% print vertex number
	disp(i)
	% load in csv
	fn=['/cbica/projects/pinesParcels/results/mixedEffectModels/Modeled_fSex_fMot_s4fxT_fAgexScale_raInt_v' num2str(i) '_bwVals_BoStr_overScales.csv'];
	df=readtable(fn);
	% AGE
	% are CI bounds on the same side of zero?
        % if so, proceed with copying the estimate to the vertex vectors
	% if no, zero out
	if (df.s_Age(2)*df.s_Age(3))>0;
		s_Age(i)=df.s_Age(1);
	else
		s_Age(i)=0;
	end
	% SCALE
	% are CI bounds on the same side of zero?
        % if so, proceed with copying the estimate to the vertex vectors
        % if no, zero out
        if (df.s_Scale(2)*df.s_Scale(3))>0;
                s_Scale(i)=df.s_Scale(1);
        else
                s_Scale(i)=0;
        end
	% AgexScale
        % are CI bounds on the same side of zero?
        % if so, proceed with copying the estimate to the vertex vectors
        % if no, zero out
        if (df.AgeXScale(2)*df.AgeXScale(3))>0;
                AgeXScale(i)=df.AgeXScale(1);
        else
                AgeXScale(i)=0;
	end
	% MOTION
        % are CI bounds on the same side of zero?
        % if so, proceed with copying the estimate to the vertex vectors
        % if no, zero out
        if (df.Motion(2)*df.Motion(3))>0;
                Motion(i)=df.Motion(1);
        else
                Motion(i)=0;
        end
	% SEX
        % are CI bounds on the same side of zero?
        % if so, proceed with copying the estimate to the vertex vectors
        % if no, zero out
        if (df.Sex(2)*df.Sex(3))>0;
                Sex(i)=df.Sex(1);
        else
                Sex(i)=0;
	end
end
% save out vectors
save('/cbica/projects/pinesParcels/results/aggregated_data/vertices_sAge','s_Age');
save('/cbica/projects/pinesParcels/results/aggregated_data/vertices_sScale','s_Scale');
save('/cbica/projects/pinesParcels/results/aggregated_data/vertices_AgeXScale','AgeXScale');
save('/cbica/projects/pinesParcels/results/aggregated_data/vertices_Motion','Motion');
save('/cbica/projects/pinesParcels/results/aggregated_data/vertices_Sex','Sex');
