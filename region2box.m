function bbox = region2box(mask, varargin)

opt.padding = 0; 
opt = CatVarargin(opt, varargin);
if min(size(mask)) == 1
    mask2 = false(opt.sz);
    mask2(mask) = 1;
    mask = mask2; clear mask2;
end
padding = opt.padding; 

[height,width, dim] = size(mask);
bbox = zeros(dim, 4,'single');

for imask = 1:dim
    tempmask = mask(:,:,imask);
    ind = find(tempmask(:));
    [indy,indx] = ind2sub([height,width],ind);
    bbox(imask,:) = getbox([indy,indx]);
    if padding > 0
        bbox(imask,1:2) = max(bbox(imask,1:2)-padding, 1);
        bbox(imask,3:4) = bbox(imask,3:4)+padding;
        bbox(imask,3) = min(height, bbox(imask,3));
        bbox(imask,4) = min(width, bbox(imask,4));
    end
end

end

function box = getbox(pos)
% minrow mincol maxrow maxcol top, left, down , right
box = [min(pos(:,1)),min(pos(:,2)),max(pos(:,1)),max(pos(:,2))];
end
