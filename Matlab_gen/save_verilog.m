function [] = save_verilog(name,sparsity,feature_value)
file_name_prefix = "verilog_value_sparsity_"+num2str(sparsity*100)+".v";
if name =="feature"
    fileID = fopen(file_name_prefix,'w');
else
    fileID = fopen(file_name_prefix,'a');
end

bit_length = 8;
%feature
if name =="feature"
    temp = "reg ["+ num2str(length(feature_value)*length(feature_value)*bit_length)+"-1:0] ";
else
    temp = "reg ["+ num2str((length(feature_value)*length(feature_value)+3)*bit_length)+"-1:0] ";
end
temp = temp + "pe_input_"+ name +"_value ='h";
fprintf(fileID,temp);
for i=length(feature_value):-1:1
    for j = length(feature_value):-1:1
        temp = feature_value(i,j);
        fprintf(fileID,temp.hex);
        if(i==1 && j==1)
            fprintf(fileID,";\n");
        else
            fprintf(fileID,"_");
        end
    end
end
%fmap col_row
fprintf(fileID,'reg [');
if name =="feature"
    fprintf(fileID,num2str(length(feature_value)*length(feature_value)*bit_length));
else
    fprintf(fileID,num2str((length(feature_value)*length(feature_value)+3)*bit_length));
end

fprintf(fileID,"-1 :0] pe_input_"+ name +"_rows='h");
f_num = length(feature_value)*length(feature_value);
f_len = length(feature_value);
for i = f_num:-1:1
    temp = floor((i-1)/f_len);
    temp = dec2hex(temp,2);
    fprintf(fileID, temp);
    if (i~=1)
        fprintf(fileID,'_');
    else
        fprintf(fileID,';\n');
    end
end
fprintf(fileID,'reg [');
if name =="feature"
    fprintf(fileID,num2str(length(feature_value)*length(feature_value)*bit_length));
else
    fprintf(fileID,num2str((length(feature_value)*length(feature_value)+3)*bit_length));
end
fprintf(fileID,"-1 :0] pe_input_"+ name +"_cols='h");
f_num = length(feature_value)*length(feature_value);
f_len = length(feature_value);
for i = f_num:-1:1
    temp = floor(mod((i-1),f_len));
    temp = dec2hex(temp,2);
    fprintf(fileID, temp);
    if (i~=1)
        fprintf(fileID,'_');
    else
        fprintf(fileID,';\n');
    end
end

fclose(fileID);