I1=double(rgb2gray(left));
I2=double(rgb2gray(right));
I3=double(groundtruth);
%figure,imshow(I1,[]);
%figure,imshow(I2,[]);
%figure,imshow(I3,[]);

Dmap1=SSDmap(I1,I2);
imagesc(Dmap1);
axis equal off;
colormap jet;
figure,imshow(Dmap1,[]);

Dmap2=NCCmap(I1,I2);
imagesc(Dmap2);
axis equal off;
colormap jet;
figure,imshow(Dmap2,[]);

err1=Dmap1(1:383,1:434)-I3;
err2=Dmap2(1:383,1:434)-I3;

performanceonSSD=mae(err1)
performanceonNCC=mae(err2)

function D = SSDmap(I1,I2)
for d=0:20
   SSD=(I1-circshift(I2,[0 d])).^2;
   SSD=conv2(SSD,ones(17));
   V(d+1,:,:)=SSD;
end 
[E, D]=min(V);
D=squeeze(D);

end


function D=NCCmap(I1,I2)
for d=0:20
   
  t1= (I1-mean2(I1)).*((circshift(I2,[0 d]) )- mean2(circshift(I2,[0 d])));
  t2= sqrt(((I1-mean2(I1)).^2).*(((circshift(I2,[0 d])) - mean2(circshift(I2,[0 d]))).^2));
  NCC=t1./t2;
  NCC=conv2(NCC,ones(17));
  V(d+1,:,:)=NCC;
end 
[E, D]=max(V);
D=squeeze(D);
end

