 %% بسم الله الرحمن الرحیم 

%% ## Load Configuration Files ##
% 09.11.2020, Ferhat Yılmaz

%% Description
%{
	Script to load configuration files. Paths are also defined in
	this script.
%}

%% Define PATH variables
% "appliancesData.json" path
PATH_applianceData = './configs/appliancesData.json';
% "residentalTypes.json" path
PATH_residentalTypes = './configs/residentalTypes.json';
% "electricVehicles.json" path
PATH_electricVehicles = './configs/electricVehicles.json';
% "defaultCoefficients.json" path
PATH_defaultCoefficients = './configs/defaultCoefficients.json';
% "initialCOnditions.json" path
PATH_initialConditions = './configs/initialConditions.json';

%% Load config files as structure
appliancesData = loadJSONFile(PATH_applianceData);
residentalTypes = loadJSONFile(PATH_residentalTypes);
electricVehicles = loadJSONFile(PATH_electricVehicles);
defaultCoefficients = loadJSONFile(PATH_defaultCoefficients);
initialConditions = loadJSONFile(PATH_initialConditions);
