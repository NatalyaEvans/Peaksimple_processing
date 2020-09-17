function read = PS_reader(filename)
% This function reads in Peaksimple ASCII files and outputs the formatted
% data for them. It takes in a variable called "filename", which is a
% string, and uses that to open the file. It saves a series of outputs in
% a single structure, including the header, the raw and PS-processed data,
% and a time vector based on the frequency of measurement. 

% read.head is the header
% read.cutval represents if the reading function ended early to avoid
% "IPOINT" values
% read.raw is the LHS of the PS.ASC file, which I believe is the raw values
% read.proc is the RHS of the PS.ASC file, which I believe have been
% smoothed.
% read.freq is the frequency of the measurement, as reported in the header
% read.time is a time vector that goes along with the chromatogram, based
% on read.freq

% Written by Natalya Evans for processing GC-FPD data for sulfur, primarily
% for plotting chromatograms.
% Last updated 16 September 2020

%Set conditions
opt = {'CollectOutput',true};
hdr = {};
out = {};
[fid,msg] = fopen(filename,'rt');
assert(fid>=3,msg) % ensure the file opened correctly.

% Process the header
for line=1:25
	hdr{end+1} = fgetl(fid);
end

read.head=hdr; % save header to object
read.cutval=0; % indicates that the read wasn't cutting an IPOINTS

% Read in data
hdr = {}; % reset read-into var
out = {}; % reset read-into var
while ~feof(fid) %checks for end of file
    hdr{end+1} = fgetl(fid);
    if any(~cellfun('isempty',strfind(hdr(end),'IPOINT')))==1 % checks if an "IPOINT" comes up
        read.cutval=1; %indicates that there was a cut
        break  % aborts loop
    end
end
fclose(fid); %closes file


% Process data into raw and filtered data by PS

% cuts the last value if relevant
if any(~cellfun('isempty',strfind(hdr(end),'IPOINT')))==1 % checks if the last value is an IPOINT
	hdr(end)=[]; % bye bye!
end

% Splits the cell array into two vectors
raw=[]; % LHS
proc=[]; % RHS
for line=1:length(hdr)
    current_line=char(hdr(line)); %sets the current line as a char
    raw(end+1,:)=str2double(current_line(1:strfind(current_line,',')-1));
    proc(end+1,:)=str2double(current_line(strfind(current_line,',')+1:end));
end

read.raw=raw;
read.proc=proc;

% Generates a time vector based on the frequency

line_ind=find(contains(read.head,'Hz')); % finds the right line in the header
current_line=char(read.head(line_ind)); % converts this line into a char
read.freq=str2double(current_line(strfind(current_line,'=')+1:strfind(current_line,'Hz')-1)); % extracts the number
read.time=[0:length(read.proc)-1]'./(read.freq.*60); % creates a time vector in minutes, starting at t=0


end

