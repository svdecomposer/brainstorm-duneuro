%% Generate the source space from the grey matter
% The options :
% 1 - decimate the cortex
% 2 - source under nodes or source under surfaces// under the node is
% recommanded
% 3 - profondeur des sources par rapport au cortex


opts.decimate_cortex = 1; % reduce the number of source
opts.under_node_or_face = 1; % 1 for node and 0 for face
figure_title = ['Source'];
if opts.decimate_cortex == 1
    % ratio of the node that should be kept
    opts.keepratio = 0.01;
    figure_title = [figure_title ' decimated at ' num2str(100*opts.keepratio) ];
end
opts.source_depth = 0.004; % metre
figure_title = [figure_title ' at depth ' num2str(opts.source_depth*1000) 'mm' ];
% Load the cortex :
gm = load('gm_face.mat');
nodes_br = gm.newnode;
brain_surface_facets = gm.newface;
clear gm;

%% Start here
if opts.decimate_cortex == 1
    v=Espace_sources_liste{1};f=brain_surface_facets;
    [sources,faces_sources]=meshresample(v,f,opts.keepratio );
    nodes_br = sources;
    brain_surface_facets = faces_sources;
end

%I: Reorientation des surfaces
[nodes_br,brain_surface_facets]=surfreorient(nodes_br,brain_surface_facets);

% II : Compute the normal at each centroide of face and/or the normal at each node
TR = triangulation(brain_surface_facets,nodes_br(:,1),nodes_br(:,2),nodes_br(:,3));
if opts.under_node_or_face == 1 % 1 for node and 0 for facette
    nrm_sur_nodes = vertexNormal(TR);
    % I- Trouver les composante spherique de chaque normale à la surface:
    [azimuth,elevation,r_norm] = cart2sph(nrm_sur_nodes(:,1),nrm_sur_nodes(:,2),nrm_sur_nodes(:,3));
    figure_title = [ figure_title ' defined on '  num2str(length(nodes_br)) ' nodes' ];
    %% II - Choisir la profondeur de la postion de l'espace des sources dans la couche du cortex :
    profondeur_sources=opts.source_depth; % en mm
    
    %% III- Trouver les composantes dans les trois directions à partir du point centroide de chaque facette:
    profondeur_x = profondeur_sources .* cos(elevation) .* cos(azimuth);
    profondeur_y = profondeur_sources .* cos(elevation) .* sin(azimuth);
    profondeur_z = profondeur_sources .* sin(elevation);
    % verif=sqrt(profondeur_x.^2+profondeur_y.^2+profondeur_z.^2);
    %% IV- Appliquer cette profondeur dans chque direction à partir du centroide de chaque feacette:
    pos_source_x=nodes_br(:,1)-profondeur_x;
    pos_source_y=nodes_br(:,2)-profondeur_y;
    pos_source_z=nodes_br(:,3)-profondeur_z;
    
else % norm on facette
    nrm_sur_facette = faceNormal(TR);size(FN);
    brain_face_centroide=meshcentroid(nodes_br,brain_surface_facets);
    [azimuth,elevation,r_norm] = cart2sph(brain_face_centroide(:,1),brain_face_centroide(:,2),brain_face_centroide(:,3));
    figure_title = [ figure_title ' defined on '  num2str(length(brain_surface_facets)) ' faces' ];
    %% II - Choisir la profondeur de la postion de l'espace des sources dans la couche du cortex :
    profondeur_sources=opts.source_depth; % en mm
    
    %% III- Trouver les composantes dans les trois directions à partir du point centroide de chaque facette:
    profondeur_x = profondeur_sources .* cos(elevation) .* cos(azimuth);
    profondeur_y = profondeur_sources .* cos(elevation) .* sin(azimuth);
    profondeur_z = profondeur_sources .* sin(elevation);
    % verif=sqrt(profondeur_x.^2+profondeur_y.^2+profondeur_z.^2);
    %% IV- Appliquer cette profondeur dans chque direction à partir du centroide de chaque feacette:
    pos_source_x=brain_face_centroide(:,1)-profondeur_x;
    pos_source_y=brain_face_centroide(:,2)-profondeur_y;
    pos_source_z=brain_face_centroide(:,3)-profondeur_z;
end

%% V- Espace de source avec une profondeur définit par la variable : profondeur_sources
source_space=[pos_source_x pos_source_y pos_source_z];

%figure;plotmesh(source_space,brain_surface_facets,'facecolor',cortex_clr);

%% VI - Verification que toutes les sources sont bien dans la couche du cortex:

figure('color',[1 1 1]);
plotmesh(nodes_br,brain_surface_facets,'FaceColor',cortex_clr,'facealpha',0.2,'edgecolor','none');
% legend('nodes','sources')
%% Ajouter les vecteurs
if opts.under_node_or_face == 1 % 1 for node and 0 for facette
    hold on; quiver3(source_space(:,1),source_space(:,2),source_space(:,3),...
        nrm_sur_nodes(:,1),nrm_sur_nodes(:,2),nrm_sur_nodes(:,3),1,'color','r');
    hold on; plotmesh(nodes_br,'k.')
    hold on;plotmesh(source_space,'bo');
else
    hold on; quiver3(source_space(:,1),source_space(:,2),source_space(:,3),...
        nrm_sur_facette(:,1),nrm_sur_facette(:,2),nrm_sur_facette(:,3),1,'color','r');
    hold on; plotmesh(brain_face_centroide,'k.')
    hold on;plotmesh(source_space,'bo');
end
title(figure_title)