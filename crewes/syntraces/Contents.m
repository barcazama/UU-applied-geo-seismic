% CREWES synthetic seismogram toolbox
% This contains tools to create convolutional synthetic seismograms
% 
%Wavelets
% EINAR ... Creates a constant Q impulse response wavelet according to Kjartanssen
% ORMSBY ... Creates an Ormsby bandpass filter
% QMATRIX ... create a matrix that applies a forward Q filter
% RICKER ... creates a Ricker wavelet
% SWEEP ... generate a linear Vibroseis sweep
% TNTAMP ... create an amplitude spectrum for an impulsive source 
% WAVEDYN ... minimum phase wavelet for impulsive sources
% WAVEMIN ... creates a minimum phase wavelet for impulsive sources
% WAVENORM ... normalize (rescale) a wavelet
% WAVEVIB ... creates a vibroseis (Klauder) wavelet
% WAVEZ ... creates a zero phase wavelet with a dominant frequency
%
%Time series
% COMB ... create a comb function (spikes every n samples)
% IMPULSE ... create a simple time series with an impulse in it
% REFLEC ... synthetic pseudo random reflectivity
% RNOISE ... create a random noise signal with a given s/n
% SPIKE ... create a signal with a single impulse in it
% SWEEP ... generate a Vibroseis sweep\
% WATERBTM ... compute the sero offset water bottom response
%
% Synthetic seismograms
% SEISMOGRAM ... compute a 1-D normal incidence seismogram using the Goupillaud model.
% SEISMO ... a simplified interfacae to SEISMOGRAM
