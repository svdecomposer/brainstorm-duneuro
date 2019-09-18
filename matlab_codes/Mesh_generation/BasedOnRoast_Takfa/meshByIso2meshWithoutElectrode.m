function [node,elem,face,allMask] = meshByIso2meshWithoutElectrode(P1,P2,T2,opt,hdrInfo,uniTag)
% [node,elem,face] = meshByIso2mesh(P1,P2,T2,opt,hdrInfo,uniTag)
%
% Generate volumetric tetrahedral mesh using iso2mesh toolbox
% http://iso2mesh.sourceforge.net/cgi-bin/index.cgi?Download
%
% (c) Yu (Andy) Huang, Parra Lab at CCNY
% yhuang16@citymail.cuny.edu
% October 2017
%
% Update and adapted to FEM MEEG forward computation model.
% Takfarinas MEDANI
% July 2019, remove the electrode from the model

[dirname,baseFilename] = fileparts(P1);
if isempty(dirname), dirname = pwd; end
[~,baseFilenameRSPD] = fileparts(P2);
if isempty(T2)
    baseFilenameRSPD = [baseFilenameRSPD '_T1orT2'];
else
    baseFilenameRSPD = [baseFilenameRSPD '_T1andT2'];
end

data = load_untouch_nii([dirname filesep baseFilenameRSPD '_masks.nii']);
allMask = data.img;
%allMaskShow = data.img;
numOfTissue = 6; % hard coded across ROAST.  max(allMask(:));
%
% sliceshow(allMaskShow,[],[],[],'Tissue index','Segmentation. Click anywhere to navigate.')
% drawnow

% data = load_untouch_nii([dirname filesep baseFilename '_' uniTag '_mask_gel.nii']);
% allMask(data.img==255) = 7;
% data = load_untouch_nii([dirname filesep baseFilename '_' uniTag '_mask_elec.nii']);
% allMask(data.img==255) = 8;

%data = load_untouch_nii([dirname filesep baseFilename '_' uniTag '_mask_gel.nii']);

% sliceshow(data.img,[],[],[],'Tissue index','Segmentation. Click anywhere to navigate.')
% drawnow

% numOfGel = max(data.img(:));
% for i=1:numOfGel
%     allMask(data.img==i) = numOfTissue + i;
% % end
% allMaskShow(data.img>0) = numOfTissue + 1;
% data = load_untouch_nii([dirname filesep baseFilename '_' uniTag '_mask_elec.nii']);
% numOfElec = max(data.img(:));
% for i=1:numOfElec
%     allMask(data.img==i) = numOfTissue + numOfGel + i;
% end
% allMaskShow(data.img>0) = numOfTissue + 2;

% sliceshow(allMask,[],[],[],'Tissue index','Segmentation. Click anywhere to navigate.')
%% Romove the bottom part of the head
allMask = data.img;

if opt.cutMri == 1;
    if isfield(opt,'keepSliceFrom') 
        keepSliceFrom = opt.keepSliceFrom;
    else
        keepSliceFrom = round(size(allMask,3)/4); % default value
    end
    allMask = allMask(:,:,keepSliceFrom:end);
    % find the voxel belonging to the head and set as head in order to
    % close the volume
    countour_head =find(allMask(:,:,1:3)~=0);
    % replace all the bottom part of the mri by the scalp/skin tissu ID
    % {'WHITE','GRAY','CSF','BONE','SKIN','AIR'}
    % {1,2,3,4,5,'AIR'}
    allMask(countour_head) = 5;
else
    keepSliceFrom = 1;
end
%% Do some processing funcion
% sliceshow(allMask,[],[],[],'Tissue index','Segmentation. Click anywhere to navigate.'); drawnow
%sliceshow(allMask,[],'gray',[],[],'MRI: Click anywhere to navigate.'); drawnow
%  http://iso2mesh.sourceforge.net/cgi-bin/index.cgi?Doc/FunctionList#Mesh_decomposition_and_query
%  vol=smoothbinvol(allMask,10);
%  allMask = uint8(vol) ;
% sliceshow(vol,[],[],[],'Tissue index','Segmentation. Click anywhere to navigate.');drawnow
%sliceshow(cleanimg,[],'gray',[],[],'MRI: Click anywhere to navigate.'); drawnow


%% mesh the volume

%[node,elem,face,regions]=vol2mesh(allMaskShow,1:size(allMaskShow,1),1:size(allMaskShow,1),1:size(allMaskShow,1),opt,opt.maxvol,1)

% allMask = uint8(allMask);

% opt.radbound = 5; % default 6, maximum surface element size
% opt.angbound = 30; % default 30, miminum angle of a surface triangle
% opt.distbound = 0.4; % default 0.5, maximum distance
% % between the center of the surface bounding circle and center of the element bounding sphere
% opt.reratio = 3; % default 3, maximum radius-edge ratio
% maxvol = 10; %100; % target maximum tetrahedral elem volume

[node,elem,face] = cgalv2m(allMask,opt,opt.maxvol);
if 0
    [node,elem,face]=vol2mesh(allMask,1:size(allMask,1),1:size(allMask,2),1:size(allMask,3),...
        opt,opt.maxvol,1,'cgalmesh')
end

node(:,1:3) = node(:,1:3) + 0.5; % then voxel space
figure;plotmesh(node(:,1:3),elem)
if ~isempty(hdrInfo)
    for i=1:3, node(:,i) = node(:,i)*hdrInfo.pixdim(i); end
end

figure;
%allMaskd=double(allMask);
h=slice(double(allMask),[],[120],[120 180]);
set(h,'linestyle','none')
hold on
plotmesh(node(:,[2 1 3]),face,'facealpha',0.7);

% Put mesh coordinates into pseudo-world space (voxel space but scaled properly
% using the scaling factors in the header) to avoid mistakes in
% solving. Putting coordinates into pure-world coordinates causes other
% complications. Units of coordinates are mm here. No need to convert into
% meter as voltage output from solver is mV.
% ANDY 2019-03-13

% figure;
% % plotmesh(node(:,1:3),face,elem)
%
% % visualize tissue by tissue
% for i=1:length(maskName)
%     indElem = find(elem(:,5) == i);
%     indFace = find(face(:,4) == i);
%     plotmesh(node(:,1:3),face(indFace,:),elem(indElem,:))
%     title(maskName{i})
%     pause
% end
disp('======================================================')
disp('     STEP 3bis : SAVE THE MESH ...       ')
disp('======================================================')
if opt.saveMeshFormatMat == 1;
    disp('saving mesh mat fomat...')
    save([dirname filesep baseFilename '_' uniTag '.mat'],'node','elem','face','allMask');
end
if opt.saveMeshFormatMsh == 1;
    disp('saving mesh msh fomat...')
    maskName(1:numOfTissue) = {'WHITE','GRAY','CSF','BONE','SKIN','AIR'};
    savemsh(node(:,1:3),elem,[dirname filesep baseFilename '_' uniTag '.msh'],maskName);
end
end