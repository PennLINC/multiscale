Krange=2:30;

% one pseudosubject as random values between 0 and 1, 1 subject as very high w/in:b/w ratio that gets higher as K increases

for k=Krange;
	randmat=randi(100,k,k)/100;
	segmat=ones(k)/1000;
	diagval=(.99*k)/max(Krange);
	segmat(logical(eye(k)))=diagval;
	Shamhouse{k}(:,:,1)=randmat;
	Shamhouse{k}(:,:,2)=segmat;
end

fp='/cbica/projects/pinesParcels/data/sim_data';
save([fp '/shamdata.mat'], 'Shamhouse');
