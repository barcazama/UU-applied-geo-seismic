function semblance2(CMPgather,H_CMPgather,geo, cmin,cmax,velstep)
% SEMBLANCE2(CMPgather, H_CMPgather, geo, cmin, cmax, velstep) 
%
% This code generates a semblance panel for wave propagation velocities
% ranging from cmin to cmax, with a stepsize of velstep. As input it takes
% a CMP-gather at a certain midpoint together with its header.
%
% Input:    CMPgather   - CMP-gather
%           H_CMPgather - its header
%           geo         - geometry of the seismic data 
%           cmin        - minimum velocity  [m/s]
%           cmax        - maximum velocity  [m/s]
%           velstep     - velocity stepsize [m/s]
%
% See also SELECTCMP, NMO_VT
%
% June 2016, ENR: replaced plotimage with imagesc and added a plot of the
%                   CMP data

%constants
nt = geo(2);
dt = geo(1);
cmpsize=min(size(CMPgather));
counter=0;

disp(' ')
disp([' Velocity stepsize is ', num2str(velstep), ' m/s .'])
disp(' ')

% notation: NMO(i,j)

%call function nmo.m for making the NMO dataset with velocity ci
for ci=cmin:velstep:cmax;
disp([' processing for NMO velocity of ', num2str(ci), ' m/s ...'])
NMO=nmo_v(CMPgather,H_CMPgather,geo, ci);

counter = counter + 1;

for i=1:nt;
	sum = 0;
	sum2 = 0;
	for j=1:cmpsize;
		sum=sum+NMO(i,j);
		sum2=sum2+NMO(i,j)^2;
	end
	sqsum=sum^2;
	semtr(i,counter)=cmpsize^(-1)*(sqsum/sum2);
end

end

% normalize CMPgather
for k=1:cmpsize
    CMPgather(:,k)=CMPgather(:,k)/max(abs(CMPgather(:,k)));
end


disp(' ')
figure('Color','w');
subplot(1,2,1)
imagesc(1:cmpsize,0:dt:(nt-1)*dt,CMPgather)
cperc=50;
caxis([-cperc/100 cperc/100])
set(gca,'FontSize',16);
title('Normalized CMP gather','FontSize',20)
xlabel('Trace No.')
ylabel('Time [ms]')
subplot(1,2,2)
imagesc(cmin:velstep:cmax,0:dt:(nt-1)*dt,semtr)
shading interp
set(gca,'FontSize',16);
title('Semblance plot','FontSize',20)
xlabel('NMO velocity [m/s]')
ylabel('Time [ms]')
