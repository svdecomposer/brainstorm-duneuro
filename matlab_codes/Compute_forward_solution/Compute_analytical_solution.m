function [lf, model]= Compute_analytical_solution(model)
%% Compute analytical solution
disp('Compute the analytical solution')
%% Create vol ana
disp('Prepare the Volume')
vol_ana.r = model.radii;
vol_ana.cond = model.conductivity;
vol_ana.o = model.center;
sens.elecpos = model.elec_on_node;
sens.label = {};
nsens = size(sens.elecpos,1);
disp('Prepare the channels')
for i_ch=1:nsens
    sens.label{i_ch} = sprintf('elec%03d', i_ch);
end
vol_ana.sens = sens;
model.ana.vol = vol_ana;
% choose between bst or ftp solution
if ~isfield(model,'ana.vol.lf')
    disp('Compute analytical solution')
    clear lf
    if isfield(model.ana,'formulation')
        if strcmp(model.ana.formulation,'bst')
            disp('Compute from brainstorm fomulation')
            lf_ana = bst_eeg_sph(model.source, model.elec_on_node, ...
                vol_ana.o, vol_ana.r, vol_ana.cond);
            model.ana.formulation = 'bst'; 
        end
        if strcmp(model.ana.formulation,'ftp')
            disp('Compute using fieldtrip fomulation')
            lf_ana = ft_compute_leadfield(model.source, sens, vol_ana);
            model.ana.formulation = 'ftp'; 
        end
    else
        disp('fomulation not specified from model structure')
        disp('Brainstorm fomulation is used by default')
        lf_ana = bst_eeg_sph(model.source, model.elec_on_node, ...
            vol_ana.o, vol_ana.r, vol_ana.cond);
        model.ana.formulation = 'bst'; 
    end
else
    lf_ana = model.ana.vol.lf;
end
lf = lf_ana;
model.ana.vol.lf = lf;
% save the results
if isfield(model,'save_result')
    if  (model.save_result == 1)
        if isfield(model,'folder')
            save(fullfile(model.folder,model.name),'model');
        end
    end
end
disp('Load BST ana solution')
end
