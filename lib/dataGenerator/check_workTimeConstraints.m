 %% بسم الله الرحمن الرحیم 

%% ## Consideration of Work Time Constraints ##
% 13.09.2020, Ferhat Yılmaz

%% Description
%{
	Function to check work time constraint of appliances and
	end-users. Appliances can run only at these times.
	Limit times included. Other regions filled by -1.

>> Inputs:
	1. <endUsers> : structure : Structure which discrebes end-users
	2. <applianceData> : structure : Sructure which contains appliances data

<< Outputs:
	1. <endUser> : structure : Structure which discrebes end-user
%}

%%
function endUsers = check_workTimeConstraints(endUsers, appliancesData)
	% Count of end-users
	global COUNT_END_USERS;
	% Count of weeks
	global COUNT_WEEKS;
	
	% Make an iteration for each end-user
	for i = 1:COUNT_END_USERS
		% Get name of appliances belong the end-user
		endUser_appliances = fieldnames(endUsers(i).appliances);
		% Check for work time constraints which belong to end user:
		% NOTE: End-users' constraints only affect appliances; not EVs.
		endUser_constraintCount = endUsers(i).properties.constraints.constraintsCount;
		% If constraint count > 0; it means there is constaint(s).
		if endUser_constraintCount > 0
			% Iterate for each work time constraint
			for j = 1:endUser_constraintCount
				% Build constraint id
				constraintID = strcat('c_', string(j));
				% Get days which the constraint is active
				constraintDays = endUsers(i).properties.constraints.(constraintID).days;
				% Get time limits of constraint
				lowerTime = double2duration(endUsers(i).properties.constraints.(constraintID).lowerTime, '24h');
				upperTime = double2duration(endUsers(i).properties.constraints.(constraintID).upperTime, '24h');
				% Get appliances which applied constraint
				constraintedAppliances = endUsers(i).properties.constraints.(constraintID).appliancesList;
				% Build logical array describes work times according to constraint
				workTimes_logic = logicalInterval(lowerTime, upperTime);
				
				% Iterate for each appliance in the list to apply constraint
				for k = 1:numel(constraintedAppliances)
					% Check if the appliance belongs to the end-user
					if ismember(constraintedAppliances(k), endUser_appliances)
						% For each week and each specified day
						for week_index = 1:COUNT_WEEKS
							% Assign -1 to "unworked" region
							row = ((week_index-1)*7)+constraintDays;
							endUsers(i).appliances.(string(constraintedAppliances(k))).usageArray(row,~workTimes_logic) = single(-1);
						end
					end
				end
			end
		end
		% Check for each appliance which belong to the end-user, if they have constraint
		% indicated in the "appliancesData.json" configuration file
		for m = 1:numel(endUser_appliances)
			% Check for is there constraint
			if appliancesData.(string(endUser_appliances(m))).constraints.workTimeConstraint.case
				% Get lower and upper limits of the constraint
				lowerTime = double2duration(appliancesData.(string(endUser_appliances(m))).constraints.workTimeConstraint.lowerTime, '24h');
				upperTime = double2duration(appliancesData.(string(endUser_appliances(m))).constraints.workTimeConstraint.upperTime, '24h');
				% Build logical array describes work times according to constraint
				workTimes_logic = logicalInterval(lowerTime, upperTime);
				
				% Assign -1 to "unworked" region
				endUsers(i).appliances.(string(endUser_appliances(m))).usageArray(:,~workTimes_logic) = single(-1);
			end
		end
		% Check for EVs charge time constraints
		% Get name of EVs belong to the end-user
		if isstruct(endUsers(i).ev)
			endUser_evs = fieldnames(endUsers(i).ev);
			
			% Iterate for each ev
			for n = 1:numel(endUser_evs)
				% Check for is there any constraint related with the ev
				if endUsers(i).ev.(string(endUser_evs(n))).charger.constraints.workTimeConstraint.case
					% Get lower and upper limits of the constraint
					lowerTime = double2duration(endUsers(i).ev.(string(endUser_evs(n))).charger.constraints.workTimeConstraint.lowerTime, '24h');
					upperTime = double2duration(endUsers(i).ev.(string(endUser_evs(n))).charger.constraints.workTimeConstraint.upperTime, '24h');
					% Build logical array describes work times according to constraint
					workTimes_logic = logicalInterval(lowerTime, upperTime);

					% Assign -1 to "unworked" region
					endUsers(i).ev.(string(endUser_evs(n))).charger.usageArray(:,~workTimes_logic) = single(-1);
				end
			end
		end
	end
end
