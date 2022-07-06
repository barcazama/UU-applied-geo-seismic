function init();
(compiled==0)
scaleopt=[];
mxs2=[]; % set(hscale,'userdata',[scaleopt mxs2 mns smean2 stddev2]);
mns=[]; % set(hmaster,'userdata',[mxs smean stddev]);
smean2=[];
stddev2=[];
mxs=[];
smean=[];
stddev=[];
hi=[0];     % no image yet
ampflag=1;
scaleopt=2;
clip=4;
clips=[30 25 20 15 10 9 8 7 6 5 4 3 2 1 .5 .25 .1 .05 .01 .005 .001];
iclip=near(clips,clip);
clip=clips(iclip);
enb='off';   % buttons not allowed on yet
% Building menus
checkscreen=get(0,'screensize');
if(checkscreen(3)>=1000)
    wid=.4;
else
    wid=.8;
end
cfig1=figcent(wid,.4);
set(cfig1,'name','Seismic Image Plot, Simplezooming installed (Use MB1)',...
    'closerequestfcn',@PI_Close,'tag','PLOTIMAGEFIGURE',...
    'menubar','none');
set(gca,'visible','off');
selboxinit('plotimage(''zoom'')',1);
% File Menus
hfile1=uimenu(gcf,'Label','File','enable','on');
hf=uimenu(hfile1,'Label','Open .mat','visible','on','callback','OpenFile',...
    'userdata',{[1] gcf []});
hf=uimenu(hfile1,'Label','Open Segy','visible','on','callback','OpenFile',...
    'userdata',{[2] gcf []});
hfsave=uimenu(hfile1,'label','Save','callback','SaveFile','separator','on',...
    'userdata',{[1] gcf []});
hf=uimenu(hfile1,'label','Save As','callback','SaveFile',...
    'userdata',{[2] gcf []});
% 	hf=uimenu(hfile1,'label','Open Properties','callback','OpenFile',...
% 	'userdata',{[4] gcf []},'separator','on');
% 	hf=uimenu(hfile1,'label','Save Properties','callback','SaveFile',...
% 	'userdata',{[3] gcf []});
if(length(findobj(0,'type','figure','tag','PLOTIMAGEFIGURE'))<=1)
    hf=uimenu(hfile1,'label','Spawn New Image','callback','plotimage(''init'')','separator','on');
end
filenames=[];
previousload=[];
if(isempty(filenames))
    % if there is no previous loaded session, this is creating blank
    % menu items
    xx1=uimenu(hfile1,'separator','on','callback','OpenFile',...
        'visible','off','userdata',{[3] gcf []},'tag','QUICK_OPENFILE');
    previousload=[previousload xx1];
    for ii=1:3
        xx=uimenu(hfile1,'callback','OpenFile',...
            'visible','off','userdata',{[3] gcf []});
        previousload=[previousload xx];
    end
    set(xx1,'userdata',{[3] gcf previousload});
elseif(~isempty(filenames))
    % this is creating menu items for the files that were previously load
    % in other sessions
    for ii=1:4
        vis='on';
        if(isempty(strunpad(filenames(ii,:))))
            vis='off';
        end
        if(size(filenames,1)>=ii)
            lbl=strunpad(filenames(ii,:));
            xx1=uimenu(hfile,'label',strunpad(lbl),...
                'callback','OpenFile','visible',vis,...
                'userdata',{[3] gcf []});
        else
            xx=uimenu(hfile,'callback','OpenFile',...
                'visible',vis,'userdata',{[3] gcf []},'userdata');
        end
        previousload=[previousload xx];
        set(previouload(1),'userdata',[[3] gcf previousload],'separator','on',...
            'tag','QUICK_OPENFILE');
    end
end
hf=uimenu(hfile1,'label','Close','callback',@PI_Close,'separator','on',...
    'userdata',[gcf]);  % closing will be different for master figs and spawened figs

% Option Menus
hfile2=uimenu(gcf,'label','Options','tag','PLOTIMAGEOPTIONS','enable',enb);
hf1=uimenu(hfile2,'label','Limit Box: ON','enable','on','tag','LIMITBOXMENU',...'
    'callback','LmLnActivation');
hf2=uimenu(hfile2,'label','Visibility of Data Figure','callback','plotimage(''limlnfigurevis'')',...
    'enable','off','tag','LIMITBOXDATAFIGUREMENU');
if(isempty(PICKS))
    PICKS={[gcf] [] []};
else
    PICKS{size(PICKS,1)+1,1}=gcf;
end

%put the x axis on top
if(XAXISTOP)
    set(gca,'xaxislocation','top')
end

%make a few buttons
sep=.005;
ht=.05;
wd=.11;
x=sep;
hzoompick=uicontrol('style','popupmenu',...
    'string','Zoom|Pick(O)|Pick(N)',...
    'units','normalized','tooltipstring','Define mouse action as zoom or pick',...
    'position',[x 0 wd ht],'callback','plotimage(''zoompick'')',...
    'enable',enb);
x=x+wd+sep;
wd=.18;
hflip=uicontrol('style','popupmenu',...
    'string','Normal Polarity|Reverse Polarity',...
    'units','normalized','tooltipstring','Set display polarity',...
    'position',[x 0 wd ht],'callback','plotimage(''flip'')',...
    'userdata',1,'enable',enb);
x=x+wd+sep;
wd=.05;
fsize=get(0,'factoryuicontrolfontsize');
black=[0 0 0];white=[1 1 1];
hbrighten=uicontrol('style','pushbutton','fontsize',fsize/3,'string','brt',...
    'units','normalized','tooltipstring','Brighten the image','backgroundcolor',white,'foregroundcolor',black,...
    'position',[x 0 wd ht],'callback','brighten(.5)','visible','off','enable',enb);
x=x+wd+sep;
hdarken=uicontrol('style','pushbutton','fontsize',fsize/3,'string','drk',...
    'units','normalized','tooltipstring','Darken the image','backgroundcolor',black,'foregroundcolor',white,...
    'position',[x 0 wd ht],'callback','brighten(-.5)','visible','off','enable',enb);

x=x-wd-sep;
wd=.1;
fsize=get(0,'factoryuicontrolfontsize');
hlabel=uicontrol('style','text','fontsize',fsize/2,'string','Bright 0','units','normalized',...
    'position', [x,ht/2,wd,2*ht/3],'tooltipstring','Current brightness level','userdata',0,'enable',enb);
hslider=uicontrol('style','slider','string','Bright','units','normalized','position',...
    [x,0,wd,ht/2],'callback','plotimage(''brighten'')',...
    'tooltipstring','Set image brightness','max',10,'min',-10,...
    'tag','phase','value',0,'userdata',hlabel,'sliderstep',[1/20 1/20],'enable',enb);

%  wd=.1;
%  fsize=get(0,'factoryuicontrolfontsize');
%  hbrighten=uicontrol('style','pushbutton','fontsize',fsize/3,'string','brighten',...
%  	'units','normalized',...
% 	'position',[x ht/2 wd ht/2],'callback','brighten(.5)');
% 	 %x=x+wd+sep;
%  hdarken=uicontrol('style','pushbutton','fontsize',fsize/3,'string','darken',...
%  	'units','normalized',...
% 	'position',[x 0 wd ht/2],'callback','brighten(-.5)');
x=x+wd+sep;
wd=.1;
hcmap=uicontrol('style','pushbutton','string','Colormap',...
    'units','normalized',...
    'position',[x 0 wd ht],'callback','plotimage(''colormap'')',...
    'visible','off','enable',enb);
%x=x+wd+sep;
wd=.17;
% user data for below is being used
hmsg=uicontrol('style','text','string','Polarity Normal',...
    'units','normalized',...
    'position',[x 0 wd ht],'visible','off','enable',enb);
%x=x+wd+sep;
x=x+sep;
wd=.1;
hmaster=uicontrol('style','popupmenu','string','Ind.|Master|Slave',...
    'units','normalized','position',[x,0,wd,ht],'tooltipstring','Define amplitude control',...
    'callback','plotimage(''rescale'')','value',ampflag,'enable',enb);
x=x+wd+sep;
wd=.16;
hscale=uicontrol('style','popupmenu','string',str2mat('Mean scaling',...
    'Max scaling'),'units','normalized','position',[x,0,wd,ht],'tooltipstring','Define data scaling mechanism',...
    'callback','plotimage(''rescale'')','value',scaleopt,'enable',enb);
vis='on'; if(scaleopt==2) vis='off'; end
x=x+wd+sep;
wd=.15;
nclips=length(clips);
clipmsg=num2strmat(clips);
clipmsg=[ones(nclips,1)*'Cliplevel: ' num2strmat(clips)];
hclip=uicontrol('style','popupmenu','string',clipmsg,...
    'units','normalized','position',[x,0,wd,ht],'tooltipstring','Set clip level in std deviations',...
    'callback','plotimage(''rescale'')','value',iclip,...
    'visible',vis,'enable',enb);
boxstr=strmat('Limit Box: OFF','Limit Box: ON ');
hlimbox=uicontrol('style','popupmenu','string',boxstr,...
    'units','normalized','position',[.83,0,wd,ht],...
    'tooltipstring','Constrains master values to box',...
    'callback','LmLnActivation','value',[1],...
    'visible','off','enable',enb);
% hlimbox visibility is now set off and actions will be accessed
% through a uicontext menu

set(gcf,'userdata',[hflip,hbrighten,hdarken,hmsg,hi,hscale,hclip,hcmap,...
        hzoompick hmaster hlabel hslider hclip hlimbox hfile2])
    
    set(hscale,'userdata',[scaleopt mxs2 mns smean2 stddev2]);
    set(hmaster,'userdata',[mxs smean stddev]);
    set(hclip,'userdata',iclip);
    set(hmsg,'userdata',clips)
    
    %colorview(gca,hi,mns,mxs,0)
    
    if(~nobrighten) brighten(.5); end
    
    global NAME_
    global NOSIG
    if(isempty(NOSIG))nosig=0;else nosig=NOSIG; end
    if(~nosig)
        signature(NAME_);
    end
