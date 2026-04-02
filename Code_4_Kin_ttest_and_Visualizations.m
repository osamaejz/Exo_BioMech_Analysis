clear all
load("Downhill_Data/Downhill_Exo_Biomechanics_Data.mat")

%% Functions
extractHipMoments = @(C) cellfun(@(T) ...
    T{:, find(contains(T.Properties.VariableNames,'LHipForce'),1) : ...
        find(contains(T.Properties.VariableNames,'LHipForce'),1)+2}, ...
    C,'UniformOutput',false);

extractKneeMoments = @(C) cellfun(@(T) ...
    T{:, find(contains(T.Properties.VariableNames,'LKneeForce'),1) : ...
        find(contains(T.Properties.VariableNames,'LKneeForce'),1)+2}, ...
    C,'UniformOutput',false);

extractAnkleMoments = @(C) cellfun(@(T) ...
    T{:, find(contains(T.Properties.VariableNames,'LAnkleForce'),1) : ...
        find(contains(T.Properties.VariableNames,'LAnkleForce'),1)+2}, ...
    C,'UniformOutput',false);


nSub = length(Downhill_Exo_Biomechanics_Data);

for j = 1:3
    for c = 1:4
        AllMoments{j,c} = [];
    end
end
%% For all subjects
for sub = 1:nSub
    
    conds = {
        Downhill_Exo_Biomechanics_Data{sub}.L_gait_cycles_kin
        Downhill_Exo_Biomechanics_Data{sub}.L_Exo_gait_cycles_kin
        Downhill_Exo_Biomechanics_Data{sub}.L_Load_gait_cycles_kin
        Downhill_Exo_Biomechanics_Data{sub}.L_Exoload_gait_cycles_kin
        };
    
    for c = 1:4
        
        Hip   = extractHipMoments(conds{c});
        Knee  = extractKneeMoments(conds{c});
        Ankle = extractAnkleMoments(conds{c});
        
        joints = {Hip,Knee,Ankle};
        
        for j = 1:3
            
            for i = 1:numel(joints{j})
                
                M = joints{j}{i};
                
                M_norm = interp1( ...
                    linspace(0,100,size(M,1)), ...
                    M, ...
                    linspace(0,100,101));
                
                AllMoments{j,c} = cat(3,AllMoments{j,c},M_norm);
                
            end
            
        end
        
    end
    
end

%% t test
%for hip
hip_load = AllMoments{1,1};   % r for joint and c for condition
hip_exoload = AllMoments{1,2};   

for j = 1:3           % joints (hip,knee,ankle)
    for t = 1:101     % gait cycle timepoints
        
        x = squeeze(hip_load(t,j,:));   % trials cond1
        y = squeeze(hip_exoload(t,j,:));   % trials cond2
        
        [hip_h_val(t,j), hip_p_val(t,j)] = ttest2(x,y);  % two-sample t-test
        
    end
end

%for knee
knee_load = AllMoments{2,1};   % r for joint and c for condition
knee_exoload = AllMoments{2,2};   

for j = 1:3           % joints (hip,knee,ankle)
    for t = 1:101     % gait cycle timepoints
        
        x = squeeze(knee_load(t,j,:));   % trials cond1
        y = squeeze(knee_exoload(t,j,:));   % trials cond2
        
        [knee_h_val(t,j), knee_p_val(t,j)] = ttest2(x,y);  % two-sample t-test
        
    end
end

%for ankle
ankle_load = AllMoments{3,1};   % r for joint and c for condition
ankle_exoload = AllMoments{3,2};   

for j = 1:3           % joints (hip,knee,ankle)
    for t = 1:101     % gait cycle timepoints
        
        x = squeeze(ankle_load(t,j,:));   % trials cond1
        y = squeeze(ankle_exoload(t,j,:));   % trials cond2
        
        [ankle_h_val(t,j), ankle_p_val(t,j)] = ttest2(x,y);  % two-sample t-test
        
    end
end



%% Visualization
figure;

condIdx = [3 4];

condNames = {'No Exo No Load','Exo'};
jointNames = {'Hip Force (N/Kg)','Knee Force (N/Kg)','Ankle Force (N/Kg)'};
planeNames = {'Sagittal','Frontal','Transverse'};
colors = lines(2);

for j = 1:3
    for p = 1:3
        
        subplot(3,3,(j-1)*3 + p)
        hold on
        
        lineHandles = gobjects(2,1);
        x = 1:101;
        
        %% Plot mean ± SEM
        for k = 1:2
            
            c = condIdx(k);
            
            Y = squeeze(AllMoments{j,c}(:,p,:));
            
            meanY = mean(Y,2);
            semY  = std(Y,0,2)./sqrt(size(Y,2));
            
            fill([x fliplr(x)], ...
                 [meanY'+semY' fliplr(meanY'-semY')], ...
                 colors(k,:), ...
                 'FaceAlpha',0.2,'EdgeColor','none');
            
            lineHandles(k) = plot(x,meanY,...
                                  'Color',colors(k,:),...
                                  'LineWidth',2);
        end
        
        grid on
        xlim([0 100])
        
        %% Select p-values for this joint
        if j == 1
            pvals = hip_p_val;
        elseif j == 2
            pvals = knee_p_val;
        else
            pvals = ankle_p_val;
        end
        
        %% Significance markers for THIS subplot
        sig = pvals(:,p) < 0.05;
        
        yl = ylim;   % must come after plotting
        ysig = yl(1) + 0.05*(yl(2)-yl(1));
        
        plot(x(sig), ysig*ones(sum(sig),1),'k.','MarkerSize',7)
        
        %% Titles
        if j == 1
            title(planeNames{p},'FontWeight','bold')
        end
        
        if p == 1
            ylabel(jointNames{j},'FontWeight','bold')
        end
        
        %% Legend
        if j == 1 && p == 2
            legend(lineHandles,condNames,...
                'Orientation','horizontal',...
                'Location','northoutside',...
                'Box','off')
        end
        
    end
end

xlabel('Gait Cycle (%)','FontWeight','bold')