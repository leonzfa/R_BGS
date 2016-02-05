function z = drawHist(setNum,opts)

ftrsDir  = opts.ftrsDirNotAddSample;


load([ftrsDir 'features_color_positive' '-' num2str(setNum) '.mat']);
load([ftrsDir 'features_color_negative' '-' num2str(setNum) '.mat']);
load([ftrsDir 'features_depth_positive' '-' num2str(setNum) '.mat']);
load([ftrsDir 'features_depth_negative' '-' num2str(setNum) '.mat']);

x = 0;
for ftrNum = [4 8 7 9]
figure;
subplot(2,1,1);hist(features_color_positive(ftrNum,:),16); title('positive');
subplot(2,1,2);hist(features_color_negative(ftrNum,:),16); title('negative');
set(gcf,'Position',[400+x*280,400,240,180], 'color','w')

figure;
subplot(2,1,1);hist(features_depth_positive(ftrNum,:),16); title('positive');
subplot(2,1,2);hist(features_depth_negative(ftrNum,:),16); title('negative');
set(gcf,'Position',[400+x*280,100,240,180], 'color','w')
x = x + 1;
end
z = 1;
end
