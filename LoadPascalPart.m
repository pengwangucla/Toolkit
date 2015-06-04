function VOCPartopts = LoadPascalPart()

VOCPartopts.classes_all ={...
    'aeroplane'
    'bicycle'
    'bird'
    'boat'
    'bottle'
    'bus'
    'car'
    'cat'
    'chair'
    'cow'
    'diningtable'
    'dog'
    'horse'
    'motorbike'
    'person'
    'pottedplant'
    'sheep'
    'sofa'
    'train'
    'tvmonitor'};

VOCPartopts.classes = {'dog', 'cat', 'cow', 'horse', 'sheep', 'person', 'bird'}; 
[~,VOCPartopts.obj_id] = ismember(VOCPartopts.classes, VOCPartopts.classes_all);  % the object id of the evaluating object inside the original pascal labels. 
VOCPartopts.SemPartsNames = GenPartLabelList(VOCPartopts.classes); 

end

function SemParts = GenPartLabelList(cls)

SemParts = cell(1,1); 
ipart = 1; 
for icls = 1:length(cls)
    cls_name = cls{icls}; 
    mapping = Cls2Part(cls_name); 
    for ip = 1:length(mapping.Parts); 
        SemParts{ipart} = [cls_name, '_', mapping.Parts{ip}]; 
        ipart = ipart + 1; 
    end
end

end