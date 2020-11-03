 %% بسم الله الرحمن الرحیم 

%% ## Build Main Usage Array ##
% 03.11.2020, Ferhat Yılmaz

%% Description
%{
	Function to build main usage array for each end-user. All usage
	arrays will be combined. As a result, a structure will be generated
	which contains end-users and theirs main usage arrays.

>> Inputs:
	1. <endUsers>: structure : A structure which describes end-users
	
<< Outputs:
	1. <mainUsageStructure>: structure : A structure contains main usage arrays
																			 for each end-user
%}

function mainUsageStructure = buildMainUsageStructure(endUsers)
	% Get count of weeks
	global COUNT_WEEKS;
	% Get count of sample in a day
	global COUNT_SAMPLE_IN_DAY;
	% Count of end-users
	global COUNT_END_USERS;
	
	% Definition of <mainUsageStructure>
	mainUsageStructure = struct('type', [], 'mainUsageArray', [], 'meanUsageVector', []);
	
	% For each user
	for user_index = 1:COUNT_END_USERS
		% build usage array template
		usageArrayTemplate = single(zeros(COUNT_WEEKS*7, COUNT_SAMPLE_IN_DAY));
		% Assign type of the end-user
		mainUsageStructure(user_index).type = endUsers(user_index).type;
		% Get name of appliances owned by the end-user
		applianceList = transpose(fieldnames(endUsers(user_index).appliances));
		% For each appliance, sum usage arrays
		for appliance = applianceList
			usageArrayTemplate = usageArrayTemplate + endUsers(user_index).appliances.(string(appliance)).usageArray;
		end
		
		% If the end-user has an EV
		if isstruct(endUsers(user_index).ev)
			% Get models of EVs
			evList = transpose(fieldnames(endUsers(user_index).ev));
			% For each EV
			for evModel = evList
				% Add its usage array to <mainUsageStructure>
				usageArrayTemplate = usageArrayTemplate + endUsers(user_index).ev.(string(evModel)).charger.usageArray;
			end
		end
		% Assign <usageArrayTemplate> to <mainUsageStructure.mainUsageArray>
		mainUsageStructure(user_index).mainUsageArray = usageArrayTemplate;
		% Determine <meanUsageVector>
		mainUsageStructure(user_index).meanUsageVector = mean(mainUsageStructure(user_index).mainUsageArray);
	end
end
