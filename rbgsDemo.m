clc
% if reExtract     = 1, re-extract features 
% if reTrain       = 1, re-train forest
% if reRefine      = 1, use the forest to calculate new results
% if drawHistogram = 1, draw the histogram for features
reExtract     = 0;
reTrain       = 0;
reRefine      = 1;
bgs_method_id = 3;% 1~3
opts.dataSetNum = 3;


bgs_methods = {'DPAdaptiveMedianBGS','MOG','FuzzySOM','StaticFrameDifferenceBGS'};
opts.bgs_method_id = bgs_method_id;
opts.methods  = bgs_methods;
opts.method   = bgs_methods{1,bgs_method_id}; % method to choose foreground to extract features
opts.addSample  = 1;

% some dir
opts.imageDir = 'E:/Research_2016/PRLetters-28012014/code/images/'; % 
opts.imageFnm = {'ColCamSeq/','GenSeq/','ShSeq/','Wall/'};        % dataset name
opts.imgColor = 'Color/';
opts.imgDepth = 'Depth/';
opts.imgGt    = 'GroundTruth/';

%source images
opts.bgsColor      = [ opts.methods{1,bgs_method_id} '/'];
opts.bgsDepth      = [ opts.methods{1,bgs_method_id} '/'];
%result images
opts.resultDir     = ['results/'];
opts.postResultDir = ['post_results/'];
opts.sampleDir     = ['samples/'];
opts.ftrsDir       = ['features/'];
opts.ftrsDirNotAddSample = ['features/notAddSample/'];
opts.forestDir     = ['forests/' ];

opts.saveSamples= 1;

opts.numOfTree_C = 12;
opts.numOfTree_D = 6;
opts.maxDepth_C = 6;
opts.maxDepth_D = 6;




if(reExtract)
    %first extracting features
    disp('Extracting features! @ rgbsDemo.m');
    ftrs = ftrExtr(opts);
end

if(reTrain)
    % then train forest
    disp('Training forest! @ rgbsDemo.m');
    for setNum = 1:opts.dataSetNum
        z = trainForest(setNum,opts);
    end
end

if(reRefine)
    % then use the forest to refine
    disp('Refining the results! @ rgbsDemo.m');
    for setNum = 1:opts.dataSetNum
       refineTime = refineBGS(setNum,opts);
       z = postProcessing(setNum,opts);
       save([opts.resultDir opts.imageFnm{1,setNum} opts.method '/refineTime.mat'],'refineTime','-v7.3');
    end
end
% analysis the methods in different datasets
disp(opts.method);
for setNum=1:opts.dataSetNum
    disp('evaluate the methods in different datasets');
    disp(['dataSet = ' opts.imageFnm{1,setNum}(1:end-1)]);
    [zz0, zz1, zz2,zz3,zz4] = evaluate(setNum,opts);    
    disp('    TE        FN        FP        TN         TP         S');
    disp('-------------------------------------------------------------');
    zz00 = num2str(roundn(zz0*100,-2)); disp( zz00);
    zz01 = num2str(roundn(zz1*100,-2)); disp( zz01);
    zz02 = num2str(roundn(zz2*100,-2)); disp( zz02);
    zz03 = num2str(roundn(zz3*100,-2)); disp( zz03);
    zz04 = num2str(roundn(zz4*100,-2)); disp( zz04);
    
    FPs = [zz0(3) zz1(3) zz2(3) zz3(3) zz4(3)];
    TPs = [zz0(5) zz1(5) zz2(5) zz3(5) zz4(5)];
    save([opts.resultDir opts.imageFnm{1,setNum} opts.method '/FPs.mat'],'FPs','-v7.3');
    save([opts.resultDir opts.imageFnm{1,setNum} opts.method '/TPs.mat'],'TPs','-v7.3');
end

% draw histogram for features;


