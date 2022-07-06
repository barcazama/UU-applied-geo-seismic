function waveleted(arg1,arg2,arg3)

% WAVELETED is an interactive wavelet editor for creating and modifying
% wavelets.  It accepts an EarthObject full of wavelets and provides
% graphical facilities for the analysis and/or modification of the existing
% wavelets and the creation of new wavelets which are then put into the
% object.
%
% Calling mechanisms:
% waveleted ... with no arguments, a blank wavelet editor window is opened
%               which can then be used to create or import any number
%               of wavelets or to open an existing wavelet object from disk
% waveleted(waveletobj) ... with a single argument which is a wavelet object,
%		WAVELETED opens an editor with the wavelets in this object
%		available for editing
% waveleted(waveletobj,hmasterfig,transferfcn) ... this mode is used when it
%               is desired to have another program (or figure) in control of
%               the wavelet editor. It causes the 'xmit' action in WAVELETED
%               to be enabled. If the user selects 'xmit', WAVELETED does
%               the following:
%			figure(hmasterfig)
%			eval([transferfcn '(''wavelets'',waveletobj)'])
%		That is it sets the figure whose handle is hmasterfig to be
%		c urrent and then uses the MATLAB eval function to call the
%		function whose name is given by the string transferfcn with
%		the arguments 'wavelets',waveletobj. Thus if you have a
%		program called DOSTUFF which wants to invoke the wavelet
%		editor, then you must include a segment of code in DOSTUFF
%		which can respond to the call:
%		dostuff('wavelets',waveletobj)  and you supply
%		WAVELETED with the string 'dostuff' as its third argument.
%		(This 'xmit' action will not dismiss the editor, that must
%		be done manually.)
%
% G.F. Margrave, March 1994
% Updated July 1997
%
% NOTE: Wavelet files saved in version 4.x are not compatible with current
% version 5. 
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


% Description of Wavelet objects
% 1) The wavelets themselves are stored in a fleximat whos x coordinate
%	is just a numeric index and whos y coordinate is time.
% 2) The fleximat is in a container whose datatype is 'wlet' and whose name
%	refers to the entire collection of wavelets e.g.: 'Freds favorite wavelets'
% 3) The name of the fleximat within the container will always be 'wavelets'
% 4) The individual wavelet names will be in a string matrix and stored in the
%	container under the name 'wavelet names'. The string matrix will pad the
% 	names with 1's so that they are distinct from blanks and can be detected and
%	removed. Note that objget will return this as a numeric matrix and you
%	must run setstr on the result to get strings.
% 5) Additionally, WAVELETED will insert a parameters object that, among other
%	things, will remember which wavelets were last being edited
%

global currentMenu

if(nargin<1)
	action='init';
	wlet=[]; hmasterfig=[]; transfer=[]; dt=[]; 
else
	if( ~isstr(arg1) )
		action='init';
		wlet=arg1;
		dt=[];
		if( nargin< 2)
			hmasterfig=[];
			transfer=[];
		else
			hmasterfig=arg2;
			transfer=arg3;
		end
	else
		action=arg1;
	end
end

global COMPILED
global EXPIRATION_DATE;
crcompile;  % set COMPILED and EXPIRATION_DATE in crcompiled.m

if( nargin < 1 )
    action = 'init';
end

if(COMPILED&strcmp(action,'init'))
   today=datenum(date);
   daysleft=EXPIRATION_DATE-today;
   if((daysleft<30)&(daysleft>0))
       uiwait(msgbox(['Your license for WAVELETED will expire in ' num2str(daysleft) ' days. ',...
        'CREWES Sponsors can download new executables on Jan 2 of the next year.'],...
         ' CREWES wants you to know ','modal'))
   end
   if(daysleft<=0)
       msgbox(['Your license for WAVELETED has expired. '...
        'Please contact CREWES at crewesinfo@crewes.org to renew sponsorship or purchase a new license.'],...
        'Oh Oh, this is a truly sad day...')
        return
   end
end

% userdata assignments:
% the figures userdata contains all relevent handles of children
%		set(hfig,'userdata',[haction, hnew, hchange, hxmit, hsave, hsaveascii,...
%			hsaveobject, hquit, hax1, hax2, hax3, hwave, ...
%			hactive, hmsg hdelete hzoom hunzoom hrename,...
%			hsavecurrent hsaveall hshowsave]);
% haction (the actions menu) ... integer indicating the current action
% hnew (new action menu) ... integer 1 and the handle of the active design
%			window
% hchange (change action menu) ... integer 2
% hxmit (xmit action menu) ... integer 4 and the handle of the master figure
% hsave (save action menu) ... integer 5
% hsaveascii (saveascii action menu) ... the transfer function used by xmit
% hsaveobject (saveobject action menu) ... the time sample rate
% hquit (quit action menu) ... the wavelet object
% hax1 (time axis) ... don't use (used by zooming etc)
% hax2 (db freq axis) ... don't use (used by zooming etc)
% hax3 (phase freq axis) ... don't use (used by zooming etc)
% hwave (wavelets menu) ... vector of handles of the wavlet submenus. Handle is
%		negative if the wavelet is on display
% hactive (active wavlet msg panel) ... the menu handle of the active wavelet
% hmsg (msg panel) ... six pairs of numbers giving the default axis settings for
%		the 3 plots
% hdelete (delete menu) ... the integer 3
% hzoom ... the integer 6
% hunzoom ... the integer 7
% hrename ... the integer 8
% hmenu (the various wavelet menus) ... if the wavelet is plotted, then the
%	userdata has the handles of the three curve (time, amp, phs) otherwise
%	it is null
% hsavecurrent ... not used
% hsaveall ... not uset
% hshowsave ... not used


if( strcmp(action,'init') )
 %put a file object in the wavlet object if needed
	%get the fileobj
	if( ~isempty(wlet) )
	 fileobj=objget(wlet,'file');

		if( isempty(fileobj) )
			fileobj=contobj('file','prvt');
			filename='undefined';
			pathname=' ';
			fileobj=objset(fileobj,'filename',filename);
			fileobj=objset(fileobj,'pathname',pathname);

			wlet=objset(wlet,'file',fileobj);
		 end
	end
	
	%open up a new figure
        hfig=figure;
        positionWindow(hfig,'waveleted','main',800,800);
        set(hfig,'menubar','none'); 
        set(hfig,'name','Wavelet Editor','numbertitle','off');
		%create an actions menu
		haction=uimenu(hfig,'label','File','userdata',0);

		% various action submenus
		hopen=uimenu(haction,'label','Open Saved Wavelet File','callback',...
			'waveleted(''open'')','userdata',9);

		hnew=uimenu(haction,'label','New Wavelet','callback',...
					'waveleted(''new'')','userdata',[1 0]);
		hchange=uimenu(haction,'label','Modify Active Wavelet','callback',...
					'waveleted(''change'')','userdata',2,'enable','off');

		hrename=uimenu(haction,'label','Rename Active Wavelet','callback',...
				'waveleted(''rename'')','userdata',8,'enable','off');
					
		hdelete=uimenu(haction,'label','Delete Active Wavelet','callback',...
					'waveleted(''delete'')','userdata',3,'enable','off');


		hxmit=uimenu(haction,'label','Transmit Changes','callback',...
					'waveleted(''xmit'')','userdata',[4 hmasterfig]);
		
		if( isempty(hmasterfig) )
			set(hxmit,'enable','off');
		end

		hsave=uimenu(haction,'label','Save...','userdata',5,...
			'callback','waveleted(''save'');');
		hsaveopts=uimenu(haction,'label','Save Options');
		hsaveascii=uimenu(hsaveopts,'label','ASCII file','callback',...
			'waveleted(''saveopts'')','checked','off','userdata',transfer);
		hsaveobject=uimenu(hsaveopts,'label','Object file','callback',...
			'waveleted(''saveopts'')','userdata',dt,'checked','on');
		hsavecurrent=uimenu(hsaveopts,'label','Save Active Wavelet','callback',...
			'waveleted(''saveopts'')','checked','off');
		hsaveall=uimenu(hsaveopts,'label','Save All Wavelets','callback',...
			'waveleted(''saveopts'')','checked','on');
		hshowsave=uimenu(hsaveopts,'label','Show Save File','callback',...
			'waveleted(''showsave'')');
		hquit=uimenu(haction,'label','Quit','callback','waveleted(''quit'')');
		set(hquit,'userdata',wlet);

  		%create an view menu
		hview=uimenu(hfig,'label','View','userdata',0);
		hzoom=uimenu(hview,'label','Zoom','callback',...
					'waveleted(''zoominit'')','userdata',6);
		hunzoom=uimenu(hview,'label','unZoom','callback',...
					'waveleted(''unzoom'')','userdata',7);

        
        
		%make three axes
		%reserve the bottom 10% for controls, each axis gets 30%

		hax1=axes('Position',[.15,.65,.8,.23]);
		set(hax1,'ylabel',text(0,0,'Amplitude'));
		set(hax1,'xlabel',text(0,0,'Time'));
		hax2=axes('Position',[.15,.35,.8,.23]);
		set(hax2,'ylabel',text(0,0,'Decibels'));
		set(hax2,'xlabel',text(0,0,'Frequency'));
		hax3=axes('Position',[.15,.05,.8,.23]);
		set(hax3,'ylabel',text(0,0,'Phase Angle'));
		set(hax3,'xlabel',text(0,0,'Frequency'));

		% make the wavelets menu
		hwave=uimenu(gcf,'label','Wavelets');

		%get the wavelet names
		if( ~isempty(wlet) )
			wnames=objget(wlet,'wavelet_names');
			[numnames,r]=size(wnames);
			wletparms=objget(wlet,'waveleted params');
		else
			wletparms=[];
			wnames=[];
			numnames=0;
		end

		%make the wavelets menus
		if( isempty(wletparms) )
			wletparms=zeros(1,numnames);
			wletparms(1)=1;
		end

		nameflags=wletparms(1:numnames);
		hwmenu=zeros(1,numnames);
		for k=1:numnames
			if(nameflags(k))
				checked='on';
			else
				checked='off';
			end
			hwmenu(k)=uimenu(hwave,'label',strunpad(wnames(k,:)),...
				'callback','waveleted(''switchwave'')','checked',checked);

			% - sign to indicate a live wavelet
			if( strcmp( checked,'on' ) )
				hwmenu(k)=-hwmenu(k);
			end

		end
		%
		set(hwave,'userdata',hwmenu);

		%make the msg window and the active wavelet window
		sep=.005;
		height=.03;
		xnow=sep;ynow=1.0-height-sep;width=1.0-2*sep;
		hactive=uicontrol('style','text','string','Active Wavelet: none',...
			'units','normalized','position',[xnow,ynow,width,height]);
		ynow=ynow-height-sep;
		if( ~isempty(wlet) )
			hmsg=uicontrol('style','text','string',...
			'Click on a wavelet to activate it',...
			'units','normalized','position',[xnow,ynow,width,height]);
		else
			hmsg=uicontrol('style','text','string',...
			'Make a new wavelet or open a wavelet file',...
			'units','normalized','position',[xnow,ynow,width,height]);
		end

		% save handles in user data of figure
		set(hfig,'userdata',[haction, hnew, hchange, hxmit, hsave, hsaveascii,...
			hsaveobject, hquit, hax1, hax2, hax3, hwave, ...
			hactive, hmsg hdelete hzoom hunzoom hrename,...
			hsavecurrent hsaveall hshowsave]);

		%plot the active wavelets
		waveleted('plot');

		return;
	end

if( strcmp(action,'quit') )
	h=get(gcf,'userdata');
	hxmit=h(4);
	flag=get(hxmit,'enable');
	if( strcmp(flag,'on') )
        yes = questdlg('Transmit changes first?',...
                'Exit confirmation',...
                'Yes','No','Yes');
        if yes
            waveleted('quit2');
        end
	else
        yes = questdlg('Are you sure you want to quit?',...
                'Exit confirmation',...
                'Yes','No','Yes');
        if yes
            waveleted('quit2');
        end
	end
	return;
end

if(strcmp(action,'quit2'))
	h=get(gcf,'userdata');
	hxmit=h(4);
	a=yesnofini;
	if( a==-1 )
		return;
	end
	flag=get(hxmit,'enable');
	hfig=gcf;
	if(a>0 & strcmp(flag,'on') )
		waveleted('xmit');
	elseif( a>0 )
		waveleted('save');
	end
    saveWindowPosition(hfig,'waveleted','main');
	close(hfig);
	return;
end

 if( strcmp(action,'plot') )
		h=get(gcf,'userdata');
		hsaveobject=h(7);
		hquit=h(8);
		hax1=h(9);
		hax2=h(10);
		hax3=h(11);
		hwave=h(12);
		hmsg=h(14);
    % get the wavelets

		wlet=get(hquit,'userdata');
		if( isempty(wlet) )
			return;
		end
		fmw=objget(wlet,'wavelets');
		ws=fmget(fmw,'mat');
		t=fmget(fmw,'y');

		%generate some colors
		nkol=6;
		c=zeros(3,nkol);
		c(1,:)=(nkol:-1:1)/nkol;%red
		c(2,:)=[2:2:nkol nkol-2:-2:0]/nkol;%green
		c(3,:)=(1:nkol)/nkol;%blue

		%get the wavelet menu handles
		hws=get(hwave,'userdata');

		set(gcf,'currentaxes',hax1);
		cla;
		set(gcf,'currentaxes',hax2);
		cla;
		set(gcf,'currentaxes',hax3);
		cla;


		%loop over wavelets and plot as requested
		for k=1:length(hws)
			if(hws(k)<0)
				%get the wavelet
				wavelet=ws(:,k);
				%get the live samples
				ilive=find(~isnan(wavelet));
				wavelet=wavelet(ilive);
				tw=t(ilive);

				%plot it in hax1
				kcol=rem(k,nkol);
				if(kcol==0) kcol=6; end
				set(gcf,'currentaxes',hax1);
				hwtime=line(tw,real(wavelet),'color',c(:,kcol)','userdata',abs(hws(k)),...
					'buttondownfcn','waveleted(''activate'')');

				%transform it
				%wp=padpow2(wavelet);
				%twp=xcoord(tw(1),tw(2)-tw(1),wp);
				wp=wavelet;
				twp=tw;
				%adjust for time zero
				izero=near(twp,0);
    			%make sure its close
    			if(abs(twp(izero))<twp(2)-twp(1))
    				wp=[wp(izero:length(wp));wp(1:izero-1)];
    			else
    				disp('***WARNING*** unable to find time zero, phase may be inaccurate')
    			end
				[W,f]=fftrl(wp,twp);
				% adjust for time zero
				%phs_shift=exp(-i*2*pi*twp(1)*f);
				%W=W.*phs_shift;
				%to db & phs
				W=todb(W);

				%plot amp spectrum
				set(gcf,'currentaxes',hax2);
				hwamp=line(f,real(W),'color',c(:,kcol)','userdata',abs(hws(k)),...
					'buttondownfcn','waveleted(''activate'')');
				%set(hax2,'ylim',[-80 0]);

				%plot phase spectrum
				set(gcf,'currentaxes',hax3);
				hwphs=line(f,180*imag(W)/pi,'color',c(:,kcol)','userdata',...
					abs(hws(k)),'buttondownfcn','waveleted(''activate'')');

				%store the curve handles in the menu userdata
				set(abs(hws(k)),'userdata',[hwtime, hwamp, hwphs]);

				if(k==1)
					dt=tw(2)-tw(1);
					set(hsaveobject,'userdata',dt);
				end

			end
		end

		set(hmsg,'string','Click on a wavelet to activate it');

		return;
	end

	% turn wavelets on and off
if(strcmp(action,'switchwave'))
		h=get(gcf,'userdata');
		hwave=h(12);
		hactive=h(13);
		hchange=h(3);
		hdelete=h(15);
		hrename=h(18);
		hws=get(hwave,'userdata');

		hmenu=gcbo;
		if(isempty(hmenu))
			hmenu=currentMenu;
			ind=find(abs(hws)==hmenu);
			if(isempty(ind))
				disp('faulty switch')
				return;
			end
		end
		ind=find(abs(hws)==hmenu);
		if(isempty(ind))
			hmenu=currentMenu;
			ind=find(abs(hws)==hmenu);
			if(isempty(ind))
				disp('faulty switch')
				return;
			end
		end

		flag=get(hmenu,'checked');

		if( strcmp(flag,'on') ) % turn it off
			set(hmenu,'checked','off','userdata',[]);
			ind=find(abs(hws)==hmenu);
			hws(ind)=hmenu;
			dat=get(hactive,'userdata');
			if( ~isempty(dat) )
			   if(hmenu==dat)
				set(hactive,'userdata',[],'string','Active Wavelet: none');
				set(hchange,'enable','off');
				set(hdelete,'enable','off');
				set(hrename,'enable','off');
			   end
			end
		else %turn it on
			set(hmenu,'checked','on');
			ind=find(abs(hws)==hmenu);
			hws(ind)=-hmenu;
		end

		set(hwave,'userdata',hws);


		waveleted('plot');

		return;

	end

% promote a wavelet to active (select it)
if( strcmp(action,'activate') )
		h=get(gcf,'userdata');
		hchange=h(3);
		hdelete=h(15);
		hrename=h(18);
		hcurve=gco;
		hmenu=get(gco,'userdata');
		wname=get(hmenu,'label');
		hactive=h(13);

		set(hactive,'userdata',hmenu,'string',['Active Wavelet: ' wname]);

		set(hchange,'enable','on');
		set(hdelete,'enable','on');
		set(hrename,'enable','on');

		return;

end

%initiate zoom
if(strcmp(action,'zoominit'))
	h=get(gcf,'userdata');
	hmsg=h(14);
	set(hmsg,'string','MB1: Draw zoom box');

	selboxinit('waveleted(''zoom'')');

	return;
end

%perform a zoom. This is called by the selbox routine after a zoom box is drawn
%This is implemented such that it deactivates itself after one zoom. Additionally
% a zero zoom box causes an autoscale. Unzoom will return the default view which
% is not an autoscale
if( strcmp(action,'zoom') )
	box=selboxfini;

	if(length(box)==5)
		delete(box(5));
	end
	xmin=min([box(1) box(3)]);
	xmax=max([box(1) box(3)]);
	ymin=min([box(2) box(4)]);
	ymax=max([box(2) box(4)]);
	%get the current axis settings
	xlim=get(gca,'xlim');
	ylim=get(gca,'ylim');
	test1=xmin-xlim(1)+xmax-xlim(2)+ymin-ylim(1)+ymax-ylim(2);
	test2=(xmin-xmax)*(ymin-ymax);
	if(abs(test1)<10*eps | abs(test2)< 10*eps)
		axis('auto')
	else
		set(gca,'xlim',[xmin xmax],'ylim',[ymin ymax]);
	end
	%turn off the zoom action
	set(gcf,'windowbuttondownfcn','');
	set(gcf,'windowbuttonmotionfcn','');
	set(gcf,'windowbuttonupfcn','');
	return;
end

%
if(strcmp(action,'unzoom') | strcmp(action,'unzoom2') )
	h=get(gcf,'userdata');
	hmsg=h(14);
	
	if(strcmp(action,'unzoom'))
		set(hmsg,'string','MB1: unzoom clicked plot  MB3: unzoom all plots');
		set(gcf,'windowbuttondownfcn','sca;waveleted(''unzoom2'')');
		return;
	end
	
	flag=get(gcf,'selectiontype');
	if(strcmp(flag,'normal'))
		hax=gca;
		%determine which axis
		ind=find(h(9:11)==hax);
		%if(ind==2)
		%	axis('auto');
		%	set(hax,'ylim',[-80 0]);
		%else
			axis('auto');
		%end
	else
		set(h(9),'ylimmode','auto','xlimmode','auto');
		set(h(10),'ylimmode','auto','xlimmode','auto');
		set(h(11),'ylimmode','auto','xlimmode','auto');
		set(h(10),'ylim',[-80,0]);
	end
	
	set(gcf,'windowbuttondownfcn','');
	set(hmsg,'string','');
	
	return;
end
	
% initiate the creation of a new wavelet through the WAVELETDESIGN
% dialog
if(strcmp(action,'new')|strcmp(action,'new2') )
	h=get(gcf,'userdata');
	hnew=h(2);
	hsaveobject=h(7);
	hquit=h(8);
	hwave=h(12);
	hmsg=h(14);

	% see if we have a non-null wavelet object and determine the sample
	% rate
	wlet=get(hquit,'userdata');
	if( ~isempty(wlet) )
		% get the wavelet matrix
		fmw=objget(wlet,'wavelets');
		% the time axis
		t=fmget(fmw,'y');
		if( length(t)<2 )
			dt=.01;
		else
			dt=t(2)-t(1);
		end
	else
		dt=get(hsaveobject,'userdata');
		if( isempty(dt) )
			dt=0;
		end
	end

	% if the first time through, put up the dialog
	if( strcmp(action,'new'))
	 dat=get(hnew,'userdata');
	 hdesign=dat(2);
	 % test to see if this is a legit design window
	 if( ~waveletdesign('test',hdesign) )
		hdesign=0;
	 end
	 if(hdesign)
		figure(hdesign);
		return;
	 else
		hfig=gcf;
		waveletdesigninit('waveleted(''new2'')',1,dt,hfig);
		hdesign=gcf;
		dat(2)=hdesign;
		set(hnew,'userdata',dat);
		return;
	 end
	end

	% complete the wavelet dialog
	[w,t,name]=waveletdesignfini(0);
	dat=get(hnew,'userdata');
	hdesign=dat(2);
	close(hdesign);
	
	%check for cancel
	if( isempty(w) )
		set(hmsg,'string','New wavelet cancelled');
		return;
	end

	% put the new wavelet in the object
	if( isempty(wlet) )
		wlet=contobj('Waveleted Wavelets','wlet');
		fmw=fmset([],1,t,w);
		wlet=objset(wlet,'wavelets',fmw);
		wlet=objset(wlet,'wavelet_names',name);
	else
		nwave=fmget(fmw,'x');
		newnum=max(nwave)+1;
		fmw=fmset(fmw,newnum,t,w);
		names=objget(wlet,'wavelet_names');
		names=strmat(names,name);
		wlet=objset(wlet,'wavelets',fmw);
		wlet=objset(wlet,'wavelet_names',names);
			%make a default file object
			fileobj=contobj('file','prvt');
			filename='undefined';
			pathname=' ';
			fileobj=objset(fileobj,'filename',filename);
			fileobj=objset(fileobj,'pathname',pathname);

			wlet=objset(wlet,'file',fileobj);
	end

	%put the wavelet object back
	set(hquit,'userdata',wlet);

	%make a new menu, set it current, and invoke its display
 	hnewwave=uimenu(hwave,'label',name,'callback','waveleted(''switchwave'')');
     
 	hwaves=get(hwave,'userdata');
 	set(hwave,'userdata',[hwaves hnewwave]);

 	%set(gcf,'currentmenu',hnewwave);
	currentMenu=hnewwave;
 	waveleted('switchwave');

 	return;

end
	
% initiate the change of an existing wavelet through the WAVELETCHANGE
% dialog
if(strcmp(action,'change') || strcmp(action,'change2') )
	h=get(gcf,'userdata');
	hnew=h(2);
	hquit=h(8);
	hwave=h(12);
	hactive=h(13);
	hmsg=h(14);
	
	%determine the name of the active wavelet
	hmenu=get(hactive,'userdata');
	if( isempty(hmenu) )
		set(hmsg,'string','Please select an active wavelet and try again');
		error('No active wavelet selected');
	end
	name=get(hmenu,'label');

	% get the wavelet object and the active wavelet
	wlet=get(hquit,'userdata');
	wletnames=objget(wlet,'wavelet_names');
	[numwaves,r]=size(wletnames);
	kwave=[];
	for k=1:numwaves
		if(strcmp(name,wletnames(k,1:length(name))))
			kwave=k;
			break;
		end
	end
	if( isempty(kwave) )
		set(hmsg,'string','Invalid active wavelet');
		return;
	end
	
	% get the wavelet matrix
	fmw=objget(wlet,'wavelets');
	% the wavelet counters
	nwave=fmget(fmw,'x');
	xwave=nwave(kwave);
	% the time axis
	twact=fmget(fmw,'y');
	% the active wavelet
	wmat=fmget(fmw,'mat');
	wact=wmat(:,kwave);
	

	% if the first time through, put up the dialog
	if( strcmp(action,'change'))
		hfig=gcf;
		%remove any nan's from the active wavelet
		ilive=find(~isnan(wact));
		wact=wact(ilive);
		twact=twact(ilive);
		waveletchangeinit('waveleted(''change2'')',wact,twact,name,hfig);
		return;
	end

	% complete the wavelet dialog
	[w,t,newname]=waveletchangefini;
	
	%check for cancel
	if( isempty(w) )
		set(hmsg,'string','Wavelet Change Cancelled');
		return;
	end

	% put the new wavelet in the object
	if( strcmp(newname,name) )
		fmw=fmset(fmw,xwave,t,w);
		wlet=objset(wlet,'wavelets',fmw);

		%put the wavelet object back
		set(hquit,'userdata',wlet);
	
		% replot		
 		waveleted('plot');

	else
		% see if the new name matches any existing name
		kwave=[];
		if(length(newname)<=r)
			for k=1:numwaves
				if(strcmp(newname,wletnames(k,1:length(newname))))
					kwave=k;
					break;
				end
			end
		end
		if( ~isempty(kwave) )
			xwave=fmget(fmw,'x');
			fmw=fmset(fmw,xwave(kwave),t,w);
			wlet=objset(wlet,'wavelets',fmw);

			%put the wavelet object back
			set(hquit,'userdata',wlet);
	
			% replot		
 			waveleted('plot');
 	else
			nwave=fmget(fmw,'x');
			newnum=max(nwave)+1;
			fmw=fmset(fmw,newnum,t,w);
			names=objget(wlet,'wavelet_names');
			names=strmat(names,newname);
			wlet=objset(wlet,'wavelets',fmw);
			wlet=objset(wlet,'wavelet_names',names);
		
			%make a new menu, set it current, and invoke its display
 			hnewwave=uimenu(hwave,'label',newname,'callback',...
					'waveleted(''switchwave'')');

 			hwaves=get(hwave,'userdata');
 			set(hwave,'userdata',[hwaves hnewwave]);

 			%hnewwave = get(gcf,'currentmenu');
			hnewwave=gcbo;

			%put the wavelet object back
			set(hquit,'userdata',wlet);
	
			% replot		
 			waveleted('switchwave');
 	end
	end
	
 return;

end

	
% delete the active wavelet 
if(strcmp(action,'delete'))
	h=get(gcf,'userdata');
	hnew=h(2);
	hchange=h(3);
	hdelete=h(15);
	hrename=h(18);
	hquit=h(8);
	hwave=h(12);
	hactive=h(13);
	hmsg=h(14);
	
	%determine the name of the active wavelet
	hmenu=get(hactive,'userdata');
	if( isempty(hmenu) )
		set(hmsg,'string','Please select an active wavelet and try again');
		error('No active wavelet selected');
	end
	name=get(hmenu,'label');

	% get the wavelet object and the active wavelet
	wlet=get(hquit,'userdata');
	wletnames=objget(wlet,'wavelet_names');
	[numwaves,r]=size(wletnames);
	for k=1:numwaves
		if(strcmp(name,wletnames(k,1:length(name))))
			kwave=k;
			break;
		end
	end
	if( isempty(kwave) )
		set(hmsg,'string','Invalid active wavelet');
		return;
	end
	
	% get the wavelet matrix
	fmw=objget(wlet,'wavelets');
	% the wavelet counters
	nwave=fmget(fmw,'x');
	xwave=nwave(kwave);
	% the time axis
	twact=fmget(fmw,'y');
	% the active wavelet
	wmat=fmget(fmw,'mat');
	wact=wmat(:,kwave);
	
	% remove the active wavelet from the object
	fmw=fmset(fmw,xwave,[],[]);
	
	wletnames=[wletnames(1:kwave-1,:);wletnames(kwave+1:numwaves,:)];
	wlet=objset(wlet,'wavelets',fmw);
	wlet=objset(wlet,'wavelet_names',wletnames);
		
	%delete the menu
 	delete(hmenu);

 	hwaves=get(hwave,'userdata');
 	ind=find(abs(hwaves)==hmenu);
 	hwaves(ind)=[];
 	set(hwave,'userdata',hwaves);
 	
	%put the wavelet object back
	set(hquit,'userdata',wlet);
	
	%
	set(hactive,'userdata',[],'string','Active Wavelet: none');

	set(hchange,'enable','off');
	set(hdelete,'enable','off');
	set(hrename,'enable','off');

	set(hmsg,'string',['Wavelet ' name ' deleted']);
	
	% replot		
 	waveleted('plot');

	
 return;
end
	
% rename the active wavelet 
if(strcmp(action,'rename')|strcmp(action,'rename2'))
	h=get(gcf,'userdata');
	hnew=h(2);
	hchange=h(3);
	hdelete=h(15);
	hrename=h(18);
	hquit=h(8);
	hwave=h(12);
	hactive=h(13);
	hmsg=h(14);
	
	%determine the name of the active wavelet
	hmenu=get(hactive,'userdata');
	if( isempty(hmenu) )
		set(hmsg,'string','Please select an active wavelet and try again');
		error('No active wavelet selected');
	end
	name=get(hmenu,'label');

	% get the wavelet object and the active wavelet
	wlet=get(hquit,'userdata');
	wletnames=objget(wlet,'wavelet_names');
	[numwaves,r]=size(wletnames);
	for k=1:numwaves
		if(strcmp(name,wletnames(k,1:length(name))))
			kwave=k;
			break;
		end
	end
	if( isempty(kwave) )
		set(hmsg,'string','Invalid active wavelet');
		return;
	end

	if(strcmp(action,'rename'))
		askthingsinit('waveleted(''rename2'')','New Name',name);
		return;
	end

	newname=askthingsfini;

	%check for cancel
	if(newname==-1)
		set(hmsg,'string','Rename cancelled');
		return;
	end

	% see if the new name matches any existing name
	kwave2=[];
	if(length(newname)<=r)
		for k=1:numwaves
			if(strcmp(newname,wletnames(k,1:length(newname))))
				kwave2=k;
				break;
			end
		end
	end

	if( ~isempty(kwave2) )
		set(hmsg,'string','The new name must be unique! Try again...');
		return;
	end
	
	names1=wletnames(1:kwave-1,:);
	names2=wletnames(kwave+1:numwaves,:);
	wletnames=strmat(names1,newname);
	wletnames=strmat(wletnames,names2);
	wlet=objset(wlet,'wavelet_names',wletnames);
		
	%rename the menu
 	set(hmenu,'label',newname);
	set(hmsg,'string','Wavelet renamed');

	%put the wavelet object back
	set(hquit,'userdata',wlet);
	
	%
	set(hactive,'userdata',[],'string',['Active Wavelet: ' newname]);

	set(hchange,'enable','off');
	set(hdelete,'enable','off');
	set(hrename,'enable','off');
	
	% reactivate		
	dat=get(hmenu,'userdata');
 set(gcf,'currentobject',dat(1));
 waveleted('activate');

	
 return;
end
%
% change the setting on a boolean flag menu item.
%
if( strcmp(action,'boolean') )
        %hthis = get(gcf,'currentmenu');
			hthis=gcbo;
        % get the current flag setting
        flag = get(hthis,'checked');
        % toggle it the other way
        if( strcmp(flag,'on') )
                set(hthis,'checked','off');
        else
                set(hthis,'checked','on');
        end

        return;

end

%
% set save options
%
if(strcmp(action,'saveopts'))
	h=get(gcf,'userdata');
 hsaveascii=h(6);
 hsaveobject=h(7);
 hsavecurrent=h(19);
 hsaveall=h(20);

 %hmenu= get(gcf,'currentmenu');
 hmenu=gcbo;
 state=get(hmenu,'checked');

	if( hmenu==hsaveascii)
		if(strcmp(state,'off')) %we turn it on
			set(hsaveascii,'checked','on');
			set(hsaveobject,'checked','off');
			set(hsaveall,'checked','off');
			set(hsavecurrent,'checked','on');
		else % turn it off
			set(hsaveascii,'checked','off');
			set(hsaveobject,'checked','on');
		end
 elseif( hmenu==hsaveobject )
		if(strcmp(state,'off')) %we turn it on
			set(hsaveascii,'checked','off');
			set(hsaveobject,'checked','on');
		else % turn it off
			set(hsaveascii,'checked','on');
			set(hsaveobject,'checked','off');
			set(hsaveall,'checked','off');
		end
 elseif(hmenu==hsavecurrent)
		if(strcmp(state,'off')) %we turn it on
			set(hsavecurrent,'checked','on');
			set(hsaveall,'checked','off');
		else %turn it off
			set(hsavecurrent,'checked','off');
			set(hsaveall,'checked','on');
			set(hsaveascii,'checked','off');
			set(hsaveobject,'checked','on');
		end
	elseif(hmenu==hsaveall)
		if(strcmp(state,'off')) %we turn it on
			set(hsavecurrent,'checked','off');
			set(hsaveall,'checked','on');
			set(hsaveascii,'checked','off');
			set(hsaveobject,'checked','on');
		else %turn it off
			set(hsavecurrent,'checked','on');
			set(hsaveall,'checked','off');
		end
	end

	return;

end

if(strcmp(action,'showsave'))
	h=get(gcf,'userdata');
    hquit=h(8);
    hmsg=h(14);

	%get the fileobj
	wlet=get(hquit,'userdata');
    fileobj=objget(wlet,'file');

	if( ~isempty(fileobj) )
		filename=objget(fileobj,'filename');
		pathname=objget(fileobj,'pathname');
	else
		filename= 'undefined';
		pathname='';
	end
	set(hmsg,'string',['Save file: ' pathname filename]);
	return;
end

if(strcmp(action,'save'))
    
    h=get(gcf,'userdata');
    hquit=h(8);
    hactive=h(13);
    hmsg=h(14);
    hsaveascii=h(6);
    hsaveobject=h(7);
    hsavecurrent=h(19);
    hsaveall=h(20);

    %get the savefile name

    wlet=get(hquit,'userdata');
    if isempty(wlet) 
       msgbox('No wavelets to save','Save error');
       return;
    end     
    fileobj=objget(wlet,'file');
		if( isempty(fileobj) )
				fileobj=contobj('file','prvt');
				filename='undefined';
				pathname=' ';
				fileobj=objset(fileobj,'filename',filename);
				fileobj=objset(fileobj,'pathname',pathname);
				wlet=objset(wlet,'file',fileobj);
				set(hquit,'userdata',wlet);
		end
    filename=objget(fileobj,'filename');
    pathname=objget(fileobj,'pathname');
    
    %determine the save options in effect
    saveobj=get(hsaveobject,'checked');
    if(strcmp(saveobj,'on'))
			saveobj=1;
    else
			saveobj=0;
	end
	
	saveall=get(hsaveall,'checked');
	if(strcmp(saveall,'on'))
		saveall=1;
	else
		saveall=0;
	end
	
	%see whether the save file is for ascii or object
	ind=findstr(filename,'.mat');
	if( isempty(ind) )
		asciifile=1;
	else
		asciifile=0;
	end

	%put up a file dialog if needed
	if (strcmp(filename,'undefined') || (saveobj && asciifile) ...
		| ~saveall | (~saveobj&~asciifile) )
        try
            % Next line can cause an error if we have never run this before
            lastOutputFile = getpref('waveleted','lastOutputFile');
        catch
            lastOutputFile = '';
        end
	    if( saveobj )
		    [filename,path]=myuifile(gcf,'*.mat','Output File Selection','put',lastOutputFile);
	    else
		    [filename,path]=myuifile(gcf,'*.dat','Output File Selection','put',lastOutputFile);
	    end

		if( isempty(filename) )
			set(hmsg,'string','Waveleted: Save aborted: no file name given');
			return;
		end
		if( filename==0)
			set(hmsg,'string','Waveleted: Save aborted');
			return;
		end

		%don't do this unles saving the entir object
		%update the fileobj
		if(saveall)
			fileobj=objset(fileobj,'filename',filename);
			fileobj=objset(fileobj,'pathname',pathname);

			wlet=objset(wlet,'file',fileobj);
			set(hquit,'userdata',wlet);
		end
        setpref('waveleted','lastOutputFile',fullfile(pathname,filename));
	end
 
	%active wavelet output
	if(~saveall)
		%get the current wavelet
		hmenu=get(hactive,'userdata');
		if( isempty(hmenu) )
			set(hmsg,'string','Save aborted: no active wavelet');
			return;
		end
		dat=get(hmenu,'userdata');
		t=get(dat(1),'xdata');
		t=t(:);
		w=get(dat(1),'ydata');
		w=w(:);
		name=get(hmenu,'label');

		ilive=find(~isnan(w));
		ilive2=find(~isnan(t(ilive)));
		w=w(ilive(ilive2));
		t=t(ilive(ilive2));

		%ascii file output
		if( ~saveobj )
			%form the full filename
			ind=findstr(filename,'.mat');
			if( ~isempty(ind) )
				set(hmsg,'string','ASCII Save aborted: filename cannot end in .mat');
				return;
			end

			ind=findstr(filename,'.dat');
			if(strcmp(computer,'MAC2'))
				fullfilename=filename(1:ind(1)-1);
			else
				fullfilename=[path filename(1:ind(1)-1)];
			end

			%write it out - t appears first, then (with no warning) w
			%appears below
			saveascii(fullfilename,t,w);

			set(hmsg,'string',['Save successful to ' fullfilename]);

			return;
		else
			%form the full filename
			%ind=findstr(filename,'.mat');
			%if( isempty(ind) )
			%	set(hmsg,'string','Object Save aborted: filename must end in .mat');
			%	return;
			%end
            ind=findstr(filename,'.mat');
		    if( isempty(ind) )
			    ind=length(filename)+1;
		    end
            
			if(strcmp(computer,'MAC2'))
				fullfilename=filename(1:ind(1)-1);
			else
				fullfilename=[path filename(1:ind(1)-1)];
			end

			%make a new wavelet object and put the current wavelet in it
			wavelets=contobj('Waveleted Output','wlet');
			fmw=fmset([],1,t,w);
			wavelets=objset(wavelets,'wavelets',fmw);
			wavelets=objset(wavelets,'wavelet_names',name);
			fileobj=contobj('file','prvt');
			fileobj=objset(fileobj,'filename',filename);
			fileobj=objset(fileobj,'pathname',pathname);
			wavelets=objset(wavelets,'file',fileobj);

			%write it out
			%eval([filename(1:ind(1)-1) '=newobj;']);

			%eval(['save ' fullfilename ' ' filename(1:ind(1)-1)]);
			save(fullfilename,'wavelets');

			set(hmsg,'string',['Save successful to ' fullfilename]);

			return;
		end
    else %output the entire wavelet object
		%form the full filename
		ind=findstr(filename,'.mat');
		if( isempty(ind) )
			ind=length(filename)+1;
		end

		if(strcmp(computer,'MAC2'))
			fullfilename=filename(1:ind(1)-1);
		else
			fullfilename=[path filename(1:ind(1)-1)];
		end

		%get the object
		obj=get(hquit,'userdata');


		%write it out
		%eval([filename(1:ind(1)-1) '=obj;']);
		wavelets=obj;

		%eval(['save ' fullfilename ' ' filename(1:ind(1)-1)]);
		%eval(['save ' fullfilename '  wavelets']);
		save(fullfilename,'wavelets');

		set(hmsg,'string',['Save successful to ' fullfilename '.mat']);

		return;
	
	end

	return;

end

if(strcmp(action,'open')|strcmp(action,'open2'))
	h=get(gcf,'userdata');
	hxmit=h(4);
 hquit=h(8);
 hactive=h(13);
 hmsg=h(14);
 hsaveascii=h(6);
 hsaveobject=h(7);
 hsavecurrent=h(19);
 hsaveall=h(20);

 %see is we have an object on the go
 obj=get(hquit,'userdata');
 if( ~isempty(obj) & strcmp(action,'open') )
		yesnoinit('waveleted(''open2'')','Save first?');
		return;
	end

	a=yesnofini;
	if( ~isempty(a) )
	   if(a==-1) %cancel
		set(hmsg,'string','Open cancelled');
		return;
	   elseif(a==1) %save
		%hsaveall=get(gcf,'currentmenu');
		hsaveall=gcbo;
		waveleted('saveopts');
		waveleted('save');
	   end
	end

	%put up the load file dialog
	[filename,path] = uigetfile('*.mat','Select Saved Wavelet File');

		if( isempty(filename) )
			set(hmsg,'string','Open failed: no file name given');
			error('no file name given');
		end
		if( filename==0 )
			set(hmsg,'string','Open failed: no file name given');
			error(' no file name given');
		end

		ind=findstr(filename,'.mat');
		if( length(ind)>0 )
			 filename=filename(1:ind-1);
		else
			set(hmsg,'string','Open failed: invalid file extension');
			disp('Selected file must be a wavelets file saved by WAVELETED');
			disp('and it must have a .mat extension on the file name');
			disp('To import a wavelet in GMA or SEGY formats, use the ''New Wavelet''');
			disp('command and select wavelet type to indicate the appropriate');
			disp('import file');
			error(' invalid file extension');
		end

		fullfilename = [path filename];

		% load the file

		if( strcmp(computer,'MAC2') )
			%eval(['load ' filename]);
			load(filename);
		else
			%eval(['load ' fullfilename]);
			load(fullfilename);
		end

		%re below: The wavelets structure is supposed to be in a variable with the same name as the file name
		% This is stupid, because if the user renames the file, the system is broken. I will modify Waveleted to put
		% the variable name as wavelets but leave the old code intact for legacy purposes

%  		if( exist(filename) ==1) 
%  		   %copy it into wlet
% 		    eval(['wlet=' filename ';']);
% 		    eval([filename '=[];']);
% 		elseif( exist('wavelets')==1)
%		    wlet=wavelets;
% 		else
%  			set(hmsg,'string','Invalid wavelets file');
%  			disp('Selected file must be a wavelets file saved by WAVELETED');
%             disp('and it must have a .mat extension on the file name');
% 			disp('To import a wavelet in GMA or SEGY formats, use the ''New Wavelet''');
% 			disp('command and select wavelet type to indicate the appropriate');
% 			disp('import file');
% 			error('#1   invalid wavelet file ');
% 	    end


		%test for earth object
		if(~isearthobj(wavelets))
			set(hmsg,'string','Invalid wavelets file');
			disp('Selected file must be a wavelets file saved by WAVELETED');
			disp('and it must have a .mat extension on the file name');
			disp('To import a wavelet in GMA or SEGY formats, use the ''New Wavelet''');
			disp('command and select wavelet type to indicate the appropriate');
			disp('import file');
			error('#2  invalid wavelet file ');
		end
		wn=objget(wavelets,'wavelet_names');
		if( isempty(wn) )
			set(hmsg,'string','Invalid wavelets file');
			disp('Selected file must be a wavelets file saved by WAVELETED');
			disp('and it must have a .mat extension on the file name');
			disp('To import a wavelet in GMA or SEGY formats, use the ''New Wavelet''');
			disp('command and select wavelet type to indicate the appropriate');
			disp('import file');
			error('#3  invalid wavelet file ');
		end

		%see if we have a master figure in control
		dat=get(hxmit,'userdata');
		transfer=get(hsaveascii,'userdata');
		if(length(dat)>1)
			hmasterfig=dat(2);
		else
			hmasterfig=0;
		end

		%clear the figure
		close(gcf);

		%reinitialize
		if(hmasterfig)
			waveleted(wavelets,hmasterfig,transfer);
		else
			waveleted(wavelets); 
		end

		return;

	end

	if( strcmp(action,'xmit'))
		h=get(gcf,'userdata');
		hxmit=h(4);
        hsaveascii=h(6);
		hquit=h(8);
		hmsg=h(14);

		%get the wavelet object
		wlet=get(hquit,'userdata');

		%get the transfer function
		transfer=get(hsaveascii,'userdata');
		if( isempty(transfer) )
			set(hmsg,'string','XMIT failed: invalid transfer function');
			error('XMIT failed: invalid transfer function');
		end

		%get the master figure
		dat=get(hxmit,'userdata');
		hmasterfig=dat(2);

		hfigs=figs;
		ind=find(hfigs==hmasterfig);

		if( isempty(ind) )
			set(hmsg,'string','XMIT failed: invalid master figure');
			error('XMIT failed: invalid master figure');
		end

		set(hmsg,'string',['Wavelets transferred to ' transfer]);

		figure(hmasterfig);

		%form the transfer string and evaluate
		eval([transfer '(''wavelets'',wlet)']);

		return;

	end

function positionWindow(hfig,appname,windowname,xsize,ysize)
    % Attempt to use the last window size and position.
    % If the last window size and position are rediculous, just plonk the
    % window in the middle of the screen at the specified size in pixels.
    prevunits = get(0,'units');
    set(0,'units','pixels');
    s = get(0,'screensize');
    set(0,'units',prevunits);
    skipprefs = false;
    try 
        p = getpref(appname,[windowname  'windowposition']);
        beyondTopOrRight = any([p(1) p(2) + p(4)] > s(3:4));
        beyondBottomOrLeft = any(p(1:2) < s(1:2));
        tooSmall = any(p(3:4) < 100);
        if  beyondTopOrRight || beyondBottomOrLeft  || tooSmall
            skipprefs = true;
        end
    catch
        skipprefs = true;
    end
        
    if skipprefs
         p = [(s(3)-xsize)/2 (s(4)-ysize)/2 xsize ysize];    
    end

    prevunits = get(hfig,'units');   
    set(hfig,'position',p);
    set(0,'units',prevunits);

    
function saveWindowPosition(hfig,appname,windowname)
    prevunits = get(hfig,'units');
    set(hfig,'units','pixels');
    p = get(gcf,'position');
    setpref(appname,[windowname 'windowposition'],p);
    set(hfig,'units',prevunits);
