 %% بسم الله الرحمن الرحیم 

%% ## Genetic Algorithm Load Configuration Files ##
% 09.11.2020, Ferhat Yılmaz

%% Description
%{
  Script to load configuration files. Paths are also defined in
  this script.
%}

%% Define PATH variables
% "appliancesData.json" path
PATH_applianceData = strcat('..', filesep, '..', filesep, 'configs', filesep, 'appliancesData.json');
% "residentalTypes.json" path
PATH_residentalTypes = strcat('..', filesep, '..', filesep, 'configs', filesep, 'residentalTypes.json');
% "initialConditions.json" path
PATH_initialConditions = strcat('..', filesep, '..', filesep, 'configs', filesep, 'initialConditions.json');
% "geneticAlgorithm.json" path
PATH_geneticAlgorithm = strcat('..', filesep, '..', filesep, 'configs', filesep, 'geneticAlgorithm.json');
% "defaultValues.json" path
PATH_defaultValues = strcat('..', filesep, '..', filesep, 'configs', filesep, 'defaultValues.json');
% "runprobabilityParameters_yyyyMMddHHmmss_.json" path
PATH_runprobabilityParameters = strcat('..', filesep, '..', filesep, 'configs');

%% Load config files as structure
appliancesData = loadJSONFile(PATH_applianceData);
residentalTypes = loadJSONFile(PATH_residentalTypes);
initialConditions = loadJSONFile(PATH_initialConditions);
geneticAlgorithm = loadJSONFile(PATH_geneticAlgorithm);
defaultValues = loadJSONFile(PATH_defaultValues);
