
function [partsMask, instbox, varargout] = GenPartMask(anno, img, pimap, objID_all, mappings)
% instbox: l top, left, down , right
    [cls_mask, inst_mask, part_mask] = mat2map(anno, img, pimap); 
    class = unique(cls_mask(:)); 
    [~,~,id] =  intersect(class, objID_all, 'stable'); % object id exist in the image 
    if isempty(id); partsMask = zeros(size(part_mask),'single'); 
        partsMask = []; 
        instbox = []; 
        return; 
    end 
    
    cls_mask = Map2ID(cls_mask, objID_all, id);
    partsMask = Mappnig2JointLabel(cls_mask, part_mask, mappings); % map cls mask find the part slots and put the label in
    inst_mask(cls_mask == 0) = 0; 
    instbox = GetInstBox(inst_mask); 
    if nargin > 2
        varargout{1} = cls_mask;
        varargout{2} = inst_mask;
    end
end

function cls_mask2 = Map2ID(cls_mask, objID, id) 

cls_mask2 = zeros(size(cls_mask), 'uint8');  
for iclass = id'
    cls_mask2(cls_mask == objID(iclass)) = iclass; % turn the cls map into current lable sets 
end 

end

function partMask = Mappnig2JointLabel(cls_mask, part_mask, mappings)

clsID = unique(cls_mask); clsID(clsID == 0) = []; 
partMask = zeros(size(cls_mask), 'uint8'); 

for icls = 1:length(clsID)
    cls_id = clsID(icls); 
    obj_mask = cls_mask == cls_id ;
    
    partMap = zeros(size(obj_mask), 'uint8') ;
    partMap(obj_mask) = part_mask(obj_mask); 
    
    partID = unique(part_mask(obj_mask)); partID(partID == 0) = [];
    
    
    if (sum(partID > length(mappings(cls_id).pid)) > 0)
        partID(partID  > length(mappings(cls_id).pid)) = []; 
    end
    
    for ipart = 1:length(partID);
        prt_id = partID(ipart); 
        partMask(partMap == prt_id) = mappings(cls_id).pid(prt_id); 
    end
end
end

function instbox = GetInstBox(inst_mask); 
inst = unique(inst_mask); 
inst(inst == 0) = []; 
instnum = max(inst); 
instbox = zeros(instnum, 4); 
for iinst = 1:length(inst)
    mask = inst_mask == inst(iinst); 
    instbox(iinst, :) = region2box(mask); 
end
end
