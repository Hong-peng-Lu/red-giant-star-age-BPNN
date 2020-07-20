clc; clear; close all;

[data0,str0] = xlsread('RG_spectra_Age.xlsm');
[a0,b0] = size(data0);

F_test = data0(3,[1,2,3,4,5])'; % Note: 1:Teff,2:logg,3:[Fe/H],4:¦Ímax,5:?¦Í

net = load('-mat','Optimal_model.mat');     
mynet = net.net;

FF_test = mapstd('apply',F_test,net.ps_input);

A_sim = sim(mynet,FF_test);

AA_test = mapstd('reverse',A_sim,net.ps_output);

AA_error = AA_test * 0.23717;

fprintf('%20s %5.3f %3s %5.3f %5s','Estimated Age: ',AA_test, '+/-', AA_error, 'Gyr')








