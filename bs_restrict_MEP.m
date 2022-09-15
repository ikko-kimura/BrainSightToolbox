function bs_restrict_MEP(odir,int,iname)

% quick data viz for qc and save only needed data
% Ikko Kimura, Osaka University, 2020/08/30
% Ikko Kimura, Osaka University, 2020/09/17, removed dataviz steps because
% this causes confusion with the next visualiseEMG step..

if nargin<3
iname='MEP_preprocessed.mat';
end
load(fullfile(odir,iname)) 
trials=trials(int,:);
save(fullfile(odir,'MEP_preprocessed2.mat'),'trials','subject','parameters')
