% load the gmsh file 
 filename = 'sub00440.msh';
[~,~,ext] = fileparts(filename);
if strcmp(ext,'.msh')
% covert msh to bst format
femhead = bst_msh2bst(filename);
end
if strcmp(ext,'.mat')
% covert msh to bst format
femhead = bst_mat2bst(filename);
end
% basci matlab display
bst_display_femhead(femhead,'x>0')

% Display on gmsh : need to instal gmsh
system(['gmsh ' filename])
system(['gmsh help'])

%% Advanced Plot need iso2mesh
% {'1-WM'}    {'2-GM'}    {'3-CSF'}    {'4-Skull'}    {'5-Scalp'}    {'6-Eyes'}
tissu = 'all';  %tissu = {'4-Skull' }     tissu = {'6-Eyes'}
bst_DefineOptionMeshPlot
% Main function for plot
bst_plotFemMesh(femhead, plotMeshOption)
