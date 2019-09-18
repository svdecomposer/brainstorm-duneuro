%% Process of segmentation derived from roast
% last modification july 10th 2019 Takfarinas MEDANI

close all;clear all
answer = questdlg(' Are you new user  ?', ...
    ' Roast Toolbox',...
    'Yes', ...
    'No','No');
% Handle response
switch answer
    case 'Yes'
        newUser = 1;
        
    case 'No'
        newUser = 0;
end
if newUser
    % In order to use this script you need to download the rost toolbox
    y = 1; n = 0;
    % HaveRoast = input('Do you have Roast Toolbox :  [ y or n]:  ' );
    HaveRoast = inputdlg('Do you have Roast Toolbox :  [ 1 for yes or  0 for no]:  ' );
    HaveRoast = str2num(HaveRoast{1});
    if ~HaveRoast
        answer = questdlg('You need to download roast ?', ...
            ' Roast Toolbox',...
            'Go to Roast WebPage', ...
            'Cancel','Go to Roast WebPage');
        % Handle response
        switch answer
            case 'Go to Roast WebPage'
                uiwait(msgbox({'You will be directed to the roast webpage' ; ...
                    'download the toolbox and then re-run this script '}))
                web(' https://www.parralab.org/roast/')
                return
            case 'Cancel'
                disp('I''ll bring you your check.')
                return
        end
    end
    
    %pathToRoast = input('Enter the full path to the roast toolbox  [as a string ''path/to/roast'' ]:  ' );
    pathToRoast = inputdlg('Enter the full path to the roast toolbox  ''path/to/roast'' :  ');
    % add this path und subfolder to matlab
    if ~isfolder(pathToRoast{1})
        error('This is not a correct path')
    end
    if isfolder(pathToRoast{1})
        addpath(genpath(pathToRoast{1}))
        currentFolder = pwd;
        cd(pathToRoast{1})
    else
        error('This is not a correct path')
    end
    
end
%% path to Name of the MRI data
%subjRSPD = 'example/MNI152_T1_1mm.nii';
subjRSPD = 'example\anandmri\009_S_4337_T1w.nii';

% you can either add a T2 image in order to improve the mesh
T2 = [];

[dirname,baseFilename] = fileparts(subjRSPD);
[~,baseFilenameRSPD] = fileparts(subjRSPD);
%%  STEP 0 : VIEW OF THE MRI...
data = load_untouch_nii(subjRSPD);
allMaskShow = data.img;
allMaskShow = data.img(:,:,90:end);

figure;
sliceshow(allMaskShow,[],[],[],'Tissue index','Segmentation. Click anywhere to navigate.')
drawnow

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

model =0;
if model == 0,    maxvol = 50; reratio = 3; radbound = 5; angbound = 30; distbound = 0.4; end
if model == 1,    maxvol = 10; reratio = 3; radbound = 5; angbound = 30; distbound = 0.4; end
if model == 2,    maxvol =   5; reratio = 3; radbound = 5; angbound = 30; distbound = 0.4; end
if model == 3,    maxvol =   1; reratio = 3; radbound = 5; angbound = 30; distbound = 0.4; end
 
saveMeshFormatMat = 1;
saveMeshFormatMsh= 0;

meshOpt = struct('radbound',radbound,'angbound',angbound,...
                             'distbound',distbound,'reratio',reratio,...
                             'maxvol',maxvol,'saveMeshFormatMat',saveMeshFormatMat,...
                             'saveMeshFormatMsh',saveMeshFormatMsh);
% uniqueTag = ['reratio_', num2str(reratio),'_maxvol_',num2str(maxvol)];
uniqueTag = ['MeshModel_', num2str(maxvol),'_',num2str(reratio)...
                                            '_',num2str(radbound), '_',num2str(angbound) , '_',num2str(distbound)];

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
title(['Model '  num2str(model) '  ' baseFilename '  ' uniqueTag], 'Interpreter', 'none');

% plot the boundary surface of the generated mesh
allMaskd=double(allMask);
figure;
h=slice(allMaskd,[],[120],[120 180]);
set(h,'linestyle','none')
hold on
plotmesh(node(:,[2 1 3]),face,'facealpha',0.7);

