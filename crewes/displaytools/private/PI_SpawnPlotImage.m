function SpawnPlotImage(hObject, eventdata, handles)
global SCALE_OPT NUMBER_OF_COLORS GRAY_PCT CLIP COLOR_MAP NOBRIGHTEN PICKS PICKCOLOR XAXISTOP ZOOM_VALUE ZOOM_LOCKS
mainax=findobj(gcf,'type','axes','tag','MAINAXES');
posax=findobj(gcf,'type','axes','tag','POSITIONAXES');
haxs=mainax;
ttl=get(mainax,'title');
dat=get(ttl,'userdata');
if(isempty(dat))
    return
end
file=dat{1};
h=get(gcf,'userdata');
hmsg=h(2);
hgca=mainax;
hi=h(5);
seisdat=get(hi,'userdata');
xdat=get(hi,'xdata');   ydat=get(hi,'ydata');
if(isempty(seisdat))
    return
end
% acquiring orignal data
seis=seisdat{1};
dist=seisdat{2};
t=seisdat{3};
nkolsdat=seisdat{4};
nkols=nkolsdat{1};
originalcolormap=nkolsdat{2};
hscale=h(6);
hmaster=h(10);
dat1=seisdat{5};
dat2=seisdat{6};
xaxdat=get(haxs,'xlim');
yaxdat=get(haxs,'ylim');
try
catch
    return
end
sampint=t(2)-t(1);
ylbl=get(haxs,'ylabel'); ylbl=get(ylbl,'string');
xlbl=get(haxs,'xlabel'); xlbl=get(xlbl,'string');
ttl=get(haxs,'title');
stringinfo=['Spawning new plot image for "' dat{1} '"'];
set(hmsg,'string',stringinfo,'backgroundcolor',[1 1 1]);
PI_init_image;
h=get(gcf,'userdata');
hscale=h(6);
hclip=h(7);
hmaster=h(10);
hvertscrol=h(16);
hhorscrol=h(17);
for ii=1:length(h)
    if(ishandle(h(ii))&ii~=5)
        set(h(ii),'enable','on');
    end
end
hposax=findobj(gcf,'type','axes','tag','POSITIONAXES');
haxis=gca;
newim=image(dist,t,seis);
set(newim,'xdata',dist,'ydata',t);
set(hvertscrol,'min',t(1),'max',t(end),'visible','off');
set(hhorscrol,'min',dist(1),'max',dist(end),'visible','off');
set(gcf,'currentaxes',hposax);
hi2=image(dist,t,seis);
cdat=get(hi2,'cdata');
    cdat=cdat(1:4:size(cdat,1),1:4:size(cdat,2));
set(hi2,'xdata',dist,'ydata',t,'cdata',cdat);
set(hposax,'visible','on','xtick',[],'ytick',[]);
title('Holding Line Data');
set(get(hposax,'title'),'visible','off');
% position lines
col='r';
lwid=.25;
% bottom
ln1=line([dist(1) dist(end)],[t(end) t(end)],'color',col,'linewidth',lwid,'visible','off');
% top
ln2=line([dist(1) dist(end)],[t(1) t(1)],'color',col,'linewidth',lwid,'visible','off');
% Left Side
ln3=line([dist(1) dist(1)],[t(1) t(end)],'color',col,'linewidth',lwid,'visible','off');
% Right Side
ln4=line([dist(end) dist(end)],[t(1) t(end)],'color',col,'linewidth',lwid,'visible','off');
% patch
pt1=patch([dist(1) dist(end) dist(end) dist(1)],[t(1) t(end) t(end) t(1)],col);
set(pt1,'visible','off','buttondownfcn',@PI_positionaxes_linebuttondown,'facealpha',[.02],...
    'edgecolor','none');
set(get(hposax,'title'),'userdata',[ln1 ln2 ln3 ln4 hi2 pt1]);
set(gcf,'currentaxes',haxis);
set(hposax,'tag','POSITIONAXES');
set(haxis,'tag','MAINAXES');
if(XAXISTOP==1)
    xaxistop='top';
else
    xaxistop='bottom';
end
if(strcmp(COLOR_MAP,'seisclrs'))
    clrmap=seisclrs(NUMBER_OF_COLORS,GRAY_PCT);
    set(gcf,'colormap',clrmap);
else
    colormap(COLOR_MAP);
end
set(gca,'xaxislocation',xaxistop);
gtfigs=findobj(0,'type','figure','tag','PLOTIMAGEFIGURE');
nm=1;
xxnm=1;
adon='';
posax=findobj(gcf,'type','axes','tag','POSITIONAXES');
for ii=1:length(gtfigs)
    haxs=get(gtfigs(ii),'currentaxes');
    ttl=get(mainax,'title');
    dat=get(ttl,'userdata');
    if(~isempty(dat))
        xfile=dat{1};
        xnm=dat{2};
        if(strcmp(xfile,file));
            nm=nm+1;
            if(xnm>=nm)
                nm=xnm+1;
            end
            adon=['(' num2str(nm) ')'];
        end 
    end
end
imagetype='Seismic';    % multiple different image types
title([file adon],'tag','PLOTIMAGE-TITLE','fontweight','bold',...
    'userdata',{file nm imagetype},'interpreter','none');
xlabel(xlbl,'horizontalalignment','right');
ylabel(ylbl,'tag','PLOTIMAGE-YLABEL');
set(gca,'xlim',xaxdat,'ylim',yaxdat);
set(newim,'ydata',ydat','xdata',xdat);
h=get(gcf,'userdata');
h(5)=newim;
set(h(6),'userdata',dat1);
set(h(10),'userdata',dat2);
set(gcf,'userdata',h);
