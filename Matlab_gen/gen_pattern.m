function [feature_value,kernel_value,out] = gen_pattern(N,sparsity,padding)
% sparsity = from 0.1 to 1 will produce different sparsity matrix.
% padding = "valid" then will crop the boarder (example 28*28->PE->24*24).
% padding = "full" the will output full convolution (28*28->PE->32*32).
% N = fmap size N*N.
% gen_pattern(28,0.5,"full")
M = floor((N*sqrt(sparsity))/2)*2;
pad_N = N-M;
temp = padarray(randn(M,M),[floor(pad_N/2),ceil(pad_N/2)],0,'both');
feature_value = fi(temp,1,8,4);
kernel_value = fi(randn(5,5),1,8,4);
feature_value = feature_value(:);
feature_value = feature_value(randperm(length(feature_value)));
feature_value = reshape(feature_value,[N N]);
kernel_value = kernel_value(:);
kernel_value = kernel_value(randperm(25));
kernel_value = reshape(kernel_value,[5 5]);

[m,n] = size(feature_value);
[m1,n1] = size(kernel_value);

mn = [m,n] + 2*([m1,n1]-1);
F = fimath('RoundingMethod','Floor');
a0 = fi(zeros(mn),1,8,4);
a0.fimath  =F; 
a0(m1:(end-m1+1),n1:(end-n1+1)) = feature_value;

b2 = kernel_value(:);
b2.fimath = F;
out = fi(zeros(m1+m-1,n+n1-1),1,16,8);
out.fimath = F;
for ii = 1:mn(1)-m1+1
    for jj =  1:mn(2)-n1+1
        x = a0(ii:ii+m1-1,jj:jj+n1-1);
        out(ii,jj) = x(:)'*b2;
    end
end
if padding =="valid"
    start = 5;
    stop = N;
    out =out(5:N,5:N);
end
save_matrix("feature",sparsity,feature_value);
save_matrix("out",sparsity,out);
save_matrix("kernel",sparsity,kernel_value);

save_verilog("feature",sparsity,feature_value);
save_verilog("weight",sparsity,kernel_value);

temp = "verilog_output_sparsity_"+num2str(sparsity*100)+".v";
fileID = fopen(temp,'w');
for i=1:length(out)
    for j = 1:length(out)
        result = out(i,j);
        temp = sprintf('if(PE_pixels_%d_%d!==16%sh%s) $display("ERROR! at (%d,%d)%s%s");\n',j-1,i-1,"'",result.hex,j-1,i-1,'\\','n');
        fprintf(fileID,temp);
    end
end
fclose(fileID);