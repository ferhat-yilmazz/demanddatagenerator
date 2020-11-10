clear,clc
addpath("./lib/dataGenerator/");
% Add path of TRNG function
addpath('./lib/trueRandom/');
tic

% Load configurations
loadConfigurations;
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
% Assign 0 to -1 filled samples
endUsers = zero2minusOne(endUsers);
% Build <mainUsageStructure>
mainUsageStructure = buildMainUsageStructure(endUsers);

toc

%% Clear Unnecessary variables
clear PATH_applianceData PATH_residentalTypes PATH_electricVehicles...
			PATH_defaultCoefficients PATH_initialConditions msg
		
%% Clear Global Variables
clear global COUNT_END_USERS global COUNT_SAMPLE_IN_DAY global COUNT_WEEKS...
	global SAMPLE_PERIOD global TRY_LIMIT global RAND_METHOD global DAY_PIECE...
	global BATTERY_LEVEL_RAND_LIMIT global GLOB_MAX_OPERATION_LIMIT
