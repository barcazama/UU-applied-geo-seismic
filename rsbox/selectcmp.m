function [out,out2]=selectcmp(CMPsorted,H_CMP, midpnt)
% [CMPgather, H_CMPgather] = SELECTCMP(CMP_sorted_data, H_CMP, midpoint)
%
% This function selects plots a CMP gather according to its midpoint
% position. Midpoints can be found with the function ANALYSEFOLD.
% When giving in a non-existent midpoint, the CMP gather nearest-by 
% will be selected.
%
% Input:  CMP_sorted_data - CMP-sorted dataset
%                   H_CMP - CMP-sorted data header
%                midpoint - midpoint of the CMP-gather you want to plot
% Output:       CMPgather - the CMP-gather
%             H_CMPgather - its header
%
% See also SORTDATA, ANALYSEFOLD
%
% Updates:
% ENR. May 2015: added axes annotation

% Read the amount of time-samples and traces from the size of the datamatrix
[nt,ntr]=size(CMPsorted);

% CMP-gather trace counter initialisation:
% l is the number of traces in a CMP gather
l=1;


% Scan the CMP-sorted dataset for traces with the correct midpoint and put
% those traces in a cmpgather.
empty=1;
for k=1:ntr
	if H_CMP(5,k) == midpnt
        empty=0;
		cmpgather(:,l)=CMPsorted(:,k);
		cmpgather_hdr(:,l)=H_CMP(:,k);
		l = l+1;
	end
end
% Selecting nearest midpoint if CMP given is non-existent, or if testing
% for equals failed due to distances being floats, not integers.
if empty == 1
    disp('Warning: rounding off to nearest midpnt,')
    % using CREWES function 'near'
    lrange=near(H_CMP(5,:),midpnt);
    % if exactly between two midpoints, 'near' returns indices from
    % both midpoints; in that case, round off upwards
    if ~( H_CMP(5,lrange(length(lrange))) == H_CMP(5,lrange(1) ) )
        lrange=near(H_CMP(5,:),midpnt+0.01);        
    end
    disp(['         requested: ', num2str(midpnt),' given: ', ...
        num2str(H_CMP(5,lrange(1)) ), ' .' ])
    midpnt=H_CMP(5,lrange(1)); % just for proper value in plot
    cmpgather=CMPsorted(:,lrange);
	cmpgather_hdr=H_CMP(:,lrange);
end
    
out=cmpgather;
out2=cmpgather_hdr;


% Plot the requested CMP-gather
if ~( min(size((cmpgather_hdr)))== 1)
    plotseis(cmpgather,1:nt,out2(2,:));
    set(gca,'FontSize',16);
    xlabel('Offset [m]')
    ylabel('Sample No.')
else
    % the cmp is a single trace
    figure;
    clf;
    [h,hva] = wtva(cmpgather ,1:nt, 'r');
    flipy;
    set(gca,'FontSize',16);
    ylabel('Sample No.')
end
title(['CMP gather for midpoint at ', num2str(midpnt), ' m']);
