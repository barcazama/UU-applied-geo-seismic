% Read in a single shot from the Wassenaar fieldwork
[data_CSP, H_CSP, geo] = segyread('./data/f1.v3.segy');

% Initialise container for filtered data
wasfilt=zeros(10000,96);

% Filter the shot trace-by-trace with a bandpass filter
%  that was derived from data-analysis (see Ex. 5
%  on http://www.ta.tudelft.nl/intro_seismology/ )
for tracenr=1:96
wasfilt(:,tracenr)=filtf(data_CSP(:,tracenr), ...
    0:0.001:(10000-1)*0.001,35,125);
end

% Plot the data before and after filtering, in the 
%  relevant time-window
plotimage(data_CSP(1:2000,:));
title('before bandpass filtering')

plotimage(wasfilt(1:2000,:));
title('after filtering; groundroll has been suppressed, improving visibility of reflections')