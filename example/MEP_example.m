% the example script to get and analyze MEP data from Brain Sight

% Ikko Kimura, Osaka University, 2020/06/08
% Ikko Kimura, Osaka University, 2020/08/30, changed a lot for simplicity and generalizability
% Ikko Kimura, Osaka University, 2020/09/17, added param.time
% Ikko Kimura, Osaka University, 2020/09/19, bs_analyse_MEP exclude the sweep if needed
% Ikko Kimura, Osaka University, 2022/09/15, line 30: changed the name to
% bs_restrict_MEP added some descriptions

%%% TO DO
% readcell is only for R2019b

clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% !!! MODIFY THIS PART !!!
subj='IK005';
DataDir='/home/ikko/work/TEST';
param.idir=fullfile(DataDir,'data'); % where you stored the output of text file 
param.iname=[subj,'_Date.txt']; % input file name (my convention is to sava the text file with "ID_Date.txt")
param.odir=fullfile(DataDir,subj,'EMG_0'); % output directory (change the folder for multiple sessions)
param.int=[175:515]; % the sweep you are interested 
param.sess={175:204,205:234,235:264,265:294,295:324,325:354,355:362,363:392,393:423,424:453,454:484,485:515}; % the detail of each session
param.time=[0:5:60]; % when you obtained MEP in each session
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%0. PREP
mkdir(param.odir)
%%%1. PREPROCESSS 
bs_get_MEP(param.idir,param.iname,param.odir) % get emg data
findEMGBrainSight(param.odir,'MEP.mat') % preprocess MEP Area--> zeros
bs_restrict_MEP(param.odir,param.int) % get needed data
%%%2. VISUAL INSPECTION 
visualizeEMG 
% please look into 'MEP_preprocessed2.mat' and then save the output with
% the name 'MEP_preprocessed2_visualized.mat' (default)
%%%% FIRST RUN ABOVE! %%%%%

% THEN RUN BELOW 
%%%3. ANALYSE EMG waveform and plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% !!! CHNAGE THIS ACCORDINGLY !!! 
param.exclude=[188,219,250,280,281,311];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bs_analyse_MEP(param.odir,param.sess,'MEP_preprocessed2_visualized.mat',param.time,param.exclude)
% If you prefer to remove the outlier before calculating MEP change, please
% use bs_analyse_MEP2.m

save(fullfile(param.odir,'bs_param.mat'),'param') % save the prameter file just in case

