This folder contains the main function used to generate the volume mesh (tetra)
from T1 mri data. 

To run example, you should 
1- download the roast toolbox, 
2- copy/past the two functions in the same roast folder. 
	bst_mri2tetra.m
	meshByIso2meshWithoutElectrode.m
3- Now you can run the test_bst_mri2tetra.m

%%% Dependencies : 
% Roast toolbox : https://www.parralab.org/roast/
% meshByIso2meshWithoutElectrode.m



function [node,elem,face,allMask] = bst_mri2tetra(pathToT1,pathToT2,options)
% bst_mri2tetra(pathToT1,pathToT2,options)
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
%        options.aveMeshFormatMat : Save the mesh on the format mat matlab, set to  1 or 0
%        options.saveMeshFormatMsh : Save the mesh on the format mat msh, set to  1 or 0
%        options.plotMesh : Save the final mesh, set to  1 or 0
% http://www.cgal.org/Manual/3.5/doc_html/cgal_manual/Mesh_3/Chapter_main.html
%%% Dependencies : 
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
% saveMeshFormatMat = 1;
% saveMeshFormatMsh= 0;
% plotMesh = 1;
% cutMri =1;
% options = struct('radbound',radbound,'angbound',angbound,...
%                              'distbound',distbound,'reratio',reratio,...
%                              'maxvol',maxvol,'saveMeshFormatMat',saveMeshFormatMat,...
%                              'saveMeshFormatMsh',saveMeshFormatMsh,...
%                               'plotMesh',plotMesh,'cutMri',cutMri);
% bst_mri2tetra(pathToT1,pathToT2,options)