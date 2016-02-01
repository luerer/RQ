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
[S_b H_b B_b U_b L_b W_b P_b P1_b] = rfc6330_parameters( base_prime );
[S_e H_e B_e U_e L_e W_e P_e P1_e] = rfc6330_parameters( enhance_prime );


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

IntermediateSymbols = rfc6330_A_LA_inversion(A_LA,sourceSymbols,K,base);

Inter_base = IntermediateSymbols(1:L_b);
Inter_enhance = IntermediateSymbols(L_b+1:end);
EncSym_base = rfc6330_gen_encoding_symbol(base_prime,Inter_base,N_base:N_base+N_enhance-1);
EncSym_enhance = rfc6330_gen_encoding_symbol(enhance_prime,Inter_enhance,N_base:N_base+N_enhance-1);
if length(EncSym_base)~=length(EncSym_enhance)
	error('Encoded Symbols do not match');
end
EncSymbols = zeros(1,length(EncSym_base))
for ii = 1:length(EncSym_base)
	EncSymbols(ii)=bitxor(EncSym_base(ii),EncSym_enhance(ii));
end 

EncSource_enhance = EncSymbols(1:enhance);
EncRepair_enhance = EncSymbols(enhance_prime+1:end);

char(EncSource_enhance);



