 %% بسم الله الرحمن الرحیم 

%% ## Build Main End-Users Structure ##
% 10.12.2020, Ferhat Yılmaz

%% Description
%{
	Function to build main "users" structure. In addition, usage arrays of aapliances
	are generated for a week. Constraint are also considered, except confliction
	constraints.

	>> Inputs:
	1. <appliancesData> : structure : "appliancesData.json" configuration file
	2. <residentalTypes> : structure : "residentalTypes.json" configuration file
	3. <default_weeklyRunInReal> : structure : Default value for real usage in a week

<< Outputs:
	1. <endUsersStruct> : structure : Main end-users structure
%}

%%
function endUsersStruct = buildEndUsersStruct(appliancesData, residentalTypes, default_weeklyRunInReal)
	% Count of weeks
	global COUNT_WEEKS;
	% Count of sample in a day
	global COUNT_SAMPLE_IN_DAY;
	
	% Get names of end-users types
	types = transpose(fieldnames(residentalTypes));
	% Get name of appliances
	appliancesList = transpose(fieldnames(appliancesData));
	
	% Define <endUsersStruct>
	endUsersStruct = struct();
	
	% For each end-user type, assign appliances (except never owned appliances),
	% define usage arrays and consider constraints (fill related samples by FALSE)
	for type = types
		% Assign employed and nonemployed counts for the kinf of end-user
		endUsersStruct.(string(type)).employedCount = single(residentalTypes.(string(type)).employedCount);
		endUsersStruct.(string(type)).nonemployedCount = single(residentalTypes.(string(type)).nonemployedCount);
		% Assign job schedule if there is
		if residentalTypes.(string(type)).jobSchedule.case
			endUsersStruct.(string(type)).jobSchedule.case = true;
			endUsersStruct.(string(type)).jobSchedule.workDays = uint16(residentalTypes.(string(type)).jobSchedule.workDays);
			endUsersStruct.(string(type)).jobSchedule.lowerSample =...
																					 duration2sample(timeVector2duration(residentalTypes.(string(type)).jobSchedule.lowerTime, '24h'), '24h');
			endUsersStruct.(string(type)).jobSchedule.upperSample =...
																					 duration2sample(timeVector2duration(residentalTypes.(string(type)).jobSchedule.upperTime, '24h'), '24h');
		else
			endUsersStruct.(string(type)).jobSchedule.case = false;
		end
		
		% Assign appliances and their constraints such that:
		%		* Never owned appliances never will be assigned
		%		* Appliance worktime constraint
		%		* End-user type worktime constraint(s)
		%		* End-user type sleep time constraint (for appliances which need operator to run)
		for appliance = appliancesList
			% Continue if the appliance is in the never owned appliances list for the end-user type
			% OR an appliance is "periodic" and "continuous" run mode
			if ismember(appliance, residentalTypes.(string(type)).neverAppliances) || logical(appliancesData.(string(appliance)).operation.continuity)
				continue;
			end
			
			% Assign usage array for the appliance as count of weeks
			endUsersStruct.(string(type)).appliances.(string(appliance)).usageArray = true(COUNT_WEEKS*7, COUNT_SAMPLE_IN_DAY);
			% Assign operation information of the appliance
			endUsersStruct.(string(type)).appliances.(string(appliance)).operation = appliancesData.(string(appliance)).operation;
			% Assign information of  weekly run in real life
			% If there is no data for real usage in a week, then assign default usage values
			if appliancesData.(string(appliance)).weeklyRunInReal.case
				endUsersStruct.(string(type)).appliances.(string(appliance)).weeklyRunInReal = appliancesData.(string(appliance)).weeklyRunInReal;
			else
				endUsersStruct.(string(type)).appliances.(string(appliance)).weeklyRunInReal = default_weeklyRunInReal;
			end
			% Assing information that the appliance need operator or not to run
			endUsersStruct.(string(type)).appliances.(string(appliance)).needOperator = appliancesData.(string(appliance)).needOperator;
			
			% Consider constraints
			%		1. Appliance worktime constraint
			if appliancesData.(string(appliance)).constraints.workTimeConstraint.case
				c1_lowerDuration = timeVector2duration(appliancesData.(string(appliance)).constraints.workTimeConstraint.lowerTime, '24h');
				c1_upperDuration = timeVector2duration(appliancesData.(string(appliance)).constraints.workTimeConstraint.upperTime, '24h');
				endUsersStruct.(string(type)).appliances.(string(appliance)).usageArray(:, ~logicalInterval(c1_lowerDuration, c1_upperDuration)) = false;
			end
			%		2. End-user type worktime constraint(s)
			if residentalTypes.(string(type)).constraints.constraintsCount > 0
				for constraint_index = 1:residentalTypes.(string(type)).constraints.constraintsCount
					constraint_id = strcat('c_', string(constraint_index));
					if ismember(appliance, residentalTypes.(string(type)).constraints.(constraint_id).appliancesList)
						constraintDays = transpose(uint8(residentalTypes.(string(type)).constraints.(constraint_id).days));
						c2_lowerDuration = timeVector2duration(residentalTypes.(string(type)).constraints.(constraint_id).lowerTime, '24h');
						c2_upperDuration = timeVector2duration(residentalTypes.(string(type)).constraints.(constraint_id).upperTime, '24h');
						endUsersStruct.(string(type)).appliances.(string(appliance))...
																													.usageArray(constraintDays,~logicalInterval(c2_lowerDuration, c2_upperDuration)) = false;
					end
				end
			end
			%		3. End-user type sleep time constraint
			if residentalTypes.(string(type)).sleepTime.case
				if appliancesData.(string(appliance)).needOperator
					c3_lowerDuration = timeVector2duration(residentalTypes.(string(type)).sleepTime.lowerTime, '24h');
					c3_upperDuration = timeVector2duration(residentalTypes.(string(type)).sleepTime.upperTime, '24h');
					endUsersStruct.(string(type)).appliances.(string(appliance)).usageArray(:, logicalInterval(c3_lowerDuration, c3_upperDuration)) = false;
				end
			end
		end
		
	end
end
