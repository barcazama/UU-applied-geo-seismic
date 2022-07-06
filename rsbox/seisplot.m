function [fact] = ...
         seisplot(datain,t1,t2,tr1,tr2,smp,scal,pltflg,scfact,colour,tstart)

% [fact]=seisplot(datain,t1,t2,tr1,tr2,smp,scal,pltflg,scfact,colour,tstart)
%
% function for plotting seismic traces
%
% Input Arguments
% ---------------------------------------------------------------
% datain   - input matrix of seismic traces
% t1,t2    - beginning and end times to be displayed
% tr1,tr2  - first and last traces to be displayed
%  
% smp      - sampling interval (s)
% scal     - 1 for max, 0 for ave
% pltflg   - 1 plot only filled peaks, 0 plot wiggle traces and filled peaks,
%            2 plots wiggle traces only and 3 or more plots grayscale image
% scfact   - scaling factor
% colour   - trace colour, default is black
% tstart   - starting time (s)
%
% Notes 
% --------------------------------------------------------------- 
% 1. to display traces in reverse direction set tr1 equal to larger trace
% 
% 2. datain is a matrix i.e. dsivar.dat{1} and not a dsivar!
%  
% Output
% ---------------------------------------------------------------  
% fact - factor that matrix was scaled by for plotting
%        if you want to plot several matrices using the same 
%        scaling factor, capture 'fact' and pass it as input 
%        variable 'scal' to future matrices with 'scfact' set to 1
%
% DSI customized VSP processing software
%  
% written by G. Perron January, 1998
% modified by Jonathan Ajo-Franklin, June 16, 2005
%  
% 1. JBAF : june 16, 2005 : dealt with the t1:smp:t2 exception ...
%

%disp('bahs');


% setting up some defaults
if tr1>tr2
 inc=-1;
 traces=tr2:tr1;
else
 inc=1;
 traces=tr1:tr2;
end 

if (nargin<10)   colour='k';  end; 
if (nargin<11)   tstart=0;    end; 


%[t1,t2,tr1,tr2,smp,scal,pltflg,scfact,tstart]
%op1 = round((t1-tstart)/smp)+1;
%op2 = round((t2-tstart)/smp)+1;
%[op1,op2]
%[tr1,tr2]
%size(datain)
%t2
%(t2-tstart)
%smp
%(t2-tstart)/smp
%op2
%if(op2>


% a subsections the data
a=datain(round((t1-tstart)/smp)+1:round((t2-tstart)/smp)+1,traces);

%disp(cat(1,['Size of a = ',num2str(length(a))]));

if     (scal==1)  fact=max(max(abs(a)));
elseif (scal==0)  fact=max(mean(abs(a)));
else              fact=scal;
end

fact=fact./scfact;
a=a./fact;

if pltflg>=3
  imagesc(traces,t1:smp:t2,a);
  colormap(gray)
  colorbar
  xlabel('Trace Number')
  ylabel('Time (s)')
  if tr1>tr2
    set(gca,'xdir','reverse')
  end %if
  return;
end %if

b=find(a<0);

%disp(cat(1,['Size of b = ',num2str(length(b))]));

c=a;

%disp(cat(1,['Size of c = ',num2str(length(c))]));

c(b)=0;

[xmat,ymat]=meshgrid(traces,t1:smp:t2);

% little kludge to deal with length issue not matching
% I still don't understand why the original t1:smp:t2 
% sometimes generates the wrong answer - some funny 
% rounding thing somewhere ....
%
if(length(xmat)~=length(c))
  [xmat,ymat] = meshgrid(traces,t1:smp:(t2+smp));
end;

%format long;
%disp(cat(1,['t1  = ',num2str(t1,18)]));
%disp(cat(1,['t2  = ',num2str(t2,18)]));
%disp(cat(1,['smp = ',num2str(smp,18)]));
%disp(cat(1,['length of [t1:smp:t2] = ',num2str(length([t1:smp:t2]))]));
%disp(cat(1,['Size of c    = ',num2str(length(c))]));
%disp(cat(1,['Size of xmat = ',num2str(length(xmat))]));



c=c.*inc+xmat;
c(1,:)=xmat(1,:);
c(round(t2/smp+1-t1/smp),:)=xmat(1,:);
a=a.*inc+xmat;


if pltflg==0
   h=fill(c,ymat,colour);
   set(h,'edgecolor','none')
   hold on
   plot(a,ymat,colour);
   hold off
elseif pltflg==1
   h=fill(c,ymat,colour);
   set(h,'edgecolor','none');
elseif pltflg==2
   plot(a,ymat,colour);;
end
set(gca,'ydir','reverse');
if tr1>tr2
 axis([tr2-1 tr1+1 t1 t2]);
 set(gca,'xdir','reverse');
else
 axis([tr1-1 tr2+1 t1 t2]);
end %if/else
%xlabel('Trace Number');
%ylabel('Time (s)');
set(gca,'ygrid','on');

