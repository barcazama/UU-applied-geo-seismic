function timeanalcb(action)% Determine the parameters for the Plus Time analysis function which finds the % delay time values at each receivers if( nargin < 1 )   action = 'init';endif( strcmp(action,'init'))   q=str2mat('Include all shots?',...             'Use the reciprocal time difference?',...             'Limit the offset?',...             'Specify offset limit:');   a=str2mat('Yes|No only the one with CVPAVG','Yes|No','No|Yes','0')   askthingsinit('timeanalcb(''answer'')',q,a,[1 1 1 0],'Parameter for the Time Analysis computation');elseif( strcmp(action,'answer'))   a=askthingsfini;   [strings tmp] = size(a);      fbtime=refdata('get','fbtime');   fbcoord=refdata('get','fbcoord');   shotcoord=refdata('get','shotcoord');   nshots=refdata('get','nshots');   % First question: Interpolate NaNs in the CVP average array, or not.   if( strcmp( deblank(a(1,:)), 'Yes') )	cvpavg=refdata('get','cvpavg');      for side = 1:2         shots = 1:nshots;         okavg = find(~isnan(cvpavg(:,side)));         nanavg = find(isnan(cvpavg(:,side)));         firstokavg = okavg(1);                % This is the first good shot         lastokavg = okavg(length(okavg));     % This is the last good shot         % Build a new CVP average array, with only the points between         % the first and last good shots.  This will be interpolated.         cvpint = cvpavg(firstokavg:lastokavg,side);         shotint = firstokavg:lastokavg;         % Now we need to find the NaN's in the CVP average array that         % will be interpolated (cvpint)         okavg = find(~isnan(cvpint));         nanavg = find(isnan(cvpint));         % Interpolate over any NaN's in the middle CVP array.          fixed = interp1(shotint(okavg), cvpint(okavg), shotint(nanavg));         % Now, put the interpolated CVP average values back into the array         cvpint(nanavg) = fixed;            cvpavg(firstokavg:lastokavg,side) = cvpint;      end    else	cvpavg=refdata('get','cvpavg');    end    % Next question: subtract the difference matrix or not    diffmat=refdata('get','diffmat');    [diffrows diffcols] = size(diffmat);    % If the difference matrix is not the right size, then compute it by    % calling the reciprocal time difference function    disp('Recomputing time difference matrix...');    if( strcmp(deblank(a(2,:)),'Yes') & diffrows~=nshots & diffcols~=nshots)       diffmat = rectime(0, 0, 0, fbcoord, shotcoord, fbtime, 0, nshots);       refdata('set','diffmat',diffmat);    end    if( strcmp( deblank(a(2,:)), 'No' ))       diffmat = zeros([nshots nshots]);    end    % Offset limit determining the valid receivers inside     % the Plus time analysis window     if( strcmp( deblank(a(3,:)), 'No' ))       offsetpt = NaN;    else       offsetpt = str2num(a(4,:));    end    % Call the Plus time analysis function    [td1] = timeanal(fbtime,fbcoord,shotcoord,nshots,diffmat,cvpavg, offsetpt);        refdata('set','offsetpt',offsetpt);    refdata('set','cvpavg',cvpavg);    refdata('set','td1',td1);     % Setup menus    PMTsetmenus;end
