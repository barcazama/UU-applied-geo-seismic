function zoompick();
global SCALE_OPT NUMBER_OF_COLORS GRAY_PCT CLIP COLOR_MAP NOBRIGHTEN PICKS PICKCOLOR XAXISTOP ZOOM_VALUE ZOOM_LOCKS
h=get(gcf,'userdata');
hmsg=h(2);
hi=h(5);
hzoompick=h(9);
value=get(hzoompick,'value');
delete(findobj(gcf,'type','line','tag','PICKMARKER'));
delete(findobj(gcf,'type','text','tag','PICKTEXT'));
col=[1 1 1];
switch value
case 1
    selboxinit('plotimage(''zoom'')',1);
    set(gcf,'name','Seismic Image Plot, Simplezooming installed (Use MB1)');
    stringinfo='Zooming enabled';
case 2
    drawlineinit('plotimage(''pick'')');
    set(gcf,'name','Seismic Image Plot, Picking resummed (Use MB1)');
    stringinfo='Pick lines enabled';
case 3
    % This is disabling the automatic zoom picking at this time
    % stringinfo='Adanced Auto Picking is not enabled at this time';
    col=[1 1 0];
    udat=get(hi,'userdata');
    seisstruct.SEIS=udat{1};
    seisstruct.X=udat{2};
    seisstruct.T=udat{3};
    pref.hmsg=hmsg;
    masteraxes=gca;
    holdhandle=gca;
    picksle('plotimage(''pick'')',seisstruct,masteraxes,pref);
    set(gcf,'name','Seismic Image Plot, Picking resummed (Use MB1)');
    stringinfo='Automatic Picking has been enabled';
case 4
    % this removes all picked lines
    if(~isempty(PICKS))
        for ii=1:size(PICKS,1)
            CheckFigure=PICKS{ii,1};
            if(CheckFigure==gcf)
                PICKS{ii,3}=[];
                PICKS{ii,2}=[];
            end
        end
    end
    delete(findobj(gcf,'type','line','tag','PICKS'));
    drawlineinit('plotimage(''pick'')');
    set(gcf,'name','Seismic Image Plot, Picking new (Use MB1)');
    set(hzoompick,'userdata',[]);
    stringinfo='Old picks removed, pick new lines';
end
set(hmsg,'string',stringinfo,'backgroundcolor',col);

