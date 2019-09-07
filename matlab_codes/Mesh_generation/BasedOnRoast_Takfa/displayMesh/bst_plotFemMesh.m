function bst_plotFemMesh(femtemplate, options)
% bst_plotFemMesh(femtemplate, options)
% Adapted version to plot the mesh from the bst structure. 
% plotMeshOption : struct with fields:

% CutingPlanEquation: '1*x+0*y+0*z+0>0' : Eqution of the cuttin plan 
% displayedge: 1
%   edgecolor: 'k'
%   linestyle: '--'
% displaynode: 1
%   nodestyle: '.'
%   nodecolor: 'k'
%   markersize: 10
% displayfacecolor: 1
%   facecolor: 'g'
% transparency: 1
%   facealpha: 0.6000

% TODO : when the pbm of the femtemplate is solved, you should adapt the TissueLabels
% %%%%%
% last modification September 7th 2019
% Created on September 6th 2019 2019
% Takfarinas MEDANI
% medani@usc.edu

DefineTissuColors

plotMeshOption = options;
node = femtemplate.Vertices;
elem =   [femtemplate.Elements femtemplate.Tissue];
%brain =  femtemplate.Vertices;
if ~isempty(femtemplate.TissueLabels)
    tissuelabel = vol.head_model.tissuelabel; %femtemplate.TissueLabels
else
    tissuelabel = {'Inner' 'Outer' 'Scalp'};
end
tissueId =  sort(unique(femtemplate.Tissue));


% Plot
if ~isfield(plotMeshOption,'CutingPlanEquation')
    figure;
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
        plotmesh(node,elem(id,:),...
            'edgecolor','none',...
            'facecolor',colorInnerOuterScalp(ind,:),...
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
        set(h, 'edgecolor',plotMeshOption.edgecolor)
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
    figure;
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
            'facecolor',colorInnerOuterScalp(ind,:),...
            'DisplayName',tissuelabel{ind});
        hold on;
    end
    hold off
    legend show
    set(0,'defaultLegendAutoUpdate','off');
    
    % display displaynode
    if plotMeshOption.displaynode == 1
        hold on;
            plotmesh(node,plotMeshOption.CutingPlanEquation,...
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
end