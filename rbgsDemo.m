clc
% if reTrain       = 1, start from features extraction, train forest
% if reRefine      = 1, use the forest to calculate new results
% if drawHistogram = 1, draw the histogram for features
reTrain       = 0;
reRefine      = 0;
drawHistogram = 0;

% some dir
opts.imageDir = 'images/'; % 
opts.imageFnm = {'ColCamSeq/','GenSeq/','ShSeq/','Wall/'};        % dataset name
opts.bgsColor = 'Color/MOG/';
opts.bgsDepth = 'Depth/MOG/';
opts.imgColor = 'Color/';
opts.imgDepth = 'Depth/';
opts.imgGt    = 'GroundTruth/';

opts.resultDir     = 'result/';
opts.postResultDir = 'post_result/';
opts.sampleDir  = 'sample/';
opts.ftrsDir    = 'ftrs/';
opts.ftrsDirNotAddSample = 'ftrs/notAddSample/';
opts.forestDir  = 'forest/';
opts.saveSamples= 1;
opts.addSample  = 1;

if(reTrain)
    % first extracting features
    % ftrs = ftrExtr(opts);
    % then train forest
    for setNum = [2 3]
        z = trainForest(setNum,opts);
    end
end
if(reRefine)
    % then use the forest to refine
    for setNum = [2 3]
        z = refineBGS(setNum,opts);
        z = postProcessing(setNum,opts);
    end
end
% analysis the methods in different datasets
for setNum = [2 3]
    if(setNum == 2)  dataset =  'GenSeq'; else dataset = 'ShSeq';end
    for method = 0:1;
        Z1 = analysis(setNum,method,opts);        
        if(method == 0)  bgs =  'MOG'; else bgs = 'FuzzyAdaptiveSOM';end
        disp([dataset '(' bgs '):']);
        if(method == 0)  
            disp('[GT&F/GT GT&F0/F0 GT&FC/FC  GT&FD/FD FGR&FC/FC FGR&FD/FD] = ');
            disp( Z1);
        else disp('[GT&F/GT GT&F0/F0 GT&FC/FC  GT&FD/FD ] = ');
            disp( Z1(1:4));
        end        
    end
end
% evaluate the methods in different datasets
for setNum = [2 3]
    method = 0;
    Z2 = evaluate(setNum,method,opts);
    if(setNum == 2)  dataset =  'GenSeq'; else dataset = 'ShSeq';end
    disp([dataset ':']);
    disp('[TE FN FP S] = ');
    disp( Z2);
end

% draw histogram for features;
if(drawHistogram)
    for setNum = [2 3]
        z = drawHist(setNum,opts);
    end
end
