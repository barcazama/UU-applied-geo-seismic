function [vel,x,z]=channelmodel(dx,xmax,zmax,vhigh,vlow,zchannel,wchannel,hchannel,vchannel,nlayers)
% CHANNELMODEL : build a model representing a channel in a stratigraphic sequence
%
% [vel,x,z]=channelmodel(dx,xmax,zmax,vhigh,vlow,zchannel,wchannel,hchannel,vchannel,nlayers)
%
% dx ... grid interval (distance between grid points in x and z)
% xmax ... maximum x coordinate (minimum is zero)
%  *********** default 2500 **********
% zmax ... maximum z coordinate (minimum is zero)
%  *********** default 1000 ************
% vhigh ... velocity in the wedge and the anticline
%  *********** default 4000 ************
% vlow ... velocity below the wedge and above the anticline
%  *********** default 2000 ************
% zchannel ... depth to the channel
%  *********** default zmax/2 *******
% wchannel ... width of the channel
%  *********** default 5*dx ********
% hchannel ... height (thickness) of the channel
%  *********** default  5*dx  **********
% vchannel ... velocity of the channel
%  *********** default  vlow+(vhigh-vlow)/nlayers **********
% nlayers ... number of sedimentary layers
%  *********** default 4 *************
%
% vel ... velocity model matrix
% x ... x coordinate vector for vel
% z ... z coordinate vector for vel
%
% NOTE: the simplest way to plot vel is: plotimage(vel-mean(vel(:)),z,x)
%


if(nargin<5)
    vlow=2000;
end
if(nargin<4)
    vhigh=4000;
end
if(nargin<3)
    zmax=1000;
end
if(nargin<2)
    xmax=2500;
end
if(nargin<6)
    zchannel=zmax/2;
end
if(nargin<7)
    wchannel=5*dx;
end
if(nargin<8)
    hchannel=5*dx;
end
if(nargin<10)
    nlayers=4;
end
if(nargin<9)
    vchannel=vlow+(vhigh-vlow)/nlayers;
end
%initialize
thicknom=zmax/nlayers;%nominal thickness
x=0:dx:xmax;z=0:dx:zmax; % x and z coordinate vector
vrange=vhigh-vlow; % high and low velocities
vel=vhigh*ones(length(z),length(x));%initialize velocity matrix
zlay=zeros(nlayers);
xpoly=[-dx xmax+dx xmax+dx -dx];

for k=2:nlayers
    tmp=thicknom*(rand(1)+.5);
    tmp=round(tmp/dx)*dx;
    zlay(k) = zlay(k-1)+tmp;
    zpoly=[zlay(k-1)-dx zlay(k-1)-dx zlay(k) zlay(k)];
    vlayer=vlow+(k-1)*vrange/(nlayers);
    vel=afd_vmodel(dx,vel,vlayer,xpoly,zpoly);%install layer
end

%install channel
xm=mean(x);
x1=round((xm-wchannel/2)/dx)*dx;
x2=round((xm+wchannel/2)/dx)*dx;
z1=round(zchannel/dx)*dx;
z2=round((zchannel+hchannel)/dx)*dx;
xpoly=[x1 x2 x2 x1];
zpoly=[z1 z1 z2 z2];
vel=afd_vmodel(dx,vel,vchannel,xpoly,zpoly);%install channel