# R_BGS
A refinement framework for background subtration based on color and depth data

-----------------------------------------------
First, you need to install two toolboxes and add them to the Matlab's path.
1. Piotr's Matlab Toolbox
It's availabel on http://vision.ucsd.edu/~pdollar/toolbox/doc/
Or https://github.com/pdollar/toolbox
2. Structured Edge Detection Toolbox
It's availabel on https://github.com/pdollar/edges

Then, you need to copy the forest model "modelBsds.mat" in Structured Edge Detection Toolbox to
"edgeModels\forest\".


-----------------------------------------------
Run the rbgsDemo.m to calculate the performance.
--If you want to re-extract the features, set reExtract = 1.
--If you want to re-train the forest, set reTrain = 1.
--If you want to re-calculate the results(foreground), set reRefine = 1.
--If you want to draw the histogram of the features, set drawHistogram = 1.

-----------------------------------------------
imageDir = 'images/';
imageFnm = {'ColCamSeq/','GenSeq/','ShSeq/','Wall/'}. i = 1,2,3,4
--Foreground results and background results based on color are in [imageDir imageFnm{1,i} 'Color/MOG/'] and [imageFnm 'Color/FuzzySOM/'].
--Foreground results and background results based on Depth are in [imageDir imageFnm{i,i} 'Depth/MOG/'] and [imageFnm 'Depth/FuzzySOM/'].
--Color data are in [imageFnm 'Color/'].
--Depth data are in [imageFnm 'Depth/'].
--Groundtruth data are in [imageFnm 'GroundTruth/'].

In order to run our demo, you need to prepare these five kinds of data. But since the dataset are not opened by the oringal author, we encourage readers to ask for the datasets and use BGS on these datasets.

Enjoy!
