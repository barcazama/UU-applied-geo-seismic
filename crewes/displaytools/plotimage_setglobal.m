function plotimage_setglobal(arg1)
%-----------------------------------
%----- PLOTIMAGE GLOBAL SETTER -----
%-----------------------------------
%
% plotimage_setglobal('SET');
%
% PLOTIMAGE_SETGLOBAL is used in conjunction with PLOTIMAGE.  Running this
% routine with the 'SET' argument (and only the 'SET' argument) allows the
% user to preset the global variables encountered in PLOTIMAGE.
% PLOTIMAGE_SETGLOBALS will not run if there is plotimage window open, this
% routine is ment to run before plotimage is executed.
%
% The askthingsle figure allow the user to preset the following PLOTIMAGE
% global variables
%
% SCALE_OPT (Scaling Option) 
% **************************
% Mean: Plotimage window begins in mean scaling mode witha clip level of 4.
% Maximum: Plotimage window begins in maximum scaling mode (no clipping)
% --- defaults to maximum ---
%
% CLIP (Clipping Level)
% *********************
% Data clip level in standard deviations from the mean.  Only effects
% plotimage when scaling is in Mean mode.
%
% NUMBER_OF_COLORS (Number of Colors)
% ***********************************
% This integer vlue sets the number of colors (greg level usually).  Use a
% bigger number for more detail, be beware that it tkaes longer to comute
% --- defaults to 64 ---
%
% GREY_PCT (Grey Percentage)
% **************************
% Should be a number between 1 and 100.  This affects how the seisclrs
% colormap is buitl.  When GREY_PCT=100. you get a true linear gray scale.
% For a true-amplitude display, you should use GREY_PCT=100 and
% SCALE_OPT=Mean.  When GRAY_PCT is say, 20, it means that then first 40%
% of the greay levels are set to black and the last 40% to white.  Only the
% middle 20% do you get a gradient from black to white.  This accomplishes
% a display that is visually similar to wiggle traces in that the positives
% tend to be all black and negatives all white.  It is a kind of clipping.
% --- defaults to 50 ---
%
% COLOR_MAP (Colour Map)
% **********************
% The colour map that will be used to display the image
% --- defaults to SEISCLRS ---
%
% NOBRIGHTEN (SEISCLRS Brightening)
% *********************************
% Either brightens or clipped linear ramps SEISCLRS
% --- defaults to brigthen ---
%
% PICKCOLOR (Colour of picks lines)
% *********************************
% Colour to draw picsk in.  
% ---- defaults to red ---
%
% XAXISTOP (Location of X Axis)
% *****************************
% Axis title can either be located on the top or on the botton of the axis
% --- defaults to bottom ---
%
% CLOSEREQUEST (Close type)
% *************************
% Allows user to specify whether they want plotimage to close with or
% without a warning
% --- defaults to give user a warning ---
%
% IMCONTROLS (Visibility of the GUI controls)
% *******************************************
% Allows the user to control whether the GUI controls and location axes are
% on or off upon start up of plotimage.
% --- defaults to 'on' or GUI visiable ---
%
% Most of these properties can be changed while in a PLOTIMAGE session.
% The gcf uicontextmenu has a menu which will easily allow user to change
% values
%
% All these values can be set manually in the command window, or controlled
% by another program.  When manually setting these values before plotimage
% is open the propertie CHECK_GLOBAL must have a value.  This will stop
% plotiage from opening a previous sessions porperties values
%

if(nargin==0)
    stringinfo={'Please see plotimage_setglobal help for details on proper use.'};
    helpdlg(stringinfo,'Check PLOTIMAGE_SETGLOBAL help file');
    return
elseif(nargin==1)
    % checking to see if plotimage is open, and if it is, not allowing
    % PLOTIMAGE_SETGLOBAL to run
    checkpi=get(0,'children');
    checkpi=get(checkpi,'tag');
    if(iscell(checkpi))
        for ii=1:size(checkpi,1)
            if(strcmp(checkpi{ii},'PLOTIMAGEFIGURE'))
                stringinfo={'plotimage_setglobal can not be accessed while plotimage is open.',...
                        'Please see plotimage_setglobal help for details on proper use.'};
                helpdlg(stringinfo,'Check PLOTIMAGE_SETGLOBAL help file');
                return
            elseif(strcmp(checkpi{ii},'PLOTIMAGEFIGURE'))
                stringinfo={'plotimage_setglobal can not be accessed while plotimage is open.',...
                        'Please see plotimage_setglobal help for details on proper use.'};
                helpdlg(stringinfo,'Check PLOTIMAGE_SETGLOBAL help file');
                return
            end
        end
    end
    global SCALE_OPT NUMBER_OF_COLORS GRAY_PCT CLIP COLOR_MAP NOBRIGHTEN PICKS PICKCOLOR XAXISTOP CLOSEREQUEST
    global CHECK_GLOBAL
    q1a='Type of Scaling';
    a1a='Maximum|Mean';
    q1b='Clipping Level';
    a1b='4';
    q1='Type of Color Map';
    a1='seisclrs|autumn|bone|colorcube|cool|copper|flag|gray|hot|hsv|jet|lines|pink|prism|spring|summer|white|winter';
    q2='Brighten';
    a2='Auto Brighten|Clipped Linear';
    q3='Number of Colors (if seisclrs)';
    a3='64';
    q4='Grey Percentage (if seisclrs)';
    a4='50';
    q5='Picks Color';
    a5='Red|Green|Blue';
    q6='X-Axis Location';
    a6='Bottom|Top';
    q7='Type of Close';
    a7='Check with User|Quick Close';
    q8='Controls at start:';
    a8='On|Off';
    qs={q1a q1b q1 q2 q3 q4 q5 q6 q7 q8};
    as={a1a a1b a1 a2 a3 a4 a5 a6 a7 a8};
    flgs=[1 1 1 1 1 1 1 1 1 1];
    a=askthingsle(gcf,qs,as,flgs,'See PLOTIMAGE_SETGLOBAL for more details');
    if(isempty(a))
        % cancel has occured
        return
    end
    scal_opt=deblank(a{1});
    switch scal_opt
        case 'Maximum'
            SCALE_OPT=2;
        case 'Mean'
            SCALE_OPT=1;
    end
    clp=str2num(deblank(a{2}));
    if(isempty(clp))
        % user did not input a number
        CLIP=4;
    else
        CLIP=clp;
    end
    COLOR_MAP=deblank(a{3});
    nobrighten=deblank(a{4});
    switch nobrighten
        case 'Auto Brighten'
            NOBRIGHTEN=0;
        case 'Clipped Linear'
            NOBRIGHTEN=1;
    end
    number_of_colors=sort([4 round(deblank(a{5})) 150]);
    NUMBER_OF_COLORS=number_of_colors(2);
    gray_pct=sort([10 round(deblank(a{6})) 100]);
    GRAY_PCT=gray_pct(2);
    allpifig=findobj(0,'type','figure','tag','PLOTIMAGEFIGURE');
    allaxis=get(allpifig,'currentaxes');
    pickcolor=strunpad(a{7});
    PICKCOLOR=lower(pickcolor(1,:));
    set(findobj(gcf,'type','line','tag','PICKS'),'color',PICKCOLOR);
    xaxistop=lower(strunpad(a{8}));
    switch xaxistop
        case 'top'
            XAXISTOP=1;
        case 'bottom'
            XAXISTOP=0;
    end
    checkclose=a{9};
    switch checkclose
        case 'Check with User'
            CLOSEREQUEST='Slow Close';
        case 'Quick Close'
            CLOSEREQUEST='Fast Close';
    end
    IMCONRTOLS=a{10};
    hgcf=gcf;
    for ii=1:length(allpifig)
        set(0,'currentfigure',allpifig(ii));
        set(gca,'xaxislocation',xaxistop);
    end
    CHECK_GLOBAL='USER PRESET';
    ans=questdlg('Would you like to open PLOTIMAGE now?','Open PLOTIMAGE?',...
        'Yes','No','No');
    switch ans
        case 'Yes'
            plotimage;
        case 'No'
        case ''
    end
end
