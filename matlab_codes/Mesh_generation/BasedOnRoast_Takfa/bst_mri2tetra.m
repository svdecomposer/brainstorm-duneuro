function [node,elem,face,allMask] = bst_mri2tetra(pathToT1,pathToT2,options)
% [node,elem,face,allMask] = bst_mri2tetra(pathToT1,pathToT2,options)
% volumetric mesh generation from segmented mri volumetric images 

% input :
% pathToT1 :  string, absolute or relative path to the T1 MRI, with the data format *.nii
% pathToT2 :  string or empty vector [], absolute or relative path to the T2 MRI, with
% the data format  *.nii, if T2 is not available, empy vector as input is accepted [].
% options: parameters for CGAL mesher, if options is a structure,
%              options = struct('radbound',radbound,'angbound',angbound,...
%                              'distbound',distbound,'reratio',reratio,...
%                              'maxvol',maxvol,'saveMeshFormatMat',saveMeshFormatMat,...
%                              'saveMeshFormatMsh',saveMeshFormatMsh);
% then
%	     options.radbound: defines the maximum surface element size
%	     options.angbound: defines the miminum angle of a surface triangle
%	     options.distbound: defines the maximum distance between the
%		 center of the surface bounding circle and center of the
%		 element bounding sphere
%	     options.reratio:  maximum radius-edge ratio
%	     if options is a scalar, it only specifies radbound.
%	     options.maxvol: target maximum tetrahedral elem volume
% The additional parameters are :
%        options.cutMri  : Option 1 or 0, that allows to cut the IMR on the Z direction
% and keeping only the top part, whic ic the most relebant for MEEG
% modeling, the defaut cutting value is set to z = roud(size(mriVol,3)/4);
%        options.keepSliceFrom : value of the slice        
%        options.saveMeshFormatMat : Save the mesh on the format mat matlab, set to  1 or 0
%        options.saveMeshFormatMsh : Save the mesh on the format mat msh, set to  1 or 0
%        options.plotMesh : Save the final mesh, set to  1 or 0
% http://www.cgal.org/Manual/3.5/doc_html/cgal_manual/Mesh_3/Chapter_main.html
% ouput :
%    node: output, node coordinates of the tetrahedral mesh
% 	 elem: output, element list of the tetrahedral mesh, the last 
% 	       column is the region ID
% 	 face: output, mesh surface element list of the tetrahedral mesh
% 	       the last column denotes the boundary ID
%     allMask : The output of the MRI segmentation used to generate the mesh
% The main extracted tissu are : {'WHITE','GRAY','CSF','BONE','SKIN'}
%% Dependencies : 
% Roast toolbox : https://www.parralab.org/roast/
% meshByIso2meshWithoutElectrode.m
% %%%%%
% last modification july 10th 2019
% Created on july 10th 2019
% Takfarinas MEDANI
% medani@usc.edu
%% Example :
% cd to the roast toolbox
% pathToT1 = 'example\anandmri\009_S_4337_T1w.nii';
% pathToT2 = [];
% model =0;
% if model == 0,    maxvol = 50; reratio = 3; radbound = 5; angbound = 30; distbound = 0.4; end
% if model == 1,    maxvol = 10; reratio = 3; radbound = 5; angbound = 30; distbound = 0.4; end
% if model == 2,    maxvol =   5; reratio = 3; radbound = 5; angbound = 30; distbound = 0.4; end
% if model == 3,    maxvol =   1; reratio = 3; radbound = 5; angbound = 30; distbound = 0.4; end
% 
% saveMeshFormatMat = 0;
% saveMeshFormatMsh= 0;
% plotMesh = 1;
% cutMri =1;
% options = struct('radbound',radbound,'angbound',angbound,...
%                              'distbound',distbound,'reratio',reratio,...
%                              'maxvol',maxvol,'saveMeshFormatMat',saveMeshFormatMat,...
%                              'saveMeshFormatMsh',saveMeshFormatMsh,...
%                               'plotMesh',plotMesh,'cutMri',cutMri);
% [node,elem,face,allMask] = bst_mri2tetra(pathToT1,pathToT2,options)



%% Process of segmentation derived from roast toolbox

%% path to Name of the MRI data
%subjRSPD = 'example/MNI152_T1_1mm.nii';
subjRSPD =pathToT1;

% you can either add a T2 image in order to improve the mesh
T2 = pathToT2;

[dirname,baseFilename] = fileparts(subjRSPD);
[~,baseFilenameRSPD] = fileparts(subjRSPD);
%%  STEP 0 : VIEW OF THE MRI...
data = load_untouch_nii(subjRSPD);
allMaskShow = data.img;
%%%% set automatic way to cut the MRI image
allMaskShow = data.img(:,:,90:end);

if 0
    figure;
    sliceshow(allMaskShow,[],[],[],'Tissue index','Segmentation. Click anywhere to navigate.')
    drawnow
end
%%  STEP 1 : SEGMENT THE MRI...
% step 1  : segmentation using spm ... goo deeper in order to have more
% details about this function
if (isempty(T2) && ~exist([dirname filesep 'c1' baseFilenameRSPD '_T1orT2.nii'],'file')) ||...
        (~isempty(T2) && ~exist([dirname filesep 'c1' baseFilenameRSPD '_T1andT2.nii'],'file'))
    disp('======================================================')
    disp('       STEP 1 : SEGMENT THE MRI...          ')
    disp('======================================================')
    start_seg(subjRSPD,T2);
else
    disp('======================================================')
    disp('          MRI ALREADY SEGMENTED, SKIP STEP 1          ')
    disp('======================================================')
end

%%  STEP 2 : SEGMENTATION TOUCHUP...
if (isempty(T2) && ~exist([dirname filesep baseFilenameRSPD '_T1orT2_masks.nii'],'file')) ||...
        (~isempty(T2) && ~exist([dirname filesep baseFilenameRSPD '_T1andT2_masks.nii'],'file'))
    disp('======================================================')
    disp('     STEP 2 : SEGMENTATION TOUCHUP...       ')
    disp('======================================================')
    segTouchup(subjRSPD,T2);
else
    disp('======================================================')
    disp('    SEGMENTATION TOUCHUP ALREADY DONE, SKIP STEP 2    ')
    disp('======================================================')
end

%%  STEP 3: MESH GENERATION...
% see cgalv2m for more information
meshOpt = options;
uniqueTag = ['MeshModel_', num2str(options.maxvol),'_',num2str(options.reratio)...
    '_',num2str(options.radbound), '_',num2str(options.angbound) ,...
    '_',num2str(options.distbound)];
if ~exist([dirname filesep baseFilename '_' uniqueTag '.mat'],'file')
    disp('======================================================')
    disp('        STEP 3: MESH GENERATION...         ')
    disp('======================================================')
    [node,elem,face,allMask] = meshByIso2meshWithoutElectrode(subjRSPD,subjRSPD,T2,meshOpt,[],uniqueTag);
else
    disp('======================================================')
    disp('          MESH ALREADY GENERATED, SKIP STEP 3         ')
    disp('======================================================')
    load([dirname filesep baseFilename '_' uniqueTag '.mat'],'node','elem','face');
end

% processing the mesh 
% [conn,~,~]=meshconn(elem,length(node))
% node1=smoothsurf(node,[],conn,10,20,'Lowpass')
% [no,el]=removeisolatednode(node1,elem);   % remove all internal nodes
% plotmesh(no,el,'z<120 & x>80' )

if isfield(options,'plotMesh')
    if options.plotMesh ==1
        %% STEP 3: MESH VISUALISATION...
        disp('======================================================')
        disp('   VISUALISATION OF THE MESH    ')
        disp('======================================================')
        maskName = {'WHITE','GRAY','CSF','BONE','SKIN'};
        skin_mesh_clr         = [255 213 119]/255; bone_mesh_clr  = [140  85  85]/255;
        csf_mesh_clr  = [202 50 150]/255;grey_mesh_clr = [150 150 150]/255;
        white_mesh_clr = [250 250 250]/255;
        couleur=[skin_mesh_clr;bone_mesh_clr;csf_mesh_clr;grey_mesh_clr;white_mesh_clr];
        face_color = couleur;
         %% volume visulaisation
       figure
        for i=1:length(maskName)
            hold on
            indElem = find(elem(:,5) == i);
            indFace = find(face(:,4) == i);
            %     plotmesh(node(:,1:3),face(indFace,:),elem(indElem,:))
            plotmesh(node(:,1:3),elem(indElem,:),'z<120 & x>80','facecolor',face_color(6-i,:) )
            %title([maskName{i} ' id = ' num2str(i)])
            %pause
        end
        legend({'WHITE','GRAY','CSF','BONE','SKIN'})
        title(['Volume Model '  baseFilename '  ' uniqueTag], 'Interpreter', 'none');
       
        %% Surfaces visulaisation
        figure
        for i=1:length(maskName)
            hold on
            %indElem = find(elem(:,5) == i);
            indFace = find(face(:,4) == i);
            %     plotmesh(node(:,1:3),face(indFace,:),elem(indElem,:))
            plotmesh(node(:,1:3),face(indFace,:),'z<120 & x>80','facecolor',face_color(6-i,:) )
            %title([maskName{i} ' id = ' num2str(i)])
            %pause
        end
        legend({'WHITE','GRAY','CSF','BONE','SKIN'})
        title(['Surface Model '  baseFilename '  ' uniqueTag], 'Interpreter', 'none');
        allMaskd=double(allMask);
        
        figure;
        h=slice(allMaskd,[],[120],[120 180]);
        set(h,'linestyle','none')
        hold on
        plotmesh(node(:,[2 1 3]),face,'facealpha',0.7);
    end
end
end
