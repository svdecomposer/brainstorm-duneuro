
clear all

load('G:\My Drive\GitFolders\GitHub\brainstorm-duneuro\matlab_codes\Compute_forward_solution\bst_integration\ICBM152_8233.mat')

node = vol.head_model.node; % femtemplate.Vertices
elem =  vol.head_model.elem ; % femtemplate.Elements
brain = vol.head_model.brain ; % femtemplate.Vertices
tissuelabel = vol.head_model.tissuelabel; % femtemplate.TissueLabels
tissueId = vol.head_model.tissueId; % sort(uniaue(femtemplate.Elements))

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

node = femtemplate.Vertices;
elem =   [femtemplate.Elements femtemplate.Tissue];
%brain =  femtemplate.Vertices;
tissuelabel = vol.head_model.tissuelabel; %femtemplate.TissueLabels;
tissueId =  sort(unique(femtemplate.Tissue));


skin_clr   = [255 213 119]/255;
bone_clr  = [140  85  85]/255;
csf_clr     = [202 50 150]/255;
grey_clr   = [150 150 150]/255;
white_clr  = [250 250 250]/255;

tissuColor5Layer =[skin_clr;bone_clr;csf_clr;grey_clr;white_clr];

tissuColor3Layer = [csf_clr ; bone_clr ; skin_clr];
plotMeshOption=[];
%% Parameter that the user can tune
% Plotting the mesh
% specify the equation of the plan ax+by+cz+d <==> rhs
% Input shoud be controled from the gui

ax = 1; by = 0; cz =0; d= 0;
operator = '>' ;% could be <, >, <=, >=;
rhs = 0;
if ~(ax*by*cz*d) && ~isempty(operator)
    CutingPlanEquation = ...
        [num2str(ax) '*x+' num2str(by) '*y+' num2str(cz) '*z+' num2str(d) operator  num2str(rhs)];
    plotMeshOption.CutingPlanEquation = CutingPlanEquation;
else
    if isfield(plotMeshOption,'CutingPlanEquatio');
        plotMeshOption =  rmfield(plotMeshOption,'CutingPlanEquatio');
    end
end

% Display edge (mesh)
displayedge = 1;  edgecolor = 'k'; linestyle ='--' ;% '-' | '--' | ':' | '-.' | 'none'
plotMeshOption.displayedge = displayedge;
plotMeshOption.edgecolor = edgecolor;
plotMeshOption.linestyle = linestyle;
% Display node (mesh); % Format of the node , % nodestyle : '.','o','*',.. similar as matlab plot
% Node size : markersize option
displaynode =1;  nodestyle = '.';  nodecolor = 'k';markersize = 10;
plotMeshOption.displaynode = displaynode;
plotMeshOption.nodestyle = nodestyle;
plotMeshOption.nodecolor = nodecolor;
plotMeshOption.markersize = markersize;

% Facecolor
displayfacecolor = 1;
facecolor ='g';
plotMeshOption.displayfacecolor = displayfacecolor;
plotMeshOption.facecolor = facecolor;

% Transparency
transparency = 1;
plotMeshOption.transparency = transparency;
facealpha = 0.6;
plotMeshOption.facealpha = facealpha;

% plot the brain
plotMeshOption.plotbrain =1;

if ~isfield(plotMeshOption,'CutingPlanEquatio')
    fig = figure;
    % Plot the Brain/source space
    if plotMeshOption.plotbrain == 1
        h = plotmesh(brain.Vertices,brain.Faces,...
            'edgecolor','none',...
            'facecolor',grey_clr,...
            'DisplayName','brain');
        hold on;
    end
    % Plot the head
    for ind = 1 : length(tissuelabel)
        id = elem(:,5)==ind;
        h = plotmesh(node,elem(id,:),...
            'edgecolor','none',...
            'facecolor',tissuColor3Layer(ind,:),...
            'DisplayName',tissuelabel{ind});
        hold on;
    end
    hold off
    legend show
    set(0,'defaultLegendAutoUpdate','off');

    % display displaynode
    if plotMeshOption.displaynode == 1
        hold on;
        h = plotmesh(node,[plotMeshOption.nodecolor ...
            plotMeshOption.nodestyle],...
            'markersize',plotMeshOption.markersize);
    end
    set(0,'defaultLegendAutoUpdate','off');
    % display edge
    if plotMeshOption.displayedge == 1
%        set(h, 'edgecolor',plotMeshOption.edgecolor)
        set(h, 'linestyle', plotMeshOption.linestyle) % '-' | '--' | ':' | '-.' | 'none' plotMeshOption,linestyle
    end
    % Facecolor
    if plotMeshOption.displayfacecolor == 1
        set(h, 'facecolor',plotMeshOption.facecolor)
    end
    % Transparency
    if plotMeshOption.transparency == 1
        set(h, 'facealpha',plotMeshOption.facealpha)
    end
    
else %% using cutting plan
    fig = figure;
    % Plot the Brain/source space
    if plotMeshOption.plotbrain == 1
        h = plotmesh(brain.Vertices,brain.Faces,...
            'edgecolor','none',...
            'facecolor',grey_clr,...
            'DisplayName','brain');
        hold on;
    end
    % Plot the head    
    for ind = 1 : length(tissuelabel)
        id = elem(:,5)==ind;
        h = plotmesh(node,elem(id,:),...
            plotMeshOption.CutingPlanEquation,...
            'edgecolor','none',...
            'facecolor',tissuColor3Layer(ind,:),...
            'DisplayName',tissuelabel{ind});
        hold on;
    end
    hold off
    legend show
    set(0,'defaultLegendAutoUpdate','off');

    % display displaynode
    if plotMeshOption.displaynode == 1
        hold on;
        h = plotmesh(node,plotMeshOption.CutingPlanEquation,...
            [plotMeshOption.nodecolor ...
            plotMeshOption.nodestyle],...
            'markersize',plotMeshOption.markersize);
    end
    % display edge
    if plotMeshOption.displayedge == 1
        set(h, 'edgecolor',plotMeshOption.edgecolor)
        set(h, 'linestyle', plotMeshOption.linestyle) % '-' | '--' | ':' | '-.' | 'none' plotMeshOption,linestyle
    end
    % Facecolor
    if plotMeshOption.displayfacecolor == 2
        set(h, 'facecolor',plotMeshOption.facecolor)
    end
    % Transparency
    if plotMeshOption.transparency == 1
        set(h, 'facealpha',plotMeshOption.facealpha)
    end
end



