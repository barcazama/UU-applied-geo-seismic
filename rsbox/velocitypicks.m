% VELOCITYPICKS - script containing velocity picks for selected CMPs.
%
% Each CMP must contain the same number of picks, five will generally do.
% For times smaller than the first time-pick or larger than the last 
% time-pick, the velocity is assumed constant.
%
% cmppos - CMP position [m]
% v      - NMO velocity [m/s]
% t      - time of picked NMO velocity [ms]


% --------- begin editing here ---------
%
% Given numbers are just examples.
% Times and CMP numbers have to be in ascending order.
% Matrices t and v have to be square: this means that if you did not take the 
%  same amount of velocity-time picks for all CMPs, you will have to copy 
%  velocities from your first timepick to earlier time(s), for those CMPs which
%  have fewer picks than the others (hereby assuming the velocity in the 
%  overburden stays constant).
%

cmppos = [6001; % the 1st CMP position [m] for which you did velocity analysis
          8009;
	      10001;  
          12001;
          15001;
          18001]  % etc ...
t=[250 420 660 810 1110 1190;   % time picks [ms] for 1st CMP
   230 360 530 730 890 1060;   % time picks [ms] for 2nd CMP
   210 360 520 650 1010 1120;
   180 360 590 690 1010 1160;  
   200 360 600 770 1060 1150;
   190 320 570 780 1070 1160]
v=[1670 1725 1825 1945 2290 2490; % velocities [m/s] at times picked for 1st CMP
   1670 1725 1825 1945 2290 2490; % velocities [m/s] at times picked for 2nd CMP
   1670 1725 1825 1945 2290 2490; 
   1670 1725 1825 1945 2290 2490; 
   1670 1725 1825 1945 2290 2490;
   1670 1725 1825 1945 2290 2490]  % etc ...



% Value of PhD'er
%cmppos = [
%     800;
%     1000;
%     1488;
%     2000;
%     2208;
%     ];
% 
% t = [
%     160, 572, 992, 1040, 1100;
%     148, 268, 580, 856, 976;
%     368, 488, 580, 660, 720;
%     310, 390, 600, 730, 920;
%     352, 612, 888, 1024, 1152;
%     ];
% v = [
%     1480, 1840, 1820, 2020, 2020;
%     1480, 1320, 1780, 2000, 1760;
%     1700, 1640, 1540, 1780, 1640;
%     1530, 1400, 1740, 1660, 1950;
%     1480, 1760, 1840, 2340, 2560;
%     ];

%
% --------- end editing here -----------


% Calculating CMP sequence numbers [] from midpoint positions [m]
% Note that midpnts is an input argument from generatevmodel, the 
% function calling this script
cmpdist = midpnts(2)-midpnts(1);
cmp_initoffset = midpnts(1)/cmpdist;
for a=1:length(cmppos);
    vcmp(a) = cmppos(a)/cmpdist - (cmp_initoffset-1);
end

% Preparing the velocity and time matrices for generatevmodel.m
nrows=size(t,1);
ncols=size(t,2);
% Note that geo is an input argument from generatevmodel, the 
% function calling this script 
t_max=geo(1)*( geo(2) -1 );

% loop over rows, the amount of CMPs
for k=1:nrows
% Copy to zero timesample, otherwise copy zero-sample to first timesample
% in order to keep a square matrix
if t(k,1) > 0
    t_up(k,:) = [0      t(k,:)];
    v_up(k,:) = [v(k,1) v(k,:)];
else
    t_up(k,:) = [t(k,1) geo(1) t(k,2:ncols)];
    v_up(k,:) = [v(k,1) v(k,1) v(k,2:ncols)];
end

% Copy to t_max-timesample, otherwise copy t_max-sample to t=t_max-1 
% in order to keep a square matrix
% Beware that ncols of t_up has grown in size with one
if t_up(k,ncols+1) < t_max
    t_down(k,:) = [t_up(k,:)           t_max];
    v_down(k,:) = [v_up(k,:) v_up(k,ncols+1)];
else
    t_down(k,:) = [t_up(k,1:ncols) t_max-geo(1)    t_max          ]; 
    v_down(k,:) = [v_up(k,1:ncols) v_up(k,ncols+1) v_up(k,ncols+1)];
end
end

t=t_down;
v=v_down;
