%% Info

% This script was built to read in all of the ASC raw data files in a
% folder and import them into Matlab for processing and plotting. It uses a
% string, "name_out", to save them as well once complete. It requires the
% "PS_reader.m" helper function

% Written by Natalya Evans, 16 September 2020

%% User options
to_save=1; % if 1, saves the file
save_name='Dewar_comp'; % name to save the output. It needs to be in apostrophes
normalize_plots=1; % if 1, plots are all normalized by their highest values

%% Load in file names
files=ls; % all file names
[numfiles ~]=size(files); % number of files

% Selecting which files are ASC's
for i=1:numfiles
    if isempty(strfind(convertCharsToStrings(files(i,:)),'.ASC'))==0 %checks if it contains a ".ASC" and if it does, returns a number so therefore not empty
        temp=files(i,:); % save filename
        temp(temp==' ')=[]; % remove spaces from filename
        select_files(i,:)=temp; % save char array of file names
    end
end

% BEWARE
select_files(1:2,:)=[]; % for some reason, I'm getting two leading blank file names, so I cut them out here

% process files so they van be object heads
file_names=select_files(:,1:11); % I format all of my files the same way, making this assignment easy

%% Read in files


[numfiles,~]=size(select_files); % determine number of files
for i=1:numfiles
    dummy.files(i,:)=PS_reader(select_files(i,:));
end
out=dummy.files; % remove an unnecessary layer of ocmplication

% Save the file name too
for i=1:length(out)
    out(i).filename=file_names(i,:);
end

%% Save data, if selected

if to_save==1
    save(save_name,'out');
end

%% Plot data

figure(1)

for i=1:length(out)
    x=out(i).time;
    y=out(i).raw;
    
    if normalize_plots==1
        y=out(i).raw./max(out(i).raw);
    end
    plot(x,y)
    hold on
end

hold off
xlabel('Time/min')
if normalize_plots==1
    ylabel('Relative value')
else
    ylabel('Current/mV')
end

legend(out.filename)
