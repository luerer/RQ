clear all
close all
clc

tic
%Number of source symbols
K = 100;
%-------enhance and base in the source symbols--------------
enhance = 60;base = 40;
base_prime = rfc6330_K_prime(base);
N_base = 2*base_prime-1;
enhance_prime = rfc6330_K_prime(enhance);
N_enhance = 2*enhance_prime-1;


filename = 'bible_tmp.txt';
fid = fopen(filename,'r');
myline = fgets(fid);
sourceSymbols_temp = double(myline);
sourceSymbols=sourceSymbols_temp(1:K);
baseSymbols = sourceSymbols(1:base);
enhanceSymbols = sourceSymbols(base+1:end)
fclose(fid);

char(sourceSymbols);
char(baseSymbols);

ExtendedSymbols_base = [baseSymbols zeros(1,base_prime-base)];
ExtendedSymbols_enhance = [enhanceSymbols zeros(1,enhance_prime-enhance)];

A_LA = rfc6330_A_LA(K,base);

IntermediateSymbols = rfc6330_A_LA_inversion(A_LA,sourceSymbols,K,base)


