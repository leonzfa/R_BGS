clc


% some dir
opts.imageDir = 'images/';          % 
opts.imageFnm = {'ColCamSeq/','GenSeq/','ShSeq/','Wall/'};        % dataset name
opts.bgsColor = 'Color/MOG/';
opts.bgsDepth = 'Depth/MOG/';
opts.imgColor = 'Color/';
opts.imgDepth = 'Depth/';
opts.imgGt    = 'GroundTruth/';

opts.sampleDir  = 'sample/';
opts.ftrsDir    = 'ftrs/';
opts.modelDir   = 'model/';

ftrs = ftrExtr(opts);
0
