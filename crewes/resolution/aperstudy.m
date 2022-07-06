% APERSTUDY: study the aperture effect
%
% Just run the script

vo=1500;c=.6;
A=[1000  4000  12000  20000];
z=0:25:20000;
theta=zeros(length(A),length(z));
for k=1:length(A)
	theta(k,:)=thaper(A(k),vo,c,z);
end
vo=3500;c=0;
thetac=zeros(length(A),length(z));
for k=1:length(A)
	thetac(k,:)=thaper(A(k),vo,c,z);
end
figure;
h1=line(z,thetac,'color','k','linewidth',2);
h2=line(z,theta,'color','r','linewidth',3);

%p=get(gcf,'position');
%set(gcf,'position',[p(1:2) 700 700])
ylabel('scattering angle in degrees')
xlabel('depth in meters')
set(gca,'xtick',[0:5000:20000])
set(gca,'ytick',[0:30:180])
set(gca,'ylim',[0 180])
legend([h1(1) h2(1)],'Constant velocity','Linear v(z)')
%whitefig
%grid
	
