function [] = save_matrix(name,sparsity,feature_value)
file_name_prefix = name + "_value_sparsity_"+num2str(sparsity*100)+".dat";
fileID = fopen(file_name_prefix,'w');
for i=1:length(feature_value)
    for j = 1:length(feature_value)
        temp = feature_value(i,j);
        fprintf(fileID,temp.bin);
        if(i==length(feature_value) && j==length(feature_value))
            fprintf(fileID,"");
        else
            fprintf(fileID,"\n");
        end
    end
end
fclose(fileID);