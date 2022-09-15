function bs_analyse_MEP2(odir,sess,iname,x,exclude,z_thresh)

% analyse MEP data and visulaize the results

% Ikko Kimura, Osaka University, 2020/08/30
% Ikko Kimura, Osaka University, 2020/09/17 for generalizability and added
% bootfun
% Ikko Kimura, Osaka University, 2020/09/19 exclude the sweep if needed
% Ikko Kimura, Osaka University, 2022/09/15 just added z_thresh argument

%%% TO DO
% bootstrp ci can be replaced by bootstrpci?

if nargin<6
    z_thresh=2.5;
if nargin<5
    exclude=[];
if nargin<4
    x=0:5:5*(length(sess)-1);
if nargin<3
    iname='MEP_preprocessed2_visualized.mat';
end
end
end
end
ofig1='result1_2.fig';
ofig2='result2_2.fig';
ofig3='qc_2.fig';

%%%1. ANALYSE EMG waveform and plot
load(fullfile(odir,iname))
a=cell2mat(trials.sweep_num);
%start=sess{1}(1); % get the starting point

figure();
for i=1:length(sess)
    %i0=find(a==sess{1,i}(1));
    %i1=find(a==sess{1,i}(end));
    %int=sess{i}-start+1;
    int=find(ismember(cell2mat(trials.sweep_num),sess{i})==1);
    int(ismember(int,exclude))=[];
    d=trials.ch1_MEP_amplitude(int);
    outlier_size(i)=length(find(abs(zscore(d))>z_thresh));
    d(abs(zscore(d))>z_thresh)=[];
    amp(i)=mean(d);
    amp_std(i)=std(d);
    amp_d = bootstrp(10000,@mean,d);
    amp_med(i)=prctile(amp_d,50);
    amp_low(i)=prctile(amp_d,2.5);
    amp_high(i)=prctile(amp_d,97.5);
    d=trials.ch1_MEP_latency(int);
    d(abs(zscore(d))>z_thresh)=[];
    lat(i)=mean(d);
    lat_std(i)=std(d);
    lat_d = bootstrp(10000,@mean,d);
    lat_med(i)=prctile(lat_d,50);
    lat_low(i)=prctile(lat_d,2.5);
    lat_high(i)=prctile(lat_d,97.5);
    subplot(3,5,i)
    f=cell2mat(trials.ch1(int,:));
    plot((1/3)*[1:length(f)]-50,f','Color',[0.8 0.8 0.8])
    hold on
    plot((1/3)*[1:length(f)]-50,mean(f),'Color',[0 0 0],'LineWidth',2)
    xlim([0 75])
    box off
    set(gca,'FontSize',12)
    title(num2str(i))
end    
savefig(fullfile(odir,ofig1))
save(fullfile(odir,'result2.mat'),'amp','amp_std','lat','lat_std','amp_low','amp_high','amp_med','lat_low','lat_high','lat_med','trials','x','outlier_size')
clf

%x=0:5:5*(length(sess)-1);
subplot(2,2,1)
%errorbar(x,amp,amp_std,'-k','linewidth',1.5)
X=[x,fliplr(x)];                %#create continuous x value array for plotting
Y=[amp_low,fliplr(amp_high)];
fill(X,Y,[0.9 0.9 0.9],'EdgeColor','none');
hold on 
plot(x,amp_med,'-k','linewidth',1.5)
box off
xlabel('Elapsed Time'); ylabel('Amplitude'); set(gca,'FontSize',12)

subplot(2,2,2)
plot(x,amp./amp(1),'-k','linewidth',1.5)
box off
xlabel('Elapsed Time'); set(gca,'FontSize',12)

subplot(2,2,3)
X=[x,fliplr(x)];                %#create continuous x value array for plotting
Y=[lat_low,fliplr(lat_high)];
fill(X,Y,[0.9 0.9 0.9],'EdgeColor','none');
hold on 
plot(x,lat_med,'-k','linewidth',1.5)
box off
xlabel('Elapsed Time'); ylabel('Latency'); set(gca,'FontSize',12)
subplot(2,2,4)
plot(x,lat./lat(1),'-k','linewidth',1.5)
box off
xlabel('Elapsed Time'); set(gca,'FontSize',12)
savefig(fullfile(odir,ofig2))

clf
%%%2. load location data for consistency (QC)
%name={'Sample Name','Session Name','Index Assoc.',' Target','Loc. X','Loc. Y','Loc. Z','m0n0','m0n1','m0n2','m1n0','m1n1','m1n2','m2n0','m2n1','m2n2','Dist. to Target','Target Error','Angular Error','Twist Error'};
dat=[5 6 7 8 9 10 11 12 13 14 15 16 18 19 20];
load(fullfile(odir,'full_data.mat'))
data=cell2mat(Data(sess{1}(1):sess{end}(end),dat));
%f=figure();
for i=1:size(data,1)
T=[data(i,4) data(i,7) data(i,10) 0;data(i,5) data(i,8) data(i,11) 0;data(i,6) data(i,9) data(i,12) 0;0 0 0 1];
b=T*[100;0;0;1];
Ref_x(i,:)=(b(1:3))';
end
d=[data(:,1:3) Ref_x];
subplot(3,1,1)
plot(d)
box off; title('Absolute Location'); legend('Loc. X','Loc. Y','Loc. Z','Ref X','Ref Y','Ref Z'); set(gca,'FontSize',12) 

subplot(3,1,2)
plot(d-d(1,:))
box off; title('Relative Location'); legend('Loc. X','Loc. Y','Loc. Z','Ref X','Ref Y','Ref Z'); set(gca,'FontSize',12) 

subplot(3,1,3)
plot(data(:,13:15))
box off; title('Error'); legend('Dist. To Target','Angular Error','Twist Error'); set(gca,'FontSize',12) 
savefig(fullfile(odir,ofig3))
qc=data(:,13:15);
loc=data(:,1:3);
save(fullfile(odir,'result_qc.mat'),'qc','loc','sess')