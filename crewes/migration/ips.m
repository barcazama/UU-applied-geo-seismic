function phiout=ips(phiin,f,dx,parms,dz)
%phiout=ips(phiin,f,dx,parms,dz)
%
%Isotropic phase shift extraploation (stationary).
%
%phiout...spectrum of extrapolated wavefield
%phiin...spectrum of input wavefield (+ve ftemporal frequencies only)
%f...frequencies (Hz)
%dx...surface interval of vel
%parms...velocity
%dz...depth through which to extrapolate
%
%Rob Ferguson 2003
%Assistant Professor
%Department of Geological Sciences
%University of Texas, Austin
%512 471 6405
%fergusonr@mail.utexas.edu
%

%***get sizes of things***
[rp cp]=size(phiin);
f=f(:);
[rf cf]=size(f);
parms=parms(:);
[rparms cparms]=size(parms);
%*************************

%***check input***
if rparms~=1;error('  to many parmameters for isotropy');end
if cparms~=1;error('  not a stationary velocity');end
if rf~=rp;error('  frequency axis incorrect');end
%*****************

%***initialize some variables***
kxn=1/(2*dx);%spatial nyquist
dkx=2*kxn/cp;%wavenumber interval
kx=fftshift([-kxn:dkx:kxn-dkx]);%wavenumbers
%*******************************

%***extrapolate one dz***
kz=sqrt((f*ones(1,cp)/parms).^2-(ones(rp,1)*kx).^2);%vertical slowness
kz=real(kz)+sign(dz)*i*abs(imag(kz));%ensures evanescent region is complex positive
gazx=exp(2*pi*i*dz*kz);%evenescent region will decay exponentially
phiout=phiin.*gazx;%phase shift the input spectrum
%************************
