 %% بسم الله الرحمن الرحیم 

%% ## Assign Worktime for Periodic & Continuous Appliances ##
% 15.10.2020, Ferhat Yılmaz

%% Description
%{
  Function to assign worktime for the given periodic and continous appliance.
  These appliances run all day with given wait/run durations periodically.
  There is no need run probability check.

>> Inputs:
  1. <baseStructure> : structure : Base structure
  2. <applianceStructure> : struct : Structure of the appliance
  3. <dayIndex> : integer : Day index
  4. <COUNT_WEEKS> : integer : Count of weeks
  5. <COUNT_SAMPLE_IN_DAY> : integer : Sample count in a day
  
<< Outputs:
  1. <applianceStructure> : struct : Structure of the appliance

%}

%%
function applianceStructure = worktime_periodic_continuous(baseStructure, applianceStructure, dayIndex, COUNT_WEEKS, COUNT_SAMPLE_IN_DAY)
  % Get <applianceID>
  applianceID = applianceStructure.applianceID;
  
  % Merge the usage array ans assign it to <mergedUsageArray>
  mergedUsageArray = reshape(transpose(applianceStructure.usageArray), 1, COUNT_WEEKS*7*COUNT_SAMPLE_IN_DAY);
  cloneMergedUsageArray = mergedUsageArray;
  totalSampleCount = COUNT_WEEKS * 7 * COUNT_SAMPLE_IN_DAY;
  
  % Get requested power of the appliance
  requestedPower = chooseValue(baseStructure.appliances(applianceID).power.value, baseStructure.appliances(applianceID).power.format);  
  
  % Get <runDuration>, <waitDuration>, and <cycleDuration>
  runDuration = baseStructure.appliances(applianceID).operation.runDuration;
  waitDuration = baseStructure.appliances(applianceID).operation.waitDuration;
  cycleDuration = runDuration + waitDuration;
  
  % Determine <startPointer> & <endPointer>
  startPointer = 1;
  endPointer = startPointer + runDuration - 1;
  cycleEnd = startPointer + runDuration + waitDuration - 1;
  
  % Determine how many cycle assigned and how many sample remained
  remainedSamples = mod(totalSampleCount, cycleDuration);
  totalCycleCount = (totalSampleCount-remainedSamples) / cycleDuration;
  
  for cycleNo = 1:totalCycleCount
    % If there is no confliction, assign worktime
    if all(cloneMergedUsageArray(startPointer:cycleEnd) == 0)
      cloneMergedUsageArray(startPointer:endPointer) = requestedPower;
    end
    % Go step for other cycle
    startPointer = cycleEnd + 1;
    endPointer = startPointer + runDuration - 1;
    cycleEnd = startPointer + runDuration + waitDuration - 1;
  end
  
  % Remained samples
  startPointer = totalSampleCount - remainedSamples + 1;
  if all(cloneMergedUsageArray(startPointer:end) == 0)
    if remainedSamples <= runDuration
      cloneMergedUsageArray(startPointer:end) = requestedPower;
    else
      cloneMergedUsageArray(startPointer:(startPointer + runDuration - 1)) = requestedPower;
    end
  end
  
  % Assign specified part of <cloneMergedUsageArray> to <mergedUsageArray>
  lowSample = (dayIndex-1)*COUNT_SAMPLE_IN_DAY + 1;
  upSample = (dayIndex)*COUNT_SAMPLE_IN_DAY;
  
  mergedUsageArray(lowSample:upSample) = cloneMergedUsageArray(lowSample:upSample);
  
  % Reshap <mergedUsageArray> and assign it to <evUsageArray>
  applianceStructure.usageArray = transpose(reshape(mergedUsageArray, COUNT_SAMPLE_IN_DAY, COUNT_WEEKS*7));
end
