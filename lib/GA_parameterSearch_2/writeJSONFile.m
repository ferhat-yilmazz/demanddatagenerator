 %% بسم الله الرحمن الرحیم 

%% ## JSON File Write/Generate ##
% 07.01.2021, Ferhat Yılmaz

%% Description
%{
  Function to write given structure to file in JSON format.
  The file will be saved into "configs" directory with unique
  name. So, ancient parameter files will be kept.

>> Inputs:
  1. <sourceStructure> : structure : Structure which will be encoded to JSON
  2. <filePath> : string : Location of file to save

<< Outputs:

%}

%%
function writeJSONFile(sourceStructure, filePath)
  % ## Specify name of the file ##
  % Get datetime of now
  nowDateTime = datetime('now', 'Format', 'yyyyMMddHHmmss');
  % Add prename to <nowDateTime>
  fileName = strcat('runProbabilityParameters_', string(nowDateTime), '_.json');
  
  % Open file called as <fileName> at given <filePath>
  runprobabilityParameterFile = fopen(strcat(filePath, filesep, fileName), 'w');
  assert(runprobabilityParameterFile ~= -1, '<writeJSONFile>: File open error');
  
  % Write <sourceStructure> ot <runprobabilityParameterFile> in JSON format
  fwrite(runprobabilityParameterFile, jsonencode(sourceStructure));
  
  % Close the file
  fclose(runprobabilityParameterFile);
end
