function [data_filt] = f_filt4(data,dt,fmin,fmax,perc)
%
% [data_filt] = f_filt4(data,dt,fmin,fmax,perc)
%
% Function to frequency-filter a time-domain trace or matrix. The filter is
% implemented as a cascading of two fifth-order Butterworth filters. (A
% higher order corresponds to a steeper ramp, which is good in the
% frequency domain, but corresponds to a longer filter in the time domain).
% Nevertheless, there is a signifcant ramp beyond the cutoff frequencies
% (fmin and fmax) where the amplitude is already half, or -3dB).  The
% filters may be acausal to make sure the phase is not affected.
% In opspy.signal.filter.bandpass is the standard 4th order Butterworth
%   input1: dataset in timesamples (Dim 1), traces (Dim 2) format 
%   input2: time sample duration  
%   input3: minimum corner frequency. If equal to zero, than low-pass filter
%   input4: maximum corner frequency. If equal to zero, than high-pass filter
%   input5: percentile taper at edges in time-domain, 
%       default=0%
%
% elmer.ruigrok@knmi.nl, June 2016
% This function is slightly more efficient than f_filt3.m

if nargin < 5
    perc=0;
end

n=5; % filter order
c=2; % filter type

nyquist = 1/dt/2;
if fmax==0 % high-pass filter
    w = fmin / nyquist;
    [b,a] = butter(n,w,'high');
elseif fmin==0 % low-pass filter
    w = fmax / nyquist;
    % TODO: a part was change here
    [b,a] = butter(n,w,'low');
else % bandpass filter
    w1 = fmin / nyquist; % normalized lower cut-off frequency
    w2 = fmax / nyquist; % normalized higher cut-off frequency
    [b,a]=butter(n,[w1,w2]);   
end

% applying the filter
if c==1
    data_filt = filter(b,a,data); % one pass
else
    data_filt = filtfilt(b,a,data); % two passes
end    
    

% taper the edges in the time domain
if perc~=0
    [ns, ntr]=size(data_filt);
    tl3=round(ns*perc/100);
    coef=hanning(tl3*2);
    taper=ones(ns,1);
    taper(1:tl3)=coef(1:tl3);
    taper(ns-tl3+1:ns)=coef(tl3+1:tl3*2);
    for k=1:ntr
        data_filt(:,k)=taper.*data_filt(:,k);
    end
end
