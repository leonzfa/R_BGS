function [Z0,Z1,Z2,Z3,Z4] = evaluate(setNum,opts)
% Z: 1x4
%       Z[1] : TE
%       Z[2] : FN
%       Z[3] : FP
%       Z[4] : S

dataSetDir  = opts.imageDir;
dataSetFnm  = opts.imageFnm;
bgsColorDir = opts.bgsColor;
bgsDepthDir = opts.bgsDepth;
imgColorDir = opts.imgColor;
imgDepthDir = opts.imgDepth;
imgGtDir    = opts.imgGt;
method      = opts.method;
bgs_method_id = opts.bgs_method_id;

% Get the images' number 
for i = 1:opts.dataSetNum
    gtDir = [dataSetDir  dataSetFnm{1,i} imgGtDir];
    gtIds=dir([gtDir '*.bmp']);
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

TE0=[]; % Total Error (TE) (total number of misclassified pixels normalized with respect to the image size)
FN0=[]; % False Negative rate (FN) (fraction of foreground pixels that are marked as background)
FP0=[]; % False Positive rate (FP) (fraction of the background pixels that are marked as foreground)
S0 =[]; % Similarity
TP0=[];
TN0=[];

TE1 = []; FN1 = []; FP1=[]; S1 = [];TP1=[];TN1=[];
TE2 = []; FN2 = []; FP2=[]; S2 = [];TP2=[];TN2=[];
TE3 = []; FN3 = []; FP3=[]; S3 = [];TP3=[];TN3=[];
TE4 = []; FN4 = []; FP4=[]; S4 = [];TP4=[];TN4=[];
for gtIdx = gtNum{setNum}(1:end)
%     if gtIdx == 921
%         continue;
%     end
    % load images
    resultDir = ['post_results/' dataSetFnm{1,setNum} method '/'];
    result=imread([resultDir 'result' num2str(gtIdx) '.bmp']); result = result&MASK;
    GT  =imread([dataSetDir  dataSetFnm{1,setNum} imgGtDir    'gt_'    num2str(gtIdx) 'BW.bmp']); %ground truth
    C   =imread([dataSetDir  dataSetFnm{1,setNum} imgColorDir '/img_'  num2str(gtIdx) '.bmp']); %color map
    D   =imread([dataSetDir  dataSetFnm{1,setNum} imgDepthDir '/depth_' num2str(gtIdx) '.bmp']); %depth map
    BGC =imread([dataSetDir  dataSetFnm{1,setNum} 'Color/' method '/bgc' num2str(gtIdx) '.bmp']); %bg by color
    BGD =imread([dataSetDir  dataSetFnm{1,setNum} 'Depth/' method '/bgd'    num2str(gtIdx) '.bmp']); %bg by depth
    FGC =imread([dataSetDir  dataSetFnm{1,setNum} 'Color/' method '/fgc'  num2str(gtIdx) '.bmp']); %fg by color
    FGD =imread([dataSetDir  dataSetFnm{1,setNum} 'Depth/' method '/fgd'   num2str(gtIdx) '.bmp']); %fg by depth
    if(~isa(GT,'logical')), GT=im2bw(GT);end
    if(size(FGC,3) == 3) FGC = (rgb2gray(FGC))>0;end
    if(size(FGD,3) == 3) FGD = (rgb2gray(FGD))>0;end
    if(size(BGC,3) == 3) BGC = (rgb2gray(BGC))>0;end
    if(size(BGD,3) == 3) BGD = (rgb2gray(BGD))>0;end     
        
    % evaluate CD, C, D, 
    [te, fn, fp, s, tp,tn] = eval(result, GT, MASK);
    TE0 = [TE0 te];        FN0 = [FN0 fn];        FP0 = [FP0 fp];        S0 = [S0 s];  TP0 = [TP0 tp];TN0 = [TN0 tn];
    [te, fn, fp, s, tp,tn] = eval(FGC&MASK, GT, MASK);
%     disp([te, fn, fp, s]);
    TE1 = [TE1 te];        FN1 = [FN1 fn];        FP1 = [FP1 fp];        S1 = [S1 s];  TP1 = [TP1 tp];TN1 = [TN1 tn];
    [te, fn, fp, s, tp,tn] = eval(FGD&MASK, GT, MASK);
    TE2 = [TE2 te];        FN2 = [FN2 fn];        FP2 = [FP2 fp];        S2 = [S2 s];  TP2 = [TP2 tp];TN2 = [TN2 tn];
    
    [te, fn, fp, s, tp,tn] = eval(FGD&FGC&MASK, GT, MASK); %disp([num2str(gtIdx) ', ' num2str(tn)]);
    TE3 = [TE3 te];        FN3 = [FN3 fn];        FP3 = [FP3 fp];        S3 = [S3 s];  TP3 = [TP3 tp];TN3 = [TN3 tn];
    [te, fn, fp, s, tp,tn] = eval((FGD|FGC)&MASK, GT, MASK);
    TE4 = [TE4 te];        FN4 = [FN4 fn];        FP4 = [FP4 fp];        S4 = [S4 s];  TP4 = [TP4 tp];TN4 = [TN4 tn];
    
    
end


%metric
avg_TE0 = mean(TE0); avg_FN0 = mean(FN0); avg_FP0 = mean(FP0); avg_S0  = mean(S0); avg_TP0  = mean(TP0);avg_TN0  = mean(TN0);
avg_TE1 = mean(TE1); avg_FN1 = mean(FN1); avg_FP1 = mean(FP1); avg_S1  = mean(S1); avg_TP1  = mean(TP1);avg_TN1  = mean(TN1);
avg_TE2 = mean(TE2); avg_FN2 = mean(FN2); avg_FP2 = mean(FP2); avg_S2  = mean(S2); avg_TP2  = mean(TP2);avg_TN2  = mean(TN2);
avg_TE3 = mean(TE3); avg_FN3 = mean(FN3); avg_FP3 = mean(FP3); avg_S3  = mean(S3); avg_TP3  = mean(TP3);avg_TN3  = mean(TN3);
avg_TE4 = mean(TE4); avg_FN4 = mean(FN4); avg_FP4 = mean(FP4); avg_S4  = mean(S4); avg_TP4  = mean(TP4);avg_TN4  = mean(TN4);

Z0 = [avg_TE0 avg_FN0 avg_FP0 avg_TN0 avg_TP0 avg_S0 ];
Z1 = [avg_TE1 avg_FN1 avg_FP1 avg_TN1 avg_TP1 avg_S1 ];
Z2 = [avg_TE2 avg_FN2 avg_FP2 avg_TN2 avg_TP2 avg_S2 ];
Z3 = [avg_TE3 avg_FN3 avg_FP3 avg_TN3 avg_TP3 avg_S3 ];
Z4 = [avg_TE4 avg_FN4 avg_FP4 avg_TN4 avg_TP4 avg_S4 ];
end


function [te, fn, fp, s,tp,tn] = eval(test_image, GT, MASK)
    te = sum(sum(test_image ~= GT)) ./ size(test_image,1) ./ size(test_image,2);    
    if( sum(sum(GT)) ~=0)
        fn = sum(sum((GT&~test_image))) ./ sum(sum(GT)); % False Negative rate (FN) (fraction of foreground pixels that are marked as background)
%         fn = sum(sum((GT&~test_image))) ./ sum(sum(MASK)); % False Negative rate (FN) (fraction of foreground pixels that are marked as background)
     else
        fn=0;
    end
    
    if(sum(sum(~GT))~=0)
        fp = sum(sum((~GT&test_image))) ./ sum(sum(~GT)); %(fraction of the background pixels that are marked as foreground)  
%         fp = sum(sum((~GT&test_image))) ./ sum(sum(~MASK)); %(fraction of the background pixels that are marked as foreground)  
    else
        fp=0;
    end
   
    if(sum(sum(GT|test_image)')~=0)
        s = sum(sum(GT&test_image)')./sum(sum(GT|test_image)');        
    else
        s = 1;
    end
    se = strel('disk',10);
    TPMask=imdilate(GT,se,'same'); %dilate
    
    if(sum(sum(GT|test_image)')~=0 && sum(sum(GT))~=0)
        TP = sum(sum((GT&test_image)&TPMask)')./sum(sum((GT|test_image)&TPMask)');
    else
        TP = 1;
    end
    
    if(sum(sum(GT))~=0)
        tp = sum(sum((GT&test_image))')./sum(sum((GT)'));
    else
        tp = 1;
    end
    
    if(sum(sum(~GT&MASK))~=0)
        tn = sum(sum((~GT&~test_image)&MASK)')./sum(sum((~GT&MASK)));
    else
        tn = 1;
    end
    
    
end