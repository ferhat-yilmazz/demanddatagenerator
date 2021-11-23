%% Load required configurations
% "appliancesData.json" path
PATH_applianceData = strcat('..', filesep, '..', filesep, 'configs', filesep, 'appliancesData.json');
% "residentalTypes.json" path
PATH_residentalTypes = strcat('..', filesep, '..', filesep, 'configs', filesep, 'residentalTypes.json');
% "defaultCoefficients.json" path
PATH_defaultValues = strcat('..', filesep, '..', filesep, 'configs', filesep, 'defaultValues.json');
% "initialCOnditions.json" path
PATH_initialConditions = strcat('..', filesep, '..', filesep, 'configs', filesep, 'initialConditions.json');

appliancesData = loadJSONFile(PATH_applianceData);
residentalTypes = loadJSONFile(PATH_residentalTypes);
defaultValues = loadJSONFile(PATH_defaultValues);
initialConditions = loadJSONFile(PATH_initialConditions);

%% Define read-only variables
SAMPLE_PERIOD = minutes(timeVector2duration(initialConditions.samplePeriod, 0, '24h'));
% !!! Load generated data !!!
processData = endUsers_2k;

%% Proof
% Residental types
residentalTypeNames = fieldnames(residentalTypes);
% Appliance names
applianceNames = fieldnames(appliancesData);

% Initialize result structure
% resultStruct = struct("type", "",...
%                      "appliance", "",...
%                      "realWeeklyUsage", uint16(0),...
%                      "generatedWeeklyUSage", uint16(0),...
%                      "errorPercentage", single(0));

resultStruct_idx = 1;

% For each residental type
for residentalType_idx = 1:numel(residentalTypeNames)
  % Never owned appliance list of the residental type
  neverOwnedAppliances = residentalTypes.(string(residentalTypeNames(residentalType_idx))).neverAppliances;
  
  % For each non-continuous appliance and not belong never appliances
  for appliance_idx = 1:numel(applianceNames)
    if (appliancesData.(string(applianceNames(appliance_idx))).operation.continuity == 0) &&...
        ~(sum(strcmpi(neverOwnedAppliances, applianceNames(appliance_idx))))
      tucData = dataFilter(processData, residentalType_idx, string(applianceNames(appliance_idx)));
      
      % Check for the appliance has a weekly usage statistic; if not assign default values
      if appliancesData.(string(applianceNames(appliance_idx))).weeklyRunInReal.case
        errorArray = errorPercent(appliancesData.(string(applianceNames(appliance_idx))).weeklyRunInReal,...
                                  residentalTypes.(string(residentalTypeNames(residentalType_idx))),...
                                  tucData, SAMPLE_PERIOD);
      else
        errorArray = errorPercent(defaultValues.weeklyRunInReal,...
                                  residentalTypes.(string(residentalTypeNames(residentalType_idx))),...
                                  tucData, SAMPLE_PERIOD);
      end
      
      % Add result to <resultStruct>
      resultStruct(resultStruct_idx) = struct("type", string(residentalTypeNames(residentalType_idx)),...
                                   "appliance", string(applianceNames(appliance_idx)),...
                                   "realWeeklyUsage", errorArray(1),...
                                   "generatedWeeklyUSage", errorArray(2),...
                                   "errorPercentage", errorArray(3));
      resultStruct_idx = resultStruct_idx + 1;
    end
  end
end

%% Clear unnecessary variables
% clear PATH_applianceData PATH_residentalTypes PATH_defaultValues PATH_initialConditions appliancesData residentalTypes...
%       defaultValues initialConditions SAMPLE_PERIOD residentalTypeNames applianceNames residentalType_idx appliance_idx...
%       tucData errorArray
