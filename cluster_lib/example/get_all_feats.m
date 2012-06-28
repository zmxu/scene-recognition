%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% cluster_lib      Matlab library for cluster processing
%% Author: Lubomir Bourdev   lbourdev@eecs.berkeley.edu     Jan 30, 2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% An example of an operation to do on the clusters. To make your own just
% copy from here and modify. Each operation must be in a separate file.

% Computes the powers of a set of numbers.
function handles=get_all_feats
    % Leave these unchanged
    handles.do_job       = @do_job;
    handles.collect_jobs = @collect_jobs;
end
    
% Invoked multiple times for different sets of elements. It performs the operation and saves results to
% separate file. The operation is performed for elements in the range [first_el, last_el]
%    first_el, last_el -> specifies the range of elements to work on.
%    usr_data -> a string containing any user-specified parameters. To pass
%                large parameters, save them to file and pass the file names.
%    output -> Return the results. You can return a struct of multiple elements.
%              If you return [] for all calls to do_job, collect_jobs will not be called 
%function output = do_job(first_el,last_el,usrdata_job)
%   pow = str2num(usrdata_job);  
%   for i=first_el:last_el
%      output(i-first_el+1) = power(i,pow);
%   end
function output = do_job(first_el, last_el, param_file)
addpath(genpath('/work/bharath2/highlight_code'));
addpath('/work/bharath2/imtoolbox');
detection_config;
load(param_file);
numfeats=0;
for k=first_el:last_el
    numfeats=numfeats+sum(imindices==k);
end
feats=zeros(numfeats, numel(Ws));
y=zeros(numfeats, 1);
cnt=0;
for k=first_el:last_el
    ucm=load(sprintf(ucmpath, iids{k}));
    lubo_id=find(strcmp(im.stem, iids{k}));
    ind=find(train_hits.image_id==lubo_id);
    hits_img=train_hits.select(ind);
    r_ind_img=r_indices(imindices==k);
    c_ind_img=c_indices(imindices==k);
    for l=1:numel(Ws)
        ind=find(hits_img.poselet_id==l);
        if(isempty(ind))
            continue;
        end;
        hits_poselet=hits_img.select(ind);
        ucmrewtd = reweight_ucm(hits_poselet, Ws, ucm.ucm);
        feats_poselet=diag(ucmrewtd(r_ind_img,c_ind_img));
        feats(cnt+1:cnt+length(r_ind_img),l)=feats_poselet;
    end
    y(cnt+1:cnt+length(r_ind_img))=labels(imindices==k);
    cnt=cnt+length(r_ind_img);
end
save(sprintf('/work/bharath2/feats/%d.mat',last_el), 'feats', 'y');

output=0;
end




% Invoked once after all jobs have completed. Use
% it to merge the data into a single file.
%    job_outputs -> job_outputs{i}.elements_range is the range of
%                  elements processed by job i 
%                  job_outputs{i}.output is the job output
%    usr_data -> a string containing any user-specified parameters. To pass
%                large parameters, pass their file names in this string.
%    output -> Return the results of combination. You can return a struct of multiple elements
function output = collect_jobs(job_outputs,ranges,usr_data)
output=0;

end

% handles.dont_load_jobs_in_collect = true; 
%   If this is set, collect_jobs will receive filenames of the jobs instead of the loaded
%   jobs. Do this if the jobs are too large to fit all in memory
