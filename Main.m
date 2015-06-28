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

Bayesian_Matting ( 10,20,'origin.png','trimapOrigin.png');