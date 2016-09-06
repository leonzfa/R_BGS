function ftrs = ftrExtr(opts)
disp('ftrExtr');

dataSetDir  = opts.imageDir;
dataSetFnm  = opts.imageFnm;
bgsColorDir = opts.bgsColor;
bgsDepthDir = opts.bgsDepth;
imgColorDir = opts.imgColor;
imgDepthDir = opts.imgDepth;
imgGtDir    = opts.imgGt;
addSample   = opts.addSample;
sampleDir   = opts.sampleDir ;
method      = opts.method;

ftrsDirNotAddSample = opts.ftrsDirNotAddSample;
saveSamples = opts.saveSamples;

ftrsCnt=9; %
rd = 5;

% 获得GroundTruth的图片编号，从小到大的顺序
for i = 1:opts.dataSetNum
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

setNumList = 1:opts.dataSetNum;
% parfor setNum = setNumList  %
 for setNum = setNumList 
    tic;
    features_color_positive=[];
    features_color_negative=[];
    features_depth_positive=[];
    features_depth_negative=[];
    ftrsDir     = opts.ftrsDir;
    for gtIdx = gtNum{setNum}(1:end)
        %read images
         %read images        
        C   =imread([dataSetDir  dataSetFnm{1,setNum} imgColorDir '/img_'  num2str(gtIdx) '.bmp']); %color map
        D   =imread([dataSetDir  dataSetFnm{1,setNum} imgDepthDir '/depth_' num2str(gtIdx) '.bmp']); %depth map
        BGC =imread([dataSetDir  dataSetFnm{1,setNum} 'Color/' method '/bgc' num2str(gtIdx) '.bmp']); %bg by color
        BGD =imread([dataSetDir  dataSetFnm{1,setNum} 'Depth/' method '/bgd'    num2str(gtIdx) '.bmp']); %bg by depth

        FGC =imread([dataSetDir  dataSetFnm{1,setNum} 'Color/' method '/fgc'  num2str(gtIdx) '.bmp']); %fg by color
        FGD =imread([dataSetDir  dataSetFnm{1,setNum} 'Depth/' method '/fgd'   num2str(gtIdx) '.bmp']); %fg by depth

        GT  =imread([dataSetDir  dataSetFnm{1,setNum} imgGtDir    'gt_'    num2str(gtIdx) 'BW.bmp']); %ground truth
        MASK=imread([dataSetDir  dataSetFnm{1,setNum} imgGtDir                            'gt_BW.bmp']); %mask
                    
        if(~isa(FGC,'logical')),FGC=im2bw(FGC);   end
        if(~isa(FGD,'logical')),FGD=im2bw(FGD);   end
        if(~isa(GT,'logical')), GT=im2bw(GT);     end
        if(~isa(MASK,'logical')),MASK=im2bw(MASK);end

        %nmm
        if(ndims(D)==3),D_=rgb2gray(D);else D_=D; end
        Db=(D_>0);
        MASK = MASK&Db;

%% samples
        FGC=FGC&MASK;
        FGD=FGD&MASK;
        CandD = FGC&FGD;
        CorD = FGC|FGD;
        rectC = FGC-CandD;
        rectD = FGD-CandD;
        positiveC = (rectC&GT).*MASK;
        negativeC = (rectC&~GT).*MASK;
        positiveD = (rectD&GT).*MASK;
        negativeD = ((rectD&~GT).*MASK);     
        
        %save samples
        if(saveSamples)
        if(~exist([sampleDir dataSetFnm{1,setNum} method '/'],'dir')),
            mkdir([sampleDir dataSetFnm{1,setNum} method '/']); end
            imwrite(positiveC,[sampleDir dataSetFnm{1,setNum} method '/' '/positiveC-' num2str(gtIdx) '.bmp']);
            imwrite(negativeC,[sampleDir dataSetFnm{1,setNum} method '/' '/negativeC-' num2str(gtIdx) '.bmp']);
            imwrite(positiveD,[sampleDir dataSetFnm{1,setNum} method '/' '/positiveD-' num2str(gtIdx) '.bmp']);
            imwrite(negativeD,[sampleDir dataSetFnm{1,setNum} method '/' '/negativeD-' num2str(gtIdx) '.bmp']);
            imwrite(CandD,    [sampleDir dataSetFnm{1,setNum} method '/' '/CandD-'     num2str(gtIdx) '.bmp']);
        end
      
        for i=1:4
            if(i==1), [y,x]=find(positiveC);end
            if(i==2), [y,x]=find(negativeC);end
            if(i==3), [y,x]=find(positiveD);end
            if(i==4), [y,x]=find(negativeD);end
            if(addSample)
                if((sum(sum(negativeD))<sum(sum(positiveD))))  
                    sample_add=sum(sum(positiveD))-sum(sum(negativeD));
                    rect_new=MASK-CorD;
                    [ya,xa]=find(rect_new);
                    if(length(ya)<sample_add),sample_add=length(ya);end
                    rp=randperm(length(ya),sample_add);
                    ya=ya(rp);xa=xa(rp);
                    x=[x;xa];y=[y;ya];
                end
                if((sum(sum(positiveD))<sum(sum(negativeD))))  
                    sample_add=sum(sum(negativeD))-sum(sum(positiveD));
                    rect_new=CandD;
                    [ya,xa]=find(rect_new);
                    if(length(ya)<sample_add),sample_add=length(ya);end
                    rp=randperm(length(ya),sample_add);
                    ya=ya(rp);xa=xa(rp);
                    x=[x;xa];y=[y;ya];
                end            
            end
%% feature
        %calculate features
        C_luv=rgbConvert(C,'luv'); %luv 1-3
        BGC_luv=rgbConvert(BGC,'luv'); %luv
        diff_luv=abs(C_luv-BGC_luv);%luv-luv 4-6
        
        if(ndims(D)==3) 
            diff_depth=rgb2gray(abs(double(D) - double(BGD))./255);
        else
            if(ndims(BGD)==3) BGD=rgb2gray(BGD);end
            diff_depth=abs(double(D) - double(BGD))./255;
        end

        [EC ECd]= imgradient(rgb2gray(C));
        if(ndims(D)==3)
        D_gray=im2double(rgb2gray(D));
        else
        D_gray=im2double(D);
        end
        [ED EDd]= imgradient(D_gray);
        
        features=zeros(ftrsCnt,length(y),'single'); 
        [features ]=combineFtrs9(double(C_luv),double(diff_luv),double(diff_depth),EC,ED,[y,x]);
        features = single(features.');
            if(i==1), features_color_positive=[features_color_positive, features];end
            if(i==2), features_color_negative=[features_color_negative, features];end
            if(i==3), features_depth_positive=[features_depth_positive, features];end
            if(i==4), features_depth_negative=[features_depth_negative, features];end
        end   
        toc
    end
    if(~addSample) ftrsDir = ftrsDirNotAddSample;end
    ftrsDir = [ftrsDir  method '/'];
    if(~exist(ftrsDir,'dir')), mkdir(ftrsDir); end     
    savedone = saveresults(ftrsDir,setNum,features_color_positive,features_color_negative,features_depth_positive,features_depth_negative)
end
disp('features extract success!');
ftrs = 1;
end

function savedone = saveresults(ftrsDir,setNum,features_color_positive,features_color_negative,features_depth_positive,features_depth_negative)
    save([ftrsDir 'features_color_positive' '-' num2str(setNum) '.mat'],'features_color_positive','-v7.3');
    save([ftrsDir 'features_color_negative' '-' num2str(setNum) '.mat'],'features_color_negative','-v7.3');
    save([ftrsDir 'features_depth_positive' '-' num2str(setNum) '.mat'],'features_depth_positive','-v7.3');
    save([ftrsDir 'features_depth_negative' '-' num2str(setNum) '.mat'],'features_depth_negative','-v7.3');
    savedone = 1;
end