image = imread('testps.jpg');
[ed]= canny_detection(image,2);
[R,T,H]  = houghtransform(ed);
houghlinedrawer(H,R,T,image);


function [output]= canny_detection(img,sigma)
imgray=rgb2gray(img);
imdouble=im2double(imgray);
G = fspecial('gaussian',5,sigma);
imfiltered = conv2(imdouble,G,'same');
derx = [-1 0 1;-1 0 1;-1 0 1];
dery=derx';
vertedge=conv2(imfiltered,derx,'same');
horizedge=conv2(imfiltered,dery,'same');
grdnt=sqrt(vertedge.*vertedge+horizedge.*horizedge);
angle=atan2(horizedge,vertedge);

grdntmax=max(max(grdnt));
grdntmin=min(min(grdnt));
level=0.1*(grdntmax-grdntmin)+grdntmin;
imthresh=max(grdnt,level.*ones(size(grdnt)));


[n,m]=size(imthresh);
for i=2:n-1
for j=2:m-1
	if imthresh(i,j) > level
	window=[imthresh(i-1,j-1),imthresh(i-1,j),imthresh(i-1,j+1);
    imthresh(i,j-1),imthresh(i,j),imthresh(i,j+1);
    imthresh(i+1,j-1),imthresh(i+1,j),imthresh(i+1,j+1)];
	Xnormalize=[vertedge(i,j)/grdnt(i,j), -vertedge(i,j)/grdnt(i,j)];
	Ynormalize=[horizedge(i,j)/grdnt(i,j), -horizedge(i,j)/grdnt(i,j)];
	windownormalize=interp2(derx,dery,window,Xnormalize,Ynormalize);
		if imthresh(i,j) >= windownormalize(1) && imthresh(i,j) >= windownormalize(2)
		temp(i,j)=grdntmax;
		else
		temp(i,j)=0;
		end
	else
	temp(i,j)=0;
	end
end
end
imshow(temp, []);
output=temp;
end

function [rho,theta,houghspace] = houghtransform(edge)
[y,x]=find(edge);
[maxy,maxx]=size(edge);
range = length(x);
maxrho = round(sqrt(maxx^2 + maxy^2));
houghspace = zeros(2*maxrho,180);
for p = 1:range
thetaindx = 1;
for theta = -pi/2:pi/180:pi/2-pi/180
rho = round(x(p).*cos(theta) + y(p).*sin(theta));
houghspace(rho+maxrho,thetaindx) = houghspace(rho+maxrho,thetaindx) + 1;
thetaindx = thetaindx + 1;
end
end

theta = rad2deg(-pi/2:pi/180:pi/2-pi/180);
rho = -maxrho:maxrho-1;

figure,imshow(uint8(houghspace),[],'xdata',theta,'ydata',rho,'InitialMagnification','fit');
xlabel('\theta'),ylabel('\rho')
axis on, axis normal;
title('Hough Matrix');
end
function houghlinedrawer(h,rho,theta,img)
hmax=imregionalmax(h);
[rhocandidate, thetacandidate]=find(hmax==1);

rholines=[];
thetalines=[];
    for li=1:1:length(rhocandidate)
        temph=h(rhocandidate(li), thetacandidate(li));
        if (temph<=0)
            %%%%
        elseif (temph > 150)
            
            rholines=[rholines;rho(rhocandidate(li))];
            thetalines=[thetalines;theta(thetacandidate(li))];
            
        end
    end
figure,imshow(img); 
hold on; 
numlines = numel(rholines); 
x0 = 1;
xend = size(img,2); 
for indx = 1 : numlines
    r = rholines(indx); th = thetalines(indx); 
    if (th == 0)
        line([r r], [1 size(im,1)], 'Color', 'blue');
    else 
        y0 = (-cosd(th)/sind(th))*x0 + (r / sind(th)); 
        yend = (-cosd(th)/sind(th))*xend + (r / sind(th));
        line([x0 xend], [y0 yend], 'Color', 'blue');
    end
   
end

end




