function [ rectimage ] = DrawRectOnImage(image,rectall,colorChoseall, option)
%DRAWRECTONIMAGE Summary of this function goes here
%   Detailed explanation goes here
%    rect: nx4 matrix left, up, right, bottom
warning off;

if size(image,3) == 1
    for icolor = 1:3
        image = repmat(image,[1,1,3]);
    end
end

rectimage = im2double(image);
if ~exist('colorChoseall','var')
    colorChoseall = 'r';
end
if ~exist('option','var')
    option.randperterb = 1;
end

if option.randperterb 
    pixlen = 3;
    randmatrix = floor((rand(size(rectall))-0.5)*2*pixlen);
    rectall = rectall + randmatrix;
end

for irect = 1:size(rectall,1)
    
    if ischar(colorChoseall)
        colorChose = colorChoseall;
    elseif iscell(colorChoseall)
        colorChose = colorChoseall{irect};
    elseif isnumeric(colorChoseall) && size(colorChoseall,1) == 1
        colorChose = colorChoseall;
    else
        colorChose = colorChoseall(irect,:);
    end
    
    rect = rectall(irect,:);
    if size(rect,2) == 4
        rect = reshape(rect,[2,2]);
    end
    
    rect(:) = max(rect(:),1);
    
    [height,width,dim] = size(image);
    if dim == 1
        image = repmat(image,[1,1,3]);
    end
    
    rect(1,2) = min(rect(1,2),width);
    rect(2,2) = min(rect(2,2),height);
    
    k = 1;
    
    channel = rectimage;
    tempcolor = zeros(size(channel));
    
    if ischar(colorChose)
    switch colorChose
        case 'r'
            tempcolor(:,:,1) = 1;
        case 'b'
            tempcolor(:,:,3) = 1;
        case 'g'
            tempcolor(:,:,2) = 1;
        case 'y'
            tempcolor(:,:,1) = 1;
            tempcolor(:,:,2) = 1;
        case 'k'
            
    end
    else
        for icolor = 1:3
            tempcolor(:,:,icolor) = colorChose(icolor);
        end
    end
    starth = max(1,rect(1,1)-k*3/2);
    slot(1) = max(1,rect(1,1)-k*1/2);
    slot(2) = min(width,rect(1,1)+k*1/2);
    endh = min(width,rect(1,1)+k*3/2);
    channel(rect(2,1):rect(2,2),starth:slot(1), :) = 1;
    channel(rect(2,1):rect(2,2),slot(2):endh, :) = 1;
    channel(rect(2,1):rect(2,2),slot(1):slot(2),:) = tempcolor(rect(2,1):rect(2,2),slot(1):slot(2),:);
    
    
    starth = max(1,rect(1,2)-k*3/2);
    slot(1) = max(1,rect(1,2)-k*1/2);
    slot(2) = min(width,rect(1,2)+k*1/2);
    endh = min(width,rect(1,2)+k*3/2);
    channel(rect(2,1):rect(2,2),starth:slot(1), :) = 1;
    channel(rect(2,1):rect(2,2),slot(2):endh, :) = 1;
    channel(rect(2,1):rect(2,2),slot(1):slot(2), :) = tempcolor(rect(2,1):rect(2,2),slot(1):slot(2),:);
    
    startv = max(1,rect(2,1)-k*3/2);
    slot(1) = max(1,rect(2,1)-k*1/2);
    slot(2) = min(height,rect(2,1)+k*1/2);
    endv = min(height,rect(2,1)+k*3/2);
    channel(startv:slot(1),rect(1,1):rect(1,2), :) = 1;
    channel(slot(2):endv,rect(1,1):rect(1,2), :) = 1;
    channel(slot(1):slot(2),rect(1,1):rect(1,2), :) = tempcolor(slot(1):slot(2),rect(1,1):rect(1,2), :);
    
    startv = max(1,rect(2,2)-k*3/2);
    slot(1) = max(1,rect(2,2)-k*1/2);
    slot(2) = min(height,rect(2,2)+k*1/2);
    endv = min(height,rect(2,2)+k*3/2);
    channel(startv:slot(1),rect(1,1):rect(1,2), :) = 1;
    channel(slot(2):endv,rect(1,1):rect(1,2), :) = 1;
    channel(slot(1):slot(2),rect(1,1):rect(1,2), :) = tempcolor(slot(1):slot(2),rect(1,1):rect(1,2), :);
    
    
    rectimage = channel;
    
end

