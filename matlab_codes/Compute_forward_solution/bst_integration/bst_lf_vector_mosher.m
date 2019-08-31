function bst_lf_vector_mosher(vol)


head_model = vol.head_model;
GridLoc = head_model.brain.Vertices';

LF = {vol.lf_bem,vol.lf_fem};
LFnames = {'OpenMEEG','DuNeuro'};
LFcolor = {[0 0 1], [1 0 0]};
% sensor locations
SensorLoc = head_model.channel_loc';
%SensorNames = sens.label;
% head model surfaces
HeadFV = struct('faces',head_model.head.Faces, 'vertices',head_model.head.Vertices);
OuterFV = struct('faces',head_model.outer.Faces, 'vertices',head_model.outer.Vertices);
InnerFV = struct('faces',head_model.inner.Faces, 'vertices',head_model.inner.Vertices);
% view the head
figure(2)
clf reset
h_h = patch(HeadFV,'facecolor','none','edgealpha',0.1);
h_o = patch(OuterFV,'facecolor','none','edgealpha',0.15);
h_i = patch(InnerFV,'facecolor','none','edgealpha',0.2);
axis vis3d, axis equal, rotate3d on, shg
% add the sensor locations
hold on
plot3(SensorLoc(1,:),SensorLoc(2,:),SensorLoc(3,:),'ko','markersize',10)
hold off
% convenient for plotting command
X = GridLoc(1,:);Y = GridLoc(2,:); Z=GridLoc(3,:);

% select the reference 
iref = 3;
ielec = 2;
% plot
hold on
plot3(SensorLoc(1,ielec),SensorLoc(2,ielec),SensorLoc(3,ielec),'r*','markersize',15) % mark the electrode
hold off

h = zeros(length(LF),1);
LeadField = cell(length(LF),1);

%% Plotting
hold on

for imodel = 1 : length(LF)    
    switch 'ref' % {'avgref','ref'}
        case 'ref'
            LeadField{imodel} = LF{imodel}(ielec,:)- ...%  leadfield row
                                                    LF{imodel}(iref,:); %  leadfield row
            plot3(SensorLoc(1,iref),SensorLoc(2,iref),SensorLoc(3,iref),'b+','markersize',15) % mark the electrode           
            
        case 'avgref'
            AvgRef = mean(LF{imodel},1);
            
            LeadField{imodel} = LF{imodel}(ielec,:)- ...%  leadfield row
                AvgRef; %  leadfield row
    end    
    LeadField{imodel} = reshape(LeadField{imodel},3,[]); % each column is a vector    
    
    U = LeadField{imodel}(1,:); 
    V = LeadField{imodel}(2,:); 
    W =LeadField{imodel}(3,:); % convenient    
    h(imodel) = quiver3(X,Y,Z,U,V,W);    
    set(h(imodel),'linewidth',1,'color',LFcolor{imodel})    
end

hold off
hl =legend(h,LFnames);
set(hl,'fontsize',24)

%% Plot errors
% figure(2)
% [~,ndx] = sort(colnorm(LeadField{1})); % sort the norm of the vector in ascending order.
% plot(colnorm(LeadField{1}(:,ndx)),'linewidth',3,'color',LFcolor{1}),
% hold on,
% for i = 2:2
%     plot(colnorm(LeadField{1}(:,ndx)-LeadField{i}(:,ndx)),'*-','linewidth',2,'color',LFcolor{i}),
% end
% hold off ; grid on; grid minor
% axis tight
% shg
% 
% hl = legend(LFnames);
% set(hl,'fontsize',24)
% xlabel('Sorted Lead Field Vector Index')
% ylabel('Norm')
% title('Leadfield Differences from Analytical')
end