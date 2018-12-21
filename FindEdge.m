v=VideoReader('edgemove.avi');

frames=zeros(v.Height,v.Width,v.NumberOfFrames);
%frames=cell(1,v.NumberOfFrames);

for i=1:v.NumberOfFrames
    frames(:,:,i)=rgb2gray(im2double(read(v,i)));
end

%perform texture segmentation with gabor filter bank
angle=45:45:180;
%wavelength defined in pixels/cycle
wL=5:5:20;
gaborBank=gabor(wL,angle);

yfront=zeros(size(frames,3));

for i=1:size(frames,3)
    test=frames(:,:,i);   
    gaborMag=imgaborfilt(test,gaborBank);
    gaborMagNet=sum(gaborMag,3);
    %scale intensity [0,1]
    gaborMagNet=gaborMagNet/(max(max(gaborMagNet)));
    %binarize image to identify cell bodies
    cells=imbinarize(gaborMagNet);
    %find largest connected component==biofilm wavefront
    comp=bwconncomp(cells);
    numPixels=cellfun(@numel,comp.PixelIdxList);
    [~,idx]=max(numPixels);
    %create mask to exclude smaller components
    mask=zeros(size(cells));
    mask(comp.PixelIdxList{idx})=1;
    cells=cells.*mask;
    %close to connect small gaps
    cells=imclose(cells,strel('square',10));
    %find image boundary Sobel,Prewitt,Roberts,zc,or Canny?
    [front,~,Gv,Gh]=edge(cells,'Sobel');
    %exclude statistically
    %1) find mean, and sd
    %2) remove any edge pixels that are outliers
    %3) compute ybar of pixels in neighborhood around new max
    [x,y]=ind2sub([size(front,1),size(front,2)],find(front));
    ybar=mean(y);
    ystd=std(y);
    x(y>ybar+1.96*ystd)=[];
    y(y>ybar+1.96*ystd)=[];
    maxY=max(y);
    yfront(i)=mean(y(y>(maxY-25) & y<(maxY+25)));
end

%%
for i=1:size(frames,3)
    imshow(frames(:,:,i));
    line([yfront(i),yfront(i)],[0,size(frames,2)],...
        'Color','blue','LineWidth',1)
    %pause(0.5)
    F(i)=getframe(gcf);
    drawnow
end

writerObj=VideoWriter('edgemoveAnnotated.avi');
writerObj.FrameRate=1;

open(writerObj);
for i=1:length(F)
    frame=F(i);
    writeVideo(writerObj,frame);
end
close(writerObj);
    

