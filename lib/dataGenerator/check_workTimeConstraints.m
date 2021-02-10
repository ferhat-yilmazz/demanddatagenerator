 %% بسم الله الرحمن الرحیم 

%% ## Consideration of Work Time Constraints ##
% 13.09.2020, Ferhat Yılmaz

%% Description
%{
	Function to check work time constraint of appliances and
	end-users. Appliances can run only at these times.
	Limit times included. Other regions filled by -1.

>> Inputs:
	1. <endUsers> : structure : The structure which contains the end-users
	2. <baseStructure> : structure : Base structure
	3. <COUNT_SAMPLE_IN_DAY> : integer : Sample count in a day
	4. <COUNT_END_USERS> : integer : Count of end-users
	5. <COUNT_WEEKS> : integer : Count of weeks
	6. <COUNT_DAYS> : integer : Count of the days

<< Outputs:
	1. <endUser> : structure : The structure which contains the end-users
%}

%%
function endUsers = check_workTimeConstraints(endUsers, baseStructure, COUNT_SAMPLE_IN_DAY, COUNT_END_USERS, COUNT_WEEKS, COUNT_DAYS)
	% For each end-user
	for endUser_idx = 1:COUNT_END_USERS
		% Get end-user type ID
		endUserTypeID = endUsers(endUser_idx).typeID;
		% Get count of appliances which belong to the end-user
		applianceCount = size(endUsers(endUser_idx).appliances, 2);
		% Get count of EVs which belong to the end-user
		electricVehicleCount = size(endUsers(endUser_idx).EVs, 2);
		
		% ## Appliance worktime constraint ##
		for appliance_idx = 1:applianceCount
			% ApplianceID
			applianceID = endUsers(endUser_idx).appliances(appliance_idx).applianceID;
			% Check for appliance has a worktime constraint
			if baseStructure.appliances(applianceID).workTimeConstraint.case
				% Get <lowerSample> and <upperSample>
				lowerSample = baseStructure.appliances(applianceID).workTimeConstraint.lowerSample;
				upperSample = baseStructure.appliances(applianceID).workTimeConstraint.upperSample;
				% Determine constrainted region
				constraintedInterval = ~logicalInterval(lowerSample, upperSample, COUNT_SAMPLE_IN_DAY);
				% Assign constraint for all day
				for day_idx = 1:COUNT_DAYS
					endUsers(endUser_idx).appliances(appliance_idx).usageArray(day_idx, constraintedInterval) = single(-1);
				end
			end
		end
		
		% ## EV worktime constraint ##
		for ev_idx = 1:electricVehicleCount
			% EV ID
			evID = endUsers(endUser_idx).EVs(ev_idx).evID;
			% Check for the EV has a worktime constraint
			if baseStructure.electricVehicles(evID).charger.workTimeConstraint.case
				% Get <lowerSample> and <upperSample>
				lowerSample = baseStructure.electricVehicles(evID).charger.workTimeConstraint.lowerSample;
				upperSample = baseStructure.electricVehicles(evID).charger.workTimeConstraint.upperSample;
				% Determine constrainted region
				constraintedInterval = ~logicalInterval(lowerSample, upperSample, COUNT_SAMPLE_IN_DAY);
				% Assign constraint for all day
				for day_idx = 1:COUNT_DAYS
					endUsers(endUser_idx).EVs(ev_idx).usageArray(day_idx, constraintedInterval) = single(-1);
				end
			end
		end
		
		% ## End-user constraints ##
		% Check for the end-user has constraints
		if baseStructure.endUserTypes(endUserTypeID).constraints.constraintsCount > 0
			% For each constraint
			for constraint_idx = 1:baseStructure.endUserTypes(endUserTypeID).constraints.constraintsCount
				% Generate constraint name
				constraintName = strcat('c_', string(constraint_idx));
				% Constraint days
				constraintDays = baseStructure.endUserTypes(endUserTypeID).constraints.(constraintName).days;
				% <lowerSample> and <upperSample>
				lowerSample = baseStructure.endUserTypes(endUserTypeID).constraints.(constraintName).lowerSample;
				upperSample = baseStructure.endUserTypes(endUserTypeID).constraints.(constraintName).upperSample;
				% Constrainted appliances IDs
				constraintedAppliancesIDs = baseStructure.endUserTypes(endUserTypeID).constraints.(constraintName).list;
				% End-users appliances IDs
				endUserAppliancesIDs = [endUsers(endUser_idx).appliances.applianceID];
				% Respective rows of constrainted appliances for the end-user
				respectiveRows = find(ismember(endUserAppliancesIDs, constraintedAppliancesIDs));
				% Determine constrainted region
				constraintedInterval = ~logicalInterval(lowerSample, upperSample, COUNT_SAMPLE_IN_DAY);
				% Assign constraint for <constraintDays> for each week
				for week_idx = 1:COUNT_WEEKS
					for day_idx = 1:numel(constraintDays)
						dayRow = ((week_idx-1)*7) + constraintDays(day_idx);
						% For each constrainted appliance
						for respectiveRow_idx = 1:numel(respectiveRows)
							% Assign <constraintedInterval> to constrainted appliances
							endUsers(endUser_idx).appliances(respectiveRows(respectiveRow_idx)).usageArray(dayRow, constraintedInterval) = single(-1);
						end
					end
				end
			end
		end
	end
end
