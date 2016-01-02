function [imgSet, varargout] = localizeObj_v2(img, opt)
% Localize based on object instance in the image 

imgSet = cell(1,1); 

opt.area_thresh = 500; 

[height,width] = size(img(:,:,1));

% InpaintSmallSegs
switch opt.type
    case 'gt' 
        assert(isfield(opt, 'instMap'));  opt.instMap(opt.instMap == 255) = 0; 
        gtMap = opt.gtMap;
        opt.gtMap = opt.gtMap > 0;
        
        if size(opt.gtMap,1) ~= height | size(opt.gtMap,2) ~= width;
            opt.gtMap = imresize(opt.gtMap, [height,width], 'nearest');
        end
        gtMap_o = opt.gtMap;
        
        % se = strel('disk',5); 
        % opt.gtMap = imdilate(opt.gtMap, se); 

        regStr = regionprops(opt.gtMap, 'Area', 'BoundingBox', 'PixelIdxList'); 
        
        indrm = [regStr.Area] < opt.area_thresh; 
        regStr(indrm) = []; 
        bbox = zeros(length(regStr), 4); 
        ibox = 1;
        
        inst_labelled = []; 
        for isubimg = 1:length(regStr);  % for each large connected components 
            
            map = false(size(gtMap_o));
            instID = unique(opt.instMap(regStr(isubimg).PixelIdxList)); instID(instID == 0) = []; 
            
            id = ismember(instID, inst_labelled); instID(id) = []; 
            
            % include all the inst inside 
            for iinst = 1:length(instID)
                map(opt.instMap == instID(iinst)) = 1;
            end
            
            seg_str = GetStrFromMap(map);
            [bbox(ibox , :), imgSet{ibox}] = GetSubImg(img, seg_str);
            ibox = ibox + 1;
        end
        [bbox, id] = unique(bbox, 'rows');
        imgSet = imgSet(id);
        
    case 'inst'
        opt.instMap(opt.instMap == 255) = 0; 
        id = unique(opt.instMap); id(id == 0) = []; 
        bbox = zeros(length(id), 4); 
        imgSet = cell(length(id), 1); 
        ibox = 1;
        for iid = 1:length(id)
            instid = id(iid);
            map = opt.instMap == instid; 
            seg_str = GetStrFromMap(map);
            [bbox(ibox , :), imgSet{ibox}] = GetSubImg(img, seg_str);
            ibox = ibox + 1; 
        end
    case 'objProp'; 
        
end

if nargout > 0
    varargout{1} = bbox;
    
end

end

function str = GetStrFromMap(map)
% my region prop using bw 
str.PixelIdxList = find(map(:)); 
[r,c] = ind2sub(size(map), str.PixelIdxList ); 
cor = [min(c(:)), max(c(:)), min(r(:)), max(r(:))]; 
str.BoundingBox = [cor(1), cor(3), cor(2)-cor(1), cor(4)-cor(3)]; 

end

function [bbox, subimg] = GetSubImg(img, seg)

[height,width] = size(img(:,:,1)); 
bbox_tmp = floor([seg.BoundingBox(1:2), seg.BoundingBox(1:2) + seg.BoundingBox(3:4)]); % 1, 1, width, height. 
bbox_tmp = enlargeBox(bbox_tmp, [height,width], 1.3);
if isempty(bbox_tmp); 
    bbox = [1,1,width, height];
    subimg = img; 
    return; 
end
bbox = bbox_tmp;
subimg = img(bbox_tmp(2):bbox_tmp(4), bbox_tmp(1):bbox_tmp(3),:);
  
end