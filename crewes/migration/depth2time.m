function [trc,t]=depth2time(ztrc,z,tzcurve,dt)
% DEPTH2TIME: Convert a trace from depth to time by a simple stretch
%
% [trc,z]=depth2time(ztrc,z,tzcurve,dt)
%
% DEPTH2TIME converts a single trace from depth to time. The conversion is
% specified by a time-depth curve that is stored in a two-column matrix.
% The first column is a list of times and the second is a list of 
% corresponding depths. The times can be either one-way or two-way and
% need only be consistent with the time-coordinate vector of the input.
% Between points in the time-depth curve, times are interpolated linearly.
% Note that this function does not apply an antialias filter. It is
% up to the user to ensure that dz is sufficiently small to preclude
% aliasing.
% 
% ztrc ... the trace in depth
% z ... depth coordinate vector for ztrc
% tzcurve ... an n-by-2 matrix giving the time-depth curve.
%	n is the number of points on the curve and is arbitrary.
%	(more points is usually more accurate.) The first column is
%	time and the second column is the depths that correspond to
%	the times in the first column. The first depth should be zero
%	and the last should be greater than or equal to max(z).
% dt ... time sample size. 
%
% G.F. Margrave, CREWES, Nov, 2000

%check tz curve limits
tz=tzcurve(:,1);zt=tzcurve(:,2);
if(min(zt)~=0)
	error('tzcurve must start at zero depth');
end
if(max(zt)<max(z))
	error('tzcurve must extend to depth greater than max(z)');
end

%make sure depths are monotonic
ztest=diff(zt);
ind=find(ztest<=0);
if(~isempty(ind))
	error('depths on tzcurve must increase monotonically')
end

%determine time range
t1=pwlint(zt,tz,z(1));
t2=pwlint(zt,tz,max(z));

t=((0:round(t2/dt))*dt)';

trc=zeros(size(t));

%interpolation sites
zint=pwlint(tz,zt,t);

%sinc function interpolation
trc=sinci(ztrc,z,zint);
