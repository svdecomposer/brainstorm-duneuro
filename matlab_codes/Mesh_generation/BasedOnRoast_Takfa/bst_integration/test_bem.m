function [lf_bem, head_model]= test_bem(head_model);
% ad to path the openmeeg path :
addpath('C:\matlab_toolbox\fieldtrip\fieldtrip-20181231\external\openmeeg');
% Create a BEM volume conduction model

vol_bem = [];
vol_bem.bnd(1).pos = head_model.head.Vertices;
vol_bem.bnd(1).tri = head_model.head.Faces;
vol_bem.bnd(2).pos = head_model.outer.Vertices;
vol_bem.bnd(2).tri = head_model.outer.Faces;
vol_bem.bnd(3).pos = head_model.inner.Vertices;
vol_bem.bnd(3).tri = head_model.inner.Faces;

% Compute the BEM
cfg=[];
cfg.method = 'openmeeg';
cfg.conductivity = head_model.conductivity;
vol_bem = ft_prepare_headmodel(cfg, vol_bem);
cfg.headmodel = vol_bem;
cfg.grid.pos = head_model.brain.Vertices;
% Create a set of electrodes on the outer surface

sens.elecpos = head_model.channel_loc;
sens.label = {};
nsens = size(sens.elecpos,1);
for ii=1:nsens
    sens.label{ii} = sprintf('Elec%03d', ii);
end
cfg.elec = sens;

grid = ft_prepare_leadfield(cfg);
head_model.grid = grid;
vol.head_model = head_model;
lf_bem = [];
for ind = 1 : length(grid.leadfield)
    lf_bem = [lf_bem grid.leadfield{ind}];
end
end