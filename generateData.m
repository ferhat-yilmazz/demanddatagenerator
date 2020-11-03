clear,clc
addpath("./lib/dataGenerator/");
% Add path of TRNG function
	addpath('./lib/trueRandom/');
tic
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

% Load global variables
globalVariables;

% Generate structure for end-users
endUsers = struct('type', [], 'properties', [], 'appliances', [], 'ev', []);
% Assign types to end-users
endUsers = assignType2endUsers(residentalTypes, endUsers);
% Assign appliances to end-users
endUsers = assignAppliances2endUsers(appliancesData, electricVehicles, endUsers);
% Check for work time constraints
endUsers = check_workTimeConstraints(endUsers, appliancesData);
% Assign worktimes and power values
endUsers = assignWorktimes2appliances(endUsers, appliancesData, initialConditions);

toc

%% Clear Unnecessary variables
clear PATH_applianceData PATH_residentalTypes PATH_electricVehicles...
			PATH_defaultCoefficients PATH_initialConditions msg
		
%% Clear Global Variables
%clear global COUNT_END_USERS global COUNT_SAMPLE_IN_DAY global COUNT_WEEKS...
%	global SAMPLE_PERIOD global TRY_LIMIT global RAND_METHOD global DAY_PIECE
