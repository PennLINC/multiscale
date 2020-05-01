function initV = selRobustInit(inFile,K,outDir)
% select robust initialization
% inFile is a text file including paths to all the candidate initializations, each line for one initialization

%ncutPath = [gdPath,filesep,'Ncut_9'];
%addpath(genpath(ncutPath));

%
fid = fopen(inFile, 'r');
initList = textscan(fid, '%s');
initList = initList{1};
fclose(fid);

repNum = length(initList);
disp('select best V...');

% load results
resSet = [];
for ri=1:repNum
    resName = initList{ri};
    load(resName);

    resSet = [resSet, initV];
    clear initV;
end
resSet = resSet';

% clustering by ncut
corrVal = corr(resSet');
corrVal(isnan(corrVal)) = -1;
nDis = 1 - corrVal;
triuInd = triu(ones(size(nDis)),1);
nDisVec = nDis(triuInd==1);

nW = exp(-nDis.^2 ./ (median(nDisVec).^2));
nW(isnan(nW)) = 0;

sumW = sum(nW,1);
sumW(sumW==0) = 1;
D = diag(sumW);
L = sqrt(inv(D))*nW*sqrt(inv(D));  
L = (L+L')/2;
opts.disp = 0;
[Ev,~] = eigs(double(L),K,'LA',opts);
normvect = sqrt(diag(Ev*Ev'));
normvect(normvect==0.0) = 1;
Ev = diag(normvect) \ Ev;

[EvDiscrete,~] = discretisation(Ev);
EvDiscrete = full(EvDiscrete);
[~, C] = max(EvDiscrete,[],2);

% get centroid
initV = zeros(size(resSet,2),K);
for ki=1:K            
    % % typical point
    if sum(C==ki)>1
        candSet = resSet(C==ki,:)';
        corrW = abs(corr(candSet));
        corrW(isnan(corrW)) = 0;
        [mVal, mInd] = max(sum(corrW));
        initV(:,ki) = candSet(:,mInd);
    elseif sum(C==ki)==1
        initV(:,ki) = resSet(C==ki,:);
    end
end
initV = initV ./ max(eps,repmat(max(initV),size(initV,1),1));

if ~exist(outDir,'dir')
    mkdir(outDir);
end
save([outDir,filesep,'init.mat'],'initV');
