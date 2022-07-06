%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Exercise 2 - Sorting Seismic Data %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars; close all; clc; % basic clear

% import label
% H_CSP - shot-sorted header matrix in 5 rows 
%         Convention for the header-row numbering:
%         1 = the unique trace number
%         2 = trace offset with respect to shot position
%         3 = shot position corresponding to the trace
%         4 = receiver position corresponding to the trace
%         5 = cmp midpoint corresponding to the trace
%
% geo   - geometry of the seismic data. Its output is a row vector
%         of length 7, with the following elements:
%        (1) time sampling dt [ms]
%        (2) number of time samples nt in a trace 
%        (3) number of shots ns
%        (4) number of receivers nr per shot
%        (5) distance between two subsequent shots dxs [m]
%        (6) distance between two subsequent receivers dxr [m]
%        (7) absolute x-coordinate of the first shot x0 [m]

%% import
[data_f8, H_CSP_f8, geo_f8] = segyread('data/f8.h1.segy');
[data_planes, H_CSP_planes, geo_planes] = segyread('data/planes.segy');
[data_points, H_CSP_points, geo_points] = segyread('data/points.segy');
[data_shotground, H_CSP_shotground, geo_shotground] = segyread('data/shotground.segy');
[data_slope, H_CSP_slope, geo_slope] = segyread('data/slope.segy');
[data_tripli, H_CSP_tripli, geo_tripli] = segyread('data/tripli.segy');

%% plot
close all;
plothdr(H_CSP_f8)
plothdr(H_CSP_planes)
plothdr(H_CSP_points)
plothdr(H_CSP_shotground)
plothdr(H_CSP_slope)
plothdr(H_CSP_tripli)

%% key question 2
load(H_SHT); % load H_SHT header matrix
plot(H_SHT)
%% Answers
% Key Question: Shot-Sorted Data [ 1/2 ]

% Key Questions: Shot-Sorted Data [ 2/2 ]
%  How can you see that the data from acquisition is sorted per shot? 
    % there is 
%  Determine the number of shots. 
    % there is 120 shots (24000 [traces] / 200 [traces/shot])
%  What is the receiver spacing in a common-shot gather dxr ? 
    % receivers are spaces by 12.5m 
%  Why does the trace offset show repetitive upward-going lines? 
    % because the relative distance between receiver and the source doesn't
    % change as they are all moved together.
%  Why does the receiver position show the same repetitive upward-going lines but now with a general up going trend over it? 
    % we also have the same movement but this time, in absolute values. So
    % the overall line is shifted upwward thus there is a upward slope
    % (same for the shot position)

%% Common Receiver Positions
H_sorted_CRP = sorthdr(H_SHT,4);
H_sorted_CMP = sorthdr(H_SHT,5);
%% Answers:
% Compare plot of H_SHT and H_sorted
    % The sorthdr with key=4 will sort by receiver position (CRP), meaning that
    % for one receiver position, there is multiple traces each one
    % from different shot. This result in more narrow shape on the
    % extremities because there is less overlap on these positions.

%% Common Midpoint Positions
% Compare plot of H_SHT and H_sorted
    % This time, traces are sorted by CMP so there is the same overlap and
    % overall shape as with the CRP sorting. However, we can observe there
    % is more traces in the extremities when sorting in CMP than CRP.
    % This can be explained by the fact that the first CMP will be located 
    % before the first receiver.
% What would you expect to be the distance between subsequent CMPs? Explain your answer. 
    % We except the distance between CMP to be half of the distance between
    % receivers, thus 12.5/2=6.25 m.
% Based on this, how many CMP-gathers are created? 
nmbr_CMP = (max(H_sorted_CMP(5,:))- min(H_sorted_CMP(5,:)))/6.25;
    % 1151 traces in total (total number of CMP - overlap = CMP gather)
% Use this plot to verify the fold for the 4th CMP, the middle CMP and the three-but-last CMP. 
[positions, folds] = analysefold(H_SHT, 5);
    % the 4th CMP contain 4 folds and third from the last contain 3 folds.
    % More generally, there is one more fold per subsequent CMP until 25
    % and the shape is symetric.
% In which gather the highest fold is reached (common-offset, common-shot, common-receiver or common-midpoint)? 
    % The highest number of fold is reached for a common-shot gather, which
    % is 200 folds (120 folds for common-offset)
 %% Slope Data set 1/3
[data, H_CSP, geo] = segyread('data/slope.segy');
plothdr(H_CSP)
% number of shot = 8989 traces / 101 receivers = 89 shots
% number of receivers = 101
% space between sources (aka shots) = 16m
% space between receivers = 16m

%% Now we want to select one shot in the middle and assign the shot-gather to a variable
H_CSP_1shot_select = H_CSP(:,101*44+1:101*45); % select only one shot for header
data_1shot_select = data(:,101*44+1:101*45); % select only one shot for data
[data_sorted_CMP,H_sorted_CMP] = sortdata(data_1shot_select,H_CSP_1shot_select,5); % sort data my CMP

plotseis(data_sorted_CMP) % plot 1 shot data
% plothdr(H_sorted_CMP) % plot 1 shot header
% __What is the (offset) spacing between the traces in a CMP-gather
% there is 101 traces and because we have one shot, there is only one
% source. The space between traces is equivalent to the space between
% receivers = 16m

%%
[data_sorted_shot,H_sorted_shot] = sortdata(data_1shot_select,H_CSP_1shot_select,3); % sort data my shot

plotseis(data_sorted_shot) % plot 1 shot data
% plothdr(H_sorted_shot) % plot 1 shot header

% Comparing middle shot-gather with middle CMP-gather, what strikes you most ? Can you provide an explanation ? 
% If we take two shots, then CMP will have two hyperbola overlapping and
% the space between each traces will be reduce while if we do a CSP, we
% will have two separate hyperbola. CMP will be easier for interpretation
% as it will stack multiple shot and an line will be visible corresponding
% to the horizon (reflector)







