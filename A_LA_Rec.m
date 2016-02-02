function RecIntermediateSymbols = A_LA_Rec(base,enhance,RecESIs_B,RecESIs_E,RecSymbols_B,RecSymbols_E)

K = enhance+base;
base_prime = rfc6330_K_prime(base);
enhance_prime = rfc6330_K_prime(enhance);
[S_b H_b B_b U_b L_b W_b P_b P1_b] = rfc6330_parameters( base_prime );
[S_e H_e B_e U_e L_e W_e P_e P1_e] = rfc6330_parameters( enhance_prime );

A1 = rfc6330_A(base_prime,RecESIs_B);
RecSym_B = [zeros(1,length(A1(:,1))-length(RecSymbols_B)) RecSymbols_B(:).'];
RecInt_B = rfc6330_inversion(A1,RecSym_B,base);

A2 = rfc6330_A(enhance_prime,RecESIs_E);
RecSym_E = [zeros(1,length(A2(:,1))-length(RecSymbols_E)) RecSymbols_E(:).'];
RecInt_E = rfc6330_inversion(A2,RecSym_E,enhance);


B = zeros(S_e+H_e+length(RecESIs_E),L_b);
RecESIs = RecESIs_E+base;
for ii = 1:length(RecESIs)
    % obtain (d,a,b) triple for given ISI
    [ d, a, b, d1, a1, b1 ] = rfc6330_tuple( base_prime, RecESIs(ii) );
    B(S_e+H_e+ii,1+b) = 1;
    for jj = 1:(d-1)
        b = mod(b+a,W_b);
        B(S_e+H_e+ii,1+b) = bitxor(B(S_e+H_e+ii,1+b),1);
    end
    while (b1>=P_b)
        b1 = mod(b1+a1,P1_b);
    end
    B(S_e+H_e+ii,1+b1+W_b) = bitxor(B(S_e+H_e+ii,1+b1+W_b),1);
    for jj = 1:(d1-1)
        b1 = mod(b1+a1,P1_b);
        while (b1>=P_b)
            b1 = mod(b1+a1,P1_b);
        end
        B(S_e+H_e+ii,1+b1+W_b) = bitxor(B(S_e+H_e+ii,1+b1+W_b),1);
    end
end
BA1Rb = GF_multiply(B,RecInt_B');
part = rfc6330_inversion(A2,BA1Rb',enhance);
temp=zeros(1,length(part));
for ii = 1:length(part)
	temp(ii)=bitxor(part(ii),RecInt_E(ii));
end
RecIntermediateSymbols = zeros(1,length(RecInt_B)+length(RecInt_E));
RecIntermediateSymbols(1:length(RecInt_B)) = RecInt_B(:).';
RecIntermediateSymbols(length(RecInt_B)+1:end) = temp(:).';
