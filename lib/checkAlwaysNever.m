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
function [endUser, applianceList] = checkAlwaysNever(endUser, applianceList)

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
			endUser.appliances.(string(endUser.properties.alwaysAppliances(index))) = [];
		end
	end
end
