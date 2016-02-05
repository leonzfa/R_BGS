function z = trainForest(setNum,opts)  



forestDir  = opts.forestDir;
if opts.addSample  ==0
    ftrsDir = opts.ftrsDirNotAddSample;
else
    ftrsDir = opts.ftrsDir;
end

if setNum ==3
    setNumListC = [1 2 4];%choose training dataset for color
    setNumListD = [1 2 4];%choose training dataset for depth
end

if setNum ==2
    setNumListC = [1 3 4];%choose training dataset for color
    setNumListD = [1  4];%choose training dataset for depth
end

setFtrsC=[1:9];%select features for color
setFtrsD=[7:9];%select features for depth

%setings for random forest
numOfTree_C = 15;
numOfTree_D = 10;
maxDepth_C  = 64;
maxDepth_D  = 6;


pTreeC=struct('M',numOfTree_C,'minCount', 1, 'minChild', 8, ...
      'maxDepth',maxDepth_C, 'H', 2, 'split', 'gini');
pTreeD=struct('M',numOfTree_D,'minCount', 1, 'minChild', 8, ...
      'maxDepth',maxDepth_D, 'H', 2, 'split', 'gini');


ftrs_color_pos = [];ftrs_color_neg = [];
for i=setNumListC,
  load([ ftrsDir 'features_color_positive' '-' num2str(i) '.mat']);
  load([ ftrsDir 'features_color_negative' '-' num2str(i) '.mat']);
  ftrs_color_pos = [ftrs_color_pos features_color_positive];
  ftrs_color_neg = [ftrs_color_neg features_color_negative];
end

ftrs_depth_pos = [];ftrs_depth_neg = [];
for i=setNumListD,
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

%save models
selDataSetC=[num2str(setNumListC(1))];
for i=2:length(setNumListC),selDataSetC=[selDataSetC '-' num2str(setNumListC(i))];end
selDataSetD=[num2str(setNumListD(1))];
for i=2:length(setNumListD),selDataSetD=[selDataSetD '-' num2str(setNumListD(i))];end

if(~exist(forestDir,'dir')), mkdir(forestDir); end
save([forestDir 'forestC' '-' selDataSetC '.mat'],'forestC','-v7.3');
save([forestDir 'forestD' '-' selDataSetD '.mat'],'forestD','-v7.3');
z = 1;
end

