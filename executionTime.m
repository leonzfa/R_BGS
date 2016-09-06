clc
% if reExtract     = 1, re-extract features 
% if reTrain       = 1, re-train forest
% if reRefine      = 1, use the forest to calculate new results
% if drawHistogram = 1, draw the histogram for features
reExtract     = 0;
reTrain       = 0;
reRefine      = 1;
bgs_method_id = 1;% 1~3
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

for bgs_method_id = 1:3
    method = bgs_methods{1,bgs_method_id};
    a_time_ = zeros(3,7);
    for setNum = 1:opts.dataSetNum
        refineTime = [];
        refineTime = load([opts.resultDir opts.imageFnm{1,setNum} opts.method '/refineTime.mat']); 
        time_ = refineTime.refineTime;        
        m_time_ = roundn(mean(time_,1)*1000,-2);
        m_time_ = m_time_ - [0,m_time_(1:end-1)];
        s_time_ = sum(m_time_);
%         disp( num2str(m_time_));
%         disp( num2str(s_time_));
        a_time_(setNum,1:6) = m_time_;
        a_time_(setNum,7)   = s_time_;
    end
    m_a_time_ = mean(a_time_,1);
    disp(num2str(roundn(m_a_time_,-2)));
end
