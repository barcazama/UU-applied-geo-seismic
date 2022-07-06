function bigfont(hdaddy,fontsize,fontwt,tickflag)
%
% bigfont(hdaddy,fontsize,fontwt,tickflag)
%
% NOTE: If your figure has a legend, turn it off before using this function
% and then recreate it afterwards.
%
% hdaddy ... handle of a figure or axes object or other parent object 
%		which contains text objects
%   ******** default = gcf ******
% fontsize ... desired fontsize expressed as a ratio of output
%		to input size
%   ******** default 2 ********
% fontwt ... 1 = normal
%			 2 = bold
%   *********  default = 2 *********
% tickflag ... 1 ... change tick labels
%			   0 ... dont change tick labels
%   ********* default = 1 *********
%
% You can customize the default behavior of bigfont by defining some
%  globals: BIGFONT_FS and BIGFONT_FW . Set these to have your desired
%  default values of fontsize and fontweight. A good place to define
%  these is in your startup.m file.
% Gary Margrave, CREWES
%

if(nargin<4)
	tickflag=1;
end
if(nargin<3)
    global BIGFONT_FW
    if(isempty(BIGFONT_FW))
	    fontwt=2;
    else
        fontwt=BIGFONT_FW;
    end
end
if(nargin<2)
    global BIGFONT_FS
    if(isempty(BIGFONT_FS))
	    fontsize=2;
    else
        fontsize=BIGFONT_FS;
    end
end
if(nargin<1)
	hdaddy=gcf;
end

if(strcmp(get(hdaddy,'type'),'figure'))
    hfigkids=get(hdaddy,'children');
    haxes=[];
    for k=1:length(hfigkids)
        if(strcmp(get(hfigkids(k),'type'),'axes'))
            haxes=[haxes hfigkids(k)];
        end
    end
else
    haxes=hdaddy;
end

for kk=1:length(haxes)

    hkids=allchild(haxes(kk));

	for k=1:length(hkids)
		if(strcmp(get(hkids(k),'type'),'text'))
			fsize=get(hkids(k),'fontsize');
			set(hkids(k),'fontsize',fontsize*fsize);
			if(fontwt==1)
				set(hkids(k),'fontweight','normal');
			elseif(fontwt==2)
				set(hkids(k),'fontweight','bold');
			end
		end
	end

	if(tickflag==1)
		fsize=get(haxes(kk),'fontsize');
		set(haxes(kk),'fontsize',fontsize*fsize);
		if(fontwt==1)
				set(haxes(kk),'fontweight','normal');
		elseif(fontwt==2)
				set(haxes(kk),'fontweight','bold');
		end
	end

end
