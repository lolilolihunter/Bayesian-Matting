clear all;
figure;
imshow('teddy.jpg');
Bayesian_Matting ( 8,10,'teddy.jpg','trimapT.png');


%%
clear all;
figure;
imshow('input2.png');
Bayesian_Matting ( 10,20,'input2.png','mask2.png');

%%
clear all;
figure;
imshow('origin.png');

Bayesian_Matting ( 10,20,'origin_half.png','trimapOrigin_half.png');

%%
clear all;
figure;
imshow('complex/half_origin.png');

Bayesian_Matting ( 10,20,'complex/half_origin.png','complex/half_trimap7.png');