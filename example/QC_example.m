% the example script to just to QC from the output of Brain Sight

% Ikko Kimura, Osaka University, 2022/09/15

%%% TODO
% readcell is only for R2019b or newer
% if large error was detected, remove that trial

clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% !!! MODIFY THIS PART !!!
subj='005';
DataDir='C:\work\TEST';
param.idir=fullfile(DataDir,'data');
param.iname=[subj,'_Date.txt']; % input file name(all of the variables must be read out)
%% output directory
param.odir=fullfile(DataDir,subj,'rTMS');
param.int=[50:250];

%%%0. PREP
mkdir(param.odir)
%%%1. PREPROCESSS 
bs_get_MEP(param.idir,param.iname,param.odir,'MEP.mat',1) % get emg data, this time I won't use MEP data, just data length 1 is enough
load(fullfile(param.odir,'full_data.mat'))
data=cell2mat(Data(param.int(1):param.int(end),[18 19 20]));
plot(data)
QC_summary=mean([data(:,1) abs(data(:,2)) abs(data(:,3))])

save(fullfile(param.odir,'QC_results.mat'))