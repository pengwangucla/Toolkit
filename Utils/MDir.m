function mnames = MDir(SourcePath,type,append,ristrict)
%return the char filename or struct group 
%Please add '/' after the sourcepath
% type has 'c' or 's'
if ~exist('ristrict','var')
    ristrict = 0;
end

mnames = [];
if SourcePath(end) ~= '/'
    SourcePath = [SourcePath,'/'];
end

if ~exist('append','var')
    append = [];
end

if ~exist('type','var') || isempty(type)
    type = 'c';
end

folderselect = 0;
if strcmp(append,'folder')
    folderselect = 1;
    Filenames = dir(SourcePath);
    Filenames(1:2) = [];
else
    if ristrict
        Filenames = dir([SourcePath, append]);
    else
        Filenames = dir([SourcePath,'*', append]);
    end
end

switch type
    case 'c'
        mnames = cell(length(Filenames),1);
        if folderselect        
            ifold = 1;
            for i = 1:length(Filenames)
                if isdir([SourcePath,Filenames(i).name])
                    mnames{ifold} = Filenames(i).name;
                    ifold = ifold + 1;
                end
            end
            mnames = mnames(~cellfun('isempty',mnames));
        else            
            for i = 1:length(Filenames)
                mnames{i} = Filenames(i).name;
            end
            if isempty(append)
                mnames(1:2) = [];
            end
        end
    case 's'
        mnames = Filenames;
end
    
end