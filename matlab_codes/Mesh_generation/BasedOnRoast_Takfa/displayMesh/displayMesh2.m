clear all
load('G:\My Drive\GitFolders\GitHub\brainstorm-duneuro\matlab_codes\Compute_forward_solution\bst_integration\ICBM152_8233.mat')
% matlab structure
femtemplate = struct(...
            'Comment',         'fem head model', ...
            'Vertices',        vol.head_model.node, ...   % [Nvert x 3] double: List of position of the nodes with their three cartesian coordinates
            'Elements',        vol.head_model.elem(:,1:4), ...   % [Nelem x 4] integers for tetrahedral meshes; or [Nnode x 8] integers for hexahedral meshes (1-based indices in the Vertices matrix)
            'Tissue',          vol.head_model.elem(:,5), ...   % [1 x Nelem] integer: tissue classification for each node
            'TissueLabels',   [], ...   % [1 x Ntissue] cell array: label of the tissues in this head model
            'History',         []);
%% pblm :
% bst can not load this structure withthe tissulabel
% or from the matlab structure
% define 5 tissus color 
DefineTissuColors

% PlotOption : Input shoud be controled from the gui
plotMeshOption=[];
%% Parameter that the user can tune
% Plotting the mesh
% specify the equation of the plan ax+by+cz+d <==> rhs
ax = 1; by = 0; cz =0; d= 0;
operator = '>' ;% could be <, >, <=, >=;
rhs = 0;
if ~(ax*by*cz*d) && ~isempty(operator)
    CutingPlanEquation = ...
        [num2str(ax) '*x+' num2str(by) '*y+' num2str(cz) '*z+' num2str(d) operator  num2str(rhs)];
    plotMeshOption.CutingPlanEquation = CutingPlanEquation;
else
    if isfield(plotMeshOption,'CutingPlanEquation');
        plotMeshOption =  rmfield(plotMeshOption,'CutingPlanEquation');
    end
end

% Display edge (mesh)
displayedge = 1;  edgecolor = 'k'; linestyle ='--' ;% '-' | '--' | ':' | '-.' | 'none'
plotMeshOption.displayedge = displayedge;
plotMeshOption.edgecolor = edgecolor;
plotMeshOption.linestyle = linestyle;
% Display node (mesh); % Format of the node , 
% Node size : markersize option
displaynode =1;  nodestyle = '.'; % nodestyle : '.','o','*',.. similar as matlab plot
nodecolor = 'k';markersize = 10;
plotMeshOption.displaynode = displaynode;
plotMeshOption.nodestyle = nodestyle;
plotMeshOption.nodecolor = nodecolor;
plotMeshOption.markersize = markersize;

% Facecolor
displayfacecolor = 1; facecolor ='g';
plotMeshOption.displayfacecolor = displayfacecolor;
plotMeshOption.facecolor = facecolor;

% Transparency
transparency = 1;
facealpha = 0.6;
plotMeshOption.transparency = transparency;
plotMeshOption.facealpha = facealpha;

% plot the brain
plotMeshOption.plotbrain = 0;

% Main function
bst_plotFemMesh(femtemplate, plotMeshOption)

