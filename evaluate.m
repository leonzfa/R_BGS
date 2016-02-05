function Z = evaluate(setNum,method,opts)
% method = 0 £ºproposed
%        = 1 £ºmogc
%        = 2 £ºmogd
% Z: 1x4
%       Z[1] : TE
%       Z[2] : FN
%       Z[3] : FP
%       Z[4] : S

% % opts.imageDir = 'images/';          % 
% % opts.imageFnm = {'ColCamSeq/','GenSeq/','ShSeq/','Wall/'};        % dataset name
% % opts.bgsColor = 'Color/MOG/';
% % opts.bgsDepth = 'Depth/MOG/';
% % opts.imgColor = 'Color/';
% % opts.imgDepth = 'Depth/';
% % opts.imgGt    = 'GroundTruth/';
% % 
% % opts.sampleDir  = 'sample/';
% % opts.ftrsDir    = 'ftrs/';
% % opts.modelDir   = 'model/';
% % forestDir       = 'forest/';

dataSetDir  = opts.imageDir;
dataSetFnm  = opts.imageFnm;
bgsColorDir = opts.bgsColor;
bgsDepthDir = opts.bgsDepth;
imgColorDir = opts.imgColor;
imgDepthDir = opts.imgDepth;
imgGtDir    = opts.imgGt;



% Get the images' number 
for i = 1:4
    gtDir = [dataSetDir  dataSetFnm{1,i} imgGtDir];
    gtIds=dir(gtDir);
    gtIds=gtIds([gtIds.bytes]>0);
    gtIds={gtIds.name};
    ext=gtIds{1}(end-2:end);
    num = [];
    for j = 1:length(gtIds);
        num = [num str2num(gtIds{j}(4:end-6))];
    end
    num = sort(num);
    gtNum{i} = num;
end


MASK=imread([dataSetDir  dataSetFnm{1,setNum} imgGtDir  'gt_BW.bmp']); %mask
if(~isa(MASK,'logical')), MASK=im2bw(MASK);end
sumMask=sum(sum(MASK)');

TE=[]; % Total Error (TE) (total number of misclassified pixels normalized with respect to the image size)
FN=[]; % False Negative rate (FN) (fraction of foreground pixels that are marked as background)
FP=[]; % False Positive rate (FP) (fraction of the background pixels that are marked as foreground)
S =[]; % Similarity

for gtIdx = gtNum{setNum}(1:end)
%     if gtIdx == 921
%         continue;
%     end
    % load images
    resultDir = ['post_result/' dataSetFnm{1,setNum} ];
    result=imread([resultDir 'result' num2str(gtIdx) '.bmp']); result = result&MASK;
    GT  =imread([dataSetDir  dataSetFnm{1,setNum} imgGtDir    'gt_'    num2str(gtIdx) 'BW.bmp']); %ground truth
    C   =imread([dataSetDir  dataSetFnm{1,setNum} imgColorDir '/img_'  num2str(gtIdx) '.bmp']); %color map
    BGC =imread([dataSetDir  dataSetFnm{1,setNum} bgsColorDir 'mogc'   num2str(gtIdx) '.bmp']); %background based on color
    FGC =imread([dataSetDir  dataSetFnm{1,setNum} bgsColorDir '/mogc'  num2str(gtIdx) '.bmp']); %foreground based on color
    D   =imread([dataSetDir  dataSetFnm{1,setNum} imgDepthDir 'depth_' num2str(gtIdx) '.bmp']); %depth map
    BGD =imread([dataSetDir  dataSetFnm{1,setNum} bgsDepthDir 'bgd'    num2str(gtIdx) '.bmp']); %background based on depth
    FGD =imread([dataSetDir  dataSetFnm{1,setNum} bgsDepthDir 'mogd'   num2str(gtIdx) '.bmp']); %foreground based on depth
    if(~isa(GT,'logical')), GT=im2bw(GT);end
    if(size(FGC,3) == 3) FGC = (rgb2gray(FGC))>0;end
    if(size(FGD,3) == 3) FGD = (rgb2gray(FGD))>0;end
    if(size(BGC,3) == 3) BGC = (rgb2gray(BGC))>0;end
    if(size(BGD,3) == 3) BGD = (rgb2gray(BGD))>0;end
        
        
        
    switch(method)
        case 0
            test_image = result;
        case 1
            test_image = FGC;
        case 2
            test_image = FGD;
        otherwise
            test_image = result;
    end
    
    
    te = sum(sum(test_image ~= GT)) ./ size(test_image,1) ./ size(test_image,2);
    TE = [TE te];
    
    if( sum(sum(GT)) ~=0)
        fn = sum(sum((GT&~test_image))) ./ sum(sum(GT)); % False Negative rate (FN) (fraction of foreground pixels that are marked as background)
        FN = [FN fn];
    else
        FN = [FN 0];
    end
    
    if(sum(sum(~GT))~=0)
        fp = sum(sum((~GT&test_image))) ./ sum(sum(~GT)); %(fraction of the background pixels that are marked as foreground)
        FP = [FP fp];
    else
        FP = [FP 0];
    end
   
    if(sum(sum(GT|test_image)')~=0)
        s = sum(sum(GT&test_image)')./sum(sum(GT|test_image)');
        S = [S s];
    else
        S = [S 1];
    end  
end


%metric
avg_TE = mean(TE);
avg_FN = mean(FN);
avg_FP = mean(FP);
avg_S  = mean(S);

Z = [avg_TE avg_FN avg_FP avg_S];
end
      