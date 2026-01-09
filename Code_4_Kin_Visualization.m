clear all
load ("Exo_Biomechanics_updated.mat")

L_gait_cycles_kin = Exo_Biomechanics.Segregated_Exo_data.L_gait_cycles_kin;
L_Exo_gait_cycles_kin = Exo_Biomechanics.Segregated_Exo_data.L_Exo_gait_cycles_kin;
L_Load_gait_cycles_kin = Exo_Biomechanics.Segregated_Exo_data.L_Load_gait_cycles_kin;
L_Exoload_gait_cycles_kin = Exo_Biomechanics.Segregated_Exo_data.L_Exoload_gait_cycles_kin;

extractHipMoments = @(C) cellfun(@(T) ...
    T{:, find(contains(T.Properties.VariableNames,'LHipMoment'),1) : ...
        find(contains(T.Properties.VariableNames,'LHipMoment'),1)+2}, ...
    C, 'UniformOutput', false);

extractKneeMoments = @(C) cellfun(@(T) ...
    T{:, find(contains(T.Properties.VariableNames,'LKneeMoment'),1) : ...
        find(contains(T.Properties.VariableNames,'LKneeMoment'),1)+2}, ...
    C, 'UniformOutput', false);

extractAnkleMoments = @(C) cellfun(@(T) ...
    T{:, find(contains(T.Properties.VariableNames,'LAnkleMoment'),1) : ...
        find(contains(T.Properties.VariableNames,'LAnkleMoment'),1)+2}, ...
    C, 'UniformOutput', false);

%% Extracting Moments
hip       = extractHipMoments(L_gait_cycles_kin);
hip_exo      = extractHipMoments(L_Exo_gait_cycles_kin);
hip_load     = extractHipMoments(L_Load_gait_cycles_kin);
hip_exoload  = extractHipMoments(L_Exoload_gait_cycles_kin);

knee       = extractKneeMoments(L_gait_cycles_kin);
knee_exo      = extractKneeMoments(L_Exo_gait_cycles_kin);
knee_load     = extractKneeMoments(L_Load_gait_cycles_kin);
knee_exoload  = extractKneeMoments(L_Exoload_gait_cycles_kin);

ankle       = extractAnkleMoments(L_gait_cycles_kin);
ankle_exo      = extractAnkleMoments(L_Exo_gait_cycles_kin);
ankle_load     = extractAnkleMoments(L_Load_gait_cycles_kin);
ankle_exoload  = extractAnkleMoments(L_Exoload_gait_cycles_kin);


%% Taking Mean
hipMean      = mean(cat(3, hip{:}), 3);
hipMean_exo     = mean(cat(3, hip_exo{:}), 3);
hipMean_load    = mean(cat(3, hip_load{:}), 3);
hipMean_exoload = mean(cat(3, hip_exoload{:}), 3);

kneeMean      = mean(cat(3, knee{:}), 3);
kneeMean_exo     = mean(cat(3, knee_exo{:}), 3);
kneeMean_load    = mean(cat(3, knee_load{:}), 3);
kneeMean_exoload = mean(cat(3, knee_exoload{:}), 3);

ankleMean      = mean(cat(3, ankle{:}), 3);
ankleMean_exo     = mean(cat(3, ankle_exo{:}), 3);
ankleMean_load    = mean(cat(3, ankle_load{:}), 3);
ankleMean_exoload = mean(cat(3, ankle_exoload{:}), 3);


joints = {'Hip','Knee','Ankle'};
axisNames = {'X','Y','Z'};
conds = {'No Exo No Load','Exo only','Load only','Exo + Load'};

hipData   = {hipMean, hipMean_exo, hipMean_load, hipMean_exoload};
kneeData  = {kneeMean, kneeMean_exo, kneeMean_load, kneeMean_exoload};
ankleData = {ankleMean, ankleMean_exo, ankleMean_load, ankleMean_exoload};

jointData = {hipData, kneeData, ankleData};

figure
for j = 1:3          % rows: Hip, Knee, Ankle
    for ax = 1:3     % columns: X, Y, Z
        subplot(3,3,(j-1)*3 + ax); hold on

        for c = 1:4  % conditions
            plot(jointData{j}{c}(:,ax), 'LineWidth', 1.8)
        end

        if j == 1
            title([axisNames{ax} ' Moment'])
        end
        if ax == 1
            ylabel([joints{j} ' (N-m)'])
        end
        if j == 3
            xlabel('Gait Cycle (%)')
        end

        grid on
    end
end

legend(conds, 'Position', [0.92 0.35 0.06 0.3])

