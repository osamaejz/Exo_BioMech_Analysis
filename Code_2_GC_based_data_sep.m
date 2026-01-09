clear all
load ("Raw_data_updated.mat")

Raw_data = cell2mat(Raw_data);

all_subj_R_GC = 0;
all_subj_L_GC = 0;

L_gaitcycle = 0;
R_gaitcycle = 0;
L_Load_gaitcycle = 0;
R_Load_gaitcycle = 0;
L_Exo_gaitcycle = 0;
R_Exo_gaitcycle = 0;
L_Exoload_gaitcycle = 0;
R_Exoload_gaitcycle = 0;

L_gait_cycles_kin = {};  L_gait_cycles_EMG = {}; R_gait_cycles_kin = {};  R_gait_cycles_EMG = {}; 
L_Norm_gait_cycles_EMG = {};  L_Norm_gait_cycles_EMG = {}; R_Norm_gait_cycles_kin = {};  R_Norm_gait_cycles_EMG = {}; 

L_Load_gait_cycles_kin = {};  L_Load_gait_cycles_EMG = {};  R_Load_gait_cycles_kin = {};  R_Load_gait_cycles_EMG = {}; 
L_Norm_Load_gait_cycles_kin = {};  L_Norm_Load_gait_cycles_EMG = {};  R_Norm_Load_gait_cycles_kin = {};  R_Norm_Load_gait_cycles_EMG = {}; 

L_Exo_gait_cycles_kin = {};  L_Exo_gait_cycles_EMG = {};  R_Exo_gait_cycles_kin = {};  R_Exo_gait_cycles_EMG = {};  
L_Norm_Exo_gait_cycles_kin = {};  L_Norm_Exo_gait_cycles_EMG = {};  R_Norm_Exo_gait_cycles_kin = {};  R_Norm_Exo_gait_cycles_EMG = {};  

L_Exoload_gait_cycles_kin = {};  L_Exoload_gait_cycles_EMG = {};  R_Exoload_gait_cycles_kin = {};  R_Exoload_gait_cycles_EMG = {};
L_Norm_Exoload_gait_cycles_kin = {};  L_Norm_Exoload_gait_cycles_EMG = {};  R_Norm_Exoload_gait_cycles_kin = {};  R_Norm_Exoload_gait_cycles_EMG = {};

L_Level_hip = []; L_Level_knee = []; L_Level_ankle = []; 
L_Exo_hip = []; L_Exo_knee = []; L_Exo_ankle = []; 
L_Load_hip = []; L_Load_knee = []; L_Load_ankle = []; 
L_Exoload_hip = []; L_Exoload_knee = []; L_Exoload_ankle = []; 
R_Level_hip = []; R_Level_knee = []; R_Level_ankle = []; 
R_Exo_hip = []; R_Exo_knee = []; R_Exo_ankle = []; 
R_Load_hip = []; R_Load_knee = []; R_Load_ankle = []; 
R_Exoload_hip = []; R_Exoload_knee = []; R_Exoload_ankle = [];

EMG_columnNames = {'Time', 'R_RF', 'L_RF', 'R_VM', 'L_VM', 'R_TA', 'L_TA', 'L_Soleus', 'R_Soleus', 'R_GMax', 'L_GMax', 'R_BF', 'L_BF', 'R_Gastr', 'L_Gastr', 'R_iliocostalis', 'L_iliocostalis'};

for subj = 1:length(Raw_data)
    subj_R_gaitcycle = 0;
    subj_L_gaitcycle = 0;
    for trial = 1:length(Raw_data(subj).kin_trials_num)

        %fprintf("Trial %d in progress\n", trial);
        
        GC = Raw_data(subj).gait_cycle_timestamps; % one subject data
        GC_cur = cell2mat(GC(trial)); % one trial data

        trial_type = cell2mat(Raw_data(subj).kin_trials_num(trial));
        trial_type = trial_type(7:end-2);
        if trial_type == "Level"
            Level = true;
            LevelExo = false;
            LevelLoad = false;
            LevelExoLoad = false;  
            
        elseif trial_type == "LevelExo"
            Level = false;
            LevelExo = true;
            LevelLoad = false;
            LevelExoLoad = false;  
            
        elseif trial_type == "LevelLoad"
            Level = false;
            LevelExo = false;
            LevelLoad = true;
            LevelExoLoad = false;        

        elseif trial_type == "LevelExoLoad"
            Level = false;
            LevelExo = false;
            LevelLoad = false;
            LevelExoLoad = true; 
        end

        %% for getting gait cycles timestamps
        allFields = fieldnames(GC_cur);
        LS_time = {};                   % For storing corresponding values
        RS_time = {};                   % For storing corresponding values
        
        for i = 1:length(allFields)
            if startsWith(allFields{i}, 'Exo_Left_FootStrike')
                %LS_num{end+1} = allFields{i};     % Save the field name
                LS_time{end+1} = (str2num(GC_cur.(allFields{i}))); % Save its value
        
            elseif startsWith(allFields{i}, 'Exo_Right_FootStrike')
                %RS_num{end+1} = allFields{i};     % Save the field name
                RS_time{end+1} = (str2num(GC_cur.(allFields{i}))); % Save its value
            end
        end
        
        LS_time = cell2mat(LS_time);
        RS_time = cell2mat(RS_time);
           
        %% Extracting start and end time for each gait cycle of right and left leg
        rightGaitCycles = [];
        leftGaitCycles = [];

        for i = 1:length(LS_time)-1
            L_start = LS_time(i);
            L_end   = LS_time(i+1);
            leftGaitCycles = [leftGaitCycles; L_start, L_end];
        end

        for i = 1:length(RS_time)-1
            R_start = RS_time(i);
            R_end   = RS_time(i+1);
            rightGaitCycles = [rightGaitCycles; R_start, R_end];
        end


        %% making EMG and Kinematic data ready
        Kin_data = Raw_data(subj).Kin_trials_data;
        Kin_col_name = Raw_data(subj).Kin_trials_header;
        Kin_data_curr = cell2mat(Kin_data(trial));
        Kin_col_name_curr = Kin_col_name(trial);
        Kin_col_name_curr = Kin_col_name_curr{1};

        EMG_data = Raw_data(subj).emg_trials_data;
        EMG_data_curr = cell2mat(EMG_data(trial));
        
        %% Segregating EMG and Kinematic data based on gait cycles
        % Doing this gait cycle separately for Left and Right foot because there may be difference in their counts
        
        %% For Left Gait Cycle
        [num_L_cycles, ~] = size(leftGaitCycles);

        % if num_L_cycles == 0
        %     disp("Subject " + subj)
        %     disp("Trial "  + trial)
        % 
        %     break
        % end
    
    
        for l = 1:num_L_cycles
            LS_t_start = leftGaitCycles(l,1);
            LS_t_end = leftGaitCycles(l,2);
            
            % Find indices of kin_data within the current left gait cycle
            LGC_Kin_idx = Kin_data_curr(:,1) >= LS_t_start & Kin_data_curr(:,1) < LS_t_end;
        
            LGC_EMG_idx = (EMG_data_curr(:,1))/100 >= LS_t_start & (EMG_data_curr(:,1))/100 < LS_t_end;
            
            % Segment GC data
            L_Kin_data_curr = Kin_data_curr(LGC_Kin_idx, :);
            L_EMG_data_curr = EMG_data_curr(LGC_EMG_idx, :);

            % Saving non normalized data in table format with column names
            L_Kin_data_curr_tbl = array2table(L_Kin_data_curr, 'VariableNames', Kin_col_name_curr);
            L_EMG_data_curr_tbl = array2table(L_EMG_data_curr, 'VariableNames', EMG_columnNames);

            % getting angles for ROM
            L_vars = L_Kin_data_curr_tbl.Properties.VariableNames;
            L_idx_H = find(contains(L_vars,'LHipAngles'));
            L_idx_K = find(contains(L_vars,'LKneeAngles'));
            L_idx_A = find(contains(L_vars,'LAnkleAngles'));
            
            L_hipAngles = L_Kin_data_curr_tbl{:, (L_idx_H:L_idx_H+2)};
            L_hipMin = min(L_hipAngles);
            L_hipMax = max(L_hipAngles);

            L_kneeAngles = L_Kin_data_curr_tbl{:,  (L_idx_K:L_idx_K+2)};
            L_kneeMin = min(L_kneeAngles);
            L_kneeMax = max(L_kneeAngles);

            L_ankleAngles = L_Kin_data_curr_tbl{:, (L_idx_A:L_idx_A+2)};
            L_ankleMin = min(L_ankleAngles);
            L_ankleMax = max(L_ankleAngles);

            % percentage Normalization
            nOut = 100;
            L_t_old_kin = linspace(0,100,size(L_Kin_data_curr,1));
            L_t_new = linspace(0,100,nOut);
            L_Kin_data_norm_curr = interp1(L_t_old_kin, L_Kin_data_curr, L_t_new, 'linear');

            L_t_old_emg = linspace(0,100,size(L_EMG_data_curr,1));
            L_EMG_data_norm_curr = interp1(L_t_old_emg, L_EMG_data_curr, L_t_new, 'linear');

            % Saving normalized data with column names in the table form
            L_Norm_Kin_data_curr_tbl = array2table(L_Kin_data_norm_curr, 'VariableNames', Kin_col_name_curr);
            L_Norm_EMG_data_curr_tbl = array2table(L_EMG_data_norm_curr, 'VariableNames', EMG_columnNames);

            % Store the segmented data
            
            if Level == true
                L_gait_cycles_kin{L_gaitcycle+l} = L_Kin_data_curr_tbl;
                L_gait_cycles_EMG{L_gaitcycle+l} = L_EMG_data_curr_tbl;
                L_Norm_gait_cycles_kin{L_gaitcycle+l} = L_Norm_Kin_data_curr_tbl;
                L_Norm_gait_cycles_EMG{L_gaitcycle+l} = L_Norm_EMG_data_curr_tbl;

                L_Level_hip = [L_hipMin, L_hipMax];
                L_Level_knee = [L_kneeMin, L_kneeMax];
                L_Level_ankle = [L_ankleMin, L_ankleMax];

            elseif LevelExo == true
                
                L_Exo_gait_cycles_kin{L_Exo_gaitcycle+l} = L_Kin_data_curr_tbl;
                L_Exo_gait_cycles_EMG{L_Exo_gaitcycle+l} = L_EMG_data_curr_tbl;
                L_Norm_Exo_gait_cycles_kin{L_Exo_gaitcycle+l} = L_Norm_Kin_data_curr_tbl;
                L_Norm_Exo_gait_cycles_EMG{L_Exo_gaitcycle+l} = L_Norm_EMG_data_curr_tbl;

                L_Exo_hip{L_Exo_gaitcycle+l} = [L_hipMin, L_hipMax];
                L_Exo_knee{L_Exo_gaitcycle+l} = [L_kneeMin, L_kneeMax];
                L_Exo_ankle{L_Exo_gaitcycle+l} = [L_ankleMin, L_ankleMax];
                
            elseif LevelLoad == true
                
                L_Load_gait_cycles_kin{L_Load_gaitcycle+l} = L_Kin_data_curr_tbl;
                L_Load_gait_cycles_EMG{L_Load_gaitcycle+l} = L_EMG_data_curr_tbl;
                L_Norm_Load_gait_cycles_kin{L_Load_gaitcycle+l} = L_Norm_Kin_data_curr_tbl;
                L_Norm_Load_gait_cycles_EMG{L_Load_gaitcycle+l} = L_Norm_EMG_data_curr_tbl;

                L_Load_hip{L_Load_gaitcycle+l} = [L_hipMin, L_hipMax];
                L_Load_knee{L_Load_gaitcycle+l} = [L_kneeMin, L_kneeMax];
                L_Load_ankle{L_Load_gaitcycle+l} = [L_ankleMin, L_ankleMax];

            elseif LevelExoLoad == true
                L_Exoload_gait_cycles_kin{L_Exoload_gaitcycle+l} = L_Kin_data_curr_tbl;
                L_Exoload_gait_cycles_EMG{L_Exoload_gaitcycle+l} = L_EMG_data_curr_tbl;
                L_Norm_Exoload_gait_cycles_kin{L_Exoload_gaitcycle+l} = L_Norm_Kin_data_curr_tbl;
                L_Norm_Exoload_gait_cycles_EMG{L_Exoload_gaitcycle+l} = L_Norm_EMG_data_curr_tbl;

                L_Exoload_hip{L_Exoload_gaitcycle+l} = [L_hipMin, L_hipMax];
                L_Exoload_knee{L_Exoload_gaitcycle+l} = [L_kneeMin, L_kneeMax];
                L_Exoload_ankle{L_Exoload_gaitcycle+l} = [L_ankleMin, L_ankleMax];             
                
            end

        end
       
        % counting total left gait cycles and using it for index
        subj_L_gaitcycle = subj_L_gaitcycle + num_L_cycles;
        % L_gaitcycle = L_gaitcycle + num_L_cycles;

        if Level == true
            L_gaitcycle = L_gaitcycle + num_L_cycles;
        elseif LevelExo == true
            L_Exo_gaitcycle = L_Exo_gaitcycle + num_L_cycles;
        elseif LevelLoad == true
            L_Load_gaitcycle = L_Load_gaitcycle + num_L_cycles;
        elseif LevelExoLoad == true
            L_Exoload_gaitcycle = L_Exoload_gaitcycle + num_L_cycles;
        end

        %% For Right Gait Cycle
        [num_R_cycles,~] = size(rightGaitCycles);

        % if num_R_cycles == 0
        %     disp("Subject " + subj)
        %     disp("Trial "  + trial)
        % 
        %     break
        % end
        % 
        for r = 1:num_R_cycles
            RS_t_start = rightGaitCycles(r,1);
            RS_t_end = rightGaitCycles(r,2);
            
            % Find indices of kin_data within the current right gait cycle
            RGC_Kin_idx = Kin_data_curr(:,1) >= RS_t_start & Kin_data_curr(:,1) < RS_t_end;
        
            RGC_EMG_idx = (EMG_data_curr(:,1))/100 >= RS_t_start & (EMG_data_curr(:,1))/100 < RS_t_end;

            % Segment GC data
            R_Kin_data_curr = Kin_data_curr(RGC_Kin_idx, :);
            R_EMG_data_curr = EMG_data_curr(RGC_EMG_idx, :);

            % Saving non normalized data in table format with column names
            R_Kin_data_curr_tbl = array2table(R_Kin_data_curr, 'VariableNames', Kin_col_name_curr);
            R_EMG_data_curr_tbl = array2table(R_EMG_data_curr, 'VariableNames', EMG_columnNames);

            % getting angles for ROM
            R_vars = R_Kin_data_curr_tbl.Properties.VariableNames;
            R_idx_H = find(contains(R_vars,'RHipAngles'));
            R_idx_K = find(contains(R_vars,'RKneeAngles'));
            R_idx_A = find(contains(R_vars,'RAnkleAngles'));
            
            R_hipAngles = R_Kin_data_curr_tbl{:,  (R_idx_H:R_idx_H+2)};
            R_hipMin = min(R_hipAngles);
            R_hipMax = max(R_hipAngles);

            R_kneeAngles = R_Kin_data_curr_tbl{:, (R_idx_K:R_idx_K+2)};
            R_kneeMin = min(R_kneeAngles);
            R_kneeMax = max(R_kneeAngles);

            R_ankleAngles = R_Kin_data_curr_tbl{:, (R_idx_A:R_idx_A+2)};
            R_ankleMin = min(R_ankleAngles);
            R_ankleMax = max(R_ankleAngles);

            % percentage Normalization
            nOut = 100;
            R_t_old_kin = linspace(0,100,size(R_Kin_data_curr,1));
            R_t_new = linspace(0,100,nOut);
            R_Kin_data_norm_curr = interp1(R_t_old_kin, R_Kin_data_curr, R_t_new, 'linear');

            R_t_old_emg = linspace(0,100,size(R_EMG_data_curr,1));
            R_EMG_data_norm_curr = interp1(R_t_old_emg, R_EMG_data_curr, R_t_new, 'linear');

            % Saving normalized data with column names in the table form
            R_Norm_Kin_data_curr_tbl = array2table(R_Kin_data_norm_curr, 'VariableNames', Kin_col_name_curr);
            R_Norm_EMG_data_curr_tbl = array2table(R_EMG_data_norm_curr, 'VariableNames', EMG_columnNames);
           
            % Store the segmented data

            if Level == true
                R_gait_cycles_kin{R_gaitcycle+r} = R_Kin_data_curr_tbl;
                R_gait_cycles_EMG{R_gaitcycle+r} = R_EMG_data_curr_tbl;
                R_Norm_gait_cycles_kin{R_gaitcycle+r} = R_Norm_Kin_data_curr_tbl;
                R_Norm_gait_cycles_EMG{R_gaitcycle+r} = R_Norm_EMG_data_curr_tbl;

                R_Level_hip = [R_hipMin, R_hipMax];
                R_Level_knee = [R_kneeMin, R_kneeMax];
                R_Level_ankle = [R_ankleMin, R_ankleMax];

            elseif LevelExo == true
                R_Exo_gait_cycles_kin{R_Exo_gaitcycle+r} = R_Kin_data_curr_tbl;
                R_Exo_gait_cycles_EMG{R_Exo_gaitcycle+r} = R_EMG_data_curr_tbl;
                R_Norm_Exo_gait_cycles_kin{R_Exo_gaitcycle+r} = R_Norm_Kin_data_curr_tbl;
                R_Norm_Exo_gait_cycles_EMG{R_Exo_gaitcycle+r} = R_Norm_EMG_data_curr_tbl;

                R_Exo_hip{R_Exo_gaitcycle+r} = [R_hipMin, R_hipMax];
                R_Exo_knee{R_Exo_gaitcycle+r} = [R_kneeMin, R_kneeMax];
                R_Exo_ankle{R_Exo_gaitcycle+r} = [R_ankleMin, R_ankleMax];
                
            elseif LevelLoad == true
                R_Load_gait_cycles_kin{R_Load_gaitcycle+r} = R_Kin_data_curr_tbl;
                R_Load_gait_cycles_EMG{R_Load_gaitcycle+r} = R_EMG_data_curr_tbl;
                R_Norm_Load_gait_cycles_kin{R_Load_gaitcycle+r} = R_Norm_Kin_data_curr_tbl;
                R_Norm_Load_gait_cycles_EMG{R_Load_gaitcycle+r} = R_Norm_EMG_data_curr_tbl;

                R_Load_hip{R_Load_gaitcycle+r} = [R_hipMin, R_hipMax];
                R_Load_knee{R_Load_gaitcycle+r} = [R_kneeMin, R_kneeMax];
                R_Load_ankle{R_Load_gaitcycle+r} = [R_ankleMin, R_ankleMax];

            elseif LevelExoLoad == true
                R_Exoload_gait_cycles_kin{R_Exoload_gaitcycle+r} = R_Kin_data_curr_tbl;
                R_Exoload_gait_cycles_EMG{R_Exoload_gaitcycle+r} = R_EMG_data_curr_tbl;
                R_Norm_Exoload_gait_cycles_kin{R_Exoload_gaitcycle+r} = R_Norm_Kin_data_curr_tbl;
                R_Norm_Exoload_gait_cycles_EMG{R_Exoload_gaitcycle+r} = R_Norm_EMG_data_curr_tbl;

                R_Exoload_hip{R_Exoload_gaitcycle+r} = [R_hipMin, R_hipMax];
                R_Exoload_knee{R_Exoload_gaitcycle+r} = [R_kneeMin, R_kneeMax];
                R_Exoload_ankle{R_Exoload_gaitcycle+r} = [R_ankleMin, R_ankleMax];

            end

            % if isempty(R_gait_cycles_EMG{R_gaitcycle+r})
            %     error('Condition met – stopping execution')
            % end
        end
        
        % counting total right gait cycles 
        subj_R_gaitcycle = subj_R_gaitcycle + num_R_cycles;
        %R_gaitcycle = R_gaitcycle + num_R_cycles;

        if Level == true
            R_gaitcycle = R_gaitcycle + num_R_cycles;
        elseif LevelExo == true
            R_Exo_gaitcycle = R_Exo_gaitcycle + num_R_cycles;
        elseif LevelLoad == true
            R_Load_gaitcycle = R_Load_gaitcycle + num_R_cycles;
        elseif LevelExoLoad == true
            R_Exoload_gaitcycle = R_Exoload_gaitcycle + num_R_cycles;
        end
        
        Level = false;
        LevelExo = false;
        LevelLoad = false;
        LevelExoLoad = false;
    end
    

    % L_ROM_Level{subj} = {[L_Level_hip], [L_Level_knee], [L_Level_ankle]}; 
    % L_ROM_Exo{subj} = {[L_Exo_hip], [L_Exo_knee], [L_Exo_ankle]}; 
    % L_ROM_Load{subj} = {[L_Load_hip], [L_Load_knee], [L_Load_ankle]}; 
    % L_ROM_Exoload{subj} = {[L_Exoload_hip], [L_Exoload_knee], [L_Exoload_ankle]}; 
    % 
    % R_ROM_Level{subj} = {[R_Level_hip], [R_Level_knee], [R_Level_ankle]}; 
    % R_ROM_Exo{subj} = {[R_Exo_hip], [R_Exo_knee], [R_Exo_ankle]}; 
    % R_ROM_Load{subj} = {[R_Load_hip], [R_Load_knee], [R_Load_ankle]}; 
    % R_ROM_Exoload{subj} = {[R_Exoload_hip], [R_Exoload_knee], [R_Exoload_ankle]};

    subj_number = 'ID_' + num2str(subj);

    Segregated_GC.subj_number.L_gait_cycles_EMG = L_gait_cycles_EMG;
    Segregated_GC.subj_number.L_gait_cycles_kin = L_gait_cycles_kin;
    Segregated_GC.subj_number.R_gait_cycles_EMG = R_gait_cycles_EMG;
    Segregated_GC.subj_number.R_gait_cycles_kin = R_gait_cycles_kin;
    
    Segregated_GC.subj_number.L_Norm_gait_cycles_EMG = L_Norm_gait_cycles_EMG;
    Segregated_GC.subj_number.L_Norm_gait_cycles_kin = L_Norm_gait_cycles_kin;
    Segregated_GC.subj_number.R_Norm_gait_cycles_EMG = R_Norm_gait_cycles_EMG;
    Segregated_GC.subj_number.R_Norm_gait_cycles_kin = R_Norm_gait_cycles_kin;
    
    Segregated_GC.subj_number.L_Exo_gait_cycles_EMG = L_Exo_gait_cycles_EMG;
    Segregated_GC.subj_number.L_Exo_gait_cycles_kin = L_Exo_gait_cycles_kin;
    Segregated_GC.subj_number.R_Exo_gait_cycles_EMG = R_Exo_gait_cycles_EMG;
    Segregated_GC.subj_number.R_Exo_gait_cycles_kin = R_Exo_gait_cycles_kin;
    
    Segregated_GC.subj_number.L_Norm_Exo_gait_cycles_EMG = L_Norm_Exo_gait_cycles_EMG;
    Segregated_GC.subj_number.L_Norm_Exo_gait_cycles_kin = L_Norm_Exo_gait_cycles_kin;
    Segregated_GC.subj_number.R_Norm_Exo_gait_cycles_EMG = R_Norm_Exo_gait_cycles_EMG; 
    Segregated_GC.subj_number.R_Norm_Exo_gait_cycles_kin = R_Norm_Exo_gait_cycles_kin;
    
    Segregated_GC.subj_number.L_Load_gait_cycles_EMG = L_Load_gait_cycles_EMG;
    Segregated_GC.subj_number.L_Load_gait_cycles_kin = L_Load_gait_cycles_kin;
    Segregated_GC.subj_number.R_Load_gait_cycles_EMG = R_Load_gait_cycles_EMG;
    Segregated_GC.subj_number.R_Load_gait_cycles_kin = R_Load_gait_cycles_kin;
    
    Segregated_GC.subj_number.L_Norm_Load_gait_cycles_EMG = L_Norm_Load_gait_cycles_EMG;
    Segregated_GC.subj_number.L_Norm_Load_gait_cycles_kin = L_Norm_Load_gait_cycles_kin;
    Segregated_GC.subj_number.R_Norm_Load_gait_cycles_EMG = R_Norm_Load_gait_cycles_EMG;
    Segregated_GC.subj_number.R_Norm_Load_gait_cycles_kin = R_Norm_Load_gait_cycles_kin;
    
    Segregated_GC.subj_number.L_Exoload_gait_cycles_EMG = L_Exoload_gait_cycles_EMG;
    Segregated_GC.subj_number.L_Exoload_gait_cycles_kin = L_Exoload_gait_cycles_kin;
    Segregated_GC.subj_number.R_Exoload_gait_cycles_EMG = R_Exoload_gait_cycles_EMG;
    Segregated_GC.subj_number.R_Exoload_gait_cycles_kin = R_Exoload_gait_cycles_kin;
    
    Segregated_GC.subj_number.L_Norm_Exoload_gait_cycles_EMG = L_Norm_Exoload_gait_cycles_EMG;
    Segregated_GC.subj_number.L_Norm_Exoload_gait_cycles_kin = L_Norm_Exoload_gait_cycles_kin;
    Segregated_GC.subj_number.R_Norm_Exoload_gait_cycles_EMG = R_Norm_Exoload_gait_cycles_EMG;
    Segregated_GC.subj_number.R_Norm_Exoload_gait_cycles_kin = R_Norm_Exoload_gait_cycles_kin;


    R_gaitcycle = 0; R_Exo_gaitcycle = 0; R_Load_gaitcycle = 0; R_Exoload_gaitcycle = 0;
    L_gaitcycle = 0; L_Exo_gaitcycle = 0; L_Load_gaitcycle = 0; L_Exoload_gaitcycle = 0;
 
    L_Level_hip = []; L_Level_knee = []; L_Level_ankle = []; 
    L_Exo_hip = []; L_Exo_knee = []; L_Exo_ankle = []; 
    L_Load_hip = []; L_Load_knee = []; L_Load_ankle = []; 
    L_Exoload_hip = []; L_Exoload_knee = []; L_Exoload_ankle = []; 
    R_Level_hip = []; R_Level_knee = []; R_Level_ankle = []; 
    R_Exo_hip = []; R_Exo_knee = []; R_Exo_ankle = []; 
    R_Load_hip = []; R_Load_knee = []; R_Load_ankle = []; 
    R_Exoload_hip = []; R_Exoload_knee = []; R_Exoload_ankle = [];


    L_gait_cycles_kin = {};  L_gait_cycles_EMG = {}; R_gait_cycles_kin = {};  R_gait_cycles_EMG = {}; 
    L_Norm_gait_cycles_EMG = {};  L_Norm_gait_cycles_EMG = {}; R_Norm_gait_cycles_kin = {};  R_Norm_gait_cycles_EMG = {}; 
    
    L_Load_gait_cycles_kin = {};  L_Load_gait_cycles_EMG = {};  R_Load_gait_cycles_kin = {};  R_Load_gait_cycles_EMG = {}; 
    L_Norm_Load_gait_cycles_kin = {};  L_Norm_Load_gait_cycles_EMG = {};  R_Norm_Load_gait_cycles_kin = {};  R_Norm_Load_gait_cycles_EMG = {}; 
    
    L_Exo_gait_cycles_kin = {};  L_Exo_gait_cycles_EMG = {};  R_Exo_gait_cycles_kin = {};  R_Exo_gait_cycles_EMG = {};  
    L_Norm_Exo_gait_cycles_kin = {};  L_Norm_Exo_gait_cycles_EMG = {};  R_Norm_Exo_gait_cycles_kin = {};  R_Norm_Exo_gait_cycles_EMG = {};  
    
    L_Exoload_gait_cycles_kin = {};  L_Exoload_gait_cycles_EMG = {};  R_Exoload_gait_cycles_kin = {};  R_Exoload_gait_cycles_EMG = {};
    L_Norm_Exoload_gait_cycles_kin = {};  L_Norm_Exoload_gait_cycles_EMG = {};  R_Norm_Exoload_gait_cycles_kin = {};  R_Norm_Exoload_gait_cycles_EMG = {};

end %% Subject looop ending


%% Data Saving
for dat = 1:length(Raw_data)
    Subj_and_trial_name{dat} = Raw_data(dat).kin_trials_num;
end

%kin_columnNames = {'Time','LKneeAngle_X','LKneeAngle_Y','LKneeAngle_Z','LAnkleAngle_X','LAnkleAngle_Y','LAnkleAngle_Z','RKneeAngle_X','RKneeAngle_Y','RKneeAngle_Z','RAnkeAngle_X','RAnkleAngle_Y','RAnkleAngle_Z','LAnkleMoment_X','LAnkleMoment_Y','LAnkleMoment_Z','RAnkleMoment_X','RAnkleMoment_Y','RAnkleMoment_Z','RKneeMoment_X','RKneeMoment_Y','RKneeMoment_Z','LKneeMoment_X','LKneeMoment_Y','LKneeMoment_Z'};
%EMG_columnNames = {'Time','R_RF','L_RF','R_VM','L_VM','R_PL','L_PL','R_TA','L_TA','R_GLM','L_GLM','R_BF','L_BF','R_GMed','L_GMed','R_S','L_S'};


ROM.L_ROM_Level = L_ROM_Level;
ROM.L_ROM_Exo = L_ROM_Exo;
ROM.L_ROM_Load = L_ROM_Load;
ROM.L_ROM_Exoload = L_ROM_Exoload;
ROM.R_ROM_Level = R_ROM_Level;
ROM.R_ROM_Exo = R_ROM_Exo;
ROM.R_ROM_Load = R_ROM_Load;
ROM.R_ROM_Exoload = R_ROM_Exoload;

Segregated_Exo_data.Subj_and_trial_name = Subj_and_trial_name;
%Segregated_Exo_data.kin_columnNames = kin_columnNames;
%Segregated_Exo_data.EMG_columnNames = EMG_columnNames;

Segregated_Exo_data.L_gait_cycles_EMG = L_gait_cycles_EMG;
Segregated_Exo_data.L_gait_cycles_kin = L_gait_cycles_kin;
Segregated_Exo_data.R_gait_cycles_EMG = R_gait_cycles_EMG;
Segregated_Exo_data.R_gait_cycles_kin = R_gait_cycles_kin;

Segregated_Exo_data.L_Norm_gait_cycles_EMG = L_Norm_gait_cycles_EMG;
Segregated_Exo_data.L_Norm_gait_cycles_kin = L_Norm_gait_cycles_kin;
Segregated_Exo_data.R_Norm_gait_cycles_EMG = R_Norm_gait_cycles_EMG;
Segregated_Exo_data.R_Norm_gait_cycles_kin = R_Norm_gait_cycles_kin;

Segregated_Exo_data.L_Exo_gait_cycles_EMG = L_Exo_gait_cycles_EMG;
Segregated_Exo_data.L_Exo_gait_cycles_kin = L_Exo_gait_cycles_kin;
Segregated_Exo_data.R_Exo_gait_cycles_EMG = R_Exo_gait_cycles_EMG;
Segregated_Exo_data.R_Exo_gait_cycles_kin = R_Exo_gait_cycles_kin;

Segregated_Exo_data.L_Norm_Exo_gait_cycles_EMG = L_Norm_Exo_gait_cycles_EMG;
Segregated_Exo_data.L_Norm_Exo_gait_cycles_kin = L_Norm_Exo_gait_cycles_kin;
Segregated_Exo_data.R_Norm_Exo_gait_cycles_EMG = R_Norm_Exo_gait_cycles_EMG; 
Segregated_Exo_data.R_Norm_Exo_gait_cycles_kin = R_Norm_Exo_gait_cycles_kin;

Segregated_Exo_data.L_Load_gait_cycles_EMG = L_Load_gait_cycles_EMG;
Segregated_Exo_data.L_Load_gait_cycles_kin = L_Load_gait_cycles_kin;
Segregated_Exo_data.R_Load_gait_cycles_EMG = R_Load_gait_cycles_EMG;
Segregated_Exo_data.R_Load_gait_cycles_kin = R_Load_gait_cycles_kin;

Segregated_Exo_data.L_Norm_Load_gait_cycles_EMG = L_Norm_Load_gait_cycles_EMG;
Segregated_Exo_data.L_Norm_Load_gait_cycles_kin = L_Norm_Load_gait_cycles_kin;
Segregated_Exo_data.R_Norm_Load_gait_cycles_EMG = R_Norm_Load_gait_cycles_EMG;
Segregated_Exo_data.R_Norm_Load_gait_cycles_kin = R_Norm_Load_gait_cycles_kin;

Segregated_Exo_data.L_Exoload_gait_cycles_EMG = L_Exoload_gait_cycles_EMG;
Segregated_Exo_data.L_Exoload_gait_cycles_kin = L_Exoload_gait_cycles_kin;
Segregated_Exo_data.R_Exoload_gait_cycles_EMG = R_Exoload_gait_cycles_EMG;
Segregated_Exo_data.R_Exoload_gait_cycles_kin = R_Exoload_gait_cycles_kin;

Segregated_Exo_data.L_Norm_Exoload_gait_cycles_EMG = L_Norm_Exoload_gait_cycles_EMG;
Segregated_Exo_data.L_Norm_Exoload_gait_cycles_kin = L_Norm_Exoload_gait_cycles_kin;
Segregated_Exo_data.R_Norm_Exoload_gait_cycles_EMG = R_Norm_Exoload_gait_cycles_EMG;
Segregated_Exo_data.R_Norm_Exoload_gait_cycles_kin = R_Norm_Exoload_gait_cycles_kin;

Segregated_Exo_data.ROM = ROM;

Exo_Biomechanics.Raw_data = Raw_data;
Exo_Biomechanics.Segregated_Exo_data = Segregated_Exo_data;

%save("Exo_Biomechanics.mat", "Exo_Biomechanics", '-v7.3'); 


