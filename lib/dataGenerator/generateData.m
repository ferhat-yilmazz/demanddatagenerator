tic
% Add path of TRNG function
addpath(strcat('..', filesep, 'trueRandom', filesep));

% Load configurations
loadConfigurations;
% Load global variables
readOnlyVariables;

% Build <baseStructure>
baseStructure = buildBaseStructure(appliancesData, residentalTypes, electricVehicles, SAMPLE_PERIOD, GLOB_MAX_OPERATION_LIMIT);

% Define <endUsers> structure
endUsers = struct('typeID', uint8(0),...
                  'appliances', struct('applianceID', uint8(0),...
                                       'applianceName', '',...
                                       'duc', single(0),...
                                       'wuc', single(0),...
                                       'tuc', single(0),...
                                       'usageArray', single([])),...
                  'EVs', struct('evID', uint8(0),...
                               'evName', '',...
                               'usageArray', single([])),...
                  'totalUsage', single([]));
% Assign types to end-users
endUsers = assignType2endUsers(endUsers, baseStructure, COUNT_END_USERS, RAND_METHOD);
% endUsers = assignType2endUsers_special(endUsers, baseStructure, 2000);
% Assign appliances to end-users
endUsers = assignAppliances2endUsers(endUsers, baseStructure, COUNT_SAMPLE_IN_DAY, COUNT_END_USERS, COUNT_DAYS, RAND_METHOD);
% Check for work time constraints
endUsers = check_workTimeConstraints(endUsers, baseStructure, COUNT_SAMPLE_IN_DAY, COUNT_END_USERS, COUNT_WEEKS, COUNT_DAYS);
% Assign worktimes and power values
endUsers = assignWorktimes2appliances(endUsers, baseStructure,runProbabilityParameters, defaultCoefficients, SAMPLE_PERIOD,...
                                      COUNT_SAMPLE_IN_DAY, COUNT_END_USERS, COUNT_WEEKS, DAY_PIECE);
% Assign 0 to non-positive values in usage arrays
endUsers = eliminateNegatives(endUsers, COUNT_END_USERS);
% Totalize usage arrays for each end-user
endUsers = totalizeUsageArrays(endUsers, baseStructure, COUNT_END_USERS, COUNT_WEEKS, COUNT_SAMPLE_IN_DAY);


%% Clear Unnecessary Variables
clear PATH_applianceData PATH_residentalTypes PATH_electricVehicles PATH_defaultCoefficients PATH_initialConditions...
      PATH_runProbabilityParameters runProbabilityParametersFileNames runProbabilityParametersFiles...
      SAMPLE_PERIOD RAND_METHOD msg GLOB_MAX_OPERATION_LIMIT file_idx DAY_PIECE COUNT_WEEKS...
      COUNT_SAMPLE_IN_DAY COUNT_END_USERS COUNT_DAYS
toc
