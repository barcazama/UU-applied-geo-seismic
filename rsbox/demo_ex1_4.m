% === Intro_seismology Demonstration ===
%
% Note: for correct operation, this file should be placed
%       in the intro_seismology/ folder.

%--- Reading SEGY, plotting
disp(' ')
disp('   === Intro_seismology Demonstration ===')
disp(' ')
disp('  Please note:  for instructive use only,')
disp('      do not distribute this demo-script!')
disp(' ')
disp('  help on the shown COMMANDS can be invoked by ')
disp('  typing:   help COMMAND   on the command line ')
disp('  after this demo has finished.')
disp(' ')
disp('  [Press a key to continue.]'); pause;

disp(' ')
disp('  Reading SEGY-files  is  done  with  SEGYREAD,')
disp('  which stores  data and  headers  in  separate')
disp('  matrices.   The tripli dataset will be loaded')
disp('  after a key-press.')
disp(' ')
disp('  [Press a key to continue.]'); pause;
echo on;
[data_CSP, H_CSP, geo] = segyread('./data/tripli.segy');
echo off;

disp(' ')
disp('  [Press a key to continue.]'); pause;
disp(' ')
disp('  The geometry of the loaded dataset  is stored')
disp('  in a vector with the following structure:')
disp(' ')
disp('  [Press a key to continue.]'); pause;
disp(' ')
help geometry
disp(' ')
disp('  The geometry-vector for this dataset contains the values:')
geo
disp(' ')
disp('  [Press a key to continue.]'); pause

% Displaying
disp(' ')
disp('  Seismic data is displayed with the CREWES plot-')
disp('  tools PLOTSEIS or PLOTIMAGE. Three shotgathers')
disp('  from the tripli-dataset are shown next,  every')
disp('  second trace is displayed.')
disp(' ')
disp('  [Press a key to continue.]'); pause
disp(' ')
echo on;
plotseis(data_CSP(:,1:2:303));
echo off;
disp(' ')
disp('  [Press a key to continue.]'); pause
disp(' ')
disp('  The corresponding headers are  shown with  the')
disp('  command PLOTHDR. The headers of the six  first')
disp('  shotgathers are shown next. Detailed info on a')
disp('  certain datapoint can be obtained  by  <CTRL>-')
disp('  clicking on it.')
disp(' ')
disp('  [Press a key to continue.]'); pause
disp(' ')
echo on;
plothdr(H_CSP,1,606);
echo off;
disp(' ')
disp('  [Press a key to continue.]'); pause
disp(' ')
disp('  To make a plot with the  correct units on  the')
disp('  vertical axis,  the  time-sampling  has  to be')
disp('  specified in PLOTIMAGE or PLOTSEIS.')
disp(' ')
disp('  [Press a key to continue.]'); pause
disp(' ')
echo on;
plotseis(data_CSP(:,1:303),0:4:(351-1)*4); ylabel('twtt [ms]');
plotimage(data_CSP(:,1:303), 0:4:(351-1)*4); ylabel('twtt [ms]');
echo off;
disp(' ')
disp('  [Press a key to continue.]'); pause
disp(' ')


% --- Sorting
disp(' ')
disp(' --- Sorting of seismic data --- ')
disp(' ')
disp('  Sorting data  (and corresponding headers)  is')
disp('  done  with SORTDATA.  The tripli-dataset will')
disp('  be sorted to midpoints after a key-press.')
disp(' ')
disp('  [Press a key to continue.]'); pause;
disp(' ')
echo on;
[data_CMP, H_CMP]=sortdata(data_CSP, H_CSP, 5);
echo off;
disp(' ')
disp('  We will now plot the header after sorting  to ')
disp('  verify the success of the sorting operation.')
disp(' ')
disp('  [Press a key to continue.]'); pause;
disp(' ')
echo on;
plothdr(H_CMP,1,1000);
echo off;
disp(' ')
disp('  Sorting after common offset. The plot of the ')
disp('  zero-offset  section  should  reveal a first ')
disp('  glimpse of the subsurface structures.')
disp(' ')
disp('  [Press a key to continue.]'); pause;
disp(' ')
echo on;
[data_COF, H_COF]=sortdata(data_CSP, H_CSP, 2);
ZOgather=data_COF(:,4451:4539);
plotseis(ZOgather);
echo off;
disp(' ')
disp('  The multiplicity or fold, i.e. the gather-size')
disp('  after sorting, is displayed with  ANALYSEFOLD.')
disp(' ')
disp('  [Press a key to continue.]'); pause;
disp(' ')
echo on;
[midpnts, folds] = analysefold(H_CSP, 5);
echo off;
disp(' ')
disp('  Using the previous plot, let us select a single')
disp('  near-full fold CMP-gather for velocity-analysis in')
disp('  the next stage of the demo.')
disp(' ')
disp('  [Press a key to continue.]'); pause;
disp(' ')
echo on;
[CMP1104, H_CMP1104]=selectcmp(data_CMP, H_CMP, 1104);
echo off;

% --- Velocity analysis
disp(' ')
disp(' --- Velocity analysis --- ')
disp(' ')
disp('  Constant-velocity NMO on the selected CMP-gather')
disp('  can be performed with  NMO_V,  to  get  a  first')
disp('  idea of the procedure and  the  wave-propagation')
disp('  velocity distribution in  the  subsurface  below')
disp('  the midpoint. We will try a velocity of 1500m/s.')
disp(' ')
disp('  [Press a key to continue.]'); pause;
disp(' ')
echo on;
NMOedCMP1104=nmo_v(CMP1104, H_CMP1104, geo, 1500, 0);
plotseis(NMOedCMP1104);
echo off;
disp(' ')
disp('  And now a velocity of 1700m/s.')
disp(' ')
disp('  [Press a key to continue.]'); pause;
disp(' ')
echo on;
NMOedCMP1104=nmo_v(CMP1104, H_CMP1104, geo, 1700, 0);
plotseis(NMOedCMP1104);
echo off;
disp(' ')
disp('  Overstretched regions after NMO-correction can be')
disp('  muted by setting a value for the stretch-mute.')
disp(' ')
disp('  [Press a key to continue.]'); pause;
disp(' ')
echo on;
NMOedCMP1104=nmo_v(CMP1104, H_CMP1104, geo, 1500, 1);
plotseis(NMOedCMP1104);
echo off;
disp(' ')
disp('  A semblance plot may help finding the proper')
disp('  velocity-time profile. We will scan  through')
disp('  velocities 1000-2500 m/s using SEMBLANCE.')
disp(' ')
disp('  [Press a key to continue.]'); pause;
echo on;
semblance(CMP1104, H_CMP1104, geo, 1000, 2500, 50);
echo off;
disp(' ')
disp('  [Press a key to continue.]'); pause;
disp(' ')
disp('  NMO using a   velocity-profile varying  with')
disp('  two-way traveltime is done by NMO_VT.    The')
disp('  velocity-profile found with a few NMO_V runs')
disp('  or the semblance plot has to be inserted  in')
disp('  the file  VLOG.M first. Obviously, for wrong')
disp('  velocities the reflections will not line up,')
disp('  ajust when necessary!')
disp(' ')
disp('  Using the values stored in vlog.m ...')
disp(' ')
disp('  [Press a key to continue.]'); pause;
disp(' ')
echo on;
NMOedCMP1104=nmo_vt(CMP1104, H_CMP1104, geo, 1);
echo off;
disp(' ')
disp('  [Press a key to continue.]'); pause;
disp(' ')
disp('  The velocity picks obtained at a  few  dif-')
disp('  ferent CMP-positions are stored in the file')
disp('  VELOCITYPICKS.M.   Subsequently the command')
disp('  GENERATEVMODEL  will  linearly  interpolate')
disp('  the profiles to a 2D velocity model.')
disp('  ')
disp('  Using the values stored in velocitypicks.m ...')
disp(' ')
disp('  [Press a key to continue.]'); pause;
disp(' ')
echo on;
vmodel= generatevmodel(midpnts,geo);
echo off;
disp(' ')
disp('  [Press a key to continue.]'); pause;

% --- NMO/stack and Zero-offset time migration
disp(' ')
disp(' --- NMO/stack --- ')
disp('  NMO/stacking of a CMP-gather increases the ')
disp('  signal-to-noise ratio, as can be   verified')
disp('  by comparing the zero-offset trace from the')
disp('  MNOed CMP-gather with the stacked trace.')
disp(' ')
disp('  [Press a key to continue.]'); pause;
disp(' ')
% find zero-offset trace in CMP-gather
gathersize=min(size(CMP1104));
for trnr=1:gathersize
if H_CMP1104(2,trnr) == 0
    zotrnr=trnr;
end
    trnr=trnr +1;
end
% plot zero-offset trace from CMP-gather
%  (using code from stackplot.m)
figure;
subplot(1,2,1)
t       = (1:geo(1):geo(1)*geo(2));
[h,hva] = wtva(NMOedCMP1104(:,zotrnr) ,t);
flipy;
title('zero-offset trace from NMOedCMP')
xlabel('amplitude')
ylabel('time [ms]')
% plot stacked trace
%  (using code from stackplot.m)
subplot(1,2,2)
stack=sum(NMOedCMP1104,2)/gathersize;
[h,hva] = wtva(stack ,t);
flipy;
title('stacked trace')
xlabel('amplitude')
ylabel('time [ms]')
%
disp(' ')
disp('  NMO/stack of the CMP-sorted tripli-dataset,')
disp('  using the velocity model that was  built in')
disp('  the previous step, should produce an image ')
disp('  similar to the zero-offset section,    but ')
disp('  with much better signal-to-noise ratio ... ')
disp('  ... if a correct velocity model is used!')
disp(' ')
disp('  [Press a key to continue.]'); pause;
disp(' ')
echo on;
zosection=nmo_stack(data_CMP, H_CMP, midpnts, folds, geo, vmodel, 1);
plotimage(zosection);
echo off;
disp(' ')
disp('  [Press a key to continue.]'); pause;
disp(' ')
disp(' --- Kirchhoff time migration--- ')
disp(' ')
disp('  Using the stacked zero-offset section and ')
disp('  the velocity model, migration is performed')
disp('  to obtain a proper image of the structures')
disp('  present in the subsurface.')
disp(' ')
disp('  Kirchoff Migration stacks along reflection')
disp('  hyperbolas in the recording time domain to')
disp('  image  reflection points in  the  migrated')
disp('  domain (reflectors can be thought of a sum')
disp('  of reflection points).')
disp('  To see this, we will now migrate the zero-')
disp('  offset responses from two subsurface point')
disp('  diffractions, using the correct velocity.')
disp(' ')
disp('  [Press a key to continue.]'); pause;
disp(' ')
warning off MATLAB:flops:UnavailableFunction
echo on;
[points,hdr,geop]=segyread('./data/points.segy');
plotseis(points); pause;
pointmig=kirk_mig2(points, 500, 0.004, 10);
plotseis(pointmig);
echo off;
disp(' ')
disp('  Now we will migrate the stacked zero-offset')
disp('  section using the generated velocity model.')
disp(' ')
disp('  [Press a key to continue.]'); pause;
% Note that kirk_mig2 takes the rms velocities~stacking 
%  velocities as input, not the interval velocities.
disp(' ')
echo on;
[arymig,tmig,xmig]=kirk_mig2(zosection,vmodel,0.004, 8);
plotimage(arymig, tmig, xmig);
xlabel('Horizontal distance [m]');
ylabel('Vertical twtt [s]');
echo off;
disp('  Just to check our obtained result:')
disp('  The correct structure for the first reflector')
disp('  is revealed, albeit with low  signal-to-noise')
disp('  ratio, if we migrate the  zero-offset  gather')
disp('  using the correct constant overburden veloci-')
disp('  ty of 1500m/s.')
disp(' ')
disp('  [Press a key to continue.]'); pause;
disp(' ')
echo on;
[arymig2,tmig2,xmig2]=kirk_mig2(ZOgather,1500/2, 0.004, 8);
plotimage(arymig2,tmig2,xmig2);
xlabel('Horizontal distance [m]');
ylabel('Vertical twtt [s]');
echo off;
disp(' ')
disp('  This ends the Intro_seismology demo; take a')
disp('  look inside the file demo_ex1_4.m to review')
disp('  the commands used.')
disp('  ------------------- END -------------------')

% --- optional 1D vertical time2depth conversion
% dmig=t2d(arymig, vmodel, geo, 4);