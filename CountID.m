function CountID(i, totalnum, bin, str)
% output the progress
if ~exist('str','var')
    str = '';
end
if i == 1;    fprintf('%s %d / %d\n', str, i,totalnum); end

if mod(i,bin) == 0;
    fprintf('%s %d / %d\n', str, i,totalnum);
end
