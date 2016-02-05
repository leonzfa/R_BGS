function z = postProcessing(setNum,opts)

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
resultDir   = opts.resultDir;
postResultDir = opts.postResultDir;

% % bgsColorDir = opts.bgsColor;
% % bgsDepthDir = opts.bgsDepth;
% % imgColorDir = opts.imgColor;
% % imgDepthDir = opts.imgDepth;
imgGtDir    = opts.imgGt;

% % sampleDir =opts.sampleDir ;
% % ftrsDir  = opts.ftrsDir;
% % modelDir = opts.modelDir;

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


for gtIdx = gtNum{setNum}(1:end)
    resultDirtmp = [resultDir dataSetFnm{1,setNum} ];
    result=imread([resultDirtmp 'result' num2str(gtIdx) '.bmp']);% before post-processing
%     if setNum == 3
        se = strel('rectangle',[3 3]);
        result = imclose(result,se);
        result = imopen(result,se);
%     end
    bw2 = bwareaopen(result,50);
    resultDirtmp = [postResultDir dataSetFnm{1,setNum} ];
    if(~exist(resultDirtmp,'dir')), mkdir(resultDirtmp); end
    imwrite(bw2,[ resultDirtmp 'result' num2str(gtIdx) '.bmp']);
end
z = 1;
end
