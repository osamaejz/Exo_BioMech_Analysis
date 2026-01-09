clear all
load ("Data/Raw_data_updated.mat")

Raw_data = cell2mat(Raw_data);
subjects = ["PE004", "PE005", "PE006", "PE007", "PE008", "PE009", "PE010", "PE011", "PE012", "PE013", "PE014", "PE015"];

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

L_Load_gait_cycles_kin = {};  L_Load_gait_cycles_EMG = {};  R_Load_gait_cycles_kin = {};  R_Load_gait_cycles_EMG = {}; 

L_Exo_gait_cycles_kin = {};  L_Exo_gait_cycles_EMG = {};  R_Exo_gait_cycles_kin = {};  R_Exo_gait_cycles_EMG = {};  

L_Exoload_gait_cycles_kin = {};  L_Exoload_gait_cycles_EMG = {};  R_Exoload_gait_cycles_kin = {};  R_Exoload_gait_cycles_EMG = {};

EMG_columnNames = {'Time', 'R_RF', 'L_RF', 'R_VM', 'L_VM', 'R_TA', 'L_TA', 'L_Soleus', 'R_Soleus', 'R_GMax', 'L_GMax', 'R_BF', 'L_BF', 'R_Gastr', 'L_Gastr', 'R_iliocostalis', 'L_iliocostalis'};

for subj = 1:length(Raw_data)
    subj_R_gaitcycle = 0;
    subj_L_gaitcycle = 0;
    for trial = 1:length(Raw_data(subj).kin_trials_num)
        no_EMG_flag = false;
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
        % as PE007 has no EMG data for no exo no load condition
        if  subj == 4 
            if trial <= 3
                no_EMG_flag = true;  
            else
                EMG_data_curr = cell2mat(EMG_data(trial-3));
            end
        else 
            EMG_data_curr = cell2mat(EMG_data(trial));
        end

        %% Segregating EMG and Kinematic data based on gait cycles
        % Doing this gait cycle separately for Left and Right foot because there may be difference in their counts
        
        %% For Left Gait Cycle
        [num_L_cycles, ~] = size(leftGaitCycles);

        % if num_L_cycles == 0
        %     disp("Subject " + subj)
        %     disp("Trial "  + trial)
        % ~
        %     break
        % end
    
    
        for l = 1:num_L_cycles
            LS_t_start = leftGaitCycles(l,1);
            LS_t_end = leftGaitCycles(l,2);
            
            % Find indices of kin_data within the current left gait cycle
            LGC_Kin_idx = Kin_data_curr(:,1) >= LS_t_start & Kin_data_curr(:,1) < LS_t_end;
            if ~ no_EMG_flag
                LGC_EMG_idx = (EMG_data_curr(:,1))/100 >= LS_t_start & (EMG_data_curr(:,1))/100 < LS_t_end;
            end
            % Segment GC data
            L_Kin_data_curr = Kin_data_curr(LGC_Kin_idx, :);

            if ~ no_EMG_flag
                L_EMG_data_curr = EMG_data_curr(LGC_EMG_idx, :);
            end
            % Saving non normalized data in table format with column names
            L_Kin_data_curr_tbl = array2table(L_Kin_data_curr, 'VariableNames', Kin_col_name_curr);

            if ~ no_EMG_flag
                L_EMG_data_curr_tbl = array2table(L_EMG_data_curr, 'VariableNames', EMG_columnNames);
            end
            % Store the segmented data
            
            if Level == true
                L_gait_cycles_kin{L_gaitcycle+l} = L_Kin_data_curr_tbl;
                if ~ no_EMG_flag
                    L_gait_cycles_EMG{L_gaitcycle+l} = L_EMG_data_curr_tbl;
                end

            elseif LevelExo == true
                
                L_Exo_gait_cycles_kin{L_Exo_gaitcycle+l} = L_Kin_data_curr_tbl;
                if ~ no_EMG_flag
                    L_Exo_gait_cycles_EMG{L_Exo_gaitcycle+l} = L_EMG_data_curr_tbl;
                end
                
            elseif LevelLoad == true
                
                L_Load_gait_cycles_kin{L_Load_gaitcycle+l} = L_Kin_data_curr_tbl;
                if ~ no_EMG_flag
                    L_Load_gait_cycles_EMG{L_Load_gaitcycle+l} = L_EMG_data_curr_tbl;
                end
                
            elseif LevelExoLoad == true
                L_Exoload_gait_cycles_kin{L_Exoload_gaitcycle+l} = L_Kin_data_curr_tbl;
                if ~ no_EMG_flag
                    L_Exoload_gait_cycles_EMG{L_Exoload_gaitcycle+l} = L_EMG_data_curr_tbl;
                end
                
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
            
            if ~ no_EMG_flag
                RGC_EMG_idx = (EMG_data_curr(:,1))/100 >= RS_t_start & (EMG_data_curr(:,1))/100 < RS_t_end;
            end 

            % Segment GC data
            R_Kin_data_curr = Kin_data_curr(RGC_Kin_idx, :);

            if ~ no_EMG_flag
                R_EMG_data_curr = EMG_data_curr(RGC_EMG_idx, :);

            end

            % Saving non normalized data in table format with column names
            R_Kin_data_curr_tbl = array2table(R_Kin_data_curr, 'VariableNames', Kin_col_name_curr);
            
            if ~ no_EMG_flag
                R_EMG_data_curr_tbl = array2table(R_EMG_data_curr, 'VariableNames', EMG_columnNames);
            end
            % Store the segmented data

            if Level == true
                R_gait_cycles_kin{R_gaitcycle+r} = R_Kin_data_curr_tbl;
                if ~ no_EMG_flag
                    R_gait_cycles_EMG{R_gaitcycle+r} = R_EMG_data_curr_tbl;
                end
                
            elseif LevelExo == true
                R_Exo_gait_cycles_kin{R_Exo_gaitcycle+r} = R_Kin_data_curr_tbl;
                if ~ no_EMG_flag
                    R_Exo_gait_cycles_EMG{R_Exo_gaitcycle+r} = R_EMG_data_curr_tbl;
                end
                 
            elseif LevelLoad == true
                R_Load_gait_cycles_kin{R_Load_gaitcycle+r} = R_Kin_data_curr_tbl;
                if ~ no_EMG_flag
                    R_Load_gait_cycles_EMG{R_Load_gaitcycle+r} = R_EMG_data_curr_tbl;
                end
                
            elseif LevelExoLoad == true
                R_Exoload_gait_cycles_kin{R_Exoload_gaitcycle+r} = R_Kin_data_curr_tbl;
                if ~ no_EMG_flag
                    R_Exoload_gait_cycles_EMG{R_Exoload_gaitcycle+r} = R_EMG_data_curr_tbl;
                end
                
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

    sub.subj_num = subjects(subj); % like S004
    sub.L_gait_cycles_EMG = L_gait_cycles_EMG; 
    sub.L_gait_cycles_kin = L_gait_cycles_kin;
    sub.R_gait_cycles_EMG = R_gait_cycles_EMG;
    sub.R_gait_cycles_kin = R_gait_cycles_kin;

    sub.L_Exo_gait_cycles_EMG = L_Exo_gait_cycles_EMG;
    sub.L_Exo_gait_cycles_kin = L_Exo_gait_cycles_kin;
    sub.R_Exo_gait_cycles_EMG = R_Exo_gait_cycles_EMG;
    sub.R_Exo_gait_cycles_kin = R_Exo_gait_cycles_kin;

    sub.L_Load_gait_cycles_EMG = L_Load_gait_cycles_EMG;
    sub.L_Load_gait_cycles_kin = L_Load_gait_cycles_kin;
    sub.R_Load_gait_cycles_EMG = R_Load_gait_cycles_EMG;
    sub.R_Load_gait_cycles_kin = R_Load_gait_cycles_kin;
    
    sub.L_Exoload_gait_cycles_EMG = L_Exoload_gait_cycles_EMG;
    sub.L_Exoload_gait_cycles_kin = L_Exoload_gait_cycles_kin;
    sub.R_Exoload_gait_cycles_EMG = R_Exoload_gait_cycles_EMG;
    sub.R_Exoload_gait_cycles_kin = R_Exoload_gait_cycles_kin;
    
    
    Segregated_GC{subj} = sub;

    R_Exoload_gaitcycle = 0; R_Load_gaitcycle = 0; R_Exo_gaitcycle = 0;  R_gaitcycle = 0;
    L_Exoload_gaitcycle = 0; L_Load_gaitcycle = 0; L_Exo_gaitcycle = 0;  L_gaitcycle = 0;

    L_gait_cycles_kin = {};  L_gait_cycles_EMG = {}; R_gait_cycles_kin = {};  R_gait_cycles_EMG = {}; 

    L_Load_gait_cycles_kin = {};  L_Load_gait_cycles_EMG = {};  R_Load_gait_cycles_kin = {};  R_Load_gait_cycles_EMG = {}; 
    
    L_Exo_gait_cycles_kin = {};  L_Exo_gait_cycles_EMG = {};  R_Exo_gait_cycles_kin = {};  R_Exo_gait_cycles_EMG = {};  
    
    L_Exoload_gait_cycles_kin = {};  L_Exoload_gait_cycles_EMG = {};  R_Exoload_gait_cycles_kin = {};  R_Exoload_gait_cycles_EMG = {};


end %% Subject looop ending


%% Data Saving

Exo_Biomechanics_Data = Segregated_GC;
% save("Data/Exo_Biomechanics_Data.mat", "Exo_Biomechanics_Data", '-v7.3'); 
