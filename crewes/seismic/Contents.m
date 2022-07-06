% CREWES Seismic toolbox
% Seismic processing tools 
%
%
% Transforms
%  FFTRL: forward Fourier transform for real vectors.
%  IFFTRL: inverse Fourier transform for real time series
%  IFKTRAN: inverse fk transform
%  FKTRAN_MC: forward fk transform using less memory thatn FKTRAN
%  FKTRAN: Forward fk transform
%  IFKTRAN_MC: memory conserving inverse fk transform
%
% Filters, convolution
%  CONVM: convolution followed by truncation for min phase filters
%  CONVZ: convolution then truncation for non-min phase filters
%  FILTF: apply a bandass filter to a trace
%  FILTSPEC: designs the filter spectrum for FILTF
%  SECTCONV: runs convz on each trace in a matrix
%  SECTFILT: runs FILTF on each trace in a section
%
% Amplitude adjustment
%  AEC: automatic envelope correction, a better AGC.
%  BALANS: match the rms power of one trace to another
%  CLIP: clips the amplitudes on a trace
%
% Interpolation, resampling
%  RESAMP: resample a signal using sinc function interpolation
%  SINC: sinc function evaluation
%  SINCI: sinc function interpolation for time series without nan's
%  SINCINAN: sinc function interpolation for signals with embedded nan's 
%  SINQUE: sinc function evaluation
%  SECTRESAMP: runs resamp on each trace in a seismic section
%
% Attributes
%  INS_PHASE: Compute the instantaneous phase useing complex trace theory
%  INS_AMP: Compute the magnitude of the complex trace.
%  INS_FREQ: Compute the instantaneous frequency useing complex trace theory
%
% Deconvolution, inversion
%  LEVREC: solve Tx=b using Levinson's recursion
%
% Auto and cross correlation
%  AUTO: single-sided autocorrelation
%  AUTO2: returns the two-sided autocorrelation 
%
% Traveltime adjustment
%  STAT: static shift a trace

