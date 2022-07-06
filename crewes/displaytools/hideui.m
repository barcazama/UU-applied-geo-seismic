function hh=hideui(handin)
% HIDEUI ... hide (or restore) user interface controls
%
% hh=hideui(figno) ... hides the uicontrols on figure figno
% hideui(hh) ... restores the uicontrols whos handles are in hh
%
% G.F. Margave, CREWES, 2000
%

if(nargin<1) handin=gcf; end

flag=get(handin(1),'type');

if(strcmp(flag,'figure'))
   hhi=get(handin(1),'children');
   hh=nan*hhi;
   for kk=1:length(hhi)
	   tp=get(hhi(kk),'type');
	   if(strcmp(tp,'uicontrol'))
		   flg=get(hhi(kk),'visible');
            if(strcmp(flg,'on'))
             hh(kk)=hhi(kk);
             set(hhi(kk),'visible','off');
            end
      end
   end

   ind=find(isnan(hh));
   hh(ind)=[];
else
   for k=1:length(handin)
      set(handin(k),'visible','on');
   end
   hh=[];
end
	
