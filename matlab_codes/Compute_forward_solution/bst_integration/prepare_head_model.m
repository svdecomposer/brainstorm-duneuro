%% Prepare the head model 
% Script that generate the mesh from the surfaces
% Creation  August 28, 2019, 
%Takfarinas MEDANI 

%% 0- Main parameters
nb_layers = 3;
tissuelabel = {'Inner','Outer','Scalp'};
conductivity = [1 0.0125 1];
%% 1- Load the surfaces
% Here I use the default subject but it can be any of the surfaces
cd (bstAnatomyPath);
head  = load(fullfile(bstAnatomyPath,'tess_head.mat'));
inner  = load(fullfile(bstAnatomyPath,'tess_innerskull.mat'));
outer  = load(fullfile(bstAnatomyPath,'tess_outerskull.mat'));
brain  = load(fullfile(bstAnatomyPath,'tess_cortex_pial_low.mat'));
elctrode = load(fullfile(bstElectrodePath,'channel_BioSemi_128_A1.mat'));
%% 2- Merge the surfaces
[newnode,newelem]=mergemesh(head.Vertices,head.Faces,...
                                                     outer.Vertices,outer.Faces,...
                                                     inner.Vertices,inner.Faces);
% Channel location :
for ind = 1: length(elctrode.Channel) 
    channel_loc(ind,:) = elctrode.Channel(ind).Loc;
end
% Plot the surface and visual checking
h1 = figure;
plotmesh(newnode,newelem,'y>0');
hold on
plotmesh(mean(inner.Vertices),'r*','markersize',15)
xlabel('X');ylabel('Y');zlabel('Z');
% find the center of the mesh
coor = mean((inner.Vertices));
hold on
quiver3(coor(1),coor(2),coor(3),0,0,0.1,'LineWidth',2);
hold on;
plotmesh(channel_loc,'k.','markersize',10)
%% Find the seed point for eaxh region
% Find the distance from the center of the inner layer
center_inner = mean(inner.Vertices);
[~,~,~,~,seedRegion1]=raysurf(center_inner,[0 0 1],inner.Vertices,inner.Faces);
[~,~,~,~,seedRegion2]=raysurf(center_inner,[0 0 1],outer.Vertices,outer.Faces);
[~,~,~,~,seedRegion3]=raysurf(center_inner,[0 0 1],head.Vertices,head.Faces);
hold on;
plotmesh([seedRegion1;seedRegion2;seedRegion3],'r.','markersize',10);

%% Generate the volume Mesh
% Generate volume mesh
% [node,elem,face]=surf2mesh(v,f,p0,p1,keepratio,maxvol,regions,holes,forcebox)
% parameter to tune in order to change the mesh resolution
% maxvol = 10; % [10 to 0.0001]

factor_bst = 1.e-6;
keepratio = 1;
regions = [seedRegion1;seedRegion2;seedRegion3];
% The order is important, the outpur label will be related to this order,
% which is related to the conductivity value.
[node,elem,face]=surf2mesh(newnode,newelem,...
                                                min(newnode),max(newnode),...
                                                keepratio,maxvol*factor_bst,regions,[]);  
h2 = figure;
plotmesh(node,elem,'y>0');
xlabel('X');ylabel('Y');zlabel('Z');    
% we got this: 0 is scalp, 1 is inner,  2 outer,
% should be : 3 is scalp, 1 for inner, 2 outer 
% Identification of the volume id :: Should be done automatiquely 
% Change 
    % 0 ==> 3 for scalp
    elem((elem(:,5)==0),5) = 3;

%% Mesh check and repair 
[no,el]=removeisolatednode(node,elem(:,1:4));
% orientation required for the FEM computation (at least with SimBio, may be not for Dueneuro)
[newelem, ~]= meshreorient(no,el(:,1:4));
elem = [newelem elem(:,5)];

%% Final visualisation
close all
h3 = figure;
for ind = 1 : length(unique(elem(:,5)))
plotmesh(node,elem((elem(:,5)==ind),:) ,'y>0');
hold on;
grid on; grid minor;
end
legend({'Inner','Outer','Scalp'})
