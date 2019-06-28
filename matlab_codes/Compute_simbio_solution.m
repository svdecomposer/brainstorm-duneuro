function [lf,model] = Compute_simbio_solution(model)
%% FEM Solution based on SimBio
disp('Load the mesh')
tau_unit = 1/1;

[newelem, ~] = meshreorient(model.volume.node,model.volume.elem(:,1:4));
temp = newelem;
newelem(:,3) = temp (:,4);
newelem(:,4) = temp (:,3);
clear temp;
[newelem, ~] = meshreorient(model.volume.node,newelem);
vol_fem = [];
vol_fem.tet = newelem;%elements(:,1:4);
vol_fem.pnt = tau_unit*model.volume.node	; % nodes
vol_fem.labels = model.volume.label;%labels;
vol_fem.tissue = model.volume.elem(:,5);
vol_fem.tissuelabel={'inner', 'outer', 'scalp'};
vol_fem.unit='mm';
vol_fem.cfg=[];
% volume conductor
disp('Prepare the Volume')
cfg              = [];
cfg.method       = 'simbio';
cfg.conductivity = model.conductivity;
%cfg.unit = 'mm';
% Stifness Matrix
% compute volume model
if isfield(model,'fem')
    if ~isfield(model.fem.sb,'vol')
        disp('Volume : Computing ')
        tic
        vol_fem = ft_prepare_headmodel(cfg,vol_fem); % ceuci calcul aussi la matrice de rigidité
        time_prepare_volume = toc;
        model.fem.sb.vol = vol_fem;
        model.fem.sb.vol.time_prepare_volume = time_prepare_volume;
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
        vol_fem = model.fem.sb.vol;
    end
else
    disp('Volume : Computing ')
    tic
    vol_fem = ft_prepare_headmodel(cfg,vol_fem); % ceuci calcul aussi la matrice de rigidité
    time_prepare_volume = toc;
    model.fem.sb.vol = vol_fem;
    model.fem.sb.vol.time_prepare_volume = time_prepare_volume;
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
elseif isfield(model,'volume')
    surface_id = 1; % from volume faces
end
model = find_nearest_node(model,surface_id);
sens.elecpos = tau_unit*model.elec_on_node;
sens.label = {};
nsens = size(sens.elecpos,1);
for i_ch=1:nsens
    sens.label{i_ch} = sprintf('elec%03d', i_ch);
end
disp('Transfer Matrix ')
if isfield(model,'fem')
    if ~isfield(model.fem.sb.vol,'transfer')
        disp('Transfer Matrix : Computing ')
        tic
        [transfer] = sb_transfer(model.fem.sb.vol,sens);% calcul de la matrice de tansfert :)
        time_compute_transfer = toc;
        model.fem.sb.vol.time_compute_transfer = time_compute_transfer;
        model.fem.sb.vol.transfer = transfer;
        vol_fem.transfer = transfer;
        % save the results
        if isfield(model,'save_result')
            if  (model.save_result == 1)
                if isfield(model,'folder')
                    save(fullfile(model.folder,model.name),'model');
                end
            end
        end
    else
        disp('Transfer Matrix : Already computed, Loading ')
        vol_fem.transfer = model.fem.sb.vol.transfer;
    end
else
    disp('Transfer Matrix : Computing ')
    tic
    [transfer] = sb_transfer(model.fem.sb.vol,sens);% calcul de la matrice de tansfert :)
    time_compute_transfer = toc;
    model.fem.sb.vol.time_compute_transfer = time_compute_transfer;
    model.fem.sb.vol.transfer = transfer;
    vol_fem.transfer = transfer;
    % save the results
    if isfield(model,'save_result')
        if  (model.save_result == 1)
            if isfield(model,'folder')
                save(fullfile(model.folder,model.name),'model');
            end
        end
    end
end
% Leadfield Matrix
disp('LF Matrix')
if isfield(model,'fem')
    if isfield(model.fem.sb.vol,'lf')
        disp('LF Matrix : already exusts loading ')
        lf = model.fem.sb.vol.lf;
    else
        disp('LF Matrix : computing ')
        tic
        [lf, ~] = fc_jv_leadfield_simbio(tau_unit*model.source, vol_fem);
        time_compute_lf = toc;
        model.fem.sb.vol.time_compute_lf = time_compute_lf;
        model.fem.sb.vol.lf = lf;
        % save the results
        if isfield(model,'save_result')
            if  (model.save_result == 1)
                if isfield(model,'folder')
                    save(fullfile(model.folder,model.name),'model');
                end
            end
        end
    end
else
    disp('LF Matrix : computing ')
    tic
    [lf, ~] = fc_jv_leadfield_simbio(model.source, vol_fem);
    time_compute_lf = toc;
    model.fem.sb.vol.time_compute_lf = time_compute_lf;
    model.fem.sb.vol.lf = lf;
    % save the results
    if isfield(model,'save_result')
        if  (model.save_result == 1)
            if isfield(model,'folder')
                save(fullfile(model.folder,model.name),'model');
            end
        end
    end
end
%[lf] = leadfield_simbio(model.source, vol_fem);
disp('done')
end
