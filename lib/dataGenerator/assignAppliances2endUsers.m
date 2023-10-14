 %% بسم الله الرحمن الرحیم 

%% ## Assign Appliances to End-Users ##
% 15.08.2020, Ferhat Yılmaz

%% Description
%{
  Function to assign appliances to end-users randomly. However randomization,
  there may be appliances which must never owed or which must always
  owned. Similarly, there are dependent appliances. These conditions
  must be considered.
  As an output, <endUsers> structure returns with appliances assigned
  for each user.

>> Inputs:
  1. <endUsers> : structure : The structure which contains the end-users
  2. <baseStructure> : structure : Base structure
  3. <COUNT_SAMPLE_IN_DAY> : integer : Sample count in a day
  4. <COUNT_END_USERS> : integer : Count of end-users
  5. <COUNT_DAYS> : integer : Count of the days
  6. <RAND_METHOD> : string :  Randomization method (PRNG or TRNG)

<< Outputs:
  1. <endUsers> : structure : The structure which contains the end-users
%}

%%
function endUsers = assignAppliances2endUsers(endUsers, baseStructure, COUNT_SAMPLE_IN_DAY, COUNT_END_USERS, COUNT_DAYS, RAND_METHOD)
  % Define ID vector contains all IDs of appliances
  allAppliancesIDs = uint8(1:size(baseStructure.appliances, 2));
  % Define ID vector contains all IDs of electric vehicles
  allEVsIDs = uint8(1:size(baseStructure.electricVehicles,2));
  
  % Define random number structure for assignment of appliances and electric vehicles
  rand4appliances_and_evs = generateRandStructure(0, 1, RAND_METHOD, 5000);
  
  % For each end-user
  for endUser_idx = 1:COUNT_END_USERS
    % Get type id of the endUser
    endUserTypeID = endUsers(endUser_idx).typeID;
    % Define clone vector of <allAppliancesIDs>
    cloneAllAppliancesIDs = allAppliancesIDs;
    % Define vector contains IDs of appliances assigned to the end-user
    % (Preallocation rule will be broken)
    assignedAppliancesIDs = uint8([]);
    % Define vector contains IDs of electric vehicles assigned to the end-user
    % (Preallocation rule will be broken)
    assignedEVsIDs = uint8([]);
    
    % Remove never appliances ID from <cloneAllAppliancesIDs> for the end-user
    cloneAllAppliancesIDs(ismember(cloneAllAppliancesIDs, baseStructure.endUserTypes(endUserTypeID).neverAppliances)) = [];
    % Assign always appliances to the end-user and also remove IDs of always appliances
    % from <cloneAllAppliancesIDs> vector
    assignedAppliancesIDs = [assignedAppliancesIDs baseStructure.endUserTypes(endUserTypeID).alwaysAppliances];
    cloneAllAppliancesIDs(ismember(cloneAllAppliancesIDs, baseStructure.endUserTypes(endUserTypeID).alwaysAppliances)) = [];
    
    % Seperate appliances as dependent and independent
    dependentAppliancesLogicVector = arrayfun(@(app_idx) baseStructure.appliances(app_idx).dependency.case, cloneAllAppliancesIDs);
    dependentAppliancesIDs = cloneAllAppliancesIDs(dependentAppliancesLogicVector);
    independentAppliancesIDs = cloneAllAppliancesIDs(~dependentAppliancesLogicVector);
    
    % ## Assign independent appliances ##
    for independentApp_idx = 1:numel(independentAppliancesIDs)
      % Pick a random number for each appliance
      [randAssingnmentAppliance, rand4appliances_and_evs] = pickRandNumber(rand4appliances_and_evs);
      % If <randAssingnmentAppliance> is true, then assing the appliance
      if logical(randAssingnmentAppliance)
        assignedAppliancesIDs = [assignedAppliancesIDs independentAppliancesIDs(independentApp_idx)];
      end
    end
    
    % ## Assign dependent appliances ##
    for dependentApp_idx = 1:numel(dependentAppliancesIDs)
      % Check for dependency conditions satisfied
      switch baseStructure.appliances(dependentAppliancesIDs(dependentApp_idx)).dependency.needAll
        case true
          dependencyCondition =...
                          all(ismember(baseStructure.appliances(dependentAppliancesIDs(dependentApp_idx)).dependency.list, assignedAppliancesIDs));
        case false
          dependencyCondition =...
                          any(ismember(baseStructure.appliances(dependentAppliancesIDs(dependentApp_idx)).dependency.list, assignedAppliancesIDs));
        otherwise
          dependencyCondition = false;
          warning(strcat("<appliancesData> : ", baseStructure.appliances(dependentAppliancesIDs(dependentApp_idx)).name,...
                                                                                                                  " dependency.needAll undefined"));
      end
      
      % If dependency condition satisfied, pick a random number to check the appliance will be
      % assigned or not
      if dependencyCondition
        % Pick a random number
        [randAssingnmentAppliance, rand4appliances_and_evs] = pickRandNumber(rand4appliances_and_evs);
        % If <randAssingnmentAppliance> is true, then assing the appliance
        if randAssingnmentAppliance
          assignedAppliancesIDs = [assignedAppliancesIDs dependentAppliancesIDs(dependentApp_idx)];
        end
      end
    end
    
    % ## Assign electric vehicles ##
    % Check for the end-user EV status
    switch baseStructure.endUserTypes(endUserTypeID).haveEV
      case 0
        % End-user has not electric vehicle exactly.
      case 1
        % There is a  probability, the end-user can have an electric vehicle
        % End-users can have only one electric vehicle
        % Pick random value for electric vehicle
        [randAssingnmentEV, rand4appliances_and_evs] = pickRandNumber(rand4appliances_and_evs);
        % If <randAssignmentEV> is true, than assign one of EV list
        if logical(randAssingnmentEV)
          % Select one of from <allEVsIDs> if it has element
          if numel(allEVsIDs) > 0
            selectedEVID = allEVsIDs(randi([1 numel(allEVsIDs)]));
            % Assign selected electric vehicle
            assignedEVsIDs = [assignedEVsIDs selectedEVID];
          end
        end
      case 2
        % The end-user exactly have an EV
        % Select one of from <allEVsIDs> if it has element
        if numel(allEVsIDs) > 0
          selectedEVID = allEVsIDs(randi([1 numel(allEVsIDs)]));
          % Assign selected electric vehicle
          assignedEVsIDs = [assignedEVsIDs selectedEVID];
        end
      otherwise
        error(strcat("<residentalTypes.json> : ", "<", baseStructure.endUserTypes(endUserTypeID).type, "> ", "<haveEV> value undefined"));
    end
    
    % Save <assignedAppliancesIDs> to <endUsers> structure and generate <usageArray>
    if isempty(assignedAppliancesIDs)
      endUsers(endUser_idx).appliances = [];
    else
      for assignedApp_idx = 1:numel(assignedAppliancesIDs)
        % Get appliance ID
        assignedApplianceID = assignedAppliancesIDs(assignedApp_idx);
        % Assign appliance ID
        endUsers(endUser_idx).appliances(assignedApp_idx).applianceID = assignedApplianceID;
        % Assign appliance name
        endUsers(endUser_idx).appliances(assignedApp_idx).applianceName = baseStructure.appliances(assignedApplianceID).name;
        % Assign <duc>, <wuc> and <tuc>
        endUsers(endUser_idx).appliances(assignedApp_idx).duc = single(0);
        endUsers(endUser_idx).appliances(assignedApp_idx).wuc = single(0);
        endUsers(endUser_idx).appliances(assignedApp_idx).tuc = single(0);
        % Assign usage array
        endUsers(endUser_idx).appliances(assignedApp_idx).usageArray = repmat(generateUsageVector(COUNT_SAMPLE_IN_DAY), COUNT_DAYS, 1);
      end
    end
    
    % Save <assignedEVsIDs> to <endUsers> structure and generate <usageArray>
    if isempty(assignedEVsIDs)
      endUsers(endUser_idx).EVs = [];
    else
      for assignedEV_idx = 1:numel(assignedEVsIDs)
        % Get electric vehicle ID
        assignedEVID = assignedEVsIDs(assignedEV_idx);
        % Assign EV ID
        endUsers(endUser_idx).EVs(assignedEV_idx).evID = assignedEVID;
        % Assign EV name
        endUsers(endUser_idx).EVs(assignedEV_idx).evName = baseStructure.electricVehicles(assignedEVID).name;
        % Assign <tuc>
        endUsers(endUser_idx).EVs(assignedEV_idx).tuc = single(0);
        % Assign usage array
        endUsers(endUser_idx).EVs(assignedEV_idx).usageArray = repmat(generateUsageVector(COUNT_SAMPLE_IN_DAY), COUNT_DAYS, 1);
      end
    end
    
  end
end
