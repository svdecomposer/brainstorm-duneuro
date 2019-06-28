function [lf,model] = Compute_duneuro_solution(model)

%% adapt data input to Duneuro from the model
% create temporary directory temp
disp('Load the mesh and adapt it to duneuro')
current_dir = pwd;
temp_dir = 'temp';
mkdir(temp_dir)
% input files
filename_grid = 'model.msh';
filename_tensors = 'tet.cond';
% filename_electrodes = 'electrodes.txt';
% filename_dipoles = 'dip_position.txt';
% write the mesh file
if 1 % just to aligne the file :)
    cd(temp_dir)
    %% write the mesh file
    elem = model.volume.elem;
    node = model.volume.node;
    nnode = 1:length(node);
    nelem = 1 : length(elem);
    fc_ecriture_fichier_msh([nnode' node],[nelem' elem],nnode,filename_grid)
    %type(filename_grid)
    %% write the conductivity file
    x = model.conductivity(:);
    fileID = fopen(filename_tensors,'w');
    fprintf(fileID,'%f \n',x);
    fclose(fileID);
    %type(filename_tensors)
    %% adapt electrode
    electrodes = model.elec_on_node';
    %% adapt dipoles
    nv = size(model.source, 1); % source location
    dipoles = [kron(model.source,ones(3,1)), kron(ones(nv,1), eye(3))];
    dipoles = dipoles';
    %% Strart process of Duneuro
    %% create driver object
    disp('Prepare the Volume & create the "driver"')
    % Specify the driver type
    if isfield(model,'fem.dn')
        if ~isfield(model.fem.dn,'driver')
            if ~isfield(model,'duneuro_parameter')
                disp('driver_type : use default model ')
                cfg = [];
                cfg.type = 'fitted';
                cfg.solver_type = 'cg';
                cfg.element_type = 'tetrahedron';
            else
                disp('driver_type : load from  model.duneuro_parameter')
                cfg = [];
                cfg.type = model.duneuro_parameter.driver_type.cfg.type; %'fitted';
                cfg.solver_type = model.duneuro_parameter.driver_type.cfg.solver_type; %'cg';
                cfg.element_type = model.duneuro_parameter.driver_type.cfg.element_type; %'tetrahedron';
            end
            cfg.volume_conductor.grid.filename = filename_grid;
            cfg.volume_conductor.tensors.filename = filename_tensors;
            disp('Compute the driver')
            tic
            driver = duneuro_meeg(cfg);
            time_prepare_driver = toc;
            model.fem.dn.driver = driver;
            model.fem.dn.time_prepare_driver = time_prepare_driver;
            % save the results
            if isfield(model,'save_result')
                if  (model.save_result == 1)
                    if isfield(model,'folder')
                        save(fullfile(model.folder,model.name),'model');
                    end
                end
            end
        else % load the precomputed version
            disp('Load the driver')
            driver =  model.fem.dn.driver;
        end
    else  %%
        if ~isfield(model,'duneuro_parameter')
            disp('driver_type : use default model ')
            cfg = [];
            cfg.type = 'fitted';
            cfg.solver_type = 'cg';
            cfg.element_type = 'tetrahedron';
        else
            disp('driver_type : load from  model.duneuro_parameter')
            cfg = [];
            cfg.type = model.duneuro_parameter.driver_type.cfg.type; %'fitted';
            cfg.solver_type = model.duneuro_parameter.driver_type.cfg.solver_type; %'cg';
            cfg.element_type = model.duneuro_parameter.driver_type.cfg.element_type; %'tetrahedron';
        end
        cfg.volume_conductor.grid.filename = filename_grid;
        cfg.volume_conductor.tensors.filename = filename_tensors;
        disp('Compute the driver')
        tic
        driver = duneuro_meeg(cfg);
        time_prepare_driver = toc;
        model.fem.dn.driver = driver;
        model.fem.dn.time_prepare_driver = time_prepare_driver;
        % save the results
        if isfield(model,'save_result')
            if  (model.save_result == 1)
                if isfield(model,'folder')
                    cd(current_dir)
                    save(fullfile(model.folder,model.name),'model');
                    cd(temp_dir)
                end
            end
        end
        %%
    end
    %% Configuration for transfer matrix
    %% **********************************************
    
    
    %% **********************************************
    disp('Prepare channels')
    % Specify the elecrode computation model
    if ~isfield(model,'duneuro_parameter')
        cfg = [];
        cfg.codims = '3';
        cfg.type = 'closest_subentity_center';
    else
        cfg = [];
        cfg.codims = model.duneuro_parameter.electrode.codims; % '3'
        cfg.type = model.duneuro_parameter.electrode.type; % 'closest_subentity_center';
    end
    driver.set_electrodes(electrodes, cfg);
    %% compute transfer matrix
    disp('Compute the transfer matrix')
    % Specify the trasfer accuracy
    if ~isfield(model,'duneuro_parameter')
        cfg = [];
        cfg.post_process = 'true';
        cfg.solver.reduction = '1e-7';
    else
        cfg = [];
        cfg.post_process = model.duneuro_parameter.transfer.post_process;%'true';
        cfg.solver.reduction = model.duneuro_parameter.transfer.solver.reduction;%'1e-7';
    end
    transfer_matrix = driver.compute_eeg_transfer_matrix(cfg);
    %% compute lead field
    % Specify the source model & parameter
    disp('Specify the source Model')
    if ~isfield(model,'duneuro_parameter')
        source_model = 'venant';
    else % could be 'venant','partial_integration', 'venant' , 'subtraction' or, whitney
        source_model = model.duneuro_parameter.source_model;
    end
    
    disp('Specify the source parameter')
    if strcmp(source_model, 'partial_integration')% PI
        cfg = [];
        cfg.post_process = 'true';
        cfg.subtract_mean = 'true';
        cfg.source_model.type = 'partial_integration';%
    end
    if  strcmp(source_model, 'venant')
        cfg.source_model.type = 'venant';
        cfg.post_process = 'true';
        cfg.source_model.initialization = 'closest_vertex';
        cfg.source_model.intorderadd = '2';
        cfg.source_model.intorderadd_lb  = '2';
        cfg.source_model.numberOfMoments = '3';
        cfg.source_model.referenceLength = '20';
        cfg.source_model.relaxationFactor = '1e-6';
        cfg.source_model.restrict  = 'true';
        cfg.source_model.weightingExponent = '1';
        cfg.source_model.mixedMoments = 'false';
        cfg.subtract_mean = 'true';
    end
    
    if strcmp(source_model, 'subtraction')% subtraction
        cfg.source_model.type = 'subtraction';
        cfg.source_model.intorderadd = '2';
        cfg.source_model.intorderadd_lb  = '2';
    end
    if source_model== 4 % whitney
        error('This method is not included for now')
    end
    
    lf = driver.apply_eeg_transfer(transfer_matrix, dipoles, cfg);
    model.fem.dn.lf = lf;
    model.lf_dn = lf;
    if isfield(model,'save_result')
        if  (model.save_result == 1)
            if isfield(model,'folder')
                cd(current_dir)
                save(fullfile(model.folder,model.name),'model');
                cd(temp_dir)
            end
        end
    end
    %save(['fem_duneuro_lf_' num2str(source) '_source'],'lf')
    
end
%% return to the cirrent folder
cd(current_dir)
end


function fc_ecriture_fichier_msh(node,elem,Vn,fname)

% fc_ecriture_fichier_msh(node,elem,Vn,fname)
% Cette fonction permet de cr�e le fichier maillage *.msh qui sera lu par
% le gmesh, il prend en entr�e la liste des neouds sous la
% forme [num_node xn yn zn] et la liste des element sous la forme [num_elem
% n1 n2 n3 n4 id], le nom du fichier de sortie est 'fname'
% Une fois lancer, la fonction fais appel au fichier de sortie du code FEM
% de zhuxiang, et permet de lire le potentiel de cuaque noeud.
% Elle ne fonction uniquement avec les donnes de potentiel asoci�e au meme
% maillage
% cette fonction prend en entr� la liste des noeuds de maillage node,
% le potentiel associ�e a chaque noeud , et la liste des elements du maillage.

% Takfarinas Medani, last update 05/05/2015
%http://www.ensta-paristech.fr/~kielbasi/docs/gmsh.pdf

Nombre_de_noeuds=length(node);
Nombre_des_elements=length(elem);
% % num�rotation des noeuds et des elements
% for i=1:Nombre_de_noeuds
%     nbno(i)=i;
% end
% for i=1:Nombre_des_elements
%     nbel(i)=i;
% end
% newnode=[nbno' node];
% elem=[nbel' elem];
newnode=node;
newelem=elem;

nn=newnode(:,1);% num�ro du noeud
xn=newnode(:,2);% composante x du noeud
yn=newnode(:,3);% composante y du noeud
zn=newnode(:,4);% composante y du noeud


%a='toto2.msh';

% %ouvre ou cr�e un fichier
fid = fopen(fname,'wt');

%fprintf(fid,'%s\t\n','Maillage'); % teste
%Partie I du fichier
%fprintf(fid,'\r\n');
%% Informations du format du fichier de maillage
fprintf(fid,'%s\r\n','$MeshFormat');
fprintf(fid,'%s\r\n','2.2 0 8');
fprintf(fid,'%s\r\n','$EndMeshFormat ');

%% bloc des noeuds
fprintf(fid,'%s\r\n','$Nodes ');
%fprintf(fid,'%s\r\n',' Dimension    {3}  ');
%fprintf(fid,'\r\n');
fprintf(fid,'%i \r\n',Nombre_de_noeuds);

%�criture des noeuds ligne par ligne nn xn yn zn
for i=1:Nombre_de_noeuds
    fprintf(fid,'%i  %i  %i  %i \r\n',nn(i),xn(i),yn(i),zn(i));
end
fprintf(fid,'%s\r\n','$EndNodes');

%% bloc des elemnts
%ecriture de la partie II du fichier d'entr�e
ne=newelem(:,1); %Num�ro de l'element
ne1=newelem(:,2); %premier noeud de l'�l�ment
ne2=newelem(:,3); %2 �me  //     //
ne3=newelem(:,4); %3 �me  //     //
ne4=newelem(:,5); %4 �me  //     //
ne5=newelem(:,6); % domaine ID du materiau

elm_type_segment=1;
elm_type_triangle=2;
elm_type_quadrangle=3;
elm_type_tetra=4;

fprintf(fid,'\r\n');
fprintf(fid,'%s\r\n','$Elements');
fprintf(fid,'%i \r\n',Nombre_des_elements);

for i=1:Nombre_des_elements
    fprintf(fid,'%i %i %s  %i  %i  %i %i  %i %i \r\n',ne(i),elm_type_tetra,'2',0 ,ne5(i),ne1(i),ne2(i),ne3(i),ne4(i));
end
fprintf(fid,'%s\r\n','$EndElements');


%% bloc physical Names
fprintf(fid,'%s\r\n','$PhysicalNames');
nombre_de_couches=4;
fprintf(fid,'%i \r\n',nombre_de_couches);
fprintf(fid,'%i %i %s\r\n','1 1 toto1');
fprintf(fid,'%i %i %s\r\n','2 2 toto2');
fprintf(fid,'%i %i %s\r\n','3 3 toto3');
fprintf(fid,'%i %i %s\r\n','4 4 toto4');
fprintf(fid,'%s\r\n','$EndPhysicalNames');


%% $NodeData
% http://geuz.org/gmsh/doc/texinfo/gmsh.html#SEC62
fprintf(fid,'%s\r\n','$NodeData');
fprintf(fid,'%i \r\n',1); % one string tag:
fprintf(fid,'%s\r\n','"A scalar view"');
fprintf(fid,'%i\r\n',1); %one real tag:
fprintf(fid,'%i\r\n',0.0); %the time value (0.0)
fprintf(fid,'%i\r\n',3); % three integer tags:
fprintf(fid,'%i\r\n',0); %the time step (0; time steps always start at 0)
fprintf(fid,'%i\r\n',1); % 1-component (scalar) field
fprintf(fid,'%i\r\n',Nombre_de_noeuds); % nb associated nodal values

%Vn=fc_nodal_potential();
for i=1:Nombre_de_noeuds
    fprintf(fid,'%i %i \r\n',nn(i),Vn(i)-Vn(1));
end
fprintf(fid,'%s\r\n','$End$NodeData');
fclose(fid);
end