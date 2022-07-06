function [seismogram,seis,t]=afd_shotrec(dx,dtstep,dt,tmax, ...
         velocity,snap1,snap2,xrec,zrec,filt,phase,laplacian)
% AFD_SHOTREC ... makes finite difference shot records
%
% [seismogram,seis,t]=afd_shotrec(dx,dtstep,dt,tmax,velocity,snap1,snap2,xrec,zrec,filt,phase,laplacian)
%
%
% AFD_SHOTREC will create a shot record given a velocity model and source 
% and receiver configutations. 
% Two input snapshots of the wavefield, one at time=0-dtstep and one at 
% time=0, are used in a finite difference algorithm to propogate the 
% wavefield.  The finite difference algorithm can be calculated with a 
% five or nine point approximation to the Laplacian operator.  The five 
% point approximation is faster, but the nine point results in a 
% broader bandwidth. Note that the velocity and grid spacing must 
% fulfill the equation max(velocity)*dtstep/dx < 0.7 for the model 
% to be stable.  The source array is included in the input 
% wavefield matrices, snap1 and snap2, and the receiver locations are defined
% by the user. Receiver arrays are not explicitely provided though they
% can be simulated after-the-fact by appropriate spatial convolutions.
% Of the two required snapshots, commonly they are either set equal to each other
% or the earlier one (snap1) is set to zero. These give different initial
% conditions. Two seismograms are returned:  one including all frequencies, and
% the other filtered by a gaussian function specified by the user.
%
% dx = the bin spacing for both horizontal and vertical (in consistent units)
% dtstep = size of time step for modelling (in seconds)
%         Stability requires max(velocity)*dtstep/dx < 0.7.
% dt = size of time sample rate for output seismogram. dt<dtstep causes resampling.
%		 dt>dtstep is not allowed. This allows the model to be oversampled for
%		 propagation but then conventiently resampled.
%		 The sign of dt controls the phase of the antialias resampling filter.
%		 dt>0 gives minimum phase, dt<0 is zero phase. Resampling is of course
%		 done at abs(dt). 
% tmax = the maximum time of the seismograms in seconds
% velocity = the input velocity matrix in consisnent units
%          must have the same size as snap1 and snap2
% snap1 = the wavefield at time=0 - dtstep (same size as velocity matrix)
%       This matrix determines the x and z sizes of the simulation. It should
%		be mostly zeros except for islotated ones corresponding to sources.
% snap2 = the wavefield at time = 0 (same size as velocity matrix)
%       This matrix represents the sources after one dtstep time step. Its often
%		acceptable to make this equal snap1.
% xrec = a vector of the x-positions of receivers (in consisent units)
%		The left hand column of snap1 is x=0.
% zrec = a vector of the z-positions of receivers (in consistent units)
%       The top row of snap1 is z=0. 
% filt or wlet = a 4 component ' Ormsby ' specification = [f1 f2 f3 f4] in Hz
%        or a wavelet. If it is longer than four elements, it is assumed to be
%      a wavelet. The wavelet should be sampled at the output sample rate
%      (dt)
% phase or tw ... If a the previous input was a four point filter, then this must
%     a scalar where 0 indicates a zero phase filter and 1 is a minimum phase
%     filter. If the previous input was a wavelet, then this is the time 
%     coordinate vector for the wavelet. The time sample rate of the wavelet MUST
%		equal dt.
% laplacian - an option between two approximation to the laplacian operator
%           - 1 is a 5 point approximation
%           STABILITY CONDITION: max(velocity)*dtstep/dx MUST BE < sqrt(2)
%           - 2 is a nine point approximation
%           STABILITY CONDITION: max(velocity)*dtstep/dx MUST BE < sqrt(3/8)
%  ************** default = 1***********
%
% seismogram = the filtered output seismogram
% seis = the output seismogram including all frequencies
% t = the time vector (from 0 to tmax)
%
% by Carrie Youzwishen, February 1999
%    G. F. Margrave July 2000
%
% NOTE: It is illegal for you to use this software for a purpose other
% than non-profit education or research UNLESS you are employed by a CREWES
% Project sponsor. By using this software, you are agreeing to the terms
% detailed in this software's Matlab source file.
 
% BEGIN TERMS OF USE LICENSE
%
% This SOFTWARE is maintained by the CREWES Project at the Department
% of Geology and Geophysics of the University of Calgary, Calgary,
% Alberta, Canada.  The copyright and ownership is jointly held by 
% its author (identified above) and the CREWES Project.  The CREWES 
% project may be contacted via email at:  crewesinfo@crewes.org
% 
% The term 'SOFTWARE' refers to the Matlab source code, translations to
% any other computer language, or object code
%
% Terms of use of this SOFTWARE
%
% 1) Use of this SOFTWARE by any for-profit commercial organization is
%    expressly forbidden unless said organization is a CREWES Project
%    Sponsor.
%
% 2) A CREWES Project sponsor may use this SOFTWARE under the terms of the 
%    CREWES Project Sponsorship agreement.
%
% 3) A student or employee of a non-profit educational institution may 
%    use this SOFTWARE subject to the following terms and conditions:
%    - this SOFTWARE is for teaching or research purposes only.
%    - this SOFTWARE may be distributed to other students or researchers 
%      provided that these license terms are included.
%    - reselling the SOFTWARE, or including it or any portion of it, in any
%      software that will be resold is expressly forbidden.
%    - transfering the SOFTWARE in any form to a commercial firm or any 
%      other for-profit organization is expressly forbidden.
%
% END TERMS OF USE LICENSE

tic;
boundary=2;

[nz,nx]=size(snap1);
if(prod(double(size(snap1)~=size(snap2))))
	error('snap1 and snap2 must be the same size');
end
if(prod(double(size(snap1)~=size(velocity))))
	error('snap1 and velocity must be the same size');
end

xmax=(nx-1)*dx;
zmax=(nz-1)*dx;

x=0:dx:xmax;
z=(0:dx:zmax)';

nrec=length(xrec);
if(nrec~=length(zrec))
	error('xrec and zrec are inconsistent')
end

test=between(0,xmax,xrec,2);
if(length(test)~=length(xrec))
	error('xrec not within grid')
end

test=between(0,zmax,zrec,2);
if(length(test)~=length(zrec))
	error('zrec not within grid')
end
	

if laplacian ==1 
   if max(max(velocity))*dtstep/dx > 1/sqrt(2)
   	error('Model is unstable:  max(velocity)*dtstep/dx MUST BE < 1/sqrt(2)');
   end
elseif laplacian ==2
   if max(max(velocity))*dtstep/dx > sqrt(3/8)
   	error('Model is unstable:  max(velocity)*dtstep/dx MUST BE < sqrt(3/8)');
   end
else
  error('invalid Laplacian flag')
end


if(abs(dt)<dtstep)
	error('abs(dt) cannot be less than dtstep')
end

if(length(filt)==4)
   %switch from ormsby to filtf style
   filt=[filt(2) filt(2)-filt(1) filt(3) filt(4)-filt(3)];
   if(phase~=0 & phase ~=1)
      error('invalid phase flag');
   end
else
   if(length(filt)~=length(phase))
      error('invalid wavelet specification')
   end
   w=filt;
   tw=phase;
   filt=0;
   if abs( tw(2)-tw(1)-abs(dt)) >= 0.000000001
      error('the temporal sampling rate of the wavelet and dt MUST be the same');
   end
end

%temporal information chosen by user
%t=(0:dtstep:tmax)';

%set up matrix for output seismogram
seis=zeros(floor(tmax/dtstep),nrec);

%transform receiver locations to bin locations
ixrec = floor(xrec./dx)+1;
izrec = floor(zrec./dx)+1;

%determine linear addresses for receivers
irec=(ixrec-1)*nz + izrec;

%grab time zero from snap2
seis(1,:)=snap2(irec);

maxstep=round(tmax/dtstep)-1;
disp(['There are ' int2str(maxstep) ' steps to complete']);
time0=clock;

% each loop does two time steps
nwrite=2*round(maxstep/50)+1;
for k=1:2:maxstep
	
	%time step
	snap1=afd_snap(dx,dtstep,velocity,snap1,snap2,laplacian,boundary);
	seis(k+1,:)=snap1(irec);
    
    if(iscomplex(snap1))
        yyy=1;
    end
	
	snap2=afd_snap(dx,dtstep,velocity,snap2,snap1,laplacian,boundary);
	seis(k+2,:)=snap2(irec);
    
    if(iscomplex(snap2))
        yyy=1;
    end

        if rem(k,nwrite) == 0
           timenow=clock;
           tottime=etime(timenow,time0);

           disp(['wavefield propagated to ' num2str(k*dtstep) ...
           ' s; computation time left ' ...
            num2str((tottime*maxstep/k)-tottime) ' s']);
        end 

end

%compute a time axis
t=((0:size(seis,1)-1)*dtstep)';

if(iscomplex(seis))
        yyy=1;
end

disp('modelling completed')

%resample if desired
if(abs(dt)~=dtstep)
	disp('resampling')
	phs=(sign(dt)+1)/2;
	dt=abs(dt);
	for k=1:nrec
		cs=polyfit(t,seis(:,k),4);
		[tmp,t2]=resamp(seis(:,k)-polyval(cs,t),t,dt,[min(t) max(t)],phs);
		seis(1:length(tmp),k)=tmp+polyval(cs,t2);
	end
	seis(length(t2)+1:length(t),:)=[];
	t=t2;
end
if(iscomplex(seis))
        yyy=1;
end

%filter

seismogram=zeros(size(seis));
if(~filt)
   nzero=near(tw,0);
   disp('applying wavelet');
	ifit=near(t,.9*max(t),max(t));
	tpad=(max(t):dt:1.1*max(t))';
   for k=1:nrec
		tmp=seis(:,k);
		cs=polyfit(t(ifit),tmp(ifit),1);
		tmp=[tmp;polyval(cs,tpad)];
      tmp2=convz(tmp,w,nzero);
		seismogram(:,k)=tmp2(1:length(t));
   end
else
   disp('filtering...')
	ifit=near(t,.9*max(t),max(t));
%   HDG changed from 	tpad=(max(t):dt:1.1*max(t))';
	tpad=(max(t)+dt:dt:1.1*max(t))';
   for k=1:nrec
		tmp=seis(:,k);
		cs=polyfit(t(ifit),tmp(ifit),1);
		tmp=[tmp;polyval(cs,tpad)];
%       HDG changed from tmp2=filtf(tmp,t,[filt(1) filt(2)],[filt(3) filt(4)],phase);
        tmp2=filtf(tmp,[t;tpad],[filt(1) filt(2)],[filt(3) filt(4)],phase);
		seismogram(:,k)=tmp2(1:length(t));
   end
end

if(iscomplex(seismogram))
        %disp('Really really bad! Complex amplitudes generated...')
        seismogram=real(seismogram);
end

toc;
