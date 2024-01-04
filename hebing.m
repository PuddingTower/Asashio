% Define file paths
file1 = 'report-file-0.out';
% file2 = 'all_1_15611.out';

% Open the first file, read the header, and then read the data
fid1 = fopen(file1, 'rt');
if fid1 == -1, error('Cannot open file %s', file1); end
fgetl(fid1); % Skip the first line
fgetl(fid1); % Skip the second line
headerLine = fgetl(fid1); % Read the header line
headerLine = strrep(headerLine, '(', ''); % Remove left parentheses
headerLine = strrep(headerLine, ')', ''); % Remove right parentheses
headers = strsplit(headerLine, '" "'); % Split the header line into individual column names
headers = strrep(headers, '"', ''); % Remove double quotes from headers
headers = headers(~cellfun('isempty', headers)); % Remove any empty cells
data1 = [];
while ~feof(fid1)
    line = fgetl(fid1); % Read each line
    if ~ischar(line), break; end % If it's not a character line, stop
    nums = sscanf(line, '%f'); % Parse the numbers
    data1 = [data1; nums.'];
end
fclose(fid1);

% Open the second file and read the data
fid2 = fopen(file2, 'rt');
if fid2 == -1, error('Cannot open file %s', file2); end
fgetl(fid2); % Skip the title row
fgetl(fid2); % Skip the second row
fgetl(fid2); % Skip the header row as it is the same as the first file
data2 = [];
while ~feof(fid2)
    line = fgetl(fid2); % Read each line
    if ~ischar(line), break; end % If it's not a character line, stop
    nums = sscanf(line, '%f'); % Parse the numbers
    data2 = [data2; nums.'];
end
fclose(fid2);

% Find the overlapping part in the second file with the first file
overlap_idx = find(data2(:,1) <= data1(end, 1), 1, 'last');

% Combine data
combined_data = [data1; data2(overlap_idx+1:end, :)]; % Skip the overlapping part

% Validate that the number of headers matches the number of data columns
if size(combined_data, 2) ~= length(headers)
    error('The number of headers does not match the number of columns in the data.');
end

% Create a table with headers and combined data
combined_data_table = array2table(combined_data, 'VariableNames', headers);

% Extract the file name without extension from file1
[filepath, name, ~] = fileparts(file1);

% Construct the new file name with the extracted name and .csv extension
output_filename = fullfile(filepath, [name, '.csv']);

% Export the table to a CSV file with the new file name
writetable(combined_data_table, output_filename);


