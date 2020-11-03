 %% بسم الله الرحمن الرحیم 

%% ## Assign 0 to -1 Filled Samples ##
% 03.11.2020, Ferhat Yılmaz

%% Description
%{
	Function to assign 0 (zero) to -1 filled samples for each end-users
	and each appliance. 

>> Inputs:
	1. <endUsers>: structure : A structure which describes the end-users
	
<< Outputs:
	1. <endUsers>: structure : A structure which describes the end-users
%}

function endUsers = zero2minusOne(endUsers)
	% Get count of end-users
	global COUNT_END_USERS;
	
	% For each end-users
	for user_index = 1:COUNT_END_USERS
		% ## APPLIANCES ##
		% Get list of appliances
		applianceList = transpose(fieldnames(endUsers(user_index)).appliances);
		% For each appliance
		for appliance = applianceList
			% Assign 0 to -1 filled samples for each appliance
			endUsers(user_index).appliances.(string(appliance)).usageArray(...
			endUsers(user_index).appliances.(string(appliance)).usageArray == -1) = single(0);
		end
		
		% ## ELECTRIC VEHICLES ##
		% Check for the end-user has an EV
		if isstruct(endUsers(user_index).ev)
			% Get list of appliances
			evList = transpose(fieldnames(endUsers(user_index)).ev);
			% For each EV
			for evModel = evList
				endUsers(user_index).ev.(string(evModel)).charger.usageArray(...
				endUsers(user_index).ev.(string(evModel)).charger.usageArray == -1) = single(0);
			end
		end
	end
end
