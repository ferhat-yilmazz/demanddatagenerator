 %% بسم الله الرحمن الرحیم 

%% ## Assign Worktime for Non-Periodic Appliances ##
% 24.01.2021, Ferhat Yılmaz

%% Description
%{
  Function to assign worktime for the given non-periodic appliance. Run
  probability determination is not covered here. If there is any conflicted
  appliance or electric vehicle along working samples, then the appliance
  cannot work. Similarly, over run (run multiple times on same sample)
  will not be allowed. In these situations the function returns without
  any process.

>> Inputs:
  1. <baseStructure> : structure : Base structure
  2. <applianceStructure> : struct : Structure of the appliance
  3. <dayIndex> : integer : Day index
  4. <startSample> : integer : Sample which the apliance starts run
  5. <COUNT_WEEKS> : integer : Count of weeks
  6. <COUNT_SAMPLE_IN_DAY> : integer : Sample count in a day
  
<< Outputs:
  1. <applianceStructure> : struct : Structure of the appliance

%}

%%
function applianceStructure = worktime_nonPeriodic(baseStructure, applianceStructure, dayIndex, startSample, COUNT_WEEKS, COUNT_SAMPLE_IN_DAY)
  % Get <applianceID>
  applianceID = applianceStructure.applianceID;
  
  % Merge the usage array ans assign it to <mergedUsageArray>
  mergedUsageArray = reshape(transpose(applianceStructure.usageArray), 1, COUNT_WEEKS*7*COUNT_SAMPLE_IN_DAY);
  
  % Get requested power of the appliance
  % Determine sign of the power value according to type of the appliance:
  %    * Type - 1 : Producer (-)
  %    * Type - 0 : Consumer (+)
  if baseStructure.appliances(applianceID).type
    requestedPower = -chooseValue(baseStructure.appliances(applianceID).power.value, baseStructure.appliances(applianceID).power.format);
  else
    requestedPower = chooseValue(baseStructure.appliances(applianceID).power.value, baseStructure.appliances(applianceID).power.format);
  end
  
  % Get run duration of the appliance
  operationDuration = baseStructure.appliances(applianceID).operation.runDuration;
  
  % Determine <startPointer> and <endPointer>
  startPointer = (dayIndex - 1)*COUNT_SAMPLE_IN_DAY + startSample;
  endPointer = startPointer + operationDuration - 1;
  
  % Check for <endPointer> is not out of index
  if endPointer > numel(mergedUsageArray)
    endPointer = numel(mergedUsageArray);
  end
  
  % Assign work time if confliction and overrun issues are valid
  if all(mergedUsageArray(startPointer:endPointer) == 0)
    mergedUsageArray(startPointer:endPointer) = requestedPower;
    % Increase usage counters <duc>, <wuc> and <tuc>
    applianceStructure.duc = applianceStructure.duc + 1;
    applianceStructure.wuc = applianceStructure.wuc + 1;
    applianceStructure.tuc = applianceStructure.tuc + operationDuration;
  end
  
  % Reshap <mergedUsageArray> and assign it to <evUsageArray>
  applianceStructure.usageArray = transpose(reshape(mergedUsageArray, COUNT_SAMPLE_IN_DAY, COUNT_WEEKS*7));
end
