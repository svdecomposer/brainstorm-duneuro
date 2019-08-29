function write_duneuro_electrode_file(channel_loc, electrode_filename)
% Creation  August 28, 2019, 
%Takfarinas MEDANI 


fid = fopen(electrode_filename, 'wt+');
fprintf(fid, '%d %d %d  \n', channel_loc');
fclose(fid); 

end