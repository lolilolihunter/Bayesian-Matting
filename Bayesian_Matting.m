function  Bayesian_Matting( oriVar , Iteration , image , trimap )


FThreshold = 255 * 0.95;
BThreshold = 255 * 0.05;

%oriVar = 8;
%Iteration = 10;

%[File,Path,DialogIndex] = uigetfile({'*.jpg;*.jpeg;*.png;*.gif;*.bmp;*.tiff','Image Files (.jpg, .png, .gif, .bmp, .tiff'},'Select an Image You want to mat ');
oriImg = imread(image);
%[File,Path, DialogIndex] = uigetfile({'*.jpg;*.jpeg;*.png;*.gif;*.bmp;*.tiff','Image Files (.jpg, .png, .gif, .bmp, .tiff'},'Select an ');
triMap = imread(trimap);
if size(triMap,3)~=1,
   triMap = rgb2gray(triMap); 
end

frontImg = double(oriImg);
backImg = double(oriImg);
unknownImg = double(oriImg);
width = size(oriImg,1);
height = size(oriImg,2);


    for b= 1:height
       for a = 1:width
           for i = 1 : 3
           
                if triMap(a,b)>=FThreshold,
                    backImg(a,b,i) = 0;
                    unknownImg(a,b,i)=0;
                end
                if triMap(a,b)<=BThreshold,
                    frontImg(a,b,i) = 0;
                    unknownImg(a,b,i)=0;
                end
                if triMap(a,b)<FThreshold&&triMap(a,b)>BThreshold,
                    backImg(a,b,i) = 0;
                    frontImg(a,b,i)=0;
                end
                             
           end
       end
    end
  figure,
   imshow([uint8(frontImg) uint8(backImg) uint8(unknownImg)]);
   drawnow;
%%
% Compute mean and Covariance Matrix

for i=1:3
   temp = frontImg(:,:,i);
   Fmean(i) =mean(temp(find(temp)));  
   temp = backImg(:,:,i);
   Bmean(i) = mean(temp(find(temp)));
   temp = unknownImg(:,:,i);
   Umean(i) =mean(temp(find(temp)));
   temp = oriImg(:,:,i);
   oriMean(i) = mean(temp(find(temp)));
end

coF = [0 0 0;0 0 0;0 0 0];
coB = [0 0 0;0 0 0;0 0 0];
NF= 0 ; NB = 0;
 for b=1:height,
     for a=1:width,
        
        if any(frontImg(a,b,:)),
            shiftF = [ (frontImg(a,b,1)-Fmean(1))  (frontImg(a,b,2)-Fmean(2))  (frontImg(a,b,3)-Fmean(3)) ];
            coF = coF +(shiftF' * shiftF);
            NF = NF +1;
        end
        if any(backImg(a,b,:)),
            shiftB = [ (backImg(a,b,1)-Bmean(1))  (backImg(a,b,2)-Bmean(2))  (backImg(a,b,3)-Bmean(3)) ];
            coB = coB + (shiftB' * shiftB);     
            NB = NB +1;
        end
           
     end
  end
 coF = coF / NF;
 coB = coB / NB;
 temp = 0;
 oriImg = double(oriImg);
 for b=1:height,
     for a=1:width,
          temp = temp +((oriImg(a,b,1)- oriMean(1))^2 + (oriImg(a,b,2)- oriMean(2))^2 + (oriImg(a,b,3)- oriMean(3))^2);
     end
 end
 %oriVar = temp / (height * width*255);  
   
 
    
 %%
 unknownAlpha = double(triMap) / 255.0;
 unknownF = unknownImg;
 unknownB = unknownImg;
 invcoF = inv(coF);
 invcoB = inv(coB);
 for b=1:height
     for a=1:width
         if any(unknownImg(a,b,:)),
                alpha = 0;
                count = 0;
                if(a>1&&b>1)
                   alpha = alpha + unknownAlpha(a-1,b-1);
                   count = count +1;
                end
                if(b>1)
                    alpha = alpha + unknownAlpha(a,b-1);
                   count = count +1;
                end
                if(a<width&&b>1)
                   alpha = alpha + unknownAlpha(a+1,b-1);
                   count = count +1;
                end
                if(a>1)
                    alpha = alpha + unknownAlpha(a-1,b);
                   count = count +1; 
                end
                if(a<width)
                   alpha = alpha + unknownAlpha(a+1,b);
                   count = count +1; 
                end
                if(a>1&&b<height)
                   alpha = alpha + unknownAlpha(a-1,b+1);
                   count = count +1; 
                end
                if(b<height)
                   alpha = alpha + unknownAlpha(a,b+1);
                   count = count +1; 
                end
                if(a<width&&b<height)
                   alpha = alpha + unknownAlpha(a+1,b+1);
                   count = count +1;
                end
                alpha = alpha / count;
                preAlpha = alpha;
                for i=1:Iteration,

                    UL = invcoF + eye(3)*(alpha*alpha)/(oriVar*oriVar);
                    UR =eye(3)*alpha*(1-alpha)/(oriVar*oriVar);
                    DL = eye(3)*alpha*(1-alpha)/(oriVar*oriVar);
                    DR = invcoB + eye(3)*(1-alpha)*(1-alpha)/(oriVar*oriVar);
                    A = [UL UR;DL DR];
                    C = reshape(unknownImg(a,b,:),3,1);
                    BU = invcoF*Fmean' + C*alpha/(oriVar*oriVar);
                    BD = invcoB*Bmean' + C*(1-alpha)/(oriVar*oriVar);
                    B = [BU; BD];
                    x = A\B;
                    tempF = x(1:3); tempB = x(4:6);
                    alpha = dot((C - tempB), (tempF - tempB)) / norm(tempF-tempB).^2;
                    if abs(preAlpha - alpha)< 0.0001,
                        break;
                    end
                    preAlpha = alpha;
                    
                end
                unknownF(a,b,:) = tempF;
                unknownB(a,b,:) = tempB;
                unknownAlpha(a,b) = alpha;
                
        end
     end 
 end
 
% imshow(uint8(unknownAlpha));
 %%
 [File,Path,Index]=  uigetfile({'*.jpg;*.jpeg;*.png;*.gif;*.bmp;*.tiff','Image Files (.jpg, .png, .gif, .bmp, .tiff'},'Select an new Background ');
 newBack = imread([Path File]);
 newBack = imresize(newBack,[width  height]);
 newBack = double(newBack);
 for i=1:3
 newBack(:,:,i) = unknownF(:,:,i).*unknownAlpha(:,:) + newBack(:,:,i).*(1-unknownAlpha(:,:));   
 end
 
 for a=1:width
     for b=1:height
        if(triMap(a,b)>=FThreshold)
           newBack(a,b,:) = oriImg(a,b,:); 
        end
     end
 end
 figure;
 imshow(uint8(newBack));
 imwrite(uint8(newBack),'Bear.png')
 drawnow;
 
end

