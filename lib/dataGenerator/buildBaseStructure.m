 %% بسم الله الرحمن الرحیم 

%% ## Build Base Structure ##
% 13.01.2021, Ferhat Yılmaz

%% Description
%{
  Function to build base structure. It contains 3 structures:
    1. End-user types
    2. Appliances
    3. Electric vehicles

  Working principle is similar to RDMS (Relational Database Management System)

>> Inputs:
  1. <applianceData> : structure : "appliancesData.json" configuration file structure
  2. <residentalTypes> : structure : "residentalTypes.json" configuration file structure
  3. <electricVehicles> : structure : "electricVehicles.json" configuration file structure
  4. <SAMPLE_PERIOD> : integer : Sample period in minutes
  5. <GLOB_MAX_OPERATION_LIMIT> : integer : Global operation limit (in sample) for periodic
                                            and non-continuous appliances
  

<< Outputs:
  1. <baseStructure> : structure : Generated base structure
%}

%%
function baseStructure = buildBaseStructure(appliancesData, residentalTypes, electricVehicles,...
                                             SAMPLE_PERIOD, GLOB_MAX_OPERATION_LIMIT)
  % Define <baseStructure>
  baseStructure = struct('endUserTypes', struct('type', '',...
                                                'employedCount', single(0),...
                                                'nonemployedCount', single(0),...
                                                'alwaysAppliances', uint8([]),...
                                                'haveEV', uint8(0),...
                                                'neverAppliances', uint8([]),...
                                                'jobSchedule', struct(),...
                                                'constraints', struct(),...
                                                'sleepTime', struct()),...
                         'appliances', struct('name', '',...
                                              'type', uint8(0),...
                                              'needOperator', true,...
                                              'power', struct(),...
                                              'operation', struct(),...
                                              'dependency', struct(),...
                                              'workTimeConstraint', struct(),...
                                              'applianceConflictionConstraint', struct(),...
                                              'evConflictionConstraint', struct()),...
                         'electricVehicles', struct('name', '',...
                                                    'batteryCapacity', single(0),...
                                                    'charger', struct(),...
                                                    'chargeLevelPercentage', struct()));

  % ## APPLIANCES ##
  % Get name of appliances
  appliancesList = string(fieldnames(appliancesData));
  % Get name of electric vehicles
  evsList = string(fieldnames(electricVehicles));
  
  % For each appliance
  for appliance_idx = 1:numel(appliancesList)
    applianceName = appliancesList(appliance_idx);
    % Assign properties of the appliance
    % Name
    baseStructure.appliances(appliance_idx).name = applianceName;
    % Appliance type
    baseStructure.appliances(appliance_idx).type = uint8(appliancesData.(applianceName).type);
    % Need operator
    baseStructure.appliances(appliance_idx).needOperator = logical(appliancesData.(applianceName).needOperator);
    % Power
    baseStructure.appliances(appliance_idx).power.format = appliancesData.(applianceName).power.format;
    baseStructure.appliances(appliance_idx).power.value = appliancesData.(applianceName).power.value;
    % Operation
    baseStructure.appliances(appliance_idx).operation.periodicity = strcmp(appliancesData.(applianceName).operation.mode, 'periodic');
    if baseStructure.appliances(appliance_idx).operation.periodicity
      baseStructure.appliances(appliance_idx).operation.continuity = logical(appliancesData.(applianceName).operation.continuity);
      baseStructure.appliances(appliance_idx).operation.runDuration =...
                                          duration2sample(timeVector2duration(appliancesData.(applianceName).operation.runDuration, SAMPLE_PERIOD, 'inf'), SAMPLE_PERIOD, 'inf');
      baseStructure.appliances(appliance_idx).operation.waitDuration =...
                                          duration2sample(timeVector2duration(appliancesData.(applianceName).operation.waitDuration, SAMPLE_PERIOD, 'inf'), SAMPLE_PERIOD, 'inf');
      if ~baseStructure.appliances(appliance_idx).operation.continuity  
        baseStructure.appliances(appliance_idx).operation.maxOperationLimit =...
                                    duration2sample(timeVector2duration(appliancesData.(applianceName).operation.maxOperationLimit, SAMPLE_PERIOD, 'inf'), SAMPLE_PERIOD, 'inf');
        if baseStructure.appliances(appliance_idx).operation.maxOperationLimit <...
                    (baseStructure.appliances(appliance_idx).operation.runDuration + baseStructure.appliances(appliance_idx).operation.waitDuration)
          baseStructure.appliances(appliance_idx).operation.maxOperationLimit = GLOB_MAX_OPERATION_LIMIT;
        end
      end
    else
      baseStructure.appliances(appliance_idx).operation.continuity = false;
      baseStructure.appliances(appliance_idx).operation.runDuration =...
                                          duration2sample(timeVector2duration(appliancesData.(applianceName).operation.runDuration, SAMPLE_PERIOD, 'inf'), SAMPLE_PERIOD, 'inf');
    end
    % Dependency
    baseStructure.appliances(appliance_idx).dependency.case = logical(appliancesData.(applianceName).dependency.case);
    if baseStructure.appliances(appliance_idx).dependency.case
      baseStructure.appliances(appliance_idx).dependency.needAll = logical(appliancesData.(applianceName).dependency.needAll);
      dependencyList = string(appliancesData.(applianceName).dependency.list);
      ids = zeros(1,numel(dependencyList));
      for dependency_idx = 1:numel(dependencyList)
        ids(dependency_idx) = find(appliancesList == dependencyList(dependency_idx));
      end
      baseStructure.appliances(appliance_idx).dependency.list = uint8(ids);
    end
    % Worktime constraint
    baseStructure.appliances(appliance_idx).workTimeConstraint.case = logical(appliancesData.(applianceName).constraints.workTimeConstraint.case);
    if baseStructure.appliances(appliance_idx).workTimeConstraint.case
      baseStructure.appliances(appliance_idx).workTimeConstraint.lowerSample =...
                    duration2sample(timeVector2duration(appliancesData.(applianceName).constraints.workTimeConstraint.lowerTime, SAMPLE_PERIOD, '24h'), SAMPLE_PERIOD, '24h');
      baseStructure.appliances(appliance_idx).workTimeConstraint.upperSample =...
                    duration2sample(timeVector2duration(appliancesData.(applianceName).constraints.workTimeConstraint.upperTime, SAMPLE_PERIOD, '24h'), SAMPLE_PERIOD, '24h');
    end
    % Confliction constraint
    baseStructure.appliances(appliance_idx).applianceConflictionConstraint.case =...
                                                            logical(appliancesData.(applianceName).constraints.applianceConflictionConstraint.case);
    if baseStructure.appliances(appliance_idx).applianceConflictionConstraint.case
      conflictList = string(appliancesData.(applianceName).constraints.applianceConflictionConstraint.list);
      ids = zeros(1, numel(conflictList));
      for conflict_idx = 1:numel(conflictList)
        ids(conflict_idx) = find(appliancesList == conflictList(conflict_idx));
      end
      baseStructure.appliances(appliance_idx).applianceConflictionConstraint.list = uint8(ids);
    end
    
    baseStructure.appliances(appliance_idx).evConflictionConstraint.case =...
                                                            logical(appliancesData.(applianceName).constraints.evConflictionConstraint.case);
    if baseStructure.appliances(appliance_idx).evConflictionConstraint.case
      conflictList = string(appliancesData.(applianceName).constraints.evConflictionConstraint.list);
      ids = zeros(1, numel(conflictList));
      for conflict_idx = 1:numel(conflictList)
        ids(conflict_idx) = find(evsList == conflictList(conflict_idx));
      end
      baseStructure.appliances(appliance_idx).evConflictionConstraint.list = uint8(ids);
    end
  end
  
  % ## END-USERS ##
  % Get types of end-users
  endUserTypesList = string(fieldnames(residentalTypes));
  % For each type
  for endUserType_idx = 1:numel(endUserTypesList)
    endUserType = endUserTypesList(endUserType_idx);
    % Assign properties of the end-user type
    % Type
    baseStructure.endUserTypes(endUserType_idx).type = endUserType;
    % Employed & nonemployed count
    baseStructure.endUserTypes(endUserType_idx).employedCount = single(residentalTypes.(endUserType).employedCount);
    baseStructure.endUserTypes(endUserType_idx).nonemployedCount = single(residentalTypes.(endUserType).nonemployedCount);
    % Always appliances
    alwaysApplianceList = string(residentalTypes.(endUserType).alwaysAppliances);
    ids = zeros(1, numel(alwaysApplianceList));
    for alwaysAppliance_idx = 1:numel(alwaysApplianceList)
      ids(alwaysAppliance_idx) = find(appliancesList == alwaysApplianceList(alwaysAppliance_idx));
    end
    baseStructure.endUserTypes(endUserType_idx).alwaysAppliances = uint8(ids);
    % Never appliances
    neverApplianceList = string(residentalTypes.(endUserType).neverAppliances);
    ids = zeros(1, numel(neverApplianceList));
    for neverAppliance_idx = 1:numel(neverApplianceList)
      ids(neverAppliance_idx) = find(appliancesList == neverApplianceList(neverAppliance_idx));
    end
    baseStructure.endUserTypes(endUserType_idx).neverAppliances = uint8(ids);
    % Have electric vehicle
    baseStructure.endUserTypes(endUserType_idx).haveEV = uint8(residentalTypes.(endUserType).haveEV);
    % Job schedule
    baseStructure.endUserTypes(endUserType_idx).jobSchedule.case = logical(residentalTypes.(endUserType).jobSchedule.case);
    if baseStructure.endUserTypes(endUserType_idx).jobSchedule.case
      baseStructure.endUserTypes(endUserType_idx).jobSchedule.workDays = uint8(residentalTypes.(endUserType).jobSchedule.workDays);
      baseStructure.endUserTypes(endUserType_idx).jobSchedule.lowerSample =...
                                            duration2sample(timeVector2duration(residentalTypes.(endUserType).jobSchedule.lowerTime, SAMPLE_PERIOD, '24h'), SAMPLE_PERIOD, '24h');
      baseStructure.endUserTypes(endUserType_idx).jobSchedule.upperSample =...
                                            duration2sample(timeVector2duration(residentalTypes.(endUserType).jobSchedule.upperTime, SAMPLE_PERIOD, '24h'), SAMPLE_PERIOD, '24h');
    end
    % Constraints
    baseStructure.endUserTypes(endUserType_idx).constraints.constraintsCount = uint8(residentalTypes.(endUserType).constraints.constraintsCount);
    if baseStructure.endUserTypes(endUserType_idx).constraints.constraintsCount > 0
      for constraint_idx = 1:baseStructure.endUserTypes(endUserType_idx).constraints.constraintsCount
        constraintName = strcat('c_', string(constraint_idx));
        baseStructure.endUserTypes(endUserType_idx).constraints.(constraintName).days =...
                                                                            uint8(residentalTypes.(endUserType).constraints.(constraintName).days);
        baseStructure.endUserTypes(endUserType_idx).constraints.(constraintName).lowerSample =...
                          duration2sample(timeVector2duration(residentalTypes.(endUserType).constraints.(constraintName).lowerTime, SAMPLE_PERIOD, '24h'), SAMPLE_PERIOD, '24h');
        baseStructure.endUserTypes(endUserType_idx).constraints.(constraintName).upperSample =...
                          duration2sample(timeVector2duration(residentalTypes.(endUserType).constraints.(constraintName).upperTime, SAMPLE_PERIOD, '24h'), SAMPLE_PERIOD, '24h');
        
        constraintApplianceList = string(residentalTypes.(endUserType).constraints.(constraintName).list);  
        ids = zeros(1, numel(constraintApplianceList));
        for constraintAppliance_idx = 1:numel(constraintApplianceList)
          ids(constraintAppliance_idx) = find(appliancesList == constraintApplianceList(constraintAppliance_idx));
        end
        baseStructure.endUserTypes(endUserType_idx).constraints.(constraintName).list = uint8(ids);
      end
    end
    % Sleep time
    baseStructure.endUserTypes(endUserType_idx).sleepTime.case = logical(residentalTypes.(endUserType).sleepTime.case);
    if baseStructure.endUserTypes(endUserType_idx).sleepTime.case
      baseStructure.endUserTypes(endUserType_idx).sleepTime.lowerSample =...
                                              duration2sample(timeVector2duration(residentalTypes.(endUserType).sleepTime.lowerTime, SAMPLE_PERIOD, '24h'), SAMPLE_PERIOD, '24h');
      baseStructure.endUserTypes(endUserType_idx).sleepTime.upperSample =...
                                              duration2sample(timeVector2duration(residentalTypes.(endUserType).sleepTime.upperTime, SAMPLE_PERIOD, '24h'), SAMPLE_PERIOD, '24h');
    end
  end
  
  % ## ELECTRIC VEHICLES ##
  % For each electric vehicle
  for ev_idx = 1:numel(evsList)
    evName = evsList(ev_idx);
    % Assign properties of the electric vehicle
    % Name
    baseStructure.electricVehicles(ev_idx).name = evName;
    % Batter capacity
    baseStructure.electricVehicles(ev_idx).batteryCapacity = single(electricVehicles.(evName).batteryCapacity);
    % Charger.power
    baseStructure.electricVehicles(ev_idx).charger.power.format = electricVehicles.(evName).charger.power.format;
    baseStructure.electricVehicles(ev_idx).charger.power.value = single(electricVehicles.(evName).charger.power.value);
    % Charger.worktime constraint
    baseStructure.electricVehicles(ev_idx).charger.workTimeConstraint.case =...
                                                                    logical(electricVehicles.(evName).charger.constraints.workTimeConstraint.case);
    if baseStructure.electricVehicles(ev_idx).charger.workTimeConstraint.case
      baseStructure.electricVehicles(ev_idx).charger.workTimeConstraint.lowerSample =...
                    duration2sample(timeVector2duration(electricVehicles.(evName).charger.constraints.workTimeConstraint.lowerTime, SAMPLE_PERIOD, '24h'), SAMPLE_PERIOD, '24h');
      baseStructure.electricVehicles(ev_idx).charger.workTimeConstraint.upperSample =...
                    duration2sample(timeVector2duration(electricVehicles.(evName).charger.constraints.workTimeConstraint.upperTime, SAMPLE_PERIOD, '24h'), SAMPLE_PERIOD, '24h');
    end
    % Charger.confliction constraint
    baseStructure.electricVehicles(ev_idx).charger.applianceConflictionConstraint.case =...
                                                        logical(electricVehicles.(evName).charger.constraints.applianceConflictionConstraint.case);
    if baseStructure.electricVehicles(ev_idx).charger.applianceConflictionConstraint.case
      conflictList = string(electricVehicles.(evName).charger.constraints.applianceConflictionConstraint.list);
      ids = zeros(1, numel(conflictList));
      for conflict_idx = 1:numel(conflictList)
        ids(conflict_idx) = find(appliancesList == conflictList(conflict_idx));
      end
      baseStructure.electricVehicles(ev_idx).charger.applianceConflictionConstraint.list = uint8(ids);
    end
    
    baseStructure.electricVehicles(ev_idx).charger.evConflictionConstraint.case =...
                                                                logical(electricVehicles.(evName).charger.constraints.evConflictionConstraint.case);
    if baseStructure.electricVehicles(ev_idx).charger.evConflictionConstraint.case
      conflictList = string(electricVehicles.(evName).charger.constraints.evConflictionConstraint.list);
      ids = zeros(1, numel(conflictList));
      for conflict_idx = 1:numel(conflictList)
        ids(conflict_idx) = find(evsList == conflictList(conflict_idx));
      end
      baseStructure.electricVehicles(ev_idx).charger.evConflictionConstraint.list = uint8(ids);
    end
    % Charge level percentage
    baseStructure.electricVehicles(ev_idx).chargeLevelPercentage.format = electricVehicles.(evName).chargeLevelPercentage.format;
    baseStructure.electricVehicles(ev_idx).chargeLevelPercentage.value = single(electricVehicles.(evName).chargeLevelPercentage.value);
  end
end
