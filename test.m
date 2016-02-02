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
ISIs_B = 0:(base_prime-1);
ESIs_B = ISIs_B(1:base);
ISIs_E = 0:(enhance_prime-1);
ESIs_E = ISIs_E(1:enhance);
[S_b H_b B_b U_b L_b W_b P_b P1_b] = rfc6330_parameters( base_prime );
[S_e H_e B_e U_e L_e W_e P_e P1_e] = rfc6330_parameters( enhance_prime );


filename = 'bible_tmp.txt';
fid = fopen(filename,'r');
myline = fgets(fid);
sourceSymbols_temp = double(myline);
sourceSymbols=sourceSymbols_temp(1:K);
baseSymbols = sourceSymbols(1:base);
enhanceSymbols = sourceSymbols(base+1:end);
fclose(fid);

char(sourceSymbols)

ExtendedSymbols_base = [baseSymbols zeros(1,base_prime-base)];
ExtendedSymbols_enhance = [enhanceSymbols zeros(1,enhance_prime-enhance)];

A_LA = rfc6330_A_LA(K,base);

IntermediateSymbols = rfc6330_A_LA_inversion(A_LA,sourceSymbols,K,base);

Inter_base = IntermediateSymbols(1:L_b);
Inter_enhance = IntermediateSymbols(L_b+1:end);
EncSym_base_temp = rfc6330_gen_encoding_symbol(base_prime,Inter_base,N_base:N_base+N_enhance-1);
EncSym_enhance = rfc6330_gen_encoding_symbol(enhance_prime,Inter_enhance,0:N_enhance-1);
if length(EncSym_base_temp)~=length(EncSym_enhance)
	error('Encoded Symbols do not match');
end
EncSymbols = zeros(1,length(EncSym_base_temp));
for ii = 1:length(EncSym_base_temp)
	EncSymbols(ii)=bitxor(EncSym_base_temp(ii),EncSym_enhance(ii));
end 

EncSym_base = rfc6330_gen_encoding_symbol(base_prime,Inter_base,0:N_base-1);

EncSource_base = EncSym_base(1:base);
EncRepair_base = EncSym_base(base_prime+1:end);
EncSource_enhance = EncSymbols(1:enhance);
EncRepair_enhance = EncSymbols(enhance_prime+1:end);

SentSymbols_B = [EncSource_base EncRepair_base];
SentSymbols_E = [EncSource_enhance EncRepair_enhance];

char(EncSource_base)
char(EncSource_enhance)
%-----------------erase channel-------------------
RecAllESIs_B = 0:(length(SentSymbols_B)-1);
RecAllESIs_E = 0:(length(SentSymbols_E)-1);
RecSourceESIs_B = 0:(base-1);
RecRepairESIs_B = base:(length(SentSymbols_B)-1);
RecSourceESIs_E = 0:(enhance-1);
RecRepairESIs_E = enhance:(length(SentSymbols_E)-1);
errProb = 0.4;
RecESIs_B = [];
for ind = 0:(length(SentSymbols_B)-1)
    if (rand > errProb)
        RecESIs_B = [RecESIs_B ind];
    end
end
if (length(RecESIs_B) < base)
    disp('Insufficient number of collected symbols!')
    disp('Decoding will fail!')
end
RecESIs_E = [];
for ind = 0:(length(SentSymbols_E)-1)
    if (rand > errProb)
        RecESIs_E = [RecESIs_E ind];
    end
end
if (length(RecESIs_E) < enhance)
    disp('Insufficient number of collected symbols!')
    disp('Decoding will fail!')
end
% Receiving side
% Recover the ISIs -RecISIs- from the received ESIs -RecESIs.
indSource_B  = RecESIs_B(find(RecESIs_B < base));
indRepair_B  = RecESIs_B(find(RecESIs_B >= base));
if (~isempty(indRepair_B))
    indRepair_B = indRepair_B + base_prime - base;
end
indPadding_B = base:(base_prime-1);
RecISIs_B = [indSource_B indPadding_B indRepair_B];

indSource_E  = RecESIs_E(find(RecESIs_E < enhance));
indRepair_E  = RecESIs_E(find(RecESIs_E >= enhance));
if (~isempty(indRepair_E))
    indRepair_E = indRepair_E + enhance_prime - enhance;
end
indPadding_E = enhance:(enhance_prime-1);
RecISIs_E = [indSource_E indPadding_E indRepair_E];

RecSymbols_B = SentSymbols_B(indSource_B+1);
RecSymbols_B = [RecSymbols_B zeros(1,base_prime-base)];
RecSymbols_B = [RecSymbols_B SentSymbols_B(indRepair_B - base_prime + base + 1)];
RecSymbols_E = SentSymbols_E(indSource_E+1);
RecSymbols_E = [RecSymbols_E zeros(1,enhance_prime-enhance)];
RecSymbols_E = [RecSymbols_E SentSymbols_E(indRepair_E - enhance_prime + enhance + 1)];

RecIntermediateSymbols = A_LA_Rec(base,enhance,RecESIs_B,RecESIs_E,RecSymbols_B,RecSymbols_E);

RecIntSym_B = RecIntermediateSymbols(1:L_b);
RecIntSym_E = RecIntermediateSymbols(1+L_b:end);

RecoverSymtemp_B = rfc6330_gen_encoding_symbol(base_prime,RecIntSym_B,ESIs_E+base);
RecoverSymtemp_E = rfc6330_gen_encoding_symbol(enhance_prime,RecIntSym_E,ESIs_E);
RecoverSym_E = zeros(1,length(RecoverSymtemp_E));
for ii = 1:length(RecoverSymtemp_E)
	RecoverSym_E(ii) = bitxor(RecoverSymtemp_B(ii),RecoverSymtemp_E(ii));
end

RecoverSym_B = rfc6330_gen_encoding_symbol(base_prime,RecIntSym_B,ESIs_B);

RecoverSym = [RecoverSym_B RecoverSym_E];

char(RecoverSym_B)
char(RecoverSym_E)
char(RecoverSym)








