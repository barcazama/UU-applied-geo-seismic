clearvars; close all; clc; % basic clear

%%%%%%%%%%%%%%%%%%%%
%% 1A. MATLAB RÉSUMÉ
%%%%%%%%%%%%%%%%%%%%

%% Commands
% parameters
%%%%%%%%%%%%
m = 50; % number of row for mymatrix
n_sample = 10; % number of columns for mymatrix

% creation of the matrix `mymatrix`
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mymatrix = zeros(m,n_sample); % create a matrix with 50 rows and 10 columns
for i = 1:n_sample
    mymatrix(:,i) = i:i:50*i;
end

% creation of matrix `mat2`
%%%%%%%%%%%%%%%%%%%%%%%%%%%
mat2 = zeros(m,n_sample); % create empty matrix m x n
mat2(:,1) = 1:1:m; % assign 1 to m for the first column 
for i = 2:n_sample
    mat2(:,i) = mat2(:,i-1)*1.5; % make each column 1.5x larger than last
end
mat2_selection = mat2(:,3:7); % create a matrix with only column 3 to 7

%% plotting a matrix
clf; close all; % close windows and figure

% plot(mat2)
% image(mat2)
clim = [10,50]; % define min and max of colorbar
imagesc(mat2,clim)
colorbar

%% plotting 1D array
clf; close all; % close windows and figure

mat2_array = mat2(:,4);
plot(mat2_array)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1B. DIGITIZING SEISMIC DATA %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars; close all; clc; % basic clear

% parameters
n_sample = 200; % number of sample
fs = 50; % sample rate
r = 5; % resampling rate

% computing parameters
dt = 1/fs; % sample duration
t = 0:dt:(n_sample-1)/fs; % time array
noise = randn(1,n_sample); % noise array

resamp_5th = noise(1:r:end); % resampling by taking 1/5th of the data
resamp_dec = decimate(noise,r); % resampling using low-pass filter + resampling
t_resamp = t(1:r:end);

hold on
plot(t,noise,':k')
plot(t_resamp,resamp_dec,'r*')
plot(t_resamp,resamp_5th,'bx')
legend('Reference','Resample Decimate','Resample 1/5th')
% the decimate function remove high frequency before resampling

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1C. DIGITIZING SEISMIC DATA %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars; close all; clc; % basic clear

% import
data = segyread('data/shotground.segy'); % import data from file

% parameters
dt = 0.004; % time interval [s]
dxr = 100; % distance between receivers [m]
n_sample = size(data,1); % number of sample
n_trace = size(data,2); % number of traces
t = 0:dt:(n_sample-1)*dt;
x = 0:dxr:(n_trace-1)*dxr;

% plot
figure('Name','Traces from time sample 150 to 250 from dataset')
plotseis(data(150:250,:))
xlabel('trace number [ - ]')
ylabel('sample number [ - ]')

figure('Name','Traces 20 to 40 from dataset')
plotseis(data(:,20:40))
xlabel('trace number [ - ]')
ylabel('sample number [ - ]')

figure('Name','Trace 1 from dataset')
plot(data(:,1))
xlabel('time [ s ]')
ylabel('reflection parameter')

figure('Name','Dataset with time as y-axis')
plotseis(data,t,x)
xlabel('distance from source [ m ]')
ylabel('time [ s ]')

figure('Name','Continuous interpretation')
smoothimage(data,t(1),t(end),10,50,dt,60,2,0,10,350)





