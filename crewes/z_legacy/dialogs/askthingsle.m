function ansfini=askthingsle(masterfig,qst,a,flags,titlestr,ttstr,figmode);

% ansfini=askthingsle(masterfig,qst,a,flags)
% ansfini=askthingsle(masterfig,qst,a,flags,titlestr)
% ansfini=askthingsle(masterfig,qst,a,flags,titlestr,ttstr);
% ansfini=askthingsle(masterfig,qst,a,flags,titlestr,ttstr,figmode);
% 
% askthingsle is a replacement for the askthingsinit, askthings and
% askthingsfini dialogs askthingsle only needs to be called once with the
% desired questions, answers and flags unlike the old version which took
% two seperate programs to run.
%
% masterfig - askthingsle can only be called if there is a master figure
% present.  Inputting gcf is usually acceptable
% 
% qst - Are the questions you desires to ask.  These must be
% set up in cell format as follows.  
%   qst={'Example Question 1?' 'What Colour?' 'Optional Naming?'};
%
% a - Are the answers you want the user to answer.  Two formats are
% available, an editable box which is either blank or has some predefined
% editable answer or a popup box with multiple predefined uneditable
% answers.  Use '|' between options to create a popup menu. There must be 
% as many answers as there are questions which must be set up in a cell 
% format as follows
%   a={'Exampled answer' 'Blue|Black|Maroon' ''};
% 
% flags - There has to be one flag for every answer.  Placing a 1 as a flag
% forces the user to place an answer in the desired editable box.  Placing
% a 0 make the question optional.  The flags must be set up as follows
%   flags=[1 1 0];
%
% titlstr - A title string for the question box.
% titlestr='Please Answer These Questions';
%
% ttstr - Tool tip string for each question.  There has to be as many tool
% tip strings as there are questions and have to be set up in cell format
% which looks as follows.  
%  ttstr={'Only an example question' 'Choose a colour' 'Fill in if desired'};
%
% figmode - The askthingsle figure is defaulted to be [1] or modal.  To set
% the askthingsle figure to be none modal set figmode=[0];
%   figmode=[1]; (default, modal)    figmode=[0]; (non-modal);
%
% ansfini - The answers are returned in cell format.  There are as many
% answers as there are question.  Unanswered optional questions are
% returned blank.  Cancel will return a blank cell.
%       {'Example output' 'Black' ''}
%
%
% C.B. Harrison 2002
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

try
    if(nargin<=3)
        errordlg('Need More Arguments, See "askthingsle" Help For Details');
        return
    elseif(nargin==4)
        titlestr='Please Supply This Information:';
        ttstr=[];
    elseif(nargin==5)
        ttstr=[];
    elseif(nargin>=8)
        errordlg('Too Many Input Aguments, See "askthingsle" Help For Details');
        return
    end
    if(size(qst,2)==size(a,2))&(size(qst,2)==size(flags,2))
    else
        errordlg('You Must Have The Same Number Of Questions, Answers and Flags');
        return
    end
    if(nargin==6)
        if(size(ttstr,2)==size(qst,2))
        else
            errordlg('You Must Have The Same Number Of Tool Tip Strings As Questions');
            return
        end
    end
    if(nargin==7)
        if(ischar(figmode))
            errordlg('Figure Mode Has To Be Either [1] For Modal Or [0] For Non-Modal');
            return
        elseif(figmode==1)
            figmode='modal';
        elseif(figmode==0)
            figmode='normal';
        else
            errordlg('Figure Mode Has To Be Either [1] For Modal Or [0] For Non-Modal');
            return
        end   
    else
        figmode='modal';
    end
    
    if(~ischar(titlestr))
        titlestr='Please supply this information:';
    end
    % find the maximum question or answer length
    qlen=10;
    for ii=1:size(qst,2)
        checkquestion=qst{ii};
        if(~ischar(checkquestion))
            errordlg('Questions Have To Be Strings');
            return
        else
            nsize=length(checkquestion);
            if(nsize>=qlen)
                qlen=nsize;
            end
        end    
    end
    alen=10;
    for ii=1:size(a,2)
        checkans=a{ii};
        if(iscell(checkans))
            for jj=1:size(checkans,2)
                checkans2=checkans{jj};
                nsize=length(checkans2);
                if(nsize>=alen)
                    alen=nsize;
                end
            end
        else
            % checking for | to see what is the longest ans in series
            [ansout ansleft]=strtok(checkans,'|');
            while ~isempty(ansleft)
                nsize=length(ansout);
                if(nsize>=alen)
                    alen=nsize;
                end
                [ansout ansleft]=strtok(ansleft,'|');
            end
            nsize=length(ansout);
            if(nsize>=alen)
                alen=nsize;
            end
        end
    end
    
    %build the dialog box and the questions
    hdial=figure('visible','on','menubar','none','numbertitle','off',...
        'name','Question(s)','closerequestfcn',@askthingsleCancel,'resize','off');
     %   'windowstyle',figmode);
    % set(hdial,'windowstyle','modal');
    pos=get(hdial,'position');
    sep=1;
    %
    % assume 10 chars in 50 pixels
    %
    qwidth=50*ceil(qlen/10);
    fmltq=0;
    if(qwidth>=600)
        qwidth=600;
        fmlq=2;
    end
    awidth=max([80*ceil(alen/10) 100]);
    fmlta=0;
    if(awidth>=600)
        awidth=600;
        fmlta=2;
    end
    
    width=mean([qwidth awidth]);
    % compute height of title string (allow long strings to wrap)
    titlen=50*ceil(length(titlestr)/9);
    factor=ceil(titlen/(2*(width+sep)));
    height=20;
    titheight=factor*height;
    figheight=(height+sep)*(size(qst,2)+1+factor);
    figwidth=2*(width+sep);
    ynow=figheight-titheight;
    xnow=sep;
    hmsg=uicontrol('style','text','string',titlestr,...
        'position',[xnow ynow figwidth titheight],...
        'foregroundcolor','r');
    hq=zeros(1,size(qst,2));ha=zeros(1,size(qst,2));
    ynow=ynow-sep-height;
    bgkol=[0 1 1];
    for ii=1:size(qst,2)
        q=qst{ii};
        if(isempty(ttstr))
            hq(ii)=uicontrol('style','text','string',deblank(q),'position',...
                [xnow,ynow,qwidth,height+factor*fmltq],'userdata',q,'value',1);
        else
            tt=ttstr{ii};
            hq(ii)=uicontrol('style','text','string',deblank(q),'position',...
                [xnow,ynow,qwidth,height+factor*fmltq],'tooltipstring',tt,'userdata',q,'value',1);
        end
        xnow=xnow+qwidth+sep;
        ind=findstr(a{ii},'|');
        %if(strcmp(blanks,a(k,:)))
        if( isempty(ind) )
            if(flags(ii))
                ha(ii)=uicontrol('style','edit','string',...
                    a{ii},'position',[xnow,ynow,awidth,height+factor*fmlta],...
                    'backgroundcolor',bgkol,'userdata',deblank(a{ii}),'value',1);
            else
                ha(ii)=uicontrol('style','edit','string',...
                    a{ii},'position',[xnow,ynow,awidth,height+factor*fmlta],...
                    'userdata',deblank(a{ii}),'value',1);
            end
        else
            ind=find(abs(a{ii})==1);
            if( isempty(ind) ) ind=length(a{ii})+1; end
            if(flags(ii)<1) flags(ii)=1; end
            ha(ii)=uicontrol('style','popupmenu','string',...
                a{ii},'horizontalalignment','center',...
                'position',[xnow,ynow,awidth,height+factor*fmlta],'value',flags(ii),...
                'userdata',a{ii},'value',1);
        end
        xnow=sep;
        ynow=ynow-sep-height;
    end
    
    hdone=uicontrol('style','pushbutton','string','Done','position',...
        [xnow ynow width height],'callback',@askthingsleDone,...
        'foregroundcolor','r');
    
    xnow=xnow+width+sep;
    hcancel=uicontrol('style','pushbutton','string','Cancel','position',...
        [xnow ynow width height],'callback',@askthingsleCancel);
    
    % get the position of the calling figure.  Need to make sure that the
    % units acquired are pixels
    gcfunits=get(masterfig,'units');
    set(masterfig,'units','pixels');
    pospar=get(masterfig,'position');
    set(masterfig,'units',gcfunits); 
    %unitspar=get(hparent,'units');
    
    px=pospar(1)+pospar(3)/2-figwidth/2;
    py=pospar(2)+pospar(4)/2-figheight/2;
    posdial=[px py figwidth figheight];
    
    set(hdial,'position',posdial);
    set(hdial,'visible','on');
    
    hans=uicontrol('style','text','visible','off','userdata',a);
    
    finalanswers={};
    set(hdial,'userdata',{ha flags masterfig hmsg finalanswers});
    
    uiwait;
    
    dat=get(gcf,'userdata');
    ansfini=dat{5};
    delete(gcf);
catch
    ansfini={};
    delete(gcf);
    errordlg('Invalid Input Arguments');
end

function askthingsleCancel(hObject, eventdata, handles)
% user just wants to quit
dat=get(gcf,'userdata');
dat{5}=[];
uiresume;

function askthingsleDone(hObject, eventdata, handles)
% preparing data to export according to user preference
hbutton=gco;
dat=get(gcf,'userdata');
ha=dat{1};
flags=dat{2};
mastfig=dat{3};
hmsg=dat{4};
finalanswer=cell(1,size(ha,2));

for ii=1:size(ha,2)
    checkflag=flags(ii);
    checkans=get(ha(ii),'string');
    if(isempty(checkans))
    else
        checkans=checkans(get(ha(ii),'value'),:);
    end
    if(checkflag==1) & (isempty(checkans))
        stringinfo='Please Answer Blue Questions Or Cancel';
        set(hmsg,'string',stringinfo);
        return 
    end
    finalanswer{ii}=deblank(checkans);    
end
dat{5}=finalanswer;
set(gcf,'userdata',dat);
uiresume;
