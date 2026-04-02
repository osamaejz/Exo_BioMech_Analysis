clear, close all

subjects = ["PE004", "PE005", "PE006", "PE007", "PE008", "PE009", ...
            "PE010", "PE011", "PE012", "PE013", "PE014", "PE015"];

% Initialize structure with empty cells
fields = {'Slope_L_Stride_Time','Slope_R_Stride_Time', ...
          'Slope_L_Step_Length','Slope_R_Step_Length', ...
          'Slope_L_Step_Width','Slope_R_Step_Width', ...
          'Slope_L_Cadence','Slope_R_Cadence', ...
          'SlopeExo_L_Stride_Time','SlopeExo_R_Stride_Time', ...
          'SlopeExo_L_Step_Length','SlopeExo_R_Step_Length', ...
          'SlopeExo_L_Step_Width','SlopeExo_R_Step_Width', ...
          'SlopeExo_L_Cadence','SlopeExo_R_Cadence', ...
          'SlopeLoad_L_Stride_Time','SlopeLoad_R_Stride_Time', ...
          'SlopeLoad_L_Step_Length','SlopeLoad_R_Step_Length', ...
          'SlopeLoad_L_Step_Width','SlopeLoad_R_Step_Width', ...
          'SlopeLoad_L_Cadence','SlopeLoad_R_Cadence', ...
          'SlopeExoLoad_L_Stride_Time','SlopeExoLoad_R_Stride_Time', ...
          'SlopeExoLoad_L_Step_Length','SlopeExoLoad_R_Step_Length', ...
          'SlopeExoLoad_L_Step_Width','SlopeExoLoad_R_Step_Width', ...
          'SlopeExoLoad_L_Cadence','SlopeExoLoad_R_Cadence'};

for f = 1:length(fields)
    spatiotemporal.(fields{f}) = cell(length(subjects), 0); % assume max 20 trials
end

for subj = 1:length(subjects)

    Slope = 0; SlopeExo = 0; SlopeLoad = 0; SlopeExoLoad = 0; 

    EMG_folderPath = 'D:\PhD\Research\Exoskeleton_test\Downhill_Exo_Experiment\EMG\' + subjects(subj);
    EMG_fileList = dir(fullfile(EMG_folderPath, '*.csv'));

    for i = 1:length(EMG_fileList)

        fileName = fullfile(EMG_folderPath, EMG_fileList(i).name);
        [~, name, ~] = fileparts(fileName);
        trial_type = char(extractBetween(name, 7, strlength(name)-2));

        if trial_type == "Slope"
            Slope = Slope + 1;
            trial_index_counter = Slope;

        elseif trial_type == "SlopeExo"
            SlopeExo = SlopeExo +1;
            trial_index_counter = SlopeExo;

        elseif trial_type == "SlopeLoad"
            SlopeLoad = SlopeLoad +1;
            trial_index_counter = SlopeLoad;

        elseif trial_type == "SlopeExoLoad"
            SlopeExoLoad = SlopeExoLoad +1;
            trial_index_counter = SlopeExoLoad;

        end

        fid = fopen(fileName, 'r');
        raw_lines = textscan(fid, '%s', 'Delimiter', '\n');
        fclose(fid);

        raw_lines = raw_lines{1};

        data_start_idx = find(startsWith(raw_lines, 'Events'), 1);
        metadata_lines = raw_lines(1:data_start_idx-1);

        % --- Extract values ---
        for k = 4:length(metadata_lines)

            if ~isempty(metadata_lines{k})

                parts = strsplit(metadata_lines{k}, ',');

                if length(parts) < 4
                    continue
                end

                side  = strtrim(parts{2});
                param = strtrim(parts{3});
                value = str2double(parts{4});

                % Clean parameter name
                param_clean = strrep(param, ' ', '_');

                % Only required parameters
                if ismember(param, {'Cadence','Step Length','Step Width','Stride Time'})

                    if strcmp(side, 'Left')
                        fieldname = [trial_type '_L_' param_clean];
                    elseif strcmp(side, 'Right')
                        fieldname = [trial_type '_R_' param_clean];
                    else
                        continue
                    end

                    % if k == 4
                    %     % Store value
                    % 
                    % end

                    spatiotemporal.(fieldname){subj, trial_index_counter} = value;

                end
            end
        end
        
    end
end

%% Mean and Std NENL Values
Cademce_mean_L_NENL = [mean(cell2mat(spatiotemporal.Slope_L_Cadence(:))) std(cell2mat(spatiotemporal.Slope_L_Cadence(:)))];
Cademce_mean_R_NENL = [mean(cell2mat(spatiotemporal.Slope_R_Cadence(:))) std(cell2mat(spatiotemporal.Slope_R_Cadence(:)))];

Stride_mean_L_NENL = [mean(cell2mat(spatiotemporal.Slope_L_Stride_Time(:))) std(cell2mat(spatiotemporal.Slope_L_Stride_Time(:)))];
Stride_mean_R_NENL = [mean(cell2mat(spatiotemporal.Slope_R_Stride_Time(:))) std(cell2mat(spatiotemporal.Slope_R_Stride_Time(:)))];

Steplen_mean_L_NENL = [mean(cell2mat(spatiotemporal.Slope_L_Step_Length(:))) std(cell2mat(spatiotemporal.Slope_L_Step_Length(:)))];
Steplen_mean_R_NENL = [mean(cell2mat(spatiotemporal.Slope_R_Step_Length(:))) std(cell2mat(spatiotemporal.Slope_R_Step_Length(:)))];

Stepwid_mean_L_NENL = [mean(cell2mat(spatiotemporal.Slope_L_Step_Width(:))) std(cell2mat(spatiotemporal.Slope_L_Step_Width(:)))];
Stepwid_mean_R_NENL = [mean(cell2mat(spatiotemporal.Slope_R_Step_Width(:))) std(cell2mat(spatiotemporal.Slope_R_Step_Width(:)))];

%% Mean and Std Exo Values
Cademce_mean_L_Exo = [mean(cell2mat(spatiotemporal.SlopeExo_L_Cadence(:))) std(cell2mat(spatiotemporal.SlopeExo_L_Cadence(:)))];
Cademce_mean_R_Exo = [mean(cell2mat(spatiotemporal.SlopeExo_R_Cadence(:))) std(cell2mat(spatiotemporal.SlopeExo_R_Cadence(:)))];

Stride_mean_L_Exo = [mean(cell2mat(spatiotemporal.SlopeExo_L_Stride_Time(:))) std(cell2mat(spatiotemporal.SlopeExo_L_Stride_Time(:)))];
Stride_mean_R_Exo = [mean(cell2mat(spatiotemporal.SlopeExo_R_Stride_Time(:))) std(cell2mat(spatiotemporal.SlopeExo_R_Stride_Time(:)))];

Steplen_mean_L_Exo = [mean(cell2mat(spatiotemporal.SlopeExo_L_Step_Length(:))) std(cell2mat(spatiotemporal.SlopeExo_L_Step_Length(:)))];
Steplen_mean_R_Exo = [mean(cell2mat(spatiotemporal.SlopeExo_R_Step_Length(:))) std(cell2mat(spatiotemporal.SlopeExo_R_Step_Length(:)))];

Stepwid_mean_L_Exo = [mean(cell2mat(spatiotemporal.SlopeExo_L_Step_Width(:))) std(cell2mat(spatiotemporal.SlopeExo_L_Step_Width(:)))];
Stepwid_mean_R_Exo = [mean(cell2mat(spatiotemporal.SlopeExo_R_Step_Width(:))) std(cell2mat(spatiotemporal.SlopeExo_R_Step_Width(:)))];

