function write_duneuro_conductivity_file(conductivity_tensor,cond_filename)
% Creation  August 28, 2019, 
%Takfarinas MEDANI 

fid = fopen(cond_filename , 'wt+');
for indl = 1: size(conductivity_tensor,1)
    for indc = 1 : size(conductivity_tensor,2)
            fprintf(fid, '%d\t', conductivity_tensor(indl,indc));
    end
    fprintf(fid, '\n');
end
fclose(fid);


end