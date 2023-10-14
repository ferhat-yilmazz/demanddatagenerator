 %% بسم الله الرحمن الرحیم 

%% ## Determine Run Probability ##
% 27.01.2021, Ferhat Yılmaz

%% Description
%{
  Function to determine run probability of the apliance.

>> Inputs:
  1. <endUserID> : integer : ID of the end-user
  2. <baseStructure> : structure : Base structure
  3. <applianceStructure> : structure : Structure of the object
  4. <dayNumber> : integer : Number of day [1,7]
  5. <runProbabilityParameters> : structure : Run probability parameters acquired from real usage
                                              values
  6. <defaultParameters> : structure :  Default run probability parameters
  7. <startSample> : integer : Selected start sample

<< Outputs:
  1. <runProbability> : integer : Probability of working of appliance
%}

%%
function runProbability = determineRunProbability(endUserID, baseStructure, applianceStructure, runProbabilityParameters,...
                                                  defaultParameters, dayNumber, startSample)
  
  % Get ID of the appliance
  applianceID = applianceStructure.applianceID;
  % Get name of the appliance
  applianceName = baseStructure.appliances(applianceID).name;
  % Get type of the end-user
  endUserType = baseStructure.endUserTypes(endUserID).type;
  
  % Check for sleep-time issue: If the appliance start sample in located at
  % sleep time and the appliance needs an operator to run, then return
  % <runProbability as zero>
  if baseStructure.appliances(applianceID).needOperator
    if baseStructure.endUserTypes(endUserID).sleepTime.case
      if isInInterval(startSample, baseStructure.endUserTypes(endUserID).sleepTime.lowerSample,...
                                   baseStructure.endUserTypes(endUserID).sleepTime.upperSample)
        runProbability = 0;
        return;
      end
    end
  end
  
  % Get run probability parameters
  try
    % User Type Parameter
    userTypeParameter = runProbabilityParameters.(endUserType).(applianceName).userTypeParameter;
    % Daily Usage Parameter
    dailyUsageParameter = runProbabilityParameters.(endUserType).(applianceName).dailyUsageParameter;
    % Weekly Usage Parameter
    weeklyUsageParameter = runProbabilityParameters.(endUserType).(applianceName).weeklyUsageParameter;
  catch ME
    if strcmp(ME.identifier, 'MATLAB:nonExistendtField')
      warning(strcat("<determineRunProbability> : Parameters for <", endUserType, ":", applianceName,...
                     "> not found. Default parameters will be used"));             
    % User Type Parameter
    userTypeParameter = defaultParameters.userTypeParameter;
    % Daily Usage Parameter
    dailyUsageParameter = defaultParameters.dailyUsageParameter;
    % Weekly Usage Parameter
    weeklyUsageParameter = defaultParameters.weeklyUsageParameter;
    
    else
      error(strcat(ME.identifier, " »» ", ME.message));
    end
  end
  
  %{
            ###############################################
            ########## DETERMINE RUN PROBABILITY ##########

                                                  Apliance Needs Operator
                                            _________________|_________________
                                            |                                  |
                                      (TRUE)|                                  |(FALSE)
                                            |                                  |
                                End-User Have Job Schedule                 # E+N #
                                  __________|__________                    
                                  |                    |
                            (TRUE)|                    |(FALSE)
                                  |                    |
                            Start Time Located     # E+N #
                              in Job Times                        
                            ______|______                                ** E: Employed count           
                            |            |                                ** N: Nonemployed count
                      (TRUE)|            |(FALSE)
                            |            |                  
                          # N #      # E+N #

  %}
  % Condition for that the appliance need opertor or not
  cond1 = baseStructure.appliances(applianceID).needOperator;
  % Condition for that the end-user have job schedule or not
  cond2 = baseStructure.endUserTypes(endUserID).jobSchedule.case;
  % If the end-user have job schedule,
  % condition for the selected sample is in job times or not
  if cond2
    cond3 = ismember(dayNumber, baseStructure.endUserTypes(endUserID).jobSchedule.workDays) &&...
            isInInterval(startSample, baseStructure.endUserTypes(endUserID).jobSchedule.lowerSample,...
            baseStructure.endUserTypes(endUserID).jobSchedule.upperSample);
  else
    cond3 = false;
  end
  
  % Determine run probability according to <cond1>, <cond2> and <cond3>
  if cond1 && cond2 && cond3
    runProbability = (baseStructure.endUserTypes(endUserID).nonemployedCount * userTypeParameter)...
                     - (applianceStructure.duc * dailyUsageParameter) - (applianceStructure.wuc * weeklyUsageParameter);
  else
    runProbability = ((baseStructure.endUserTypes(endUserID).nonemployedCount...
                       + baseStructure.endUserTypes(endUserID).employedCount) * userTypeParameter)...
                     - (applianceStructure.duc * dailyUsageParameter) - (applianceStructure.wuc * weeklyUsageParameter);
  end
end
