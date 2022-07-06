function [seis,t,line_name,ntr,nrec,xs,ys,xr,yr,offs,...
		selevs,relevs,sdepths,cdps]=readsegy(filename)

% [seis,t,line_name,ntr,nrec,xs,ys,xr,yr,offs,...
%		selevs,relevs,sdepths,cdps]=readsegy(filename)
%
% READSEGY reads a disk dataset in "Promax" segy format
%	and returns a matrix.
%
%	filename ... full file name to read from
%
%	seis ... the seismic matrix. One trace per column.
%	t ... time coordinate vector
%	line_name ... line name
%	ntr ...  number of traces per gather in the segy dataset
%	nrec ... number of gathers in the segy dataset
%	xs ... inline source coordinates for each trace in fmseis
%	ys ... crossline source coordinates for each trace in fmseis
%	xr ... inline receiver coordinates for each trace in fmseis
%	yr ... crossline receiver coordinates for each trace in fmseis
%	offs ... s-r offsets for each trace in fmseis
%	selevs ... source elevation for each trace in fmseis
%	relevs ... receiver elevation for each trace in fmseis
%	sdepths ... source depths for each trace in fmseis
%	cdps ... cdp numbers for each trace in fmseis
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

% initialize variables
seis=[]; t=[]; line_name=[]; ntr=[]; nrec=[]; xs=[]; ys=[];
xr=[]; yr=[]; offs=[]; selevs=[]; relevs=[]; sdepths=[]; cdps=[];

nrec=1;
%open the file and read the master header
[fid,line_name,nsamp,dt,ntr,nrec]=segyin_open(filename)

%disp([' Line name: ' line_name])

%allocate arrays
ntraces=ntr*nrec;
if isempty(ntraces)
	ntraces=500;
else
	if ntraces==0
		ntraces=500;
	end
end

xs=zeros(1,ntraces);
ys=zeros(1,ntraces);
xr=zeros(1,ntraces);
yr=zeros(1,ntraces);
offs=zeros(1,ntraces);
selevs=zeros(1,ntraces);
relevs=zeros(1,ntraces);
sdepths=zeros(1,ntraces);
cdps=zeros(1,ntraces);
seis=zeros(nsamp,ntraces);

t=dt*(0:nsamp-1)';
trc=[]; seqno=[]; itr=[]; irec=[]; dt=[]; offset=[]; sdepth=[]; selev=[];
relev=[]; Xs=[]; Ys=[]; Xr=[]; Yr=[]; cdp=[];

%loop over traces and read each
	[trc,seqno,itr,irec,dt,offset,sdepth,selev,relev,Xs,Ys,Xr,Yr,cdp]=...
		segyin(fid)
	k=1;
while(~isnan(trc(1)))
	if(rem(k,50)==0)
		disp([int2str(k) ' traces of ' int2str(nsamp) ' samples read']);
	end
	if( k> ntraces)
		grab=1000;%grab more memory
		ntraces=ntraces+grab;
		xs=[xs zeros(1,grab)];
		ys=[ys zeros(1,grab)];
		xr=[xr zeros(1,grab)];
		yr=[yr zeros(1,grab)];
		offs=[offs zeros(1,grab)];
		selevs=[selevs zeros(1,grab)];
		relevs=[relevs zeros(1,grab)];
		sdepths=[sdepths zeros(1,grab)];
		cdps=[cdps zeros(1,grab)];
		seis=[seis zeros(nsamp,grab)];
	end
	xs(k)=Xs;
	ys(k)=Ys;
	xr(k)=Xr;
	yr(k)=Yr;
	selevs(k)=selev;
	relevs(k)=relev;
	sdepths(k)=sdepth;
	cdps(k)=cdp;
	offs(k)=offset;
	seis(:,k)=trc;
	[trc,seqno,itr,irec,dt,offset,sdepth,selev,relev,Xs,Ys,Xr,Yr,cdp]=...
		segyin(fid);
	k=k+1;
end
kmax=k-1;
if( kmax<ntraces)
	xs=xs(1:kmax);
	ys=ys(1:kmax);
	xr=xr(1:kmax);
	yr=yr(1:kmax);
	offs=offs(1:kmax);
	selevs=selevs(1:kmax);
	relevs=relevs(1:kmax);
	sdepths=sdepths(1:kmax);
	cdps=cdps(1:kmax);
	seis=seis(:,1:kmax);
end
if(isempty(nrec))
	nrec=ceil(kmax/ntr);
end
disp([int2str(kmax) ' traces of ' int2str(nsamp) ...
		' samples read in '])

fclose(fid);
