clearvars -except Exo_Biomechanics_Data
% load ("Data/Exo_Biomechanics_Data.mat")
all_EMG_NENL = {}; all_EMG_Exo = {}; all_EMG_Load = {}; all_EMG_EL = {}; 
all_EMG_subj_NENL = {}; all_EMG_subj_Exo = {}; all_EMG_subj_Load = {}; all_EMG_subj_EL = {};
subj_mean_NENL = {};  subj_mean_Exo = {};  subj_mean_Load = {};  subj_mean_EL = {};

for subj = 1:length(Exo_Biomechanics_Data)
    %% for No Exo No Load
    Left_GC_EMG = Exo_Biomechanics_Data{subj}.L_gait_cycles_EMG;
    Right_GC_EMG = Exo_Biomechanics_Data{subj}.R_gait_cycles_EMG;
    NENL_EMG = [Left_GC_EMG Right_GC_EMG]; % combining left and right GC EMG for combine analysis
    trial_EMG = {};
    for trial = 1:length(NENL_EMG)
        % getting EMG Channels name
        ch_name = NENL_EMG{trial}.Properties.VariableNames;
        total_ch = length(ch_name);
        % getting EMG data
        EMG_raw = table2array(NENL_EMG{trial});        
        % applying filter
        fs = 1000;                               
        [b,a] = butter(4,[20 450]/(fs/2));      % band-pass
        EMG_filt = filtfilt(b,a,EMG_raw);       % filter
        EMG_rect = abs(EMG_filt);               % rectification
        % Making GC % normalize
        EMG_norm = interp1(linspace(0,100,size(EMG_rect,1)), EMG_rect, linspace(0,100,101));
        % saving every trial of all subject
        all_EMG_NENL{end+1} = EMG_norm;
        all_EMG_subj_NENL{end+1} = Exo_Biomechanics_Data{subj}.subj_num;   
        trial_EMG{end+1} = EMG_norm;
    end
    subj_mean_NENL{end+1} = mean(cat(3, trial_EMG{:}), 3);

    %% for Exo No Load
    LeftExo_GC_EMG = Exo_Biomechanics_Data{subj}.L_Exo_gait_cycles_EMG;
    RightExo_GC_EMG = Exo_Biomechanics_Data{subj}.R_Exo_gait_cycles_EMG;
    Exo_EMG = [LeftExo_GC_EMG RightExo_GC_EMG]; % combining left and right GC EMG for combine analysis
    trial_EMG = {};
    for trial = 1:length(Exo_EMG)
        % getting EMG Channels name
        ch_name = Exo_EMG{trial}.Properties.VariableNames;
        total_ch = length(ch_name);
        % getting EMG data
        EMG_raw = table2array(Exo_EMG{trial});        
        % applying filter
        fs = 1000;                               
        [b,a] = butter(4,[20 450]/(fs/2));      % band-pass
        EMG_filt = filtfilt(b,a,EMG_raw);       % filter
        EMG_rect = abs(EMG_filt);               % rectification
        % Making GC % normalize
        EMG_norm = interp1(linspace(0,100,size(EMG_rect,1)), EMG_rect, linspace(0,100,101));
        % saving every trial of all subject
        all_EMG_Exo{end+1} = EMG_norm;
        all_EMG_subj_Exo{end+1} = Exo_Biomechanics_Data{subj}.subj_num; 
        trial_EMG{end+1} = EMG_norm;
    end
    subj_mean_Exo{end+1} = mean(cat(3, trial_EMG{:}), 3);

    %% for Load
    LefttLoad_GC_EMG = Exo_Biomechanics_Data{subj}.L_Load_gait_cycles_EMG;
    RightLoad_GC_EMG = Exo_Biomechanics_Data{subj}.R_Load_gait_cycles_EMG;
    Load_EMG = [LefttLoad_GC_EMG RightLoad_GC_EMG]; % combining left and right GC EMG for combine analysis
    trial_EMG = {};
    for trial = 1:length(Load_EMG)
        % getting EMG Channels name
        ch_name = Load_EMG{trial}.Properties.VariableNames;
        total_ch = length(ch_name);
        % getting EMG data
        EMG_raw = table2array(Load_EMG{trial});        
        % applying filter
        fs = 1000;                               
        [b,a] = butter(4,[20 450]/(fs/2));      % band-pass
        EMG_filt = filtfilt(b,a,EMG_raw);       % filter
        EMG_rect = abs(EMG_filt);               % rectification
        % Making GC % normalize
        EMG_norm = interp1(linspace(0,100,size(EMG_rect,1)), EMG_rect, linspace(0,100,101));
        % saving every trial of all subject
        all_EMG_Load{end+1} = EMG_norm;
        all_EMG_subj_Load{end+1} = Exo_Biomechanics_Data{subj}.subj_num;   
        trial_EMG{end+1} = EMG_norm;
    end
    subj_mean_Load{end+1} = mean(cat(3, trial_EMG{:}), 3);

    %% for ExoLoad
    LeftExoLoad_GC_EMG = Exo_Biomechanics_Data{subj}.L_Exoload_gait_cycles_EMG;
    RightExoLoad_GC_EMG = Exo_Biomechanics_Data{subj}.R_Exoload_gait_cycles_EMG;
    EL_EMG = [LeftExoLoad_GC_EMG RightExoLoad_GC_EMG]; % combining left and right GC EMG for combine analysis
    trial_EMG = {};
    for trial = 1:length(EL_EMG)
        % getting EMG Channels name
        ch_name = EL_EMG{trial}.Properties.VariableNames;
        total_ch = length(ch_name);
        % getting EMG data
        EMG_raw = table2array(EL_EMG{trial});        
        % applying filter
        fs = 1000;                               
        [b,a] = butter(4,[20 450]/(fs/2));      % band-pass
        EMG_filt = filtfilt(b,a,EMG_raw);       % filter
        EMG_rect = abs(EMG_filt);               % rectification
        % Making GC % normalize
        EMG_norm = interp1(linspace(0,100,size(EMG_rect,1)), EMG_rect, linspace(0,100,101));
        % saving every trial of all subject
        all_EMG_EL{end+1} = EMG_norm;
        all_EMG_subj_EL{end+1} = Exo_Biomechanics_Data{subj}.subj_num;  
        trial_EMG{end+1} = EMG_norm;
    end
    subj_mean_EL{end+1} = mean(cat(3, trial_EMG{:}), 3);

end
% Taking mean for visualization
meanEMG_NENL = mean(cat(3, all_EMG_NENL{:}), 3);
meanEMG_Exo = mean(cat(3, all_EMG_Exo{:}), 3);
meanEMG_Load = mean(cat(3, all_EMG_Load{:}), 3);
meanEMG_EL = mean(cat(3, all_EMG_EL{:}), 3);

% Visualization of GC synchronised EMG
figure;
for ch_plt = 2:total_ch 
    subplot(4,4,ch_plt-1)
    hold on   
    plot(meanEMG_NENL(:,ch_plt),'Color',[0 0 0],'LineWidth',1.2)        % Black
    plot(meanEMG_Exo(:,ch_plt),'Color',[0.85 0.33 0.1],'LineWidth',1.2) % Orange
    plot(meanEMG_Load(:,ch_plt),'Color',[0 0.45 0.74],'LineWidth',1.2)  % Blue
    plot(meanEMG_EL(:,ch_plt),'Color',[0.47 0.67 0.19],'LineWidth',1.2) % Green
    title(ch_name(ch_plt),'Interpreter','none')
    xlim([0 101])
    grid on    
end
legend('No Exo No Load', 'Exo', 'Load', 'Exo Load');

%% Computing amplitude difference in each subject
amp_diff = {};
for subj = 1:length(Exo_Biomechanics_Data) 
    amp_diff{subj} = mean(subj_mean_Exo{subj}) - mean(subj_mean_NENL{subj});
end

amp_diff_mat = cell2mat(amp_diff');   % size = N x 17
amp_diff_mat(any(isnan(amp_diff_mat),2),:) = [];

figure
boxplot(amp_diff_mat(:,2:17),'Labels',ch_name(2:17))
yline(0,'--k')
xlabel('Channel')
ylabel('Amplitude Difference')
title('EMG Difference (Exo - NoExo)')
grid on

%% Reporting table for amplitude Difference
amp_mat = amp_diff_mat(:,2:17);
muscle_names = ch_name(2:17);
N = size(amp_mat,1);

MeanDiff = mean(amp_mat);
StdDiff  = std(amp_mat);
SEM      = StdDiff/sqrt(N);
CI_low   = MeanDiff - 1.96*SEM;
CI_high  = MeanDiff + 1.96*SEM;

p_vals = zeros(1,16);
for ch = 1:16
    [~,p_vals(ch)] = ttest(amp_mat(:,ch));
end

Cohen_d = MeanDiff ./ StdDiff;

% Interpretation
Interpret = strings(1,16);
for i = 1:16
    if p_vals(i) < 0.05
        Interpret(i) = "Significant";
    else
        Interpret(i) = "Not significant";
    end
end

% Create table
ResultsTable = table(muscle_names', MeanDiff', StdDiff', ...
                     CI_low', CI_high', p_vals', ...
                     Cohen_d', Interpret', ...
'VariableNames',{'Muscle','MeanDiff','Std','CI_Low','CI_High',...
                 'p_value','EffectSize_d','Interpretation'});

disp(ResultsTable)
% writetable(ResultsTable,'EMG_Amplitude_diff.xlsx')

%% Computing timing difference

N = numel(subj_mean_Exo);
timing_diff_cell = cell(1,N);
cnt = 1;

for s = 1:N
    exo  = subj_mean_Exo{s};
    noxo = subj_mean_NENL{s};

    % --- Skip missing data ---
    if isempty(exo) || isempty(noxo)
        continue
    end

    tdiff = zeros(1,16);

    for ch = 1:16
        [~,t_exo]  = max(exo(:,ch+1));
        [~,t_noxo] = max(noxo(:,ch+1));
        tdiff(ch) = t_exo - t_noxo;   % in % gait cycle
    end

    timing_diff_cell{s} = tdiff;
    cnt = cnt + 1;
end

timing_mat = cell2mat(timing_diff_cell');

%% Timing Difference Visualization
figure
boxplot(timing_mat, 'Labels',ch_name(2:17))
yline(0,'--k')
xlabel('Muscle')
ylabel('Timing Difference (% Gait Cycle)')
title('Peak Timing Shift (Exo - NoExo)')
grid on

%% Timing difference reporting table

% mean
mean_timing = mean(timing_mat,'omitnan');
std_timing  = std(timing_mat,'omitnan');
n = sum(~isnan(timing_mat));

% CI
alpha = 0.05;
for m = 1:size(timing_mat,2)
    sem = std(timing_mat(:,m),'omitnan')/sqrt(n(m));
    tval = tinv(1-alpha/2,n(m)-1);
    CI_low(m)  = mean_timing(m) - tval*sem;
    CI_high(m) = mean_timing(m) + tval*sem;
end

% Stats
for m = 1:size(timing_mat,2)
    [~,p_val(m)] = ttest(timing_mat(:,m));  % paired
end

% Effect Size
for m = 1:size(timing_mat,2)
    d(m) = mean_timing(m) / std_timing(m);
end

Results = table(mean_timing',CI_low',CI_high', ...
                std_timing',d',p_val', ...
 'VariableNames',{'Mean','CI_low','CI_high','STD','Cohen_d','p_value'});
disp(Results)
% writetable(Results,'EMG_Activation_Timing.xlsx')