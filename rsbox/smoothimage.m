function smoothimage(data,t1,t2,tr1,tr2,dt,cperc,intno,tstart,x1,x2)

% smoothimage(data,t1,t2,tr1,tr2,dt,cperc,intno,tstart,x1,x2)
%
% function for plotting seismic data as an image. A smooth image is
% obtained by interpolating the data laterally (if intno>1) before
% plotting.
%
% Input Arguments
% ---------------------------------------------------------------
% data     - input matrix of seismic traces [time and space samples]
% t1,t2    - beginning and end times to be displayed
% tr1,tr2  - first and last traces to be displayed
% dt       - time sample duration (s)
% cperc    - percentage of the maximum absolute amplitude that is clipped
% intno    - must be a scalar; if larger than one, (intno-1) is 
%            the number of grid cells that are spline interpolated 
%            between each grid cell 
% tstart   - starting time (s)
% x1       - lateral distance (or station number) at first station 
% x2       - lateral distance (or station number) at last station
%
% e.n.ruigrok@uu.nl, August 2015

% setting up some defaults
traces=tr1:tr2;
[~, no]=size([tr1:tr2]);
offset_inc=abs(x2-x1)/(no-1);
offset=x1:offset_inc:x2;

% a subsections the data
a=data(round((t1-tstart)/dt)+1:round((t2-tstart)/dt)+1,traces);

[row col]=size(a);

dnew=1/intno;

data_t1=spline([1:col],a,[1:dnew:col]);
data_t2=spline([1:row],data_t1',[1:dnew:row]);
data_new=data_t2';

imagesc(offset,t1:dt:t2,data_new);
colormap(french)
maxamp=max(max(abs(a)));
cmax=cperc*maxamp/100; 
caxis([-cmax cmax])
%colorbar
set(gca,'FontSize',14);
set(gcf,'Color',[1 1 1]);
xlabel('X [m]')
ylabel('Time [s]')
if tr1>tr2
  set(gca,'xdir','reverse')
end %if
return;