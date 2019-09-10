function write_duneuro_dipole_file(dipoles_pos,dipole_filename)
% Creation  August 28, 2019, 
%Takfarinas MEDANI 


Nb_dipole = size(dipoles_pos, 1); 
% generate triedre orientation for each dipole
dipoles_pos_orie = [kron(dipoles_pos,ones(3,1)), kron(ones(Nb_dipole,1), eye(3))];
fid = fopen(dipole_filename, 'wt+');
fprintf(fid, '%d %d %d %d %d %d \n', dipoles_pos_orie');
fclose(fid); 

end