function [] = f_plot(data,dt)
%
% [] = f_plot(data,dt)
%
% input1: data matix in format [nt ntr] 
%       (number of time samples by number of traces)
% input2: time sample duration  

[ns ntr]=size(data);
x=[1:ntr];
tend=ns*dt;
t=[0:dt:tend-dt];

% bring data to the f-x domain
% a standard CREWES script is used (in comparison with fft, only positive
% f)
[data_f,f]= fftrl(data,t);
f0=min(f);
f1=max(f);
nf=size(data_f,1);
df=f1/(nf-1)';

figure('Color','w'); imagesc(x,f(1:nf),abs(data_f(1:nf,:)));
set(gca,'FontSize',16);
title('Amplitude spectrum, all traces','FontSize',20)
xlabel('Station No. [-]')
ylabel('Frequency (Hz)')

data_f(isnan(data_f)) = 0;
if ntr>1
    trace_stack_f=sum(abs(data_f(:,1:ntr)'));
else
    trace_stack_f=abs(data_f);
end
figure('Color','w'); plot(f(1:nf),trace_stack_f(1:nf));
set(gca,'FontSize',16);
title('Filtered (30-80) amplitude spectrum','FontSize',20)
xlabel('Frequency (Hz)')
ylabel('Amplitude')
set(gca,'PlotBoxAspectRatio',[2 1 1])