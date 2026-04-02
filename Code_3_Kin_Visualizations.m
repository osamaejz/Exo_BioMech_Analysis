clear
load("Downhill_Data/Downhill_Exo_Biomechanics_Data.mat")

%% Functions
extractHipMoments = @(C) cellfun(@(T) ...
    T{:, find(contains(T.Properties.VariableNames,'LHipMoment'),1) : ...
        find(contains(T.Properties.VariableNames,'LHipMoment'),1)+2}, ...
    C,'UniformOutput',false);

extractKneeMoments = @(C) cellfun(@(T) ...
    T{:, find(contains(T.Properties.VariableNames,'LKneeMoment'),1) : ...
        find(contains(T.Properties.VariableNames,'LKneeMoment'),1)+2}, ...
    C,'UniformOutput',false);

extractAnkleMoments = @(C) cellfun(@(T) ...
    T{:, find(contains(T.Properties.VariableNames,'LAnkleMoment'),1) : ...
        find(contains(T.Properties.VariableNames,'LAnkleMoment'),1)+2}, ...
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

%% Final mean across ALL subjects and cycles
for j = 1:3
    for c = 1:4
        MeanMoment{j,c} = mean(AllMoments{j,c},3);
    end
end

%% Visualization
figure;

condNames = {'No Exo No Load','Exo','Load','Exoload'};
jointNames = {'Hip Moment (Nmm/Kg)','Knee Moment (Nmm/Kg)','Ankle Moment (Nmm/Kg)'};
planeNames = {'Sagittal','Frontal','Transverse'};
colors = lines(4);  % 4 distinct colors

for j = 1:3
    for p = 1:3
        subplot(3,3,(j-1)*3 + p)
        hold on
        
        lineHandles = gobjects(4,1);  % store handles for legend
        
        for c = 1:4
            Y = squeeze(AllMoments{j,c}(:,p,:));  % 101 x nCycles
            meanY = mean(Y,2);
            semY = std(Y,0,2) ./ sqrt(size(Y,2));
            ci95 = 1.96 * semY;
            x = 1:101;
            
            % Shaded CI
            fill([x fliplr(x)], [meanY'+ci95' fliplr(meanY'-ci95')], ...
                 colors(c,:), 'FaceAlpha',0.2, 'EdgeColor','none');
            
            % Plot mean line
            lineHandles(c) = plot(x, meanY, 'Color', colors(c,:), 'LineWidth',2);
        end
        
        grid on
        xlim([0 100])
        
        % Titles
        if j == 1
            title(planeNames{p}, 'FontWeight','bold')
        end
        if p == 1
            ylabel(jointNames{j}, 'FontWeight','bold')
        end
        
        % Legend (once, horizontal at top)
        if j == 1 && p == 2  % top row, middle column
            legend(lineHandles, condNames, ...
                   'Orientation','horizontal', ...
                   'Location','northoutside', ...
                   'Box','off');
        end
    end
end

xlabel('Gait Cycle (%)','FontWeight','bold')