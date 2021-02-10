 %% بسم الله الرحمن الرحیم 

%% ## Totalize Usage Arrays ##
% 10.02.2021, Ferhat Yılmaz

%% Description
%{
	Function to totalize usage arrays belong to each appliances and electric
	vehicles for each en-user.

>> Inputs:
	1. <endUsers> : structure : The structure which contains the end-users
	2. <baseStructure> : structure : Base structure
	3. <COUNT_END_USERS> : integer : Count of end-users
	4. <COUNT_WEEKS> : integer : Count of weeks
	5. <COUNT_SAMPLE_IN_DAY> : integer : Count of samples in a day
	
<< Outputs:
	1. <endUsers> : structure : The structure which contains the end-users

%}

%%
function endUsers = totalizeUsageArrays(endUsers, baseStructure, COUNT_END_USERS, COUNT_WEEKS, COUNT_SAMPLE_IN_DAY)
	% For each end-user
	for endUser_idx = 1:COUNT_END_USERS
		% Define <totalUsageArray>
		totalUsageArray = single(zeros(COUNT_WEEKS*7, COUNT_SAMPLE_IN_DAY));
		
		% ## APPLIANCES ##
		% Get count of appliances
		countAppliances = size(endUsers(endUser_idx).appliances, 2);
		% For each appliance
		for appliance_idx = 1:countAppliances
			% Get ID of appliance
			applianceID = endUsers(endUser_idx).appliances(appliance_idx).applianceID;
			% Get sign of appliance:
			% (-) if producer
			% (+) if consumer
			if baseStructure.appliances(applianceID).type
				sign = -1;
			else
				sign = 1;
			end
			% Sum
			totalUsageArray = totalUsageArray + (sign*endUsers(endUser_idx).appliances(appliance_idx).usageArray);
		end
		
		% ## ELECTRIC VEHICLES ##
		% Get count of electric vehicles
		countEvs = size(endUsers(endUser_idx).EVs, 2);
		% For each electric vehicle
		for ev_idx = 1:countEvs
			totalUsageArray = totalUsageArray + endUsers(endUser_idx).EVs.usageArray;
		end
		
		% Assign <totalUsageArray>
		endUsers(endUser_idx).totalUsage = totalUsageArray;
	end
end
