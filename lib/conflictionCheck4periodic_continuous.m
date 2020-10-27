 %% بسم الله الرحمن الرحیم 

%% ## Check Confliction Constraint for Periodic & Continuous Appliances ##
% 21.10.2020, Ferhat Yılmaz

%% Description
%{
	Function to check confliction constraints for periodic and continuous appliances.
	The appliance can not run at conflicted samples. These samples filled by -1.
	Run duration cannot seperated. If there least one sample, then all run duration
	will be canceled.

>> Inputs:
	1. <appliancesData> : structure : "appliancesData.json" config structure 
	2. <endUser>: structure : Structure of the the end-user
	3. <appliance> : string : A periodic & continuous appliance
	4. <runDay> : integer : Day number which the appliance run
	5. <runInterval> : array: Time index which run the appliance in the day

<< Outputs:
	1. <endUser>: structure : Structure of the the end-user
%}

%%
function endUser = conflictionCheck4periodic_continuous(appliancesData, endUser, appliance, runDay, runInterval)
	% Check for is there any appliance which conflict with the given appliance
	if appliancesData.(appliance).constraints.conflictionConstraint.case
		conflictAppliances = cellstr(appliancesData.(appliance).constraints.conflictionConstraint.list);
		% Be sure <conflictAppliances> are not empty
		assert(~isempty(conflictAppliances), string(appliance) + ' has configuration error!');
		
		% For each conflict appliance
		for conflictAppliance = conflictAppliances
			% Check for <conflictAppliance> owned by the end-user
			if isfield(endUser.appliances.(string(conflictAppliance)))
				% Check <conflictAppliance> works at related samples
				if sum(endUser.appliances.(string(conflictAppliance)).usageArray(runDay, runInterval(1):runInterval(2)) == 1) > 0
					% Fill by -1 conflicted samples
					endUser.appliances.(string(appliance)).usageArray(endUser.appliances.(string(conflictAppliance))...
						.usageArray(runDay, runInterval(1):runInterval(2)) == 1) = single(-1);
					% After -1 filled; reassign worktime to the periodic and continuous appliance
					endUser = worktime_periodic_continuous(appliancesData, endUser, appliance);
				end
			end
		end
	end
end
