function [lf,model] = Compute_openmeeg_solution(model)
%% Compute bem solution
disp('Load the mesh')
vol_bem = [];
vol_bem.bnd(1).pos = model.surface.inner.node;
vol_bem.bnd(1).tri = model.surface.inner.face; % pointing inwards!!!
vol_bem.bnd(2).pos = model.surface.outer.node;
vol_bem.bnd(2).tri = (model.surface.outer.face); % pointing inwards!!!
vol_bem.bnd(3).pos = model.surface.head.node;
vol_bem.bnd(3).tri = (model.surface.head.face); % pointing inwards!!!
disp('Prepare the Volume')
cfg=[];
cfg.method = 'openmeeg';
cfg.conductivity = model.conductivity;
% compute volume model
if isfield(model,'bem')
    if ~isfield(model.bem,'vol')
        disp('Volume : Computing ')
        tic
        vol_bem = ft_prepare_headmodel(cfg, vol_bem);
        time_prepare_volume = toc;
        model.bem.om.vol = vol_bem;
        model.bem.om.vol.time_prepare_volume = time_prepare_volume;
        % save the results
        if isfield(model,'save_result')
            if  (model.save_result == 1)
                if isfield(model,'folder')
                    save(fullfile(model.folder,model.name),'model');
                end
            end
        end
    else
        disp('Volume : already computed loading . . .')
        vol_bem = model.bem.om.vol;
    end
else
    disp('Volume : Computing ')
    tic
    vol_bem = ft_prepare_headmodel(cfg, vol_bem);
    time_prepare_volume = toc;
    model.bem.om.vol = vol_bem;
    model.bem.om.vol.time_prepare_volume = time_prepare_volume;
    % save the results
    if isfield(model,'save_result')
        if  (model.save_result == 1)
            if isfield(model,'folder')
                save(fullfile(model.folder,model.name),'model');
            end
        end
    end
end
disp('Prepare channels')
if ~isfield(model,'volume')
    surface_id = 0; % from surface
    model = find_nearest_node(model,surface_id);
    sens.elecpos = model.surface.elec_on_node;
elseif isfield(model,'volume')
    % if already computed
    if isfield(model,'elec_on_node')
        sens.elecpos = model.elec_on_node;
    else
        surface_id = 1; % from volume faces
        model = find_nearest_node(model,surface_id);
        sens.elecpos = model.elec_on_node;
    end
end
sens.label = {};
nsens = size(sens.elecpos,1);
for i_ch=1:nsens
    sens.label{i_ch} = sprintf('elec%03d', i_ch);
end

% Compute the grid matrix
cfg.grid.pos = model.source;
cfg.elec = sens;
cfg.headmodel = vol_bem;
model.bem.om.vol = vol_bem;

clear lf
lf = [];
if isfield(model,'bem')
    if ~isfield(model.bem.om.vol,'lf')
        disp('Leadfield Matrix : Computing ')
        grid = ft_prepare_leadfield(cfg);
        for ind = 1 : length(grid.leadfield)
            lf = [lf grid.leadfield{ind}];
        end
        model.bem.om.vol.lf = lf;
        % save the results
        if isfield(model,'save_result')
            if  (model.save_result == 1)
                if isfield(model,'folder')
                    save(fullfile(model.folder,model.name),'model');
                end
            end
        end
    else
        disp('Leadfield Matrix : Loading ')
        lf = model.bem.om.vol.lf;
    end
else
    disp('Leadfield Matrix : Computing ')
    grid = ft_prepare_leadfield(cfg);
    for ind = 1 : length(grid.leadfield)
        lf = [lf grid.leadfield{ind}];
    end
    model.bem.om.vol.lf = lf;
    
    % save the results
    if isfield(model,'save_result')
        if  (model.save_result == 1)
            if isfield(model,'folder')
                save(fullfile(model.folder,model.name),'model');
            end
        end
    end
end
disp('done!!')
end
