singparc_dir=['/cbica/projects/pinesParcels/data/SingleParcellation/'];
bblids=load('/cbica/projects/pinesParcels/data/bblids.txt');
Krange=2:3;
% +1 for subj ID column
iter_errormat=zeros(length(bblids),length(Krange)+1);
iter_nmat=zeros(length(bblids),length(Krange)+1);
for s=1:length(bblids);
	iter_errormat(s,1)=bblids(s);
	iter_nmat(s,1)=bblids(s);
	for K=2:max(Krange);
		iterlog=load(strcat(singparc_dir, 'SingleParcel_1by1_kequal_', num2str(K), '/Sub_', num2str(bblids(s)), '/Iteration_error.mat'));
		iterlog_err=iterlog.iterLog;
		iter_n=length(iterlog_err);
		iter_nmat(s,K)=iter_n;
		iter_errormat(s,K)=iterlog_err(iter_n);
	end
end
csvwrite('/cbica/projects/pinesParcels/data/aggregated_data/iter_n',iter_nmat);	
csvwrite('/cbica/projects/pinesParcels/data/aggregated_data/iter_error',iter_errormat);

