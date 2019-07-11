% Example :
%cd to the roast toolbox
pathToT1 = 'example\anandmri\009_S_4337_T1w.nii';
pathToT2 = [];
model =0;
if model == 0,    maxvol = 50; reratio = 3; radbound = 5; angbound = 30; distbound = 0.4; end
if model == 1,    maxvol = 10; reratio = 3; radbound = 5; angbound = 30; distbound = 0.4; end
if model == 2,    maxvol =   5; reratio = 3; radbound = 5; angbound = 30; distbound = 0.4; end
if model == 3,    maxvol =   1; reratio = 3; radbound = 5; angbound = 30; distbound = 0.4; end

saveMeshFormatMat = 1;
saveMeshFormatMsh= 0;
plotMesh = 1;
cutMri =1;
options = struct('radbound',radbound,'angbound',angbound,...
                             'distbound',distbound,'reratio',reratio,...
                             'maxvol',maxvol,'saveMeshFormatMat',saveMeshFormatMat,...
                             'saveMeshFormatMsh',saveMeshFormatMsh,...
                              'plotMesh',plotMesh,'cutMri',cutMri);
                          
bst_mri2tetra(pathToT1,pathToT2,options)