function z = trainForest(setNum,opts) 

method = opts.method;
forestDir  = opts.forestDir; forestDir = [forestDir method '/'];
if opts.addSample  ==0
    ftrsDir = opts.ftrsDirNotAddSample;
else
    ftrsDir = opts.ftrsDir;
end
ftrsDir = [ftrsDir method '/'];

setFtrsC=[1:9];%select features for color
setFtrsD=[7:9];%select features for depth

%setings for random forest
numOfTree_C = opts.numOfTree_C;
numOfTree_D = opts.numOfTree_D;
maxDepth_C  = opts.maxDepth_C;
maxDepth_D  = opts.maxDepth_D;

pTreeC=struct('M',numOfTree_C,'minCount', 1, 'minChild', 8, ...
      'maxDepth',maxDepth_C, 'H', 2, 'split', 'gini');
pTreeD=struct('M',numOfTree_D,'minCount', 1, 'minChild', 8, ...
      'maxDepth',maxDepth_D, 'H', 2, 'split', 'gini');


ftrs_color_pos = [];ftrs_color_neg = [];

for i=1:opts.dataSetNum
    if i == setNum
        continue;
    end  
  load([ ftrsDir 'features_color_positive' '-' num2str(i) '.mat']);
  load([ ftrsDir 'features_color_negative' '-' num2str(i) '.mat']);
  ftrs_color_pos = [ftrs_color_pos features_color_positive];
  ftrs_color_neg = [ftrs_color_neg features_color_negative];
end

ftrs_depth_pos = [];ftrs_depth_neg = [];

for i=1:opts.dataSetNum
    if i == setNum || i ==3
        continue;
    end
  
  load([ ftrsDir 'features_depth_positive' '-' num2str(i) '.mat']);
  load([ ftrsDir 'features_depth_negative' '-' num2str(i) '.mat']);
  ftrs_depth_pos = [ftrs_depth_pos features_depth_positive];
  ftrs_depth_neg = [ftrs_depth_neg features_depth_negative];
end


%generate training set
%color
siz1=size(features_color_positive);
siz2=size(features_color_negative);
sample_num=2*min(siz1(2),siz2(2));
rp1=randperm(siz1(2),siz1(2));
rp2=randperm(siz2(2),siz2(2));
rp3=randperm(sample_num,sample_num);
features_color_positive(:,:)=features_color_positive(:,rp1);
features_color_negative(:,:)=features_color_negative(:,rp2);

ftrsTrainC=zeros(siz1(1),sample_num,'single');
ftrsTrainC(:,1:sample_num/2)=features_color_positive(:,1:sample_num/2);
ftrsTrainC(:,sample_num/2+1:sample_num)=features_color_negative(:,1:sample_num/2);
labelsTrainC=[ones(1,sample_num/2,'single'),zeros(1,sample_num/2,'single')];%%1-true, 0-false
ftrsTrainC(:,:)=ftrsTrainC(:,rp3);
labelsTrainC=labelsTrainC(rp3);
ftrsTrainC=ftrsTrainC';labelsTrainC=labelsTrainC'+1;

%depth
siz1=size(features_depth_positive);
siz2=size(features_depth_negative);
sample_num=2*min(siz1(2),siz2(2));
rp1=randperm(siz1(2),siz1(2));
rp2=randperm(siz2(2),siz2(2));
rp3=randperm(sample_num,sample_num);
features_depth_positive(:,:)=features_depth_positive(:,rp1);
features_depth_negative(:,:)=features_depth_negative(:,rp2);

ftrsTrainD=zeros(siz1(1),sample_num,'single');
ftrsTrainD(:,1:sample_num/2)=features_depth_positive(:,1:sample_num/2);
ftrsTrainD(:,sample_num/2+1:sample_num)=features_depth_negative(:,1:sample_num/2);
labelsTrainD=[ones(1,sample_num/2,'single'),zeros(1,sample_num/2,'single')];%1-true, 0-false
ftrsTrainD(:,:)=ftrsTrainD(:,rp3);
labelsTrainD=labelsTrainD(rp3);
ftrsTrainD=ftrsTrainD';labelsTrainD=labelsTrainD'+1;

%train random forest
%select features
ftrsTrainC_=ftrsTrainC(:,setFtrsC);
ftrsTrainD_=ftrsTrainD(:,setFtrsD);

forestC=forestTrain(ftrsTrainC_,labelsTrainC,pTreeC); 
[hs,ps] = forestApply( ftrsTrainC_, forestC, maxDepth_C, 8, 0 );
accuracy = (100-100*symerr(hs,double(labelsTrainC))/length(hs));
disp('forestC train accuracy:');disp(accuracy);

forestD=forestTrain(ftrsTrainD_,labelsTrainD,pTreeD); 
[hs,ps] = forestApply( ftrsTrainD_, forestD, maxDepth_D, 8, 0 );
accuracy = (100-100*symerr(hs,double(labelsTrainD))/length(hs));
disp('forestD train accuracy:');disp(accuracy);


if(~exist(forestDir,'dir')), mkdir(forestDir); end
save([forestDir 'forestC' '-' num2str(setNum) '.mat'],'forestC','-v7.3');
save([forestDir 'forestD' '-' num2str(setNum) '.mat'],'forestD','-v7.3');
z = 1;
end

