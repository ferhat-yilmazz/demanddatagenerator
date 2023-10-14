 %% بسم الله الرحمن الرحیم 

%% ## Count of End-Users ##
% 20.02.2021, Ferhat Yılmaz

%% Description
%{
  Function to returns count of users which belong to
  for each cosumer profile.

>> Inputs:
  1. <endUsersData>
  2. <endUserTypeCount>

<< Outputs:
  1. <figure>
%}

%%
function usersCount(endUsersData, endUsersProfileCount)
  for profile_idx = 1:endUsersProfileCount
    cnt = sum([endUsersData.typeID] == profile_idx);
    fprintf("\n Type-%1d : %4d\n", profile_idx, cnt);
  end
  fprintf("\n");
end
