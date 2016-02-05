function z = refineBGS(setNum,opts)
% refine the bgs results 
% setNum can only be equal to 2 or 3
% the refined results without post-processing are store in 'result/'

if(setNum ~= 2 & setNum ~= 3)
    disp('setNum for testing can only be 2 or 3');
    z = 0;
    return;
end

%% calculate the foreground for the dataset
maxDepth_C  = 64;
maxDepth_D  = 6;

ftrsCnt=9; %
if setNum ==3
    setNumListC = [1 2 4];%choose the forest for color
    setNumListD = [1 2 4];%choose the forest for depth
end

if setNum ==2
    setNumListC = [1 3 4];%choose the forest for color
    setNumListD = [1  4];%choose the forest for depth
end

setFtrsC=[1:9];%features for color
setFtrsD=[7:9];%features for depth
rd = 5;

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
forestDir   = opts.forestDir;

dataSetDir  = opts.imageDir;
dataSetFnm  = opts.imageFnm;
bgsColorDir = opts.bgsColor;
bgsDepthDir = opts.bgsDepth;
imgColorDir = opts.imgColor;
imgDepthDir = opts.imgDepth;
imgGtDir    = opts.imgGt;
resultDir   = opts.resultDir;
% % sampleDir =opts.sampleDir ;
% % ftrsDir  = opts.ftrsDir;
% % modelDir = opts.modelDir;
% % 
% % saveSamples = 1;
ftrsCnt=9; %
rd = 5;

% get image number
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


selDataSetC=[num2str(setNumListC(1))];
for i=2:length(setNumListC),selDataSetC=[selDataSetC '-' num2str(setNumListC(i))];end
selDataSetD=[num2str(setNumListD(1))];
for i=2:length(setNumListD),selDataSetD=[selDataSetD '-' num2str(setNumListD(i))];end

%load forest
load([ forestDir 'forestC-' selDataSetC '.mat']);
load([ forestDir 'forestD-' selDataSetD '.mat']);


FP=zeros(1,length(gtNum{setNum}));
FN=zeros(1,length(gtNum{setNum}));
for gtIdx = gtNum{setNum}(1:end)
        %read images
        C   =imread([dataSetDir  dataSetFnm{1,setNum} imgColorDir '/img_'  num2str(gtIdx) '.bmp']); %color map
        BGC =imread([dataSetDir  dataSetFnm{1,setNum} bgsColorDir 'mogc'   num2str(gtIdx) '.bmp']); %bg by color
        FGC =imread([dataSetDir  dataSetFnm{1,setNum} bgsColorDir '/mogc'  num2str(gtIdx) '.bmp']); %fg by color
        D   =imread([dataSetDir  dataSetFnm{1,setNum} imgDepthDir 'depth_' num2str(gtIdx) '.bmp']); %depth map
        BGD =imread([dataSetDir  dataSetFnm{1,setNum} bgsDepthDir 'bgd'    num2str(gtIdx) '.bmp']); %bg by depth
        FGD =imread([dataSetDir  dataSetFnm{1,setNum} bgsDepthDir 'mogd'   num2str(gtIdx) '.bmp']); %fg by depth
        GT  =imread([dataSetDir  dataSetFnm{1,setNum} imgGtDir    'gt_'    num2str(gtIdx) 'BW.bmp']); %ground truth
        MASK=imread([dataSetDir  dataSetFnm{1,setNum} imgGtDir                         'gt_BW.bmp']); %mask
        
        %convert to logical
        if(~isa(FGC,'logical')),FGC=im2bw(FGC);end
        if(~isa(FGD,'logical')),FGD=im2bw(FGD);end
        if(~isa(GT,'logical')), GT=im2bw(GT);  end
        if(~isa(MASK,'logical')),MASK=im2bw(MASK);end

    total=sum(sum(MASK)');
    
    %nnm
    if(ndims(D)>2),D_=rgb2gray(D);else D_=D; end
    Db=(D_>0);
    [y0,x0]=find(~Db.*MASK);
    for i=1:length(y0),MASK(y0(i),x0(i))=0;end

    %calculate features for color
    C_luv=rgbConvert(C,'luv'); %luv 1-3
    BGC_luv=rgbConvert(BGC,'luv'); %luv      
    diff_luv=abs(C_luv-BGC_luv);%luv-luv 4-6

    if(ndims(D)>2) 
        diff_depth=rgb2gray(abs(double(D) - double(BGD))./255);
    else
        BGD=rgb2gray(BGD);
        diff_depth=abs(double(D) - double(BGD))./255;
    end

    EC=edgesColor(C); %

    FGC=FGC&MASK;
    FGD=FGD&MASK;
    CandD = FGC&FGD;
    CorD = FGC|FGD;
    rectC = FGC-CandD;
    rectD = FGD-CandD;

    V=zeros(1,rd*2+1,'single');%for depth continuity
    H=zeros(1,rd*2+1,'single');

    
    [yC,xC]=find(rectC);
    ftrsC=zeros(length(yC),ftrsCnt,'single');
    labelsGtC=zeros(length(yC),1,'single');

    if(ndims(D)==3)
        D_gray=im2double(rgb2gray(D));
    else
        D_gray=im2double(D);
    end

    for j=1:length(yC),
        ftrsC(j,1:3)=C_luv(yC(j),xC(j),:);
        ftrsC(j,4:6)=diff_luv(yC(j),xC(j),:);
        ftrsC(j,7)=diff_depth(yC(j),xC(j),:);
        ftrsC(j,8)=EC(yC(j),xC(j));
        V(1,:)=D_gray(yC(j),xC(j)-rd:xC(j)+rd);
        H(1,:)=(D_gray(yC(j)-rd:yC(j)+rd,xC(j)))';
        HV = D_gray(yC(j)-rd:yC(j)+rd,xC(j)-rd:xC(j)+rd);
        HV2 = D_gray(yC(j)+rd:-1:yC(j)-rd,xC(j)-rd:xC(j)+rd);
        U = diag(HV); W = diag(HV2);
        ftrsC(j,9)=min([var(H),var(V),var(U),var(W)]);    
        labelsGtC(j,1)=GT(yC(j),xC(j));
    end
    %calculate features for depth
    [yD,xD]=find(rectD);
    ftrsD=zeros(length(yD),ftrsCnt,'single');     
    labelsGtD=zeros(length(yD),1,'single');
    for j=1:length(yD),
        ftrsD(j,1:3)=C_luv(yD(j),xD(j),:);
        ftrsD(j,4:6)=diff_luv(yD(j),xD(j),:);
        ftrsD(j,7)=diff_depth(yD(j),xD(j),:);
        ftrsD(j,8)=EC(yD(j),xD(j));
        V(1,:)=D_gray(yD(j),xD(j)-rd:xD(j)+rd);
        H(1,:)=(D_gray(yD(j)-rd:yD(j)+rd,xD(j)))';
        HV = D_gray(yD(j)-rd:yD(j)+rd,xD(j)-rd:xD(j)+rd);
        HV2 = D_gray(yD(j)+rd:-1:yD(j)-rd,xD(j)-rd:xD(j)+rd);
        U = diag(HV); W = diag(HV2);

        ftrsD(j,9)=min([var(H),var(V),var(U),var(W)]);  
        labelsGtD(j,1)=GT(yD(j),xD(j));
    end

    % select features
    ftrsC_=ftrsC(:,setFtrsC);
    ftrsD_=ftrsD(:,setFtrsD);


    % testing
    [labelC,ps] = forestApply( ftrsC_, forestC, maxDepth_C, 8, 0 );
    labelC=labelC-1;
    accuracy = (100-100*symerr(labelC,double(labelsGtC))/length(labelC));
    disp('forestC test accuracy:');disp(accuracy);

    [labelD,ps] = forestApply( ftrsD_, forestD, maxDepth_D, 8, 0 );
    labelD=labelD-1;
    accuracy = (100-100*symerr(labelD,double(labelsGtD))/length(labelD));
    disp('forestD test accuracy:');disp(accuracy);

    result=CandD;
    % refinement
    for i=1:length(labelC)
        if labelC(i)==1, result(yC(i),xC(i))=1;end
    end
    for i=1:length(labelD)
        if labelD(i)==1, result(yD(i),xD(i))=1;end
    end
% % %     % post-processing
% % %     if setNum == 3
% % %         se = strel('rectangle',[3 2]);
% % %         result = imopen(result,se); 
% % %     end
% % %     bw2 = bwareaopen(result,40);
    
    % save results
    resultDirtmp = [resultDir dataSetFnm{1,setNum} ];
    if(~exist(resultDirtmp,'dir')), mkdir(resultDirtmp); end
    imwrite(result,[ resultDirtmp 'result' num2str(gtIdx) '.bmp']);
    z = 1;
end




