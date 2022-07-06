function figflag=waveletdesign(action,htestfig)
% 
% The WAVELETDESIGN dialog is initiated by calling WAVELETDESIGNINIT which
% then calls WAVELETDESIGN. With one exception, WAVELETDESIGN is never called
% directly from another program. Tha exception is when another program has
% a figure handle that may be a legitimate WAVELETDESIGN window or not.
% Calling waveletdesign('test',figurehandle) will return 1 if it is a legit
% design window and zero otherwise.
%
% G.F. Margrave
%
figflag=[]; ind=[];

% userdata assignments
%
% Figure userdata:
%		set(hfig,'userdata',[hmsg,htypelabel,htype,hamplabel,hamp,...
%			hbandplabel,hbandp,hdomlabel,hdom,hsweeplabel,...
%			hsweep,hlengthlabel,hlength,hsamplabel,hsamp,...
%			hdone hconstplabel hconstp hnamelabel hname,...
%			hcancel,htzsamplabel,htzsamp hnorm]);
%
% all unused except:
% htype ... filename and pathname strings for import from disk
% hmsg ... the transfer function
% hdone ... the handle of the master figure
% hname ... temporary storage for wavelet while importing
%
%
if(strcmp(action,'init'))

		% get the input information
		stuff=get(gca,'userdata');
		ind=find(isnan(stuff));
		transfer=stuff(1:ind(1)-1);
		nameflag=stuff(ind(1)+1);
		dt=stuff(ind(2)+1);
		hfigmaster=stuff(ind(3)+1);

		%get the new figure
		hfig=gcf;
		set(gca,'visible','off');
		geom=get(hfig,'position');
		figwidth=402;
		if( nameflag )
			figheight=190;
		else
			figheight=170;
		end

		% a top label
		height=20;
		sep=1;
		ynow=figheight-height-sep;
		xnow=sep;
		width=figwidth;
        
        set(hfig, 'Name', 'Wavelet Design Specification','NumberTitle','off');
        
		hmsg=uicontrol('style','text','string',...
			'','position',...
			[xnow,ynow,width,height]);

		% a wavelet type label and popup
		width=200;
		xnow=sep;
		ynow=ynow-height-sep;
		htypelabel=uicontrol('style','text','string','Wavelet Type:',...
			'position',[xnow,ynow,width,height]);

		xnow=xnow+width+sep;
		width=200;
		htype=uicontrol('style','popupmenu','string',...
			'Constant Phase|Minimum Phase|Import GMA or SEGY','position',...
			[xnow,ynow,width,height],'callback','waveletdesign(''type'');');

		%now the amplitude spectrum selector
		xnow=sep;
		ynow=ynow-height-sep;
		width=200;
		hamplabel=uicontrol('style','text','string','Amplitude Spectrum:',...
			'position',[xnow,ynow,width,height]);

		xnow=xnow+width+sep;
		width=200;
		hamp=uicontrol('style','popupmenu','string',...
			'Bandpass|Simulated Imp Source|Ricker|Vibroseis',...
			'position',[xnow,ynow,width,height],'callback',...
			'waveletdesign(''amp'');');

		% the bandpass parameters

		xnow=sep;
		ynow=ynow-height-sep;
		width=250;
		hbandplabel=uicontrol('style','text','string',...
			'Bandpass parms (f1 f2 f3 f4 in Hz):',...
			'position',[xnow,ynow,width,height]);
		
		xnow=xnow+width+sep;
		width=150;
		hbandp=uicontrol('style','edit','string','5 10 60 70',...
			'position',[xnow,ynow,width,height],'HorizontalAlignment','left');

		% the dominant frequency parameter
		xnow=sep;
		width=200;

		hdomlabel=uicontrol('style','text','string','Dominant Frequency (Hz):',...
			'position',[xnow,ynow,width,height],'visible','off');

		xnow=xnow+width+sep;
		width=50;
		hdom=uicontrol('style','edit','string','40','position',...
			[xnow,ynow,width,height],'visible','off','HorizontalAlignment','left');

		% the sweep parameters
		xnow=sep;
		width=300;
		hsweeplabel=uicontrol('style','text','string',...
			'Sweep (minf  maxf (Hz), sweep length (sec)) :',...
			'position',[xnow,ynow,width,height],'visible','off');

		xnow=xnow+width+sep;
		width=100;
		hsweep=uicontrol('style','edit','string','10 80 12','position',...
			[xnow,ynow,width,height],'visible','off','HorizontalAlignment','left');

		% the constant phase infor
		xnow=sep;
		ynow=ynow-height-sep;
		width=200;
		hconstplabel=uicontrol('style','text','string',...
			'Constant Phase (degrees):','position',[xnow,ynow,width,height]);

		xnow=xnow+width+sep;
		width=50;
		hconstp=uicontrol('style','edit','string','0.0','position',...
			[xnow,ynow,width,height],'HorizontalAlignment','left');

		%the wavelet length
		xnow=sep;
		ynow=ynow-height-sep;
		width=200;
		hlengthlabel=uicontrol('style','text','string',...
			'Wavelet length (seconds):',...
			'position',[xnow,ynow,width,height]);

		xnow=xnow+width+sep;
		width=50;
		hlength=uicontrol('style','edit','string','.2','position',...
			[xnow,ynow,width,height],'HorizontalAlignment','left');

		%the normalize check box
		xnow=sep;
		width=200;
		hnorm=uicontrol('style','checkbox','string','Normalize wavelet',...
		'position',[xnow,ynow,width,height],'visible','off','value',1);

		%the wavelet sample rate
		xnow=sep;
		ynow=ynow-height-sep;
		width=200;
		hsamplabel=uicontrol('style','text','string','Sample rate (seconds):',...
			'position',[xnow,ynow,width,height]);

		xnow=xnow+width+sep;
		if(dt)
			width=50;
			hsamp=uicontrol('style','text','string',num2str(dt),...
				'position',[xnow,ynow,width,height]);
		else
			width=50;
			hsamp=uicontrol('style','edit','string','.002',...
				'position',[xnow,ynow,width,height],'HorizontalAlignment','left');
		end

		%the sample number of time zero
		xnow=sep;
		width=350;
		htzsamplabel=uicontrol('style','text','string','',...
			'position',[xnow,ynow,width,height],'visible','off');

		xnow=xnow+width+sep;
		width=50;
		htzsamp=uicontrol('style','edit','string','','position',...
			[xnow,ynow,width,height],'visible','off','HorizontalAlignment','left');


		% the name field
		if(nameflag)
			xnow=sep;
			ynow=ynow-height-sep;
			width=100;
			hnamelabel=uicontrol('style','text','string','Wavelet Name:',...
				'Position',[xnow,ynow,width,height]);
			
			xnow=xnow+width+sep;
			width=200;
			hname=uicontrol('style','edit','string','','position',...
				[xnow,ynow,width,height],'HorizontalAlignment','left');
		else
			hnamelabel=0;
			hname=0;
		end

		%the done button

		xnow=sep;
		width=60;
		ynow=ynow-height-sep;
		hdone=uicontrol('style','pushbutton','string','Done','position',...
			[xnow,ynow,width,height],'callback','waveletdesign(''done'');');

		%the cancel button
		xnow=xnow+width+sep;
		width=60;
		hcancel=uicontrol('style','pushbutton','string','Cancel','position',...
			[xnow,ynow,width,height],'callback','waveletdesign(''cancel'');');

		set(hfig,'position',[geom(1:2) figwidth figheight]);
		set(hfig,'visible','on');
		set(hfig,'userdata',[hmsg,htypelabel,htype,hamplabel,hamp,...
			hbandplabel,hbandp,hdomlabel,hdom,hsweeplabel,...
			hsweep,hlengthlabel,hlength,hsamplabel,hsamp,...
			hdone hconstplabel hconstp hnamelabel hname,...
			hcancel htzsamplabel htzsamp hnorm]);

		% put the transfer command in hmsg userdata
		set(hmsg,'userdata',transfer);

		%put the master figure handle in hdone
		set(hdone,'userdata',hfigmaster);

		return;

	end

	% switch the amplitude specs panel
	if(strcmp(action,'amp') )
		h=get(gcf,'userdata');
		htype=h(3); % 1=constant phase, 2=min phase, 3=read from file
		hamp=h(5);
		hbandplabel=h(6);
		hbandp=h(7);
		hdomlabel=h(8);
		hdom=h(9);
		hsweeplabel=h(10);
		hsweep=h(11);
		hconstplabel=h(17);
		hconstp=h(18);

		%get the value of the popup
		flag=get(hamp,'value');

		%get the wavelet type
		typeflag=get(htype,'value');

		if(flag==1)
			set(hbandplabel,'visible','on');
			set(hbandp,'visible','on');
			if(typeflag==1)
				set(hconstplabel,'visible','on');
				set(hconstp,'visible','on');
			else
				set(hconstplabel,'visible','off');
				set(hconstp,'visible','off');
			end

			set(hdomlabel,'visible','off');
			set(hdom,'visible','off');
			set(hsweeplabel,'visible','off');
			set(hsweep,'visible','off');
		elseif( flag==2 | flag==3 )
			set(hbandplabel,'visible','off');
			set(hbandp,'visible','off');
			if(typeflag==1)
				set(hconstplabel,'visible','on');
				set(hconstp,'visible','on');
			else
				set(hconstplabel,'visible','off');
				set(hconstp,'visible','off');
			end
			set(hdomlabel,'visible','on');
			set(hdom,'visible','on');
			set(hsweeplabel,'visible','off');
			set(hsweep,'visible','off');
		elseif( flag==4 )
			set(hbandplabel,'visible','off');
			set(hbandp,'visible','off');
			if(typeflag==1)
				set(hconstplabel,'visible','on');
				set(hconstp,'visible','on');
			else
				set(hconstplabel,'visible','off');
				set(hconstp,'visible','off');
			end
			set(hdomlabel,'visible','off');
			set(hdom,'visible','off');
			set(hsweeplabel,'visible','on');
			set(hsweep,'visible','on');
		end

		return;
	end

% process the done button
if( strcmp(action,'done') | strcmp(action,'done2') )
	h=get(gcf,'userdata');
	htype=h(3);
	hmsg=h(1);
	hamplabel=h(4);
	hamp=h(5);
	hbandplabel=h(6);
	hbandp=h(7);
	hdomlabel=h(8);
	hdom=h(9);
	hsweeplabel=h(10);
	hsweep=h(11);
	hlengthlabel=h(12);
	hlength=h(13);
	hsamplabel=h(14);
	hsamp=h(15);
	hdone=h(16);
	hconstplabel=h(17);
	hconstp=h(18);
	hname=h(20);
	htzsamplabel=h(22);
	htzsamp=h(23);
	hnorm=h(24);

	%see what type of wavelet
	typeflag=get(htype,'value');

	% the constant phase section
	if( typeflag==1 | typeflag==2 ) 
		

		% get the sample rate
		dt=sscanf(get(hsamp,'string'),'%f');

		if(isempty(dt))
			msgbox('You must supply a numeric sample rate',...
                   'Wavelet Design Specification Error','error');
			return;
		end

		if( dt<=0 | dt>1.0 )
			msgbox('Sample rate must be a positive number in seconds',...
			       'Wavelet Design Specification Error','error');
			return;
		end

		fnyq=1./(2*dt);

		
		% determine the amplitude spectrum option
		ampopt=get(hamp,'value');

		if( ampopt==1 ) %we are doing a bandpass
			%get the parameters
			bparms=sscanf(get(hbandp,'string'),'%f %f %f %f');
			%test for validity
			if( length(bparms)<4 )
				msgbox('There must be 4 bandpass parameters',...
                       'Wavelet Design Specification Error','error');
				return;
			end

			b=sort(bparms);
			test=sum(b-bparms);
			if( test )
				msgbox('The bandpass parameters must monotonically increase',...
                       'Wavelet Design Specification Error','error');
    			return;
			end

			inf=find(bparms>=fnyq);
			if(~isempty(ind))
				msgbox(['All frequencies must be less than Fnyquist= ' num2str(fnyq)],...
                       'Wavelet Design Specification Error','error');
				return;
			end

		elseif(ampopt==2|ampopt==3)
			%get the dominant frequency
			fdom=sscanf(get(hdom,'string'),'%f');

			if( length(fdom)==0 | fdom<=0)
				msgbox('Dominant frequency must be a positive number in Hertz',...
                       'Wavelet Design Specification Error','error');
					return;
			end

			if( fdom>=fnyq )
				msgbox(...
                    ['All frequencies must be less than Fnyquist= ' num2str(fnyq)],...
                     'Wavelet Design Specification Error','error');
				return;
			end
		elseif( ampopt==4)
			%get the sweep parameters
			sparms=sscanf(get(hsweep,'string'),'%f %f %f');
			if( length(sparms) < 3 )
                 msgbox('There must be at 3 sweep parameters',...
                       'Wavelet Design Specification Error','error');
				return;
			end

			inf=find(sparms(1:2)>=fnyq);
			if(~isempty(ind))
				msgbox(...
					['All frequencies must be less than Fnyquist= ' num2str(fnyq)],...
					'Wavelet Design Specification Error','error');
				return;
			end

			if(sparms(3) <1)
                msgbox('Sweep length must be at least 1 second',...
                       'Wavelet Design Specification Error','error');
				return;
			end
			if(sparms(3)>100)
                msgbox('Sweep length must be less than 100 seconds',...
                       'Wavelet Design Specification Error','error');
				return;
			end
		end

		if(typeflag==1)
			% get the constant phase parameter
			phs=sscanf(get(hconstp,'string'),'%f');
			if(isempty(phs))
				msgbox('You must supply a numeric constant phase',...
                       'Wavelet Design Specification Error','error');
				return;
			end

			if( phs<-180 | phs> 180 )
                msgbox('Phase angle must be between -180 and 180',...
                    'Wavelet Design Specification Error','error');
				return;
			end
		end

		%get the wavelet length
		tlength=sscanf(get(hlength,'string'),'%f');

		if(isempty(tlength))
			msgbox('You must supply a numeric wavelet length',...
			       'Wavelet Design Specification Error','error');
			return;
		end

		if( tlength <= 0.0 )
            msgbox('Wavelet length must be a positive number in seconds',...
                   'Wavelet Design Specification Error','error');
			return;
		end

		if( tlength > 1.0 )
            msgbox('Wavelet length can not exceed 1 second',...
                   'Wavelet Design Specification Error','error');
			return;
		end
		% get the name
		if(hname)
			name=get(hname,'string');
			if(strcmp(name,''))
				msgbox('You must provide a name for the wavelet',...
					   'Wavelet Design Specification Error','error');
				return;
			end
		else
			name=[];
		end

		% ok make the filter
		if(typeflag==1)
			t=-tlength/2:dt:tlength/2;
			if( ampopt==1 )
				fmin=[bparms(2) bparms(2)-bparms(1)];
				fmax=[bparms(3) bparms(4)-bparms(3)];
				wavelet=filtf(spike(t),t,fmin,fmax,0,100);
			elseif( ampopt==2)
				[wavelet,t]=wavez(dt,fdom,tlength);
			elseif( ampopt==3)
				[wavelet,t]=ricker(dt,fdom,tlength);
			elseif( ampopt==4)
				[wavelet,t]=wavevib(sparms(1),sparms(2),dt,sparms(3),tlength);
			end
			
			 
			%phase rotate if needed
			if(phs~=0)
				wavelet=phsrot(wavelet,phs);
			end
		elseif(typeflag==2)
			t=0:dt:tlength;
			if( ampopt==1 )
				fmin=[bparms(2) bparms(2)-bparms(1)];
				fmax=[bparms(3) bparms(4)-bparms(3)];
				wavelet=filtf(spike(t,1),t,fmin,fmax,1,100);
			elseif( ampopt==2)
				[wavelet,t]=wavemin(dt,fdom,tlength);
			elseif( ampopt==3)
				[wavelet,t]=ricker(dt,fdom,tlength);
				t=xcoord(0,dt,t);
				wavelet=tomin(wavelet);
			elseif( ampopt==4)
				[wavelet,t]=wavevib(sparms(1),sparms(2),dt,sparms(3),tlength);
				t=xcoord(0,dt,t);
				wavelet=tomin(wavelet);
			end
		end


		%make sure it tapers smoothly to zero
		%mw=mwindow(t);
		%wavelet=wavelet.*mw;

	elseif(typeflag==3) %import a wavelet from an ascii file on disk

			%get the wavelet
			dat=get(hname,'userdata');
			wavelet=dat(:,1);
			t=dat(:,2);

			%verify the time zero sample number
			zerosamp=sscanf(get(htzsamp,'string'),'%f');
			if(isempty(zerosamp))
				msgbox('Provide the sample number of zero time',...
				'Wavelet Design Specification Error','error');
				return;
			elseif( zerosamp<0 | zerosamp>length(wavelet) )
				msgbox('Number of sample zero is illogical',...
                       'Wavelet Design Specification Error','error');
				return;
			end

	
			% get the wavelet name
			if(hname)
				name=get(hname,'string');
				if(strcmp(name,''))
					msgbox('You must provide a name for the wavelet',...
                           'Wavelet Design Specification Error','error');  
					return;
				end
			else
				name=[];
			end
			% get the sample rate
			dt=sscanf(get(hsamp,'string'),'%f');

			%if(isempty(dt))
				%msgbox('You must supply a numeric sample rate',...
				%'Wavelet Design Specification Error','error');
				%return;
			%end

			if( dt<=0 | dt>1.0 )
				msgbox('Sample rate must be a positive number in seconds',...
                       'Wavelet Design Specification Error','error');
				return;
			end

			%shift for time zero
			zsamp=near(t,0.0);
			if(zsamp~=zerosamp)
				shift=zerosamp-zsamp;
				if((round(shift)-shift)==0)
					%integral sample shift
					t=t-dt*shift;
				else
					[wavelet,t]=stat(wavelet,t,-dt*shift,1);
				end
			end

			%normalize if requested
			if(get(hnorm,'value'))
				wavelet=wavenorm(wavelet,t,2);
			end
	end

		%see if there is a master figure and, if so, store the wavelet in its 
		% current axes userdat. Otherwise put it in this figure gca userdata
		hfigmaster=get(hdone,'userdata');
		if( hfigmaster )
			figure(hfigmaster);
			hax=get(hfigmaster,'currentaxes');
		else
			hax=gca;
		end

		% put the filter in axes userdata
		set(hax,'userdata',[t(:);nan; wavelet(:);nan;abs(name(:))]);
		
		% restore the waveletdesign panel to nominal configuration
		set(htype,'value',1);
		set(hamplabel,'visible','on');
		set(hamp,'visible','on','value',1);
		set(hbandplabel,'visible','on');
		set(hbandp,'visible','on');
		set(hdomlabel,'visible','off');
		set(hdom,'visible','off');
		set(hsweeplabel,'visible','off');
		set(hsweep,'visible','off');
		set(hlengthlabel,'visible','on');
		set(hlength,'visible','on');
		set(hsamplabel,'visible','on');
		set(hsamp,'visible','on');
		set(hconstplabel','visible','on');
		set(hconstp,'visible','on');
		set(htzsamplabel,'string','','visible','off');
		set(htzsamp,'string','','visible','off');
		set(hnorm,'visible','off');
		set(hname,'string','');

		% call the transfer function
		transfer=char( get(hmsg,'userdata') );
		eval(transfer);

		return;

	end

% process the cancel button
if( strcmp(action,'cancel') )
	h=get(gcf,'userdata');
	hmsg=h(1);
	hdone=h(16);

		transfer=char( get(hmsg,'userdata') );
		hfigmaster=get(hdone,'userdata');
		%close(gcf);
		%see if there is a master figure and, if so, store the answer in its 
		% current axes userdat. Otherwise put it in this figure gca userdata
		if( hfigmaster )
			figure(hfigmaster);
			hax=get(hfigmaster,'currentaxes');
		else
			hax=gca;
		end

		% put the answer in axes userdata
		set(hax,'userdata',-1);

		% call the transfer function
		eval(transfer);



		return;

	end

if(strcmp(action,'test'))
	% examine testfig to see if it is a legit wavelet design window
	% first see if it is a figure
	allfigs=figs;
	ind=find(allfigs==htestfig);
	if(~isempty(ind))
		h=get(htestfig,'userdata');
		if(~isempty(h))
			kids=get(htestfig,'children');
			ind=find(kids==h(2));
			if(~isempty(ind))
				test=get(h(2),'type');
				if( strcmp(test,'uicontrol') )
					test=get(h(2),'string');
					if(strcmp(test,'Wavelet Type:'));
						figflag=1;
						return;
					end
				end
			end
		end
	end

	figflag=0;
	return;
end

% the type callback
if(strcmp(action,'type'))
	h=get(gcf,'userdata');
	hmsg=h(1);
	htype=h(3);
	hamplabel=h(4);
	hamp=h(5);
	hbandplabel=h(6);
	hbandp=h(7);
	hdomlabel=h(8);
	hdom=h(9);
	hsweeplabel=h(10);
	hsweep=h(11);
	hlengthlabel=h(12);
	hlength=h(13);
	hsamplabel=h(14);
	hsamp=h(15);
	hconstplabel=h(17);
	hconstp=h(18);
	hmsg=h(1);
	hdone=h(16);
	hname=h(20);
	htzsamplabel=h(22);
	htzsamp=h(23);
	hnorm=h(24);


	wavetype=get(htype,'value');
        % wavetype
        %   1             constant phase
        %   2             minumum phase
        %   3             import from file

	if(wavetype==1 | wavetype==2)
		%turn on a lot of things
		set(hamplabel,'visible','on');
		set(hamp,'visible','on');
		set(hdomlabel,'visible','on');
		set(hdom,'visible','on');
		set(hbandplabel,'visible','on');
		set(hbandp,'visible','on');
		set(hsweeplabel,'visible','on');
		set(hsweep,'visible','on');
		set(hlengthlabel,'visible','on');
		set(hlength,'visible','on');
		set(hsamplabel,'visible','on');
		set(hsamp,'visible','on');
		set(hconstplabel,'visible','on');
		set(hconstp,'visible','on');
		set(htzsamplabel,'visible','off');
		set(htzsamp,'visible','off');
		set(hnorm,'visible','off');
		
		waveletdesign('amp');
		return;
	end

 %if here, we read in a wavelet and ask for its name
	% put up the file navigation widget
	hthisfig=gcf;
	[filename,pathname]=myuifile(hthisfig,'*','Select GMA or SEGY file','get');
	if(filename==0 | isempty(filename))
		msgbox('Input aborted','Wavelet Design Specification Warning','warn');
		return;
	end

	figure(hthisfig);

	[wavelet,t,wname]=readwavelet([pathname filename]);
    
    if(strcmp(wname,'nameless')==1)
        tmpname=get(hname,'string');
        if(~isempty(tmpname))
            wname=tmpname;
        end
    end

	if( wavelet == -1)
		%try reading it as SEGY
		[wavelet,dt]=altreadsegy([pathname filename]);
        t=(0:length(wavelet)-1)*dt;
		if(isempty(wavelet))
			msgbox('Unable read file');
			return;
		end
		wname='SEGY import';
		zerosamp=[];
	else
		zerosamp=near(t,0.0);
	end

	%now test the sample rate
	dtin=t(2)-t(1);
	dt=str2num(get(hsamp,'string'));
	if( abs(dt-dtin) > .00000001 )
		%sample rates don't match
		flag=get(hsamp,'type');
		if(strcmp(flag,'edit'))
			set(hsamp,'string',num2str(dtin));
		else
			%resample the wavelet
			[wavelet,t]=resamp(wavelet,t,dt,[t(1) t(length(t))],0);
			telluserinit(['Wavelet was resampled from '...
				num2str(dtin) '(sec) to ' num2str(dt) '(sec)']);
			if(~isempty(zerosamp))
				zerosamp=near(t,0.0);
			end
		end
	end

	%store the name and wavelet
	
	%turn off a lot of things
	set(hamplabel,'visible','off');
	set(hamp,'visible','off');
	set(hdomlabel,'visible','off');
	set(hdom,'visible','off');
	set(hbandplabel,'visible','off');
	set(hbandp,'visible','off');
	set(hsweeplabel,'visible','off');
	set(hsweep,'visible','off');
	set(hlengthlabel,'visible','off');
	set(hlength,'visible','off');
	set(hsamplabel,'visible','off');
	set(hsamp,'visible','off');
	set(hconstplabel,'visible','off');
	set(hconstp,'visible','off');

	%do the zero time stuff
	if(isempty(zerosamp))
		set(htzsamplabel,'string',...
		['Wavelet has ' int2str(length(wavelet)) ...
		' samples. Time zero is sample number: '],...
		'visible','on');
		set(htzsamp,'string','','visible','on','backgroundcolor','red',...
		'foregroundcolor','yellow');
	else
		set(htzsamplabel,'string',...
		['Wavelet has ' int2str(length(wavelet)) ...
		' samples. Time zero is sample number: '],...
		'visible','on');
		set(htzsamp,'string',int2str(zerosamp),'visible','on',...
		'backgroundcolor','cyan',...
		'foregroundcolor','black');
	end

	set(hnorm,'visible','on');

	set(hname,'string',wname,'foregroundcolor','k','backgroundcolor','c');
	set(hname,'userdata',[wavelet t]);
	
    if(strcmp(wname,'nameless'))
		msgbox(...
			'Please provide a name for the wavelet');
		return;
    end
    

end
