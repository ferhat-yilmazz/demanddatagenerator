 %% بسم الله الرحمن الرحیم 

%% ## Assign Worktime for Periodic & Non-Continuous Appliances ##
% 18.10.2020, Ferhat Yılmaz

%% Description
%{
  Function to assign worktime for the given periodic and non-continuous appliances.
  Run probability determination is not covered here. If there is any conflicted
  appliance or electric vehicle along a cycle (run duration + wait duration),
  then the appliance cannot work ONLY at the cycle. Similarly, over run
  (run multiple times on same sample) will not be allowed.
  In these situations the function returns without any process.

>> Inputs:
  1. <baseStructure> : structure : Base structure
  2. <applianceStructure> : struct : Structure of the appliance
  3. <dayIndex> : integer : Day index
  4. <startSample> : integer : Sample which the apliance starts run
  5. <operationDuration> : integer : Duration of operation of the appliance
  5. <COUNT_WEEKS> : integer : Count of weeks
  6. <COUNT_SAMPLE_IN_DAY> : integer : Sample count in a day
  
<< Outputs:
  1. <applianceStructure> : struct : Structure of the appliance

%}

%%
function applianceStructure = worktime_periodic_nonContinous(baseStructure, applianceStructure, dayIndex, startSample, operationDuration,...
                                                              COUNT_WEEKS, COUNT_SAMPLE_IN_DAY)
  % Get <applianceID>
  applianceID = applianceStructure.applianceID;
  
  % Merge the usage array ans assign it to <mergedUsageArray>
  mergedUsageArray = reshape(transpose(applianceStructure.usageArray), 1, COUNT_WEEKS*7*COUNT_SAMPLE_IN_DAY);
  totalSampleCount = COUNT_WEEKS * 7 * COUNT_SAMPLE_IN_DAY;
  
  % Define a bit, for a check the appliance run or not
  runBit = false;
  
  % Get requested power of the appliance
  % Determine sign of the power value according to type of the appliance:
  %    * Type - 1 : Producer (-)
  %    * Type - 0 : Consumer (+)
  if baseStructure.appliances(applianceID).type
    requestedPower = -chooseValue(baseStructure.appliances(applianceID).power.value, baseStructure.appliances(applianceID).power.format);
  else
    requestedPower = chooseValue(baseStructure.appliances(applianceID).power.value, baseStructure.appliances(applianceID).power.format);
  end
  
  % Get <runDuration> and <waitDuration> of the appliance
  runDuration = baseStructure.appliances(applianceID).operation.runDuration;
  waitDuration = baseStructure.appliances(applianceID).operation.waitDuration;
  % Determine <startPointer>, <endPointer>, and <cycleEnd>
  startPointer = ((dayIndex-1)*COUNT_SAMPLE_IN_DAY) + startSample;
  endPointer = startPointer + runDuration - 1;
  cycleEnd = startPointer + runDuration + waitDuration - 1;
  
  % Assign worktime
  while operationDuration > 0
    % Check for out of index
    if endPointer > totalSampleCount
      endPointer = totalSampleCount;
      cycleEnd = totalSampleCount;
      operationDuration = 0;
    elseif cycleEnd > totalSampleCount
      cycleEnd = totalSampleCount;
      operationDuration = 0;
    end
    
    % Assign worktime
    if all(mergedUsageArray(startPointer:cycleEnd) == 0)
      mergedUsageArray(startPointer:endPointer) = requestedPower;
      % So, the appliance must non operational on <waitDuration> sample
      mergedUsageArray(endPointer+1:cycleEnd) = single(-2);
      % Increase <tuc> total usage counter
      applianceStructure.tuc = applianceStructure.tuc + single(numel(startPointer:cycleEnd));
      % Enable <runBit>
      runBit = true;
    end
    
    % Decrease <operationDuration>
    operationDuration = operationDuration - numel(startPointer:cycleEnd);
    
    % Determine new start/end pointers
    startPointer = cycleEnd + 1;
    endPointer = startPointer + runDuration - 1;
    cycleEnd = startPointer + runDuration + waitDuration - 1;
  end
  
  if runBit
    applianceStructure.duc = applianceStructure.duc + single(1);
    applianceStructure.wuc = applianceStructure.wuc + single(1);
  end
  
  % Reshap <mergedUsageArray> and assign it to <evUsageArray>
  applianceStructure.usageArray = transpose(reshape(mergedUsageArray, COUNT_SAMPLE_IN_DAY, COUNT_WEEKS*7));
end
