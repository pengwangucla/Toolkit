function [ap, confcounts] =  EvaluateIOU(predset, gtset, opt);
% predset:  nx1 cell for predicted file names
% gtset: nx1 cell of ground truth file names
% opt: several options 

if ~exist('opt','var')
    opt = [];
end

if isempty(opt) | strcmp(predset,'para')
    ap.savepath = './IOUres'; % 
    ap.saveflag = 1;
    ap.jumpNonExist = 1;
    ap.autoResize = 1;
    ap.cropboarder = 0; % whether there is non useful boarder 
    ap.omitRangeOut = 1; 
    ap.addedBkg = 0; 
    ap.countZero = 0; 
    ap.globalFg = 0; 
    ap.rm_class = []; 
    ap.shift = 0; % this is due to a save error 
    ap.vis = 0; 
    if  strcmp(predset,'para'); return;
    else       opt = ap;   end
end

% pred set is the img set
% gt set is the gt set

num = numel(opt.categories)+1;
if opt.addedBkg; num = numel(opt.categories); end ;
if isfield(opt, 'EvalRange'); 
    num = max(opt.EvalRange) + 1; 
end

assert(length(predset) == length(gtset));
testnum = length(predset);
confcounts = zeros(num);
count=0;
evaluedImgnum = 0;
% if isfield(opt,'rm_class'); opt.categories(rm_class) = []; end 

for i=1:testnum
    % display progress
    CountID(i, testnum, 1000, 'Test Image');
    
    imname = predset{i};
    gtname = gtset{i};
    if opt.jumpNonExist 
        if ~exist(imname,'file');         continue;        end
    end
    
    [resim, ~] = imread(imname);
    [gtim, ~] = imread(gtname); 
    
    if opt.cropboarder; gtim = cropPadding(gtim, opt.padSize); end 
    if opt.shift; resim = resim + 1; end 
    
    resim = double(resim);
    gtim = double(gtim);
    if opt.globalFg; resim = resim > 0; gtim = gtim> 0;
    else
        if ~isempty(opt.rm_class);
            for irm = 1:length(opt.rm_class)
                gtim(gtim == opt.rm_class(irm)) = 0; resim(resim == opt.rm_class(irm)) = 0;
            end
            if sum(gtim(:)) == 0; continue; end 
        end
    end
    
    % visualize here
    if opt.vis
        if ~isfield(opt, 'cmap'); opt.cmap = VOClabelcolormap(); end 
        subplot_tight(1,2,1); imshow(resim, opt.cmap);
        subplot_tight(1,2,2); imshow(gtim, opt.cmap);
        pause;
    end
    
    % diffim = (gtim ~= resim);
    % diffim(diffim~=0) = 10;
    % allim = uint8([gtim, resim, double(diffim)]);
    % imwrite(allim, map, fullfile(vfld, [imname, '.png']) );
    
    % Check validity of results image
    if isfield(opt, 'categories');
        maxlabel = max(resim(:));
        if (maxlabel>num-1),
            if opt.omitRangeOut; resim(resim > num-1) = 0;
            else    error('Results image ''%s'' has out of range value %d (the value should be <= %d)',imname,maxlabel, num-1 );
            end
        end
        
        szgtim = size(gtim); 
        szresim = size(resim); 
        if any(szgtim~=szresim)
            if opt.autoResize;  resim = imresize(resim, szgtim,'nearest');  
            else error('Results image ''%s'' is the wrong size, was %d x %d, should be %d x %d.',imname,szresim(1),szresim(2),szgtim(1),szgtim(2));
            end
        end
        
        %pixel locations to include in computation
        %locs = gtim <= numel(broswer.categories);
        locs = (gtim <= num-1); 
    end
    
    if find(locs == 0); 
        disp('r')
    end 
    
    %joint histogram 
    sumim = 1+gtim+resim*num;
    hs = histc(sumim(locs),1:num*num);
    count = count + numel(find(locs));
    confcounts(:) = confcounts(:) + hs(:);
    evaluedImgnum  = evaluedImgnum  + 1;
end

fprintf('Evaluated Image number: %d \n', evaluedImgnum);
if max(confcounts(:)) == 0; error('no image is available for evaluation : < \n'); end 

% confusion matrix - row index is true label, col is inferred label
% conf = zeros(num);
% This is recall
% confcounts = confcounts(2:end, 2:end);
conf = 100*confcounts./repmat(1E-20+sum(confcounts,2),[1 size(confcounts,2)]);
rawcounts = confcounts; 

if isfield(opt,'EvalRange'); confcounts = confcounts(opt.EvalRange+1, opt.EvalRange+1);  end 

% Percentage correct labels measure is no longer being used.  Uncomment if
% you wish to see it anyway

if opt.saveflag
    fid = fopen( [opt.savepath '.txt'], 'w' );
end

overall_acc = 100*sum(diag(confcounts)) / sum(confcounts(:));
fprintf('Percentage of pixels correctly labelled overall: %6.3f%%\n',overall_acc);
if opt.saveflag
    fprintf(fid, 'Percentage of pixels correctly labelled overall: %6.3f%%\n',overall_acc);
end

accuracies = zeros( numel( opt.categories ), 1);
accuraciesp = zeros( numel( opt.categories ), 1);
IOU = zeros( numel( opt.categories ), 1);
fprintf('Accuracy for each class (intersection/union measure)\n');
for j=1:size(confcounts,1);
    gtj=sum(confcounts(j,:));
    resj=sum(confcounts(:,j));
    gtjresj=confcounts(j,j);
    
    % The accuracy is: true positive / (true positive + false positive + false negative)
    % which is equivalent to the following percentage:
    % accuracies(j)=100*gtjresj/(gtj+resj-gtjresj+eps);
    accuracies(j)=100*gtjresj/(gtj+eps);
    accuraciesp(j)=100*gtjresj/(resj+eps);
    IOU(j) = 100*gtjresj/(gtj+resj-gtjresj+eps);
    clname = opt.categories{j};
    fprintf('  %15s: R %6.3f%% P %6.3f%% IOU %6.3f%%\n',...,
        clname,accuracies(j),accuraciesp(j), IOU(j));
    
    if opt.saveflag
        fprintf(fid, '%15s: R %6.3f%% P %6.3f%% IOU %6.3f%%\n',...,
            clname,accuracies(j),accuraciesp(j), IOU(j));
    end
end

accMeanInd = accuracies>=0;
accpMeanInd = accuraciesp >= 0;
IOUMeanInd = IOU >= 0;

if ~opt.countZero
accMeanInd = accuracies>0;
accpMeanInd = accuraciesp > 0;
IOUMeanInd = IOU > 0;
end

avacc = mean(accuracies(accMeanInd));
avaccp = mean(accuraciesp(accpMeanInd));
accIOU = mean(IOU(IOUMeanInd));
FM = 2*(avacc*avaccp)/(avacc+avaccp);
fprintf('-------------------------\n');
fprintf('Average accuracy: recall: %6.2f%% precision: %6.2f%% F-m: %6.2f IOU: %6.2f%%\n',...,
    avacc,avaccp,FM,accIOU);

if opt.saveflag
fprintf(fid, '-------------------------\n');
fprintf(fid,'Average accuracy: recall: %6.3f%% precision: %6.3f%% F-m: %6.3f  IOU: %6.3f%%\n',...,
    avacc,avaccp,FM,accIOU);
fclose(fid);
end

ap.recall = avacc;
ap.prec = avaccp;
ap.F = FM;
ap.pixAcc = overall_acc; 
ap.mIOU = accIOU;
ap.IOU = IOU; 



end
