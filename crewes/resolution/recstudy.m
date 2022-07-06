% RECSTUDY: Study record length limit on scattering angle
%
% Just run the script

vo=1500;c=.6;
T=[2. 4.  6. 8];
z=0:25:26000;
theta=zeros(length(T),length(z));
for k=1:length(T)
	theta(k,:)=threc(T(k),vo,c,z);
end
vo=3500;c=0;
thetac=zeros(length(T),length(z));
for k=1:length(T)
	thetac(k,:)=threc(T(k),vo,c,z);
end

ind=find(imag(theta)~=0);
theta(ind)=nan*ind;
ind=find(imag(thetac)~=0);
thetac(ind)=nan*ind;

figure;
h1=line(z,thetac,'color','k','linewidth',2);
h2=line(z,theta,'color','r','linewidth',3);
%p=get(gcf,'position');
%set(gcf,'position',[p(1:2) 700 700])
set(gca,'ytick',[0:20:150])
ylabel('scattering angle in degrees')
xlabel('depth in meters')
legend([h1(1) h2(1)],'constant velocity','v(z)')
%whitefig
%grid

	
