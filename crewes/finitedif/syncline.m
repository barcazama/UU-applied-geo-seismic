% SYNCLINE: model a channel beneath a few layers
%
% high velocity wedge
% Just run the script
dx=10; %cdp interval
xmax=2500;zmax=1000; %maximum line length and maximum depth
x=0:dx:xmax; % x coordinate vector
z=0:dx:zmax; % z coordinate vector
vhigh=4000;vlow=2000; % high and low velocities
vrange=vhigh-vlow;

%initialize velocity matrix as a constant matrix full of vlow
vel=vlow*ones(length(z),length(x));

%first layer
xpoly=[-dx xmax+dx xmax+dx -dx];zpoly=[100 100 200 200];
vel=afd_vmodel(dx,vel,vlow+vrange/5,xpoly,zpoly);

%second layer
zpoly=[200 200 271 271];
vel=afd_vmodel(dx,vel,vlow+2*vrange/5,xpoly,zpoly);

%third layer
zpoly=[271 271 398 398];
vel=afd_vmodel(dx,vel,vlow+pi*vrange/5,xpoly,zpoly);

%last layer
zpoly=[398 398 zmax+dx zmax+dx];
vel=afd_vmodel(dx,vel,vhigh,xpoly,zpoly);

%channel
width=200;
thk=50;
xpoly=[xmax/2-width/2 xmax/2+width/2 xmax/2+width/2 xmax/2-width/2];
zpoly=[398 398 398+thk 398+thk];
vel=afd_vmodel(dx,vel,vlow+vrange/6,xpoly,zpoly);

%plot the velocity model
plotimage(vel-.5*(vhigh+vlow),z,x)

%do a finite-difference explodaing reflector model
dtstep=.001; %temporal sample rate
dt=.004;
tmax=2*zmax/vlow; %maximum time
%[w,tw]=wavemin(dt,30,.2); %minimum phase wavelet
%[w,tw]=ricker(dt,70,.2); %ricker wavelet
[seisfilt,seis,t]=afd_explode(dx,dtstep,dt,tmax, ...
 		vel,x,zeros(size(x)),[10 15 50 60],0,1);

%plot the seismogram
plotimage(seisfilt,t,x)
