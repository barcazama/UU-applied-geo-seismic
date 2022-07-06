% ALIASTUDY: study aliasing versus depth
%
% Just run the script

vo=1500;c=.6;
dx=[20 40 80 160];
z=0:25:20000;
f=60;
theta=zeros(length(dx),length(z));
for k=1:length(dx)
	theta(k,:)=thalias(dx(k),f,vo,c,z);
end
vo=3500;c=0;
thetac=zeros(length(dx),length(z));
for k=1:length(dx)
	thetac(k,:)=thalias(dx(k),f,vo,c,z);
end
figure;
h1=line(z,thetac,'color','k','linewidth',2);

h2=line(z,theta,'color','r','linewidth',3);

%p=get(gcf,'position');
%set(gcf,'position',[p(1:2) 700 700])
ylabel('scattering angle in degrees')
xlabel('depth in meters')
set(gca,'xtick',[0:2500:20000])
set(gca,'ytick',[0:30:90])
legend([h1(1) h2(1)],'Constant velocity','v(z)')
%whitefig
%grid
	
