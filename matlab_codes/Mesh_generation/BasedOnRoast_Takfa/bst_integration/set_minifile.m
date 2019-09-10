function vol = set_minifile(vol)
%% Script to fill the vol.cfg.minifile with the duneuro parameters
% Some of the parameters will be classified as : 
% 1 : Fixed parameters that the user can't see and change
% 2 : Advanced parameters that advanced used can change
% 3 : Basic parameters that user can tune and that we will set to default.
% Thiss function should be tuned from outside via the GUI
% Creation  August 28, 2019, 
%Takfarinas MEDANI 

% subpart general setting 
vol.cfg.minifile.name = 'test_eeg_forward';
vol.cfg.minifile.type  = 'fitted';
vol.cfg.minifile.solver_type  = 'cg'; % cg, dg, udg (ucg or cut to check), maybe the mini file should change according to solver_type.
vol.cfg.minifile. element_type  = 'tetrahedron'; %
vol.cfg.minifile.geometry_adapted  = 'false';
vol.cfg.minifile.tolerance  = 1e-8;
% subpart electrode : [electrodes]
vol.cfg.minifile.electrode.filename  = vol.cfg.electrode_filename;
vol.cfg.minifile.electrode.type   = 'normal'; % what are the other options ? 
% subpart electrode : [dipoles]
vol.cfg.minifile.dipole.filename = vol.cfg.dipole_filename ;
% subpart [volume_conductor.grid]
vol.cfg.minifile.volume_conductor_grid.filename = vol.cfg.head_filename;
% subpart  [volume_conductor.tensors]
vol.cfg.minifile.volume_conductor_tensors.filename = vol.cfg.cond_filename;
% subpart  [solver]
vol.cfg.minifile.solver.solver_type = 'cg';
vol.cfg.minifile.solver.preconditioner_type = 'amg';
vol.cfg.minifile.solver.cg_smoother_type = 'ssor';
vol.cfg.minifile.solver.intorderadd = 0;
% subpart  [solution]
vol.cfg.minifile.solution.post_process = 'true';
vol.cfg.minifile.solution.subtract_mean = 'true';
% subpart  [solution.solver]
vol.cfg.minifile.solution.solver.reduction = 1e-10;
% subpart  [solution.source_model]
vol.cfg.minifile.solution.source_model.type = 'venant'; % partial_integration, venant, subtraction | expand smtype
vol.cfg.minifile.solution.source_model.intorderadd = 0;
vol.cfg.minifile.solution.source_model.intorderadd_lb = 2;
vol.cfg.minifile.solution.source_model.numberOfMoments = 3;
vol.cfg.minifile.solution.source_model.referenceLength = 20;
vol.cfg.minifile.solution.source_model.weightingExponent = 1;
vol.cfg.minifile.solution.source_model.relaxationFactor = 1e-6;
vol.cfg.minifile.solution.source_model.mixedMoments = 'false';
vol.cfg.minifile.solution.source_model.restrict = 'true';
vol.cfg.minifile.solution.source_model.initialization = 'closest_vertex';
% The reste is not needed... just in case
% subpart [analytic_solution]
vol.cfg.minifile.solution.analytic_solution.radii = [1 2 3 4 ];
vol.cfg.minifile.solution.analytic_solution.center = [0 0 0];
vol.cfg.minifile.solution.analytic_solution.conductivities = [1 0.0125 1 1];
% subpart  [output]
vol.cfg.minifile.output.filename = 'out_eeg_forward_{solver_type}_{element_type}_{solution.source_model.type}';
vol.cfg.minifile.output.extension = 'txt';
% subpart [wrapper.outputtreecompare]
vol.cfg.minifile.wrapper.outputtreecompare.name = '{output.filename}';
vol.cfg.minifile.wrapper.outputtreecompare.extension = '{output.extension}';
vol.cfg.minifile.wrapper.outputtreecompare.reference = 'ref_{output.filename}';
vol.cfg.minifile.wrapper.outputtreecompare.type = 'fuzzy';
vol.cfg.minifile.wrapper.outputtreecompare.absolute = 1e-2;

end