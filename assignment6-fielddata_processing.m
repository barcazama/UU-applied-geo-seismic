%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assignement 6 - Processing Field Data %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOADING DATA
clear; clearvars; close all; clc; % basic clear
load('data/fielddata.mat')
data = data(:,1:end-1);
head = head(:,1:end-1);
%%%%%%%%%%%%%%%%%%%%
% PARAMETERS INPUT %
%%%%%%%%%%%%%%%%%%%%
% manual editing
CMP_distance = 6; % distance in (km) for CMP gather
dt = 0.004; % time step
nt = 401; % number of time sample in a trace
ns = 1355; % number of shot
dxr = 5; % distance between two receivers
dxs = 60; % distance between two shot
slicing = 0; % 1 for slicing, 0 for no slicing (migration will not be done in case of slicing)
slice_initial = 227450; % first slicing position
slice_end = 228123; % last slicing position
smute = 0.7; % smute between 0 and 1
fmin = 30; % minimum frequency for the fxilter
fmax = 80; % max frequency for the filter
border_slope_filter = 0; % make the border
atten = 2; % exponential gain constant in db/sec, attenuation?

% automatic edits
nr = round(size(data,2)/ns); % number of receiver per shot
x_abs = head(3,1); % absolute coordinate of the shot 
t = linspace(0,nt*dt,nt); % time array
tmin = t(1);
tmax = t(end);
geo = [dt*1000, nt, ns, nr,dxs,dxr,x_abs]; % create geo arrayj

%%%%%%%%%%%%%%%%%%%
% SLICING DATASET %
%%%%%%%%%%%%%%%%%%%
if slicing == 1
    data_slice = data(:,slice_initial:slice_end); % slice data to only select one
    head_slice = head(:,slice_initial:slice_end); % same for header
    x = linspace(0,size(data_slice,2)*dxr,size(data_slice,2)); % creation of x array for slice data
elseif slicing == 0
    data_slice = data; % in case we don't want any slicing
    head_slice = head;
    x = linspace(0,size(data,2)*dxr,size(data,2)); % creation of x array for full data
end

%%%%%%%%%%%%%
% FILTERING %
%%%%%%%%%%%%%
[data_slice_filtered] = f_filt4(data_slice, dt,fmin,fmax,border_slope_filter); % apply low/high band pass filter
% figure
% f_plot(data,dt)
figure
f_plot(data_slice_filtered,dt)

%%%%%%%%%%%%%%%%%
% APPLYING GAIN %
%%%%%%%%%%%%%%%%%
data_gain = zeros(size(data_slice_filtered,1),size(data_slice,2));
for i=1:size(data_slice_filtered,2)
    trin = data_slice_filtered(:,i); % select only one trace
    data_gain(:,i) = gain(trin,t',atten,tmin,tmax); % correct for gain
end

%%%%%%%%%%%
% SORTING %
%%%%%%%%%%%
[data_sort, head_sort] = sortdata(data_gain, head_slice, 5); % sort data by CMP gather
[data_CMP, head_CMP] = selectcmp(data_sort,head_sort, CMP_distance);

%%%%%%%%%%%%%%%%%%%%%%%
% TIME OFFSET REMOVAL %
%%%%%%%%%%%%%%%%%%%%%%%
data_CMP(:,abs(head_CMP(2,:))>2900) = []; % remove velocity above 2k9
head_CMP(:,abs(head_CMP(2,:))>2900) = [];
data_sort(:,abs(head_sort(2,:))>2900) = [];
head_sort(:,abs(head_sort(2,:))>2900) = [];

%%%%%%%%%%%%
% PLOTTING %
%%%%%%%%%%%%
if slicing == 1
    %plot after slice
    figure
    plotseis(data_slice,t,x)
    xlim([921,2408]);
    title('Sliced Data Original (unfiltered)','FontSize',20)
    xlabel('Distance [m]','FontSize',16)
    ylabel('Time [s]','FontSize',16)
    
    %plot after filtering
    figure
    plotseis(data_slice_filtered,t,x)
    xlim([921,2408]);
    title('Sliced Data Filtered','FontSize',20)
    xlabel('Distance [m]','FontSize',16)
    ylabel('Time [s]','FontSize',16)
    
    %plot after gain applied:
    figure
    plotseis(data_gain,t,x)
    xlim([921,2408]);
    title('Sliced data with gain applied','FontSize',20)
    xlabel('Distance [m]','FontSize',16)
    ylabel('Time [s]','FontSize',16)
    
    % plot semblance
    figure
    semblance2(data_CMP,head_CMP,geo,1000,3000,5)
elseif slicing == 0
    % plot of CMP values sorted and selected for a specific CMP
    figure
    plotseis(data_CMP,t)
    title('CMP sorted','FontSize',20)
    xlabel('Trace number [-]','FontSize',16)
    ylabel('Time [s]','FontSize',16)     
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUILDING VELOCITY MODEL %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if slicing == 0
    [position,fold] = analysefold(head_sort, 5); % compute vector with CMP-positions
    position_mod = position*1000; % converting distance from km to m
    vmodel = generatevmodel(position_mod,geo); % computing vmodel

    % plotting stack
    figure
    zosection = nmo_stack(data_sort, head_sort, position_mod, fold, geo, vmodel,smute);
    imagesc(zosection);
    title('Stacked data with muting = 0.7','FontSize',20)
    xlabel('Distance [m]','FontSize',16)
    ylabel('Time [ms]','FontSize',16)
    
    [arymig,tmig,xmig] = kirk_mig2(zosection, vmodel, dt, dxr); % migration

    % ploting migrated stack
    figure
    imagesc(xmig,tmig,arymig)
    title('Migrated stacked data','FontSize',20)
    xlabel('Distance [m]','FontSize',16)
    ylabel('Time [s]','FontSize',16)
end

%%%%%%%%%%%%%%%
% CALIBRATION %
%%%%%%%%%%%%%%%
% BUILDING VELOCITY MODEL - INVESTIGATION
% this part of the code was used to calibrate velocities and time
% close all;
% NMO = nmo_v(data_CMP, head_CMP, geo, 1725);
% plotseis(NMO,t,x)

% semblance output: 1670 1725 1825 1945 2290 2490

% CMD = 6
% 1670 0.25
% 1725 0.42
% 1825 0.66
% 1945 0.81
% 2290 1.11
% 2490 1.19
% 250 420 660 810 1110 1190

% CMD = 8
% 1670 0.23
% 1725 0.36
% 1825 0.53
% 1945 0.73
% 2290 0.89
% 2490 1.06
% 230 360 530 730 890 1060

% CMD = 10
% 1670 0.21
% 1725 0.36
% 1825 0.52
% 1945 0.65
% 2290 1.01
% 2490 1.12
% 210 360 520 650 1010 1120

% CMD = 12
% 1670 0.21
% 1725 0.36
% 1825 0.59
% 1945 0.69
% 2290 1.01
% 2490 1.16
% 180 360 590 690 1010 1160

% CMD = 15
% 1670 0.20
% 1725 0.36
% 1825 0.60
% 1945 0.77
% 2290 1.06
% 2490 1.15
% 200 360 600 770 1060 1150

% CMD = 18
% 1670 0.19
% 1725 0.32
% 1825 0.57
% 1945 0.78
% 2290 1.07
% 2490 1.16
% 190 320 570 780 1070 1160
