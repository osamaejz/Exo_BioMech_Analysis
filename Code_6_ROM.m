clearvars -except Exo_Biomechanics_Data
% load ("Data/Exo_Biomechanics_Data.mat")

NENL_ROM = [];
Load_ROM = [];
Exo_ROM = [];
ExoLoad_ROM = [];

extractHipAngles = @(C) cellfun(@(T) ...
    T{:, ...
      find(contains(T.Properties.VariableNames,'LHipAngles'),1) : ...
      find(contains(T.Properties.VariableNames,'LHipAngles'),1) + 2}, ...
    C, 'UniformOutput', false);

extractKneeAngles = @(C) cellfun(@(T) ...
    T{:, ...
      find(contains(T.Properties.VariableNames,'LKneeAngles'),1) : ...
      find(contains(T.Properties.VariableNames,'LKneeAngles'),1) + 2}, ...
    C, 'UniformOutput', false);

extractAnkleAngles = @(C) cellfun(@(T) ...
    T{:, ...
      find(contains(T.Properties.VariableNames,'LAnkleAngles'),1) : ...
      find(contains(T.Properties.VariableNames,'LAnkleAngles'),1) + 2}, ...
    C, 'UniformOutput', false);

for subj = 1:length(Exo_Biomechanics_Data)

    NENL_kin = Exo_Biomechanics_Data{subj}.L_gait_cycles_kin;
    Load_kin = Exo_Biomechanics_Data{subj}.L_Load_gait_cycles_kin;
    Exo_kin = Exo_Biomechanics_Data{subj}.L_Exo_gait_cycles_kin;
    ExoLoad_kin = Exo_Biomechanics_Data{subj}.L_Exoload_gait_cycles_kin;

    NENL_hip = extractHipAngles(NENL_kin);  NENL_knee = extractKneeAngles(NENL_kin);  NENL_ankle = extractAnkleAngles(NENL_kin);
    Load_hip = extractHipAngles(Load_kin);  Load_knee = extractKneeAngles(Load_kin);  Load_ankle = extractAnkleAngles(Load_kin);
    Exo_hip = extractHipAngles(Exo_kin);  Exo_knee = extractKneeAngles(Exo_kin);  Exo_ankle = extractAnkleAngles(Exo_kin);
    ExoLoad_hip = extractHipAngles(ExoLoad_kin);  ExoLoad_knee = extractKneeAngles(ExoLoad_kin);  ExoLoad_ankle = extractAnkleAngles(ExoLoad_kin);

    for trial = 1:length(NENL_hip)
        NENL_ROM(end+1, :) = [max(NENL_hip{trial}(:,1)) - min(NENL_hip{trial}(:,1)), max(NENL_knee{trial}(:,1)) - min(NENL_knee{trial}(:,1)), max(NENL_ankle{trial}(:,1)) - min(NENL_ankle{trial}(:,1))];
    end

    for trial = 1:length(Load_hip)   
        Load_ROM(end+1, :) = [max(Load_hip{trial}(:,1)) - min(Load_hip{trial}(:,1)), max(Load_knee{trial}(:,1)) - min(Load_knee{trial}(:,1)), max(Load_ankle{trial}(:,1)) - min(Load_ankle{trial}(:,1))];
    end

    for trial = 1:length(Exo_hip)     
        Exo_ROM(end+1, :) = [max(Exo_hip{trial}(:,1)) - min(Exo_hip{trial}(:,1)), max(Exo_knee{trial}(:,1)) - min(Exo_knee{trial}(:,1)), max(Exo_ankle{trial}(:,1)) - min(Exo_ankle{trial}(:,1))];
    end

    for trial = 1:length(ExoLoad_hip)
        ExoLoad_ROM(end+1, :) = [max(ExoLoad_hip{trial}(:,1)) - min(ExoLoad_hip{trial}(:,1)), max(ExoLoad_knee{trial}(:,1)) - min(ExoLoad_knee{trial}(:,1)), max(ExoLoad_ankle{trial}(:,1)) - min(ExoLoad_ankle{trial}(:,1))];
        
    end
end

%% plotting

Ymean = [ ...
    mean(NENL_ROM(:,1))   mean(Load_ROM(:,1))   mean(Exo_ROM(:,1))   mean(ExoLoad_ROM(:,1));  % Hip
    mean(NENL_ROM(:,2))   mean(Load_ROM(:,2))   mean(Exo_ROM(:,2))   mean(ExoLoad_ROM(:,2));  % Knee
    mean(NENL_ROM(:,3))   mean(Load_ROM(:,3))   mean(Exo_ROM(:,3))   mean(ExoLoad_ROM(:,3))   % Ankle
];

figure
b = bar(Ymean, 'grouped');
b(1).BarWidth = 0.95;

set(gca,'XTickLabel',{'Hip','Knee','Ankle'})
ylabel('ROM (deg)')

legend({'No Exo No Load','Load only','Exo only','Exo + Load'}, ...
       'Location','best','Orientation','horizontal')

grid on
box off

Ystd = [ ...
    std(NENL_ROM(:,1))   std(Load_ROM(:,1))   std(Exo_ROM(:,1))   std(ExoLoad_ROM(:,1));
    std(NENL_ROM(:,2))   std(Load_ROM(:,2))   std(Exo_ROM(:,2))   std(ExoLoad_ROM(:,2));
    std(NENL_ROM(:,3))   std(Load_ROM(:,3))   std(Exo_ROM(:,3))   std(ExoLoad_ROM(:,3))
];

colors = [ ...
    0.15 0.15 0.15;   % almost black
    0.40 0.40 0.40;   % dark gray
    0.65 0.65 0.65;   % light gray
    0.90 0.90 0.90    % almost white
];
hold on
for k = 1:numel(b)
    x = b(k).XEndPoints;
    errorbar(x, Ymean(:,k), Ystd(:,k), ...
        'k', 'LineStyle','none', 'LineWidth',1.2, ...
        'HandleVisibility','off');
    b(k).FaceColor = 'flat';
    b(k).CData = repmat(colors(k,:), size(Ymean,1), 1);
end

set(gca,'FontSize',12)
set(b,'EdgeColor','none')   % cleaner look
set(b,'FaceAlpha',0.85)

ylim([0 max(Ymean(:)+Ystd(:))*1.2])


%% ttest
joints = {'Hip','Knee','Ankle'};
conds  = {'Load','Exo','ExoLoad'};
nJ = numel(joints);
nC = numel(conds);
tstat = zeros(nJ, nC);
pval  = zeros(nJ, nC);
for j = 1:nJ        % joints
    for c = 1:nC    % conditions
        switch conds{c}
            case 'Load'
                x = Load_ROM(:,j);
            case 'Exo'
                x = Exo_ROM(:,j);
            case 'ExoLoad'
                x = ExoLoad_ROM(:,j);
        end
        y = NENL_ROM(:,j);
        % Paired t-test (same subjects)
        [~, p, ~, stats] = ttest2(x, y);
        tstat(j, c) = stats.tstat;
        pval(j, c)  = p;
    end
end
pTable = array2table(pval, ...
    'RowNames', joints, ...
    'VariableNames', conds);

tTable = array2table(tstat, ...
    'RowNames', joints, ...
    'VariableNames', conds);
pTable
tTable

