% CREWES Utilites toolbox
%
%Logical tests
% BETWEEN: logical test, finds sampls in vector between given bounds
% INSIDEPOLY: identify points inside a polygonal region in 2D.
% ISCOMPLEX: logical test for presence of complex numbers
% NEAR: return indices of those samples in a vector nearest given bounds
% NOTBETWEEN: logical test, the negation of BETWEEN
% SURROUND: analyze how a vector surrounds some test points
% WITHIN: test a point to see if it is inside a polygon or not
%
%Graphical
% CLEARLINES: clear (delete) the rays in a figure
% COLORVIEW: puts up and interactive widget to manipulate colormaps
% DRAWLINEINIT: initialize line drawing
% DRAWLINEFINI: finalize line drawing
% DRAWLINE: draw a line on a figure window
% DRAWPICK: draw a line on top of an image (e.g. seismic)
% EDITLINESFINI: used by EDITLINES to finish its work
% EDITLINESINIT: called to initiate editing with EDITLINES.
% EDITLINES: a general digital editing tool for line data.
% HARDZOOM: subset a matrix according to axis limit specs
% SCA: set current axis utility
% SELBOX: draw a selection box on a figure window
% SELBOXFINI: finalize selection box drawing
% SELBOXINIT: initialize selection box drawing
% SIGNATURE: put a signature on a figure window
% SIMPLEDIT: can be used for simple graphical editing of line graphs
% SIMPLEZOOM: figure zooming utility using SELBOX
%
%Interpolation
% PCINT: piecewise constant interpolation
% PWLINT: piecewise linear interpolation (much faster than interp1)
%
%Windowing, padding, trace conversions
% FROMDB: convert from (db,phase) to (real,imaginary)
% HILBM: Hilbert transform
% MWINDOW: creates an mwindow (boxcar with raised-cosine tapers)
% MWHALF: half an mwindow (boxcar with raised-cosing taper on one end)
% PAD: pads (truncates) one trace with zeros to be the length of another
% PADPOW2: pad a trace with zeros to the next power of 2 in legth
% TODB: converts from (real,imaginary) to (decibels, phase)
%
%Other stuff
% GAUSS: returns a gaussian distribution sampled in frequency
% NUM2STRMAT: convert a vector of numbers to a string matrix
% SLICEMAT slices a matrix along a trajectory
% XCOORD: create a coordinate vector given start, increment, and number
