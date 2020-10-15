 %% بسم الله الرحمن الرحیم 

%% ## Check Always and Never Appliances ##
% 18.08.2020, Ferhat Yılmaz

%% Description
%{
	Function to check appliances which the end-user must own or
	must not own it. If there is any appliance, it will be removed
	from <applianceList> list.

>> Inputs:
	1. <endUser> : structure : Structure which discrebes end-user
	2. <applianceList> : cellArray : A list includes appliances

<< Outputs:
	1. <endUser> : structure : Structure which discrebes end-user
	2. <applianceList> : cellArray : A list includes appliances
%}

%%
function [endUser, applianceList] = checkAlwaysNever(endUser, applianceList, countDays)

	% Check for 'never owned' appliances
	if ~isempty(endUser.properties.neverAppliances)
		for index = 1:numel(endUser.properties.neverAppliances)
			applianceList = removeItemFromCellArray(endUser.properties.neverAppliances(index), applianceList);
		end
	end
	
	% Check for 'always owned' appliances
	if ~isempty(endUser.properties.alwaysAppliances)
		for index = 1:numel(endUser.properties.alwaysAppliances)
			applianceList = removeItemFromCellArray(endUser.properties.alwaysAppliances(index), applianceList);
			% Assign usage vector, duc (dailyUsageCount), and wuc(weeklyUsageCount)
			endUser.appliances.(string(endUser.properties.alwaysAppliances(index))).usageArray =...
																																							repmat(generateUsageVector(),countDays,1);
			endUser.appliances.(string(endUser.properties.alwaysAppliances(index))).duc = uint16(0);
			endUser.appliances.(string(endUser.properties.alwaysAppliances(index))).wuc = uint16(0);
		end
	end
end
