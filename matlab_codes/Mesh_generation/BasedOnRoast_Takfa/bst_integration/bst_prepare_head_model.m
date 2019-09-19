function head_model = bst_prepare_head_model(bstAnatomyPath,MeshOpt,plotHeadModel)

%% Prepare the head model 
% [node,elem,face] = bst_prepare_head_model(bstAnatomyPath,plotHeadModel)
% Function that generate the mesh from the surfaces files, in this function
% only three surface are considered. inne, outer and scalp as dfined in
% brainstorm software.
% input : 
% bstAnatomyPath : string format, path to the bst anatomy path
% maxvol : max size of the elements
% plotHeadModel : plot or nor the model (1,0) 
% output : 
% head_model structure with these field : 
% head_model.node = node; : liste of node, face and elements.
% head_model.face  = face;
% head_model.elem = elem;
% head_model.nb_layers = 3;
% head_model.tissuelabel = {'Inner','Outer','Scalp'};
% head_model.tissueId = [1 2 3]; 
% refers to the iso2mesh toolbox.
% Dependencies : Iso2mesh toolbox
% example : 
% bstAnatomyPath = 'C:\matlab_toolbox\brainstorm\brainstorm3\defaults\anatomy\ICBM152';
% maxvol = 1;
% plotHeadModel =1; 
% head_model = bst_prepare_head_model(bstAnatomyPath,maxvol,plotHeadModel);


% Creation  August 28, 2019, Takfarinas MEDANI 
% Update : 
% August 28, 2019 : write as function and remove the electrode part from this
% function


%% 1- Load the surfaces
% Here I use the default subject but it can be any of the surfaces
head  = load(fullfile(bstAnatomyPath,'tess_head.mat'));
inner  = load(fullfile(bstAnatomyPath,'tess_innerskull.mat'));
outer  = load(fullfile(bstAnatomyPath,'tess_outerskull.mat'));
brain  = load(fullfile(bstAnatomyPath,'tess_cortex_pial_low.mat'));
%% 2- Merge the surfaces
[newnode,newelem]=mergemesh(head.Vertices,head.Faces,...
                                                     outer.Vertices,outer.Faces,...
                                                     inner.Vertices,inner.Faces);
% Find the seed point for each region
center_inner = mean(inner.Vertices);
[~,~,~,~,seedRegion1]=raysurf(center_inner,[0 0 1],inner.Vertices,inner.Faces);
[~,~,~,~,seedRegion2]=raysurf(center_inner,[0 0 1],outer.Vertices,outer.Faces);
[~,~,~,~,seedRegion3]=raysurf(center_inner,[0 0 1],head.Vertices,head.Faces);


%% Generate the volume Mesh
% Generate volume mesh
% [node,elem,face]=surf2mesh(v,f,p0,p1,keepratio,maxvol,regions,holes,forcebox)
% parameter to tune in order to change the mesh resolution
% maxvol = 10; % [10 to 0.0001]
if isstruct(MeshOpt)
    maxvol = MeshOpt.maxvol;
    if isfield(MeshOpt, 'keepratio')
        keepratio = MeshOpt.keepratio;
    else
        keepratio = 1;
    end
else
    maxvol = MeshOpt;
    keepratio = 1;
end

factor_bst = 1.e-6;
%keepratio = 1;
regions = [seedRegion1;seedRegion2;seedRegion3];
% The order is important, the outpur label will be related to this order,
% which is related to the conductivity value.
% clear node,elem,face
[node,elem,face]=surf2mesh(newnode,newelem,...
                                                min(newnode),max(newnode),...
                                                keepratio,maxvol*factor_bst,regions,[]);  
% h2 = figure;
% plotmesh(node,elem,'y>0');
% xlabel('X');ylabel('Y');zlabel('Z');    
% we got this: 0 is scalp, 1 is inner,  2 outer,
% should be : 3 is scalp, 1 for inner, 2 outer 
% Identification of the volume id :: Should be done automatiquely 
% Change 
    % 0 ==> 3 for scalp
%% ---------------------------------------- WARNING -------------------------------------
    %% The dangerous part... on doit trouver moyen d'automatise cette partie
%elem((elem(:,5)==0),5) = 3;

%% Mesh check and repair 
[no,el]=removeisolatednode(node,elem(:,1:4));
% orientation required for the FEM computation (at least with SimBio, may be not for Dueneuro)
[newelem, ~]= meshreorient(no,el(:,1:4));
elem = [newelem elem(:,5)];

%% Final visualisation
if nargin == 3
    if plotHeadModel >0
figure;
subplot(1,2,2)
col = ['r','y','b'];
elemID = unique(elem(:,5));
for ind = 1 : length(elemID)
plotmesh(node,elem((elem(:,5)==elemID(ind)),:) ,'y>0','facecolor',col(ind));
hold on;
grid on; grid minor;
end
legend({'Inner','Outer','Scalp'})
hold on
coor = mean((inner.Vertices));
%quiver3(coor(1),coor(2),coor(3),0,0,0.1,'LineWidth',2);
subplot(1,2,1) ; % figure
plotmesh(inner.Vertices,inner.Faces ,'y>0','facecolor','r'); hold on;    
plotmesh(outer.Vertices,outer.Faces ,'y>0','facecolor','y'); hold on;
plotmesh(head.Vertices,head.Faces ,'y>0','facecolor','b'); hold on;
legend({'Inner','Outer','Scalp'});
grid on; grid minor;
end

%% Output
head_model.node = node;
head_model.face  = face;
head_model.elem = elem;
head_model.nb_layers = 3;
head_model.tissuelabel = {'Inner','Outer','Scalp'};
head_model.tissueId = [1 2 3]; % should be in the same order as tissuelabel

head_model.head = head;
head_model.outer = outer;
head_model.inner = inner;
head_model.brain = brain;
                                                

end
% % Channel location :
%elctrode = load(fullfile(bstElectrodePath,'channel_BioSemi_32.mat'));
% channel_loc = zeros(length(elctrode.Channel),3);
% for ind = 1: length(elctrode.Channel) 
%     channel_loc(ind,:) = elctrode.Channel(ind).Loc;
% end
% % Plot the surface and visual checking
% h1 = figure;
% plotmesh(newnode,newelem,'y>0');
% hold on
% plotmesh(mean(inner.Vertices),'r*','markersize',15)
% xlabel('X');ylabel('Y');zlabel('Z');
% % find the center of the mesh
% coor = mean((inner.Vertices));
% hold on
% quiver3(coor(1),coor(2),coor(3),0,0,0.1,'LineWidth',2);
% hold on;
% plotmesh(channel_loc,'k.','markersize',10)hold on;
% plotmesh([seedRegion1;seedRegion2;seedRegion3],'r.','markersize',10);