clc; clear; close all;

[data0,str0] = xlsread('RG_spectra_Age.xlsm');
[a0,b0] = size(data0);

temp = xlsread('random.xlsm');

N_train = fix(a0 * 0.7);
N_test = a0 - N_train;

F_train = data0(temp(1:N_train),[1,2,3,4,5])'; %Note:1:Teff, 2:logg, 3:[Fe/H], 4:¦Ímax, 5:?¦Í, 6:H¦Á EW, 7:H¦Â EW, 8:H¦Ã EW, 9:H¦Ä EW, 10:Ca ii H EW, 11:Ca ii K EW, 12:Ca ii ¦Ë8498 EW, 13:Ca ii ¦Ë8542 EW, 14:Ca ii ¦Ë8662 EW.
A_train = data0(temp(1:N_train),15)'; %Note: 15: Age

F_test = data0(temp(N_train + 1:end),[1,2,3,4,5])';
A_test = data0(temp(N_train + 1:end),15)';

[FF_train,ps_input] = mapstd(F_train);
FF_test = mapstd('apply',F_test,ps_input);
[AA_train,ps_output] = mapstd(A_train);

RMSE = zeros(100,1);
RE = zeros(100,1);
R_square_value = zeros(100,1);
R_square_adjusted = zeros(100,1);

fid=fopen('E:\LHP_KC\DATA\RG_New_result\20200311\Training\LASSO\net3\GitHUB\result\result.txt','a');
fprintf(fid,'%20s %20s %20s %20s \n','k_ID','RMSE','RE','R_square_value');
fclose(fid); 

for k = 1:100

net = newff(FF_train,AA_train,[16 16]);

net.trainParam.epochs = 1000;
net.trainParam.goal = 0.001;
net.trainParam.lr = 0.01;

net = train(net,FF_train,AA_train);

A_sim = sim(net,FF_test);

save(['E:\LHP_KC\DATA\RG_New_result\20200311\Training\LASSO\net3\GitHUB\result\', num2str(k),'.mat']);

AA_test = mapstd('reverse',A_sim,ps_output);

%RMSE£¨Root Mean Squarde Error£©£º
RMSE(k) = sqrt(sum((AA_test - A_test).^2)/length(A_test));

%RE£¨Relative Error£©£º
AA_error = abs(AA_test - A_test)./A_test;
RE(k) = mean(AA_error);

% R square
R_square_value(k) = 1 - sum((AA_test - A_test).^2)/sum((A_test - mean(A_test)).^2);

fid=fopen('E:\LHP_KC\DATA\RG_New_result\20200311\Training\LASSO\net3\GitHUB\result\result.txt','a');
fprintf(fid,'%20d %20.5f %20.5f %20.5f\n',k,RMSE(k),RE(k),R_square_value(k));
fclose(fid); 


result = [A_test',AA_test',AA_error'];

x = -3:0.1:15;
y = x;
y1 = 0;

plot(result(:,1),result(:,2),'bo',x,y,'r--')
xlim([-3 15])
ylim([-3 15])
xlabel('Age')
ylabel('Predicted Age')
string = {'Result';['R Square value=' num2str(R_square_value(k))]};
title(string)

saveas(gcf,['E:\LHP_KC\DATA\RG_New_result\20200311\Training\LASSO\net3\GitHUB\result\', num2str(k),'.jpg']);

end

RMSE_min = min(RMSE); RMSE_mean = mean(RMSE);
RE_min = min(RE); RE_mean = mean(RE);
R_square_value_max = max(R_square_value); R_square_value_mean = mean(R_square_value);

fid=fopen('E:\LHP_KC\DATA\RG_New_result\20200311\Training\LASSO\net3\GitHUB\result\result.txt','a');
fprintf(fid,'\n%20s %20s \n','RMSE_mean','RMSE_Min');
fprintf(fid,'%20.5f %20.5f \n',RMSE_mean,RMSE_min);
fprintf(fid,'\n%20s %20s \n','RE_mean','RE_Min');
fprintf(fid,'%20.5f %20.5f \n',RE_mean,RE_min);
fprintf(fid,'\n%20s %20s \n','R_square_mean','R_square_Max');
fprintf(fid,'%20.5f %20.5f \n',R_square_value_mean,R_square_value_max);
fclose(fid); 







