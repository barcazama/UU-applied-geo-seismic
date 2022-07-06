%Demo shootrayvxz on the Marmousi model.
s=which('raymarmousi_demo')
ind = findstr(s,'raymarmousi_demo');
sm=[s(1:ind-1) 'marmousi_mod'];
disp(['Marmousi model loaded from ' sm])
load(sm)
nx=length(x);
nz=length(z);
dg=x(2)-x(1);


disp(['Marmousi Raytracing demo'])
disp(' ')
disp(' ')
plotimage(vel-mean(vel(:)),z,x)
xlabel('meters');ylabel('meters')
disp(' ')
disp(' ')
disp(['Consider this velocity model'])
disp(['Solid black is ' int2str(round(max(vel(:)))) ' m/s'])
disp(['Solid white is ' int2str(round(min(vel(:)))) ' m/s'])

msg='Enter smoother length(meters) (0<=smoother) or -1 or <cr> to end->';

r=input(msg);
if(isempty(r)) r=-1; end

while(r>=0)

smooth=r;

% Define smoother
nsmooth=2*round(.5*smooth/dg)+1;%odd number
xb=(0:nx+nsmooth-2)*dg;zb=(0:nz+nsmooth-2)*dg;
x=(0:nx-1)*dg;z=(0:nz-1)*dg;
ixcenter=1+(nsmooth-1)/2:nx+(nsmooth-1)/2;
izcenter=1+(nsmooth-1)/2:nz+(nsmooth-1)/2;

% run a smoother over it
t1=clock;
v=conv2(vel,ones(nsmooth,nsmooth)/(nsmooth*nsmooth),'same');
t2=clock;
deltime=etime(t2,t1);
disp(['smoothing time ' num2str(deltime) ' seconds']);
plotimage(v-mean(v(:)),z,x)
xlabel('meters');ylabel('meters')
title(['Raytracing after ' int2str(smooth) ' m smoother'])
%install the velocity model
rayvelmod(v,dg);

%estimate tmax,dt,tstep
vlow=min(min(v));
tmax=max(z)/vlow;dt=.004;tstep=0:dt:tmax;

%specify a fan of rays
angles=[-70:2.5:70]*pi/180;
x0=round(nx/3)*dg;z0=0;
indx=near(x,x0);indz=near(z,z0);
v0=v(indz,indx);

%trace the rays
t1=clock;
for k=1:length(angles)
	r0=[x0 z0 sin(angles(k))/v0 cos(angles(k))/v0];
	[t,r]=shootrayvxz(tstep,r0);
	line(r(:,1),r(:,2),ones(size(t)),'color','r');
end
t2=clock;
deltime=etime(t2,t1);
disp(['raytrace time ' num2str(deltime) ' seconds']);
r=input(msg);
if(isempty(r)) r=-1; end

end

disp(' ')
disp('You should look at the source file for this demo')
disp('to see how its done. Also type "help raytrace" for more info.') 
