
%%
addpath('../trainval'); 

% Intuitively mapping parts to 
DataPath = '../trainval/';
%ImgPath = [ '../../Data/VOC/VOCdevkit/VOC2012/JPEGImages/'];
%AnnoPath = [DataPath, '/Annotations_Part/'];
ImgPath = './example/JPEGImage/'; 
AnnoPath = './example/Annotations/'; 

cmap = VOClabelcolormap();
pimap = part2ind_grp();    % part index mapping,  first mapping to several general structures 

imgsNames = MDir(ImgPath, 'c'); 
% imgsNames = textread('./ImageSets/part_train.txt','%s\n'); 
imgNum = length(imgsNames); 

% for certain class 
% get image and first mapping parts into certain defined parts labels.  
VOCPart = LoadPascalPart(); 

%% 
mappings =  GetJointLabelMapping(VOCPart); % cls to part id mapping 

for iimg = 1:imgNum
     
    CountID(iimg, imgNum, 100, 'Image:'); 
    imname = imgsNames{iimg};
    
    img = imread([ImgPath, '/', imname, '.jpg']);
    
    % load annotation -- anno
    load([AnnoPath, imname, '.mat'], 'anno');
    
    [partsMask, instbox]  = GenPartMask(anno, anno.objects(1).mask, pimap,VOCPart.obj_id, mappings);  % 
    if isempty(partsMask); continue; end
    
    rectimg = DrawRectOnImage(img, instbox(:, [2,1,4,3]), 'r'); 
    subplot_tight(1,2,1); imshow(rectimg); 
    subplot_tight(1,2,2); imshow(uint8(partsMask), cmap);
    pause;
    
end


