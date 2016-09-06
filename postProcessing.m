function z = postProcessing(setNum,opts)


dataSetDir  = opts.imageDir;
dataSetFnm  = opts.imageFnm;
resultDir   = opts.resultDir;
postResultDir = opts.postResultDir;
imgGtDir    = opts.imgGt;
method      = opts.method;

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


for gtIdx = gtNum{setNum}(1:end)
    resultDirtmp = [resultDir dataSetFnm{1,setNum} method '/'];
    result=imread([resultDirtmp 'result' num2str(gtIdx) '.bmp']);% before post-processing
    se = strel('rectangle',[3 3]);    
    result = imclose(result,se);
    result = imopen(result,se);
    bw2 = bwareaopen(result,50);
    resultDirtmp = [postResultDir dataSetFnm{1,setNum} method '/'];
    if(~exist(resultDirtmp,'dir')), mkdir(resultDirtmp); end
    imwrite(bw2,[ resultDirtmp 'result' num2str(gtIdx) '.bmp']);
end
z = 1;
end
