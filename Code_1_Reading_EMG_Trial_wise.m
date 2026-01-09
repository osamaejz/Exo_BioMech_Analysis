clear, close all

subjects = ["PE004", "PE005", "PE006", "PE007", "PE008", "PE009", "PE010", "PE011", "PE012", "PE013", "PE014", "PE015"];

for subj = 1:length(subjects)

    EMG_folderPath = 'D:\PhD\Research\Exoskeleton_test\Data\EMG\' + subjects(subj); % folder that contain EMG data in csv files
    EMG_fileList = dir(fullfile(EMG_folderPath, '*.csv'));

    for i = 1:length(EMG_fileList)
        % reading EMG csv file one by one
        fileName = fullfile(EMG_folderPath, EMG_fileList(i).name); % making filename with path for file read

        opts = detectImportOptions(fileName,'FileType','text');
        % set the row that contains the column names
        opts.VariableNamesLine = 4;        
        % set the rows that contain the data (row after header to end)
        opts.DataLines = [5 Inf];          
        emg_data = readtable(fileName, opts);

        colNames = emg_data.Properties.VariableNames;

        emg_name{i} = EMG_fileList(i).name(1:end-4); % name containing subject and level number

        %disp(["Working on EMG file: ", emg_name{i}]);
        fprintf('Working on EMG file: %s\n', emg_name{i});

        if colNames{19} == "IMEMG1"

            % removing the Kinetics data from the file
            emg_data(1,:) = []; % removing first three rows (containing unrequired text or empty cells) of the csv file 
            emg_data(:,2:18) = []; % removing columns with sub frame (2) and Delsys EMG 2.2.0 #2 (3-17) both are not required

        elseif colNames{103} == "IMEMG1"

            % removing the Kinetics data from the file
            emg_data(1,:) = []; % removing first three rows (containing unrequired text or empty cells) of the csv file 
            emg_data(:,2:102) = []; % removing columns with sub frame (2) and Delsys EMG 2.2.0 #2 (3-17) both are not required

        elseif colNames{247} == "IMEMG1"
            % removing the Kinetics data from the file
            emg_data(1,:) = []; % removing first three rows (containing unrequired text or empty cells) of the csv file 
            emg_data(:,2:246) = []; % removing columns with sub frame (2) and Delsys EMG 2.2.0 #2 (3-17) both are not required

        else
            disp("Invalid EMG file format");
            return

        end

        % retaining only first 17 columns after the above rows and column removals
        emg_data = emg_data(:,1:17); % contain frame number (time) and 16 EMG sensor values

        % Finding first nan value (an empty cell) in the first column i.e. the location where EMG data ends
        first_col = emg_data{:,1}; % extracted first column for finding last emg value
        last_datapoint = find(isnan(first_col(:,1)), 1); % getting first empty cell after EMG values

        current_emg_data = emg_data(1:last_datapoint-1, 1:17); % Now EMG data has first column with time points and remaining 16 columns with EMG

        % Saving current EMG trial in a matrix
        EMG_trials{i} = table2array(current_emg_data);


    end
    disp("EMG Reading Done")
    %% Now reading kinetic/kinematic file and its relevant data extraction
    Kin_folderPath = 'D:\PhD\Research\Exoskeleton_test\Data\C3d_excel_Export\' + subjects(subj); % folder that contain csv files
    Kin_fileList = dir(fullfile(Kin_folderPath, '*.csv'));

    %% reordering UH and DH files to align with EMG files
    
    % % Extract numeric parts from file names to get the trial number
    % fileNums = zeros(length(Kin_fileList), 1);
    % for r = 1:length(Kin_fileList)
    %     % Extract number from the file name using regular expression
    %     tokens = regexp(Kin_fileList(r).name, '\d+', 'match');
    %     if ~isempty(tokens)
    %         fileNums(r) = str2double(tokens{2});  % assume only one number per file name
    %     end
    % end
    % 
    % % Get the sorted index values based on the numeric part (trial number)
    % [~, sortIdx] = sort(fileNums); 
    % 
    % % Reorder Kin_fileList
    % Kin_fileList = Kin_fileList(sortIdx);


    %%
    for i = 1:length(Kin_fileList)
        
        % reading kin csv file one by one
        kin_fileName = fullfile(Kin_folderPath, Kin_fileList(i).name); % making filename with path for file read
    
        kin_name{i} = Kin_fileList(i).name(1:end-4);  % name containing subject, UH/DH, and level number
    
        %disp(["Working on Kin file: ", kin_name{i}]);
        fprintf('Working on Kin file: %s\n', kin_name{i});

        % reading kin file through fopen to read gait events only
        fid = fopen(kin_fileName, 'r');
        if fid == -1
            error('Failed to open file: %s', kin_fileName);
        end
        
        raw_lines = textscan(fid, '%s', 'Delimiter', '\n');
        fclose(fid);
        raw_lines = raw_lines{1}; % containing all kin data and gait event timings in one cell column
        
        % Detect the first row that starts with "Time" in the first column (the line from where 
        % data starts
        data_start_idx = find(startsWith(raw_lines, 'Time'), 1);
        
        % Separate metadata (gait events) and data
        metadata_lines = raw_lines(1:data_start_idx-1);
    
        % Parse Metadata into structure
        curr_kin_metadata = struct(); % creating structure for saving gait events
        for j = 1:length(metadata_lines)
            tokens = strsplit(metadata_lines{j}, ','); % separating gait event name and its value 
            if numel(tokens) >= 2
                key = matlab.lang.makeValidName(strtrim(tokens{1})); % creating name of the gait event as key for mat structure 
                value = strtrim(tokens{2}); % creating value of the gait event as value for mat structure 
                curr_kin_metadata.(key) = value; %  creating key value pair for each gait event
            end
        end
        
        % reading kin data file again through readtable for extracting kin
        % data values
        kin_data = readtable(kin_fileName);

        %% Uncomment the below lines to select only Ankle part
        % kin_columnNames = kin_data.Properties.VariableNames;
        % 
        % selectedCols = [1];
        % 
        % for c = 1:length(kin_columnNames)
        %     if startsWith(kin_columnNames{c}, 'LAnkle') || startsWith(kin_columnNames{c}, 'RAnkle')
        %         if c + 2 <= length(kin_columnNames)  % Make sure we don't exceed bounds
        %             selectedCols = [selectedCols, c, c+1, c+2];  % Add x, y, z
        %         end
        %     end
        % end
        % curr_kinData = kin_data(2:end, selectedCols);
        
        kin_data = kin_data(2:end, :); % removing first row with nan values
        [a, b] = size(kin_data); % getting no. of row and columns in curr_kin_data

        first_col_kin = kin_data{:,1}; % extracted first column for finding last value before force
        last_datapoint = find(isnan(first_col_kin(:,1)), 1); % getting first empty cell after EMG values
        curr_kinData = kin_data(1:last_datapoint-1, 1:end); % Now EMG data has first column with time points and remaining 16 columns with EMG
        % current_kin_data_2 = kin_data(last_datapoint+2:end, 1:13);
        % the above is force plates data. Will see it later if needed.
        if isempty(curr_kinData)
            disp('curr_kinData is empty. Stopping execution.')
            disp(['No data in the file: ', kin_name{i}])
            break
        end
        
        isNum = varfun(@isnumeric, curr_kinData, 'OutputFormat', 'uniform');
        curr_kinData = curr_kinData(:, isNum);
        Kin_trials{i} = table2array(curr_kinData); % converting data type for kin data and saving each in one array 
        kin_descrip{i} = curr_kin_metadata; % saving gait events of each trial in one array
        Kin_headers{i} = curr_kinData.Properties.VariableNames;

        % Applying condition to check for the incorrect data or abscent
        % data in kin data files
        if ((b ~= 160) && (b ~= 169) && (b ~= 172) && (b ~= 175) && (b ~= 178) && (b ~= 181)) % checking if there is data more or less than angles(x,y,z) and moments(x,y,z) of knee and ankle joints
            disp(['incorrect data in the file: ', kin_name{i}])
            break
        end

        
    end
    
    %% saving all subjects and their trials emg and kin data in one structure
    sub.subj_num = subjects(subj); % like S001
    sub.emg_trials_num = emg_name; % like S001_Slope01
    sub.emg_trials_data = EMG_trials; % 1x30 cell containing each trail emg of size nx17 at each cell index
    sub.kin_trials_num = kin_name; % 1x30 cell containing name of each kin file like S001_UH_01
    sub.Kin_trials_data = Kin_trials; % 1x30 cell containing each trail kin of size nx25 at each cell index
    sub.Kin_trials_header = Kin_headers;
    sub.gait_cycle_timestamps = kin_descrip; % 1x30 cell containing each trail's gait events in separate structure in key-value pair/format


    %% Combining each subject's all data together in one structure
    Raw_data{subj} = sub;

    %% cleaning all cells for next subject
    emg_name = {};
    EMG_trials = {};
    kin_name = {};
    Kin_trials = {};
    Kin_headers = {};
    kin_descrip = {};

end

%% saving the structure (containing all data) as a .mat file
%save("Data/Raw_data_updated.mat", 'Raw_data')


