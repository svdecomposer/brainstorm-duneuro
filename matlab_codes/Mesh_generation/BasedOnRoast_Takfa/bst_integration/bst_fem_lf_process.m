%% Script : bst_fem_lf_process.m
% This script is used to generate tetra mesh from surface mesh.
% To use it correctely you have to specify three argument :  
% bstAnatomyPath : string, path to the default anatomy of bst
% bstElectrodePath : string, path to the default anatomy of bst
% outPutFolder : string, path to where to save the msh file, the file will
% be save with this name : [ 'default_subject _' num2str(length(node)) '.msh' ];
% maxvol  : max volume of the tetra element, option used by iso2mesh

% Dependencies : Iso2mesh toolbox
%                           brainstorm3\defaults\anatomy\ICBM152
%                           brainstorm3\defaults\eeg\ICBM152
%                           bst_fem_lf_process.m               
%                           set_minifile.m
%                           write_duneuro_dipole_file.m
%                           write_duneuro_minifile.m           
%                           prepare_head_model.m
%                           write_duneuro_conductivity_file.m
%                           write_duneuro_electrode_file.m
% May 20, 2019, File created :  Takfarinas MEDANI 
% August 21, 2019, Updated and commented : Takfarinas MEDANI 
% August 28, 2019, Integration in a complete process : Takfarinas MEDANI 

clear all;close all
%% 0- Specify the argument : 
bstAnatomyPath = 'C:\matlab_toolbox\brainstorm\brainstorm3\defaults\anatomy\ICBM152';
bstElectrodePath = 'C:\matlab_toolbox\brainstorm\brainstorm3\defaults\eeg\ICBM152';
outPutFolder = 'G:\My Drive\GitFolders\GitHub\brainstorm-duneuro\matlab_codes\Compute_forward_solution\bst_integration';
cd(outPutFolder); mkdir temp

%% 1- Head model (the mesh of the volume condictor)  
% Generate Volume Mesh from surface mesh
% 0- Main parameters
conductivity = [1 0.0125 1];

% iso@mesh parameter

maxvol = 0.1; % max volume of the tetra element, option used by iso2mesh, in this script it will multiplied by e-6;
                   % range from 10 for corse mesh to 1e-4 or less for very
                   % fine mesh 
% 
% keepratio = 1 ; % input, percentage of elements being kept after the simplification   
% 
% MeshOpt.maxvol = maxvol;
% MeshOpt.keepratio = keepratio;

plotHeadModel = 1;
head_model = bst_prepare_head_model(bstAnatomyPath,maxvol,plotHeadModel);
 
 % 1.2- Write the mesh in the 'msh' format (input for duneuro)
cd(outPutFolder); cd('temp')
node = head_model.node; elem = head_model.elem;
head_filename =[ 'head_model_' num2str(length(node)) '.msh' ];
% savemsh(node,elem,head_filename,tissuelabel)
% my function corrected with Tim
Vn = zeros(1,length(node)); nnode = [(1:length(node))' node];nelem = [(1:length(elem))' elem];
fc_ecriture_fichier_msh(nnode,nelem,Vn,head_filename);
clear node;
%%  2- The Source Model
% Write the source/dipole file
cd(outPutFolder); cd('temp')
dipole_filename = 'dipole_model.txt'; 
dipoles_pos = head_model.brain.Vertices;% source location
%dipoles_pos_test = dipoles_pos(1:5,:);% source location
write_duneuro_dipole_file(dipoles_pos,dipole_filename);

%% 3- The electrode Model
cd(outPutFolder); cd('temp')
electrode_filename = 'electrode_model.txt'; 
% Channel location :
elctrode = load(fullfile(bstElectrodePath,'channel_BioSemi_32.mat'));
channel_loc = zeros(length(elctrode.Channel),3);
for ind = 1: length(elctrode.Channel) 
    channel_loc(ind,:) = elctrode.Channel(ind).Loc;
end
%channel_loc_test = channel_loc(1:3,:) ;
write_duneuro_electrode_file(channel_loc, electrode_filename);
head_model.channel_loc = channel_loc;
%% 4 - The Conductivity Model
cd(outPutFolder); cd('temp')
cond_filename = 'conductivity_model.con'; 
write_duneuro_conductivity_file(conductivity,cond_filename)
head_model.conductivity = conductivity;

%% 5 Build the file that could be stored in the bst data base
vol.pos = head_model.node; 
vol.tet = head_model.elem(:,1:4);
vol.hex = [];
vol.tissue = head_model.elem(:,end);
vol.cond = conductivity;
vol.tissuelabel = head_model.tissuelabel;
vol.unit = 'm';
%% 5.1 Set mini file parameter /configuration
% put all the paramater in the cfg structure
vol.cfg.head_filename = head_filename;
vol.cfg.dipole_filename = dipole_filename;
vol.cfg.electrode_filename = electrode_filename;
vol.cfg.cond_filename = cond_filename;
%%%% ===> this step should be modified from the bst gui
vol = set_minifile(vol);
% 5.2 Write the mini file and the vol structure
cd(outPutFolder); cd('temp')
mini_filename = 'model_minifile.mini';
write_duneuro_minifile(vol, mini_filename);
save(['ICBM152_' num2str(length(head_model.node))],'vol');

%% 6 run the EEG forward problem & compute the lead field
cmd = 'test_eeg_forward.exe ';
arg = mini_filename;
cd(outPutFolder)
copyfile test_eeg_forward.exe temp
cd('temp')
 %  run the system
if ~isfile('VFEM.txt')
tic;
system([cmd  arg])
t1 = toc;
save('time_seconde_32electrode_8233nodes','t1')
temp = load('VFEM.txt');
lf_fem = temp';
vol.lf_fem = lf_fem;
save(['ICBM152_' num2str(length(head_model.node))],'vol');
end


%% %% %% %% % just for test %% %% %% %% %% 
%% Test with the BEM solution
%[lf_om , model] = Compute_openmeeg_solution(model);
[lf_bem, head_model]= test_bem(head_model);
vol.lf_bem = lf_bem;
vol.head_model = head_model;
save(['ICBM152_' num2str(length(head_model.node))],'vol');

%% Compare the two solution
load('ICBM152_8233.mat')
v_bem = sum(zscore(vol.lf_bem),2) ;
v_fem = sum(zscore(vol.lf_fem),2) ;
figure;
plot(v_bem,'ro'); hold on
plot(v_fem,'k*'); hold on
clear grid;
grid on; grid minor
legend('bem openmeeg','fem duneuro');

%% John Verification
bst_lf_vector_mosher(vol)
