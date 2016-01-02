function bbox = enlargeBox(bbox, szImg, times) 

c = [(bbox(:, 1)+bbox(:, 3) )/2, (bbox(:,2) + bbox(:,4))/2]; 
% padding to img aspect ratio 

sz = [bbox(:, 3)-bbox(:, 1), bbox(:,4)-bbox(:,2)]; 
sz = padding(sz, szImg(1)/szImg(2)); % height/width 
sz = sz *times; 

ind = sum(sz - repmat([szImg(2), szImg(1)], size(sz,1)) >=0, 2) > 0; 
sz(ind, :) = []; c(ind, :) = []; 
if isempty(sz); bbox = []; return;  end 

bbox = floor( [max(1, c(:,1)-sz(:,1)/2), ...,
    max(1,c(:,2)-sz(:,2)/2), ...,
    min(c(:,1)+sz(:,1)/2,szImg(2)), ...,
    min(c(:,2) + sz(:,2)/2, szImg(1)) ]); 

end 

function bboxsz = padding(bboxsz, asp) 
% width, height
ind = bboxsz(:,2)./bboxsz(:,1) > asp; 
% padding width 
bboxsz(ind,1) = bboxsz(ind,2)/asp; 

ind = bboxsz(:,2)./bboxsz(:,1) < asp; 
bboxsz(ind,2) = bboxsz(ind,1)*asp; 
end