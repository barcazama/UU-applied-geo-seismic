%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Exercise 3 - Velocity Analysis %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load data
clearvars; close all; clc; % basic clear
[data, H_CSP, geo] = segyread('data/tripli.segy');

%% sort data
distance = 800; % choosen CMP
% WARNING: CMP gather cannot 1488 and 1512

close all;
[sort_data, H_CMP] = sortdata(data, H_CSP, 5);
[CMP_gather, H_CMP_gather] = selectcmp(sort_data,H_CMP, distance);
nt = geo(2);
dt = geo(1)/1000;
number_receiver = size(CMP_gather,2); % number of receiver in the CMP
t = linspace(1,nt*dt,nt);
x = 1:distance/number_receiver:distance;

close all;
plotseis(data,t,x)
title('Initial Data')
ylabel('time [s]')
xlabel('x-coordinates [m]')

figure
plotseis(data,t,x)
title('Data for CMP = 800 m')
ylabel('time [s]')
xlabel('x-coordinates [m]')

%% plot
% figure
% plothdr(H_CMP_gather)
% figure
% plotseis(CMP_gather)
close all;
figure
NMO = nmo_v(CMP_gather, H_CMP_gather, geo, 1000); % apply NMO correction with 1470 m/s
plotseis(NMO,t,x)
%%
clf; close all;
NMO = nmo_vt(CMP_gather, H_CMP_gather, geo,0.1);
%%
close all;
figure
semblance2(CMP_gather,H_CMP_gather,geo,1300,2400,5)

%%
close all;
[position,fold] = analysefold(H_CMP, 5);
vmodel = generatevmodel(position,geo);

%% smute
close all;
[CMP_gather, H_CMP_gather] = selectcmp(sort_data,H_CMP,1600);
NMO = nmo_v(CMP_gather, H_CMP_gather, geo, 1700,0);
% NMO = nmo_v(CMP_gather, H_CMP_gather, geo, 1700);
%% stack
close all;
figure
NMO = nmo_vt(CMP_gather, H_CMP_gather, geo); % create NMO of gather
stack = stackplot(NMO, geo); % stack
% figure
% NMO = nmo_vt(CMP_gather, H_CMP_gather, geo,0.5); % create NMO of gather
% stack = stackplot(NMO, geo); % stack

%% STACK ALL DATA
close all;
figure
zosection = nmo_stack(sort_data, H_CMP, position, fold, geo, vmodel,0.7);
smoothimage(zosection,0, 1.4, 1, 89, 0.004, 60, 2, 0,1,351)

%% SAVE
save('ex3_out','zosection','vmodel');

%% QUESTIONS
% Plot the data and the headers of that CMP: how can you see that you have chosen only 1 CMP? 
    % Because there is only one line on the CMP plot
% Now play around with the velocities until each of the  reflectors has lined up nicely once. 
% Write down or save in a file, the  velocity [m/s] for which the reflectors lined up, and the 
% time [ms] at which the lined-up reflectors were  located in the plot after NMO correction. 
    % we test different velocities on nmo_c to align two or three reflector
    % lines (each with their own velocities). There is three visible
    % reflectors that flatten for the following [velocities,time]:
    % - [1470,1.05]1270
    % - [1900,1.17]1860
    % - [1900,1.28]2020
% semblance plot:
% use to pick more precisely the velocity. You want the most yellow (no
% interferance) for each layer. First estimate velocity using other
% knowledge (geology, estimate), take some margin, run the samblance plot
% STEPS: knowledge estimate -> semblance2 -> choose time with nmo_v -> nmo_vt with the value choosen
% => it will be more accurate when using semblance than hand-pick...

% Now we choose different CMP, we had 800 and we will do the same for 1600
% and 2400
% 800: 1270:1.05, 1860:1.17, 2020:1.28 (velocity:time)
% 1600: 1555:1.12, 1675:1.17, 2130:1.23
% 1700: 1500:1.12, 1625:1.17, 2140:1.21
% 2400: 1500:1.1, 1700:1.16, 2500:1.32
% TEST WITH DIFFERENT WAY TO CALCULATE TIME
% 800: 1440:152, 1845:584, 2080:968
% 1600: 1540:404, 1660:588, 2250:956
% 2400: 1455:540, 1720:664, 2305:1188

% GENERATING V-model
% we can see a layered structure
% we see an increase of velocity going down and toward the right

% SMUTE
% by appling 0.5 smute, we can see a slighty more smooth impulse
% of each trace (really difficult to see)

% STACK
% it is clear that we have two spikes. It is because we constructively
% stack the amplitude and only the one that are aligned between traces
% would add up to high amount. It's something that we want that we are
% stacking by common midpoint, thus there is technically only one point
% that we measured multiple times

% 
% the more aggressive smute is near 0.1. smute value of 0.7/0.8 give the
% best results (lower will remove too much of the response and higher will 
% keep some of the artifacts 