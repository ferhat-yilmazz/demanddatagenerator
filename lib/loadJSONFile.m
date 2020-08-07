 %% بسم الله الرحمن الرحیم 

%% ## JSON File Read&Load ##
% 07.08.2020, Ferhat Yılmaz

%% Description
%{
	Function to read and load given JSON file and
	return data in the file

>> Inputs:
	1. <dataFilePath> : string :  path of JSON file

<< Outputs:
	1. <loadedData> : structure : data in the JSON file
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
