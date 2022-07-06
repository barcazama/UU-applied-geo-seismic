function vt = vlog(geo)
% vt = VLOG(geo) - generate a velocity-time table v(t).
%
% This function generates a 1D vertical velocity vs. time log v(t), from
% a set of velocity-time picks, and plots the log on the screen. 
% The velocity-time log is generated by piecewise linear interpolation
% between the given picks. For times smaller than the first time-pick or
% larger than the last time-pick, the velocity is assumed constant.
%
% Input: geom - the geometry of the seismic data
%         v,t - vectors for storing the picked velocities and their
%               corresponding times (edit in this script), from
%               velocity analysis with NMO_V or SEMBLANCE
% 
% See also NMO_VT, NMO_V, SEMBLANCE

% --------- begin editing here ---------
%
% Put your velocity-time (v,t) picks here.
% Given numbers are just examples.
% You can insert any amount of picks.
% Times have to be in ascending order.
% (naturally, vectors v and t must be of the same length)
% t= [1.12 1.17 1.23];     % two-way traveltimes [ms]
% v= [1545 1790 1910];     % corresponding wave propa-
%                               gation velocities in [m/s]
%
% FOR CMO = 800
% t= [1.05 1.17 1.28];
% v= [1270 1860 2020]; 
% t = [152 584 968];
% v = [1440 1845 2080];
% FOR CMO = 1600
% t= [1.12 1.17 1.23];
% v= [1555 1675 2130]; 
% t = [404 588 968];
% v = [1540 1660 2250];
% FOR CMO = 2400
% first try value not written
t = [152 584 968];
v = [1440 1845 2280];
% --------- end editing here -----------

if t(1) > 0  % do we need to fill up to t = 0 ms
    t = [0 t];
    v = [v(1) v];
end

if t(length(t)) < geo(1)*( geo(2) -1 )  % do we need to fill down to t_max
    t = [t geo(1)*(geo(2)-1)];
    v=  [v v(length(v))];
end

% The lines below are for plotting
t2=0:geo(1):geo(1)*(geo(2)-1);v2=pwlint(t,v,t2);
figure('color','w');
plot(v2,t2,v,t,'r*');flipy;
xlabel('velocity [m/s]');ylabel('two-way traveltime [ms]');

vt = v2';

datalabel;
