function z = refineBGS(setNum,opts)
% refine the bgs results 
% setNum can only be equal to 2 or 3
% the refined results without post-processing are store in 'result/'

% % if(setNum ~= 2 & setNum ~= 3)
% %     disp('setNum for testing can only be 2 or 3');
% %     z = 0;
% %     return;
% % end
tic
%% calculate the foreground for the dataset
maxDepth_C  = opts.maxDepth_C;
maxDepth_D  = opts.maxDepth_D;
ftrsCnt=9; %

setFtrsC=[1:9];%features for color
setFtrsD=[7:9];%features for depth

forestDir   = opts.forestDir;
method      = opts.method;
dataSetDir  = opts.imageDir;
dataSetFnm  = opts.imageFnm;
bgsColorDir = opts.bgsColor;
bgsDepthDir = opts.bgsDepth;
imgColorDir = opts.imgColor;
imgDepthDir = opts.imgDepth;
imgGtDir    = opts.imgGt;
resultDir   = opts.resultDir;

ftrsCnt=9; %

% get image number
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

%load forest
forestDir = [forestDir method '/'];
load([ forestDir 'forestC-' num2str(setNum) '.mat']);
load([ forestDir 'forestD-' num2str(setNum) '.mat']);


FP=zeros(1,length(gtNum{setNum}));
FN=zeros(1,length(gtNum{setNum}));

refineTime = zeros(length(gtNum{setNum}),6);
timeIndex = 0;
for gtIdx = gtNum{setNum}(1:end)
        %read images
        C   =imread([dataSetDir  dataSetFnm{1,setNum} imgColorDir '/img_'  num2str(gtIdx) '.bmp']); %color map
        D   =imread([dataSetDir  dataSetFnm{1,setNum} imgDepthDir '/depth_' num2str(gtIdx) '.bmp']); %depth map
        BGC =imread([dataSetDir  dataSetFnm{1,setNum} 'Color/' method '/bgc' num2str(gtIdx) '.bmp']); %bg by color
        BGD =imread([dataSetDir  dataSetFnm{1,setNum} 'Depth/' method '/bgd'    num2str(gtIdx) '.bmp']); %bg by depth        
        FGC =imread([dataSetDir  dataSetFnm{1,setNum} 'Color/' method '/fgc'  num2str(gtIdx) '.bmp']); %fg by color
        FGD =imread([dataSetDir  dataSetFnm{1,setNum} 'Depth/' method '/fgd'   num2str(gtIdx) '.bmp']); %fg by depth
        MASK=imread([dataSetDir  dataSetFnm{1,setNum} imgGtDir                            'gt_BW.bmp']); %mask
        GT  =imread([dataSetDir  dataSetFnm{1,setNum} imgGtDir    'gt_'    num2str(gtIdx) 'BW.bmp']); %ground truth
        
        if(~isa(FGC,'logical')),FGC=im2bw(FGC);end
        if(~isa(FGD,'logical')),FGD=im2bw(FGD);end
        if(~isa(GT,'logical')), GT=im2bw(GT);  end
        if(~isa(MASK,'logical')),MASK=im2bw(MASK);end

        %nmm
        if(ndims(D)==3),D_=rgb2gray(D);else D_=D; end
        Db=(D_>0);
        MASK = MASK&Db;
        tstart = tic;
        %calculate features
        %luv ftrs-1~3
        C_luv=rgbConvert(C,'luv');
        t1 = toc(tstart);
        %luv-luv 4~6
        BGC_luv=rgbConvert(BGC,'luv'); %luv toc
        diff_luv=abs(C_luv-BGC_luv);
        t2 = toc(tstart);
        % ftrs-7
        if(ndims(D)==3) 
            diff_depth=rgb2gray(abs(double(D) - double(BGD))./255);
        else
            BGD=rgb2gray(BGD);
            diff_depth=abs(double(D) - double(BGD))./255;
        end
        t3 = toc(tstart);
        % ftrs-8       % ftrs-9
        
        C_gray = rgb2gray(C);
        EC = imgradient(C_gray);
        t4 = toc(tstart);
        if(ndims(D)==3)    D_gray=im2double(rgb2gray(D));
        else               D_gray=im2double(D);       
        end
        ED = imgradient(D_gray);
        t5 = toc(tstart);
        % features and lable
        FGC=FGC&MASK;
        FGD=FGD&MASK;
        CandD = FGC&FGD;
        CorD = FGC|FGD;
        uncertain_C = FGC-CandD;
        uncertain_D = FGD-CandD;
        
        [yC,xC]=find(uncertain_C);
        ftrsC=zeros(length(yC),ftrsCnt,'single');
        labelsGtC=zeros(length(yC),1,'single');
    

        [yD,xD]=find(uncertain_D);
        ftrsD=zeros(length(yD),ftrsCnt,'single');     
        labelsGtD=zeros(length(yD),1,'single');
  
        [ftrsC_, ftrsD_]=combineFtrs(double(C_luv),double(diff_luv),double(diff_depth),EC,ED,[yC,xC],[yD,xD]);
        ftrsC_=single(ftrsC_);  ftrsD_ = single(ftrsD_);

        result=CandD;
    % testing and refine
        if(~isempty(ftrsC_))
            [labelC,ps] = forestApply( ftrsC_, forestC, maxDepth_C, 8, 0 );    
            labelC=labelC-1;
            accuracy = (100-100*symerr(labelC,double(labelsGtC))/length(labelC));
           % disp('forestC test accuracy:');disp(accuracy);
            for i=1:length(labelC)
                if labelC(i)==1, result(yC(i),xC(i))=1;end
            end
        end
 
     if(~isempty(ftrsD_))
        [labelD,ps] = forestApply( ftrsD_, forestD, maxDepth_D, 8, 0 );
        labelD=labelD-1;
        accuracy = (100-100*symerr(labelD,double(labelsGtD))/length(labelD));
       % disp('forestD test accuracy:');disp(accuracy);
        for i=1:length(labelD)
            if labelD(i)==1, result(yD(i),xD(i))=1;end
        end
     end
    t6 = toc(tstart);
    timeIndex = timeIndex + 1;
    refineTime(timeIndex,:) = [t1 t2 t3 t4 t5 t6];
    % save results
    resultDirtmp = [resultDir dataSetFnm{1,setNum} method '/' ];
    if(~exist(resultDirtmp,'dir')), mkdir(resultDirtmp); end
    imwrite(result,[ resultDirtmp 'result' num2str(gtIdx) '.bmp']);
end
z = refineTime;
end




