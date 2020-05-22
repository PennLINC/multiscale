singparc_dir=['/cbica/projects/pinesParcels/data/SingleParcellation/'];
bblids=load('/cbica/projects/pinesParcels/data/bblids.txt');
Krange=2:30;
% +1 for subj ID column
iter_errormat=zeros(length(bblids),length(Krange)+1);
iter_nmat=zeros(length(bblids),length(Krange)+1);
recon_errormat=zeros(length(bblids),length(Krange)+1);
for K=2:max(Krange);
	% for all subjects at this K, get NMF fit error
	K
	for s=1:length(bblids);
		iter_errormat(s,1)=bblids(s);
		iter_nmat(s,1)=bblids(s);
		recon_errormat(s,1)=bblids(s);
		%for K=2:max(Krange);
		iterlogfp=strcat(singparc_dir, 'SingleParcel_1by1_kequal_', num2str(K), '/Sub_', num2str(bblids(s)), '/Iteration_error.mat');
		if isfile(iterlogfp)
			iterlog=load(iterlogfp);
			iterlog_err=iterlog.iterLog;
			iter_n=length(iterlog_err);
			iter_nmat(s,K)=iter_n;
			iter_errormat(s,K)=iterlog_err(iter_n);
		else
			iter_nmat(s,K)=0;
			iter_errormat(s,K)=0;
		end
		% reconstr. only
		decomp_mfp=strcat(singparc_dir, 'SingleParcel_1by1_kequal_', num2str(K), '/Sub_', num2str(bblids(s)), '/IndividualParcel_Final_sbj1_comp', num2str(K), '_alphaS21_1_alphaL10_vxInfo1_ard0_eta0/final_UV.mat');
		if isfile(decomp_mfp)
			decomp_mat=load(decomp_mfp);
			data_fp=strcat(singparc_dir, 'SingleParcel_1by1_kequal_', num2str(K), '/Sub_', num2str(bblids(s)), '/sbjData.mat');
			data_mat=load(data_fp);
			D = data_mat.sbjData{1};
			U = decomp_mat.U{1};
			V = decomp_mat.V{1};
			recon_err = calc_recon_error(D, U, V);
			recon_errormat(s,K)=recon_err;
		else
			recon_errormat(s,K)=0;
		end
	end
end
csvwrite('/cbica/projects/pinesParcels/data/aggregated_data/iter_n',iter_nmat);	
csvwrite('/cbica/projects/pinesParcels/data/aggregated_data/iter_error',iter_errormat);
csvwrite('/cbica/projects/pinesParcels/data/aggregated_data/recon_error',recon_errormat);
