function opt =  ShowImageset(imgs, option)
%SHOWIMAGES Summary of this function goes here
%   Detailed explanation goes here
if strcmp(imgs,'param')
    opt.NumEach = 100;
    opt.pages = 10;
    return;
end

if ~strcmp(class(imgs),'cell')
    [height,width,num] = size(imgs);
    imgs = mat2cell(imgs,height,width,ones(1, num));
    imgs = reshape(imgs,num,1);
end
imgnum = length(imgs);
NumEach = option.NumEach;
colnum = round (sqrt(NumEach));
rownum = ceil(NumEach/colnum);

pages = min(option.pages, ceil(numel(imgs)/NumEach));
over = 0;
for ipage = 1:pages
    figure;
    for iimg = 1:NumEach
        if iimg > imgnum
            over = 1;
            break;
        end
        axes('Position',[mod(iimg-1,rownum)/colnum, ...,
            1-(floor((iimg-1)/colnum)+1)/rownum,0.9/colnum,0.9/rownum]); % left top width height
        imshow(imgs{iimg});
        axis off;
    end
    if over 
        break;
    end
    
end

