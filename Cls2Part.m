function mapping = Cls2Part(ClasName)

switch ClasName,
        case 'cat'
            mapping.Parts = {'head',  'body', 'leg', 'tail'}; 
            
        case 'dog'
            mapping.Parts = {'head', 'body', 'leg', 'tail'};
           
        case 'cow'
            mapping.Parts = {'head',  'body', 'leg', 'tail'}; 
       
        case 'sheep'
            mapping.Parts = {'head', 'body',  'leg', 'tail'}; 
   
        case 'horse' 
            mapping.Parts = {'head',  'body', 'leg', 'tail'}; 
     
            
        case 'person' 
            mapping.Parts = {'head', 'body',  'arm', 'leg'}; 

        case 'bird' 
            mapping.Parts = {'head',  'body',  'wing',  'leg','tail'}; 

end
    
