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
PATH_applianceData = '../../configs/appliancesData.json';
% "residentalTypes.json" path
PATH_residentalTypes = '../../configs/residentalTypes.json';
% "initialConditions.json" path
PATH_initialConditions = '../../configs/initialConditions.json';
% "geneticAlgorithm.json" path
PATH_geneticAlgorithm = '../../configs/geneticAlgorithm.json';
% "defaultValues.json" path
PATH_defaultValues = '../../configs/defaultValues.json';

%% Load config files as structure
appliancesData = loadJSONFile(PATH_applianceData);
residentalTypes = loadJSONFile(PATH_residentalTypes);
initialConditions = loadJSONFile(PATH_initialConditions);
geneticAlgorithm = loadJSONFile(PATH_geneticAlgorithm);
defaultValues = loadJSONFile(PATH_defaultValues);
