function Z = analysis(setNum,method,opts)
% method = 0 £ºproposed
%        = 1 £ºmogc
%        = 2 £ºmogd
% Z: 1x6
%       Z[1] : GT&F/GT
%       Z[2] : GT&F0/F0
%       Z[3] : GT&FC/FC
%       Z[4] : GT&FD/FD
%       Z[5] : FGR&FC/FC
%       Z[6] : FGR&FD/FD
% opts.imageDir = 'images/';          % 
% opts.imageFnm = {'ColCamSeq/','GenSeq/','ShSeq/','Wall/'};        % dataset name
if(method==0)
    opts.bgsColor = 'Color/MOG/';
    opts.bgsDepth = 'Depth/MOG/';
else
    opts.bgsColor = 'Color/FuzzySOM/';
    opts.bgsDepth = 'Depth/FuzzySOM/';
end
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

Z1 = [];
Z2 = [];
Z3 = [];
Z4 = [];
Z5 = [];
Z6 = [];

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
    if(size(FGC,3) == 3) FGC = (rgb2gray(FGC))>0 & MASK;else FGC = FGC>0;end
    if(size(FGD,3) == 3) FGD = (rgb2gray(FGD))>0 & MASK;else FGD = FGD>0;end
    if(size(BGC,3) == 3) BGC = (rgb2gray(BGC))>0 ;else BGC = BGC>0;end
    if(size(BGD,3) == 3) BGD = (rgb2gray(BGD))>0 ;else BGD = BGD>0;end

    F  = FGC|FGD;
    F0 = FGC&FGD;
    FC = FGC - F0;
    FD = FGD - F0;
    
    mfc = ((result&FC) == (FC&GT)) &FC;
    mfd = ((result&FD) == (FD&GT)) &FD;
    
    
    if(sum(GT(:))~=0)
        z1 = sum(sum(GT&F)) ./ sum(GT(:));
        Z1 = [Z1 z1];
    else
        Z1 = [Z1 1];
    end
    
    if(sum(F0(:))~=0)
        z2 = sum(sum(GT&F0)) ./ sum(F0(:));
        Z2 = [Z2 z2];
    else
        Z2 = [Z2 1];
    end
    
    if(sum(FC(:))~=0)
        z3 = sum(sum(GT&FC)) ./ sum(FC(:));
        Z3 = [Z3 z3];
        z5 = sum(mfc(:)) ./  sum(FC(:));
        Z5 = [Z5 z5];
    else
        Z3 = [Z3 1];
        Z5 = [Z5 1];
    end
    
    if(sum(FD(:))~=0)
        z4 = sum(sum(GT&FD)) ./ sum(FD(:));
        Z4 = [Z4 z4];
        z6 = sum(mfd(:)) ./  sum(FD(:));
        Z6 = [Z6 z6];
    else
        Z4 = [Z4 1];
        Z6 = [Z6 1];
    end
    
end


%metric
avg_Z1 = mean(Z1);
avg_Z2 = mean(Z2);
avg_Z3 = mean(Z3);
avg_Z4 = mean(Z4);
avg_Z5 = mean(Z5);
avg_Z6 = mean(Z6);

Z = [avg_Z1 avg_Z2 avg_Z3 avg_Z4 avg_Z5 avg_Z6 ];

end
      

