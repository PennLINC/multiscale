subjs=load('/cbica/projects/pinesParcels/data/bblids.txt');
folder = '/cbica/projects/pinesParcels/data/CombinedData/'
for s=650:length(subjs)
fp=[folder num2str(subjs(s)) '/vertexwise_fc_mat.mat'];
fc=load(fp);
cm=fc.ba_conmat;
csvwrite([folder num2str(subjs(s)) '/vertexwise_fc_mat.csv'],cm);
end

