function bs_get_MEP(idir,iname,odir,oname,nrows)

% get MEP data compatible with Veta toolbox

% Ikko Kimura, Osaka University, 2020/06/08
% Ikko Kimura, 2020/07/16, modified a bit
% Ikko Kimura, 2020/08/30, no need to specify the number of headers

%%% TO DO
% multiple channels (e.g. line 19) can be determined automatically?

%%% 0. PARAMETERS
%idir='/home/ikimura/work/TBS_MRI/Test/sub-03';
%iname='20200605EMG.txt'; % input file name
%odir='/home/ikimura/work/TBS_MRI/Test/sub-03/EMG'; % output directory 
%oname='Session1.mat';
if nargin<5
    %nrows=39:639;
    nrows=40:639; % for channel1 right? 
    % if you used channel2 you heva to chnage this...
if nargin<4
    oname='MEP.mat';
if nargin<3
    odir=fullfile(idir,'EMG');
end
end
end

%%% 1. GET DATA
Data=readcell(fullfile(idir,iname),'Delimiter',{';','\t'});
%%% read data
disp('Reading data...')
flag=0;
for i=1:size(Data,1)
    % check the comment
    if contains(Data{i,1},'#')
        % if Sample Name is there, start reading
        if  strcmp(Data{i,1},'# Sample Name')
            flag=1;
        else
            flag=0;
        end
    else % no comment 
        % read only MEP things
        if flag==1
           t=Data{i,3};
           MEP{t,1}=t;
           %if strcmp(Data{i,33},'(null)')
           %MEP{t,2}=zeros(1,length(nrows));
           %else
           if ismissing(Data{i,nrows(1)})
           fprintf('data is missing in Trial #%s \n',num2str(t))
           MEP{t,2}=zeros(1,length(nrows));
           else
           MEP{t,2}=double(cell2mat(Data(i,nrows)));
           end
           Data_All(t,:)=Data(i,:);
        end
    end
end

%%%2. CONFIRMATION
a1=length(MEP);
a2=length(MEP{1,2});
if a2~=600 % the number of timepoints must be 600
    fprintf('something wrong with the time points \n')
    fprintf('current time points: %s \n',num2str(a2))
    fprintf('expected time points: 600 \n')
else
    disp('timepoints seemed to be nice')
end
fprintf('num of Session: %s \n',num2str(a1))

%%%3. CONVERT TO VETA FORMAT
disp('Converting to Veta format...')
trials=array2table(MEP,'VariableNames',{'sweep_num','ch1'});

parameters.EMG=0;
parameters.EMG_burst_channels=0;
parameters.MEP=1;
parameters.artchan_index=1;
parameters.MEP_channels=1;
parameters.CSP=0;
parameters.CSP_channels=0;
parameters.sampling_rate=3000;
parameters.num_channels=1;

subject.ID=0;
subject.handedness='r';
subject.sex='m';
subject.offset=0;

% save the data
fprintf('Saving the data to %s \n',odir)
%mkdir(fullfile(odir)) 
Data=Data_All;
save(fullfile(odir,'full_data.mat'),'Data','trials','parameters','subject')
save(fullfile(odir,oname),'trials','parameters','subject')
