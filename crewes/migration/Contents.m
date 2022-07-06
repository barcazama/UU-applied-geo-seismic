% CREWES migration toolbox
%
% Migration routines
%  FD15MIG: 15 degree finite-difference time migration
%  FKMIG: Stolt's fk migration
%  KIRK: simplified Kirchhoff time migration
%  KIRK_MIG: full-featured Kirchhoff time migration
%  PS_MIGT: time migration by Gazdag phase shift
%  PSNSPS_MIG: Exploding reflector depth migration by NSPS
%  SPLITSTEPF_MIG: Split-step Fourier depth migration
%  VZ_FKMIG: fk migration for v(z)
%  VZ_FKMOD: V(z) modelling by an fk technique
%
% Ferguson
% IPS: Isotropic phase shift extraploation (stationary)
%
%
% Utilities
%  CONV45: used by KIRK_MIG for 45 degree phase shift
%  COS_TAPER: used by KIRK_MIG
%  CLININT: Complex-valued linear interpolation (used by FKMIG)
%  CSINCI: complex valued sinc function interpolation
%  TIME2DEPTH: Convert a trace from time to depth by a simple stretch
%  DEPTH2TIME: Convert a trace from depth to time by a simple stretch
%
% Scripts
%  VZ_MOD_SIM: script to demo vz_fkmod
%  VZ_FK_SIM: script to demo vz_fkmig
