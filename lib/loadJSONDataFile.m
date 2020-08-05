 %% بسم الله الرحمن الرحیم 

%% ## JSON Data File Loader ##
% 06.03.2020, Ferhat Yılmaz

%% How Works?
%{
	1- Open file through path defined
	2- Read file and convert to char vector
	3- Encode the string vector as JSON format
	4- Assign the encoded data to related field of structure
	5- Close the file stream

>> Inputs:
	1. Char array of <dataFilePath>

<< Outputs:
	1. Structure of <loadedData>
%}

%%
function loadedData = loadJSONDataFile(dataFilePath)
% Open file stream
fileStream = fopen(dataFilePath);

% Read file
str_Data = char(fread(fileStream, inf)');

% Close file stream
fclose(fileStream);

% Decode char array as a JSON format
loadedData = jsondecode(str_Data);
end
