 %% بسم الله الرحمن الرحیم 

%% ## Eliminate Negative Values ##
% 03.11.2020, Ferhat Yılmaz

%% Description
%{
  Function to assign 0 (zero) into negative valued sample. Negative values
  not represents a power value.

>> Inputs:
  1. <endUsers>: structure : A structure which describes the end-users
  2. COUNT_END_USERS : integer : Count of end-users
  
<< Outputs:
  1. <endUsers>: structure : A structure which describes the end-users
%}

function endUsers = eliminateNegatives(endUsers, COUNT_END_USERS)
  % For each end-users
  for endUser_idx = 1:COUNT_END_USERS
    % ## APPLIANCES ##
    % Count of appliances
    countAppliances = size(endUsers(endUser_idx).appliances, 2);
    
    % For each appliance
    for appliance_idx = 1:countAppliances
      % Assign 0 to -1 filled samples for each appliance
      endUsers(endUser_idx).appliances(appliance_idx).usageArray(endUsers(endUser_idx).appliances(appliance_idx).usageArray < 0) = single(0);
    end
    
    % ## ELECTRIC VEHICLES ##
    % Check for the end-user has an EV
    if isstruct(endUsers(endUser_idx).EVs)
      % Cout of EVs
      countEvs = size(endUsers(endUser_idx).EVs, 2);
      % For each EV
      for ev_idx = 1:countEvs
        endUsers(endUser_idx).EVs(ev_idx).usageArray(endUsers(endUser_idx).EVs(ev_idx).usageArray < 0) = single(0);
      end
    end
  end
end
