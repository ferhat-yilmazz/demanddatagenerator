 %% بسم الله الرحمن الرحیم

%% ## Assign a Type to End-Users ##
% 14.08.2020, Ferhat Yılmaz

%% Description
%{
  Assign a type to end-users. Types are selected from
  <baseStructure.endUserTypes>

  Count of end-users for each type is accepted as parameter.

>> Inputs:
  1. <endUsers> : structure : The structure which contains the end-users
  2. <baseStructure> : structure : Base structure
  3. <countEachType> : integer : Count of end-user

<< Outputs:
  1. <endUsers>: structure : The structure which contains the end-users
%}

%%
function endUsers = assignType2endUsers_special(endUsers, baseStructure, countEachType)
  % Get count of end-user types
  endUserTypeCount = size(baseStructure.endUserTypes, 2);

  % Assign type for each end-user
  for type_idx = 1:endUserTypeCount
    % Assign typeID to the end-user
    for endUser_idx = ((type_idx - 1)*countEachType + 1):(type_idx * countEachType)
      endUsers(endUser_idx).typeID = type_idx;
    end
  end
end
