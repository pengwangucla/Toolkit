function mappings = GetJointLabelMapping(VOCPart)

clsnum = length(VOCPart.classes); 
mappings = repmat(struct('pid', [], 'Parts', []), [1,clsnum]);  
cur_id = 0; 
for icls = 1:clsnum 
    ClsName = VOCPart.classes{icls}; 
    temp = Cls2Part(ClsName); 
    mappings(icls).pid = cur_id + 1:cur_id + length(temp.Parts); 
    mappings(icls).Parts = temp.Parts; 
    cur_id = cur_id + length(temp.Parts); 
end