 %% بسم الله الرحمن الرحیم 

%% ## Build Main End-Users Structure ##
% 10.12.2020, Ferhat Yılmaz

%% Description
%{
  Function to build main "users" structure. In addition, usage arrays of aapliances
  are generated for a week. Constraint are also considered, except confliction
  constraints.

  >> Inputs:
  1. <appliancesData> : structure : "appliancesData.json" configuration file
  2. <residentalTypes> : structure : "residentalTypes.json" configuration file
  3. <default_weeklyRunInReal> : structure : Default value for real usage in a week
  4. <SAMPLE_PERIOD> : integer : Sample period in minutes
  5. <COUNT_SAMPLE_IN_DAY> : integer : Sample count in a day
  6. <COUNT_WEEKS> : integer : Count of weeks

<< Outputs:
  1. <endUsersStruct> : structure : Main end-users structure
%}

%%
function endUsersStruct = buildEndUsersStruct(appliancesData,...
                                              residentalTypes,...
                                              default_weeklyRunInReal,...
                                              SAMPLE_PERIOD,...
                                              COUNT_SAMPLE_IN_DAY,...
                                              COUNT_WEEKS)
  % Get names of end-users types
  types = transpose(fieldnames(residentalTypes));
  % Get name of appliances
  appliances = transpose(fieldnames(appliancesData));
  
  % Define <endUsersStruct>
  endUsersStruct = struct('type', '',...
                          'employedCount', single(0),...
                          'nonemployedCount', single(0),...
                          'jobSchedule', struct(),...
                          'appliances', struct('name', '',...
                                               'usageArray', [],...
                                               'operation', struct(),...
                                               'weeklyRunInReal', struct(),...
                                               'needOperator', false));
  
  % For each end-user type, assign appliances (except never owned appliances),
  % define usage arrays and consider constraints (fill related samples by FALSE)
  for t_idx = 1:numel(types)
    % Assign type of the endUser
    endUsersStruct(t_idx).type = string(types(t_idx));
    % Assign employed and nonemployed counts for the kinf of end-user
    endUsersStruct(t_idx).employedCount = single(residentalTypes.(string(types(t_idx))).employedCount);
    endUsersStruct(t_idx).nonemployedCount = single(residentalTypes.(string(types(t_idx))).nonemployedCount);
    % Assign job schedule if there is
    if residentalTypes.(string(types(t_idx))).jobSchedule.case
      endUsersStruct(t_idx).jobSchedule.case = true;
      endUsersStruct(t_idx).jobSchedule.workDays = uint16(residentalTypes.(string(types(t_idx))).jobSchedule.workDays);
      endUsersStruct(t_idx).jobSchedule.lowerSample =...
                                  duration2sample(timeVector2duration(residentalTypes.(string(types(t_idx))).jobSchedule.lowerTime,...
                                                                      '24h',...
                                                                      SAMPLE_PERIOD),...
                                                  '24h',...
                                                  SAMPLE_PERIOD);
      endUsersStruct(t_idx).jobSchedule.upperSample =...
                                  duration2sample(timeVector2duration(residentalTypes.(string(types(t_idx))).jobSchedule.upperTime,...
                                                                      '24h',...
                                                                      SAMPLE_PERIOD),...
                                                  '24h',...
                                                  SAMPLE_PERIOD);
    else
      endUsersStruct(t_idx).jobSchedule.case = false;
    end
    
    % Assign appliances and their constraints such that:
    %    * Never owned appliances never will be assigned
    %    * Appliance worktime constraint
    %    * End-user type worktime constraint(s)
    %    * End-user type sleep time constraint (for appliances which need operator to run)
    for a_idx = 1:numel(appliances)
      % Continue if the appliance is in the never owned appliances list for the end-user type
      % OR an appliance is "periodic" and "continuous" run mode
      if ismember(appliances(a_idx), residentalTypes.(string(types(t_idx))).neverAppliances)...
                                                                        || logical(appliancesData.(string(appliances(a_idx))).operation.continuity)
        continue;
      end
      
      % Assign name of the appliance
      endUsersStruct(t_idx).appliances(a_idx).name = string(appliances(a_idx));
      % Assign usage array for the appliance as count of weeks
      endUsersStruct(t_idx).appliances(a_idx).usageArray = true(COUNT_WEEKS*7, COUNT_SAMPLE_IN_DAY);
      % Assign operation information of the appliance
      endUsersStruct(t_idx).appliances(a_idx).operation = appliancesData.(string(appliances(a_idx))).operation;
      % Assign information of  weekly run in real life
      % If there is no data for real usage in a week, then assign default usage values
      if appliancesData.(string(appliances(a_idx))).weeklyRunInReal.case
        endUsersStruct(t_idx).appliances(a_idx).weeklyRunInReal = appliancesData.(string(appliances(a_idx))).weeklyRunInReal;
      else
        endUsersStruct(t_idx).appliances(a_idx).weeklyRunInReal = default_weeklyRunInReal;
      end
      % Assing information that the appliance need operator or not to run
      endUsersStruct(t_idx).appliances(a_idx).needOperator = appliancesData.(string(appliances(a_idx))).needOperator;
      
      % Consider constraints
      %    1. Appliance worktime constraint
      if appliancesData.(string(appliances(a_idx))).constraints.workTimeConstraint.case
        c1_lowerDuration = timeVector2duration(appliancesData.(string(appliances(a_idx))).constraints.workTimeConstraint.lowerTime,...
                                               '24h',...
                                               SAMPLE_PERIOD);
        c1_upperDuration = timeVector2duration(appliancesData.(string(appliances(a_idx))).constraints.workTimeConstraint.upperTime,...
                                               '24h',...
                                               SAMPLE_PERIOD);
        endUsersStruct(t_idx).appliances(a_idx).usageArray(:, ~logicalInterval(c1_lowerDuration,...
                                                                               c1_upperDuration,...
                                                                               SAMPLE_PERIOD,...
                                                                               COUNT_SAMPLE_IN_DAY)) = false;
      end
      %    2. End-user type worktime constraint(s)
      if residentalTypes.(string(types(t_idx))).constraints.constraintsCount > 0
        for constraint_index = 1:residentalTypes.(string(types(t_idx))).constraints.constraintsCount
          constraint_id = strcat('c_', string(constraint_index));
          if ismember(appliances(a_idx), residentalTypes.(string(types(t_idx))).constraints.(constraint_id).appliancesList)
            constraintDays = transpose(uint8(residentalTypes.(string(types(t_idx))).constraints.(constraint_id).days));
            c2_lowerDuration = timeVector2duration(residentalTypes.(string(types(t_idx))).constraints.(constraint_id).lowerTime,...
                                                   '24h',...
                                                   SAMPLE_PERIOD);
            c2_upperDuration = timeVector2duration(residentalTypes.(string(types(t_idx))).constraints.(constraint_id).upperTime,...
                                                   '24h',...
                                                   SAMPLE_PERIOD);
            endUsersStruct(t_idx).appliances(a_idx)...
                                      .usageArray(constraintDays,~logicalInterval(c2_lowerDuration,...
                                                                                  c2_upperDuration,...
                                                                                  SAMPLE_PERIOD,...
                                                                                  COUNT_SAMPLE_IN_DAY)) = false;
          end
        end
      end
      %    3. End-user type sleep time constraint
      if residentalTypes.(string(types(t_idx))).sleepTime.case
        if appliancesData.(string(appliances(a_idx))).needOperator
          c3_lowerDuration = timeVector2duration(residentalTypes.(string(types(t_idx))).sleepTime.lowerTime,...
                                                 '24h',...
                                                 SAMPLE_PERIOD);
          c3_upperDuration = timeVector2duration(residentalTypes.(string(types(t_idx))).sleepTime.upperTime,...
                                                 '24h',...
                                                 SAMPLE_PERIOD);
          endUsersStruct(t_idx).appliances(a_idx).usageArray(:, logicalInterval(c3_lowerDuration,...
                                                                                c3_upperDuration,...
                                                                                SAMPLE_PERIOD,...
                                                                                COUNT_SAMPLE_IN_DAY)) = false;
        end
      end
    end
    
    % Check for empty appliances rows
    emptyRows = [];
    for appliance_row = 1:size(endUsersStruct(t_idx).appliances, 2)
      if isempty(endUsersStruct(t_idx).appliances(appliance_row).name)
        emptyRows = [emptyRows, appliance_row];
      end
    end
    % Clear empty rows
    endUsersStruct(t_idx).appliances(emptyRows) = [];
  end
end
