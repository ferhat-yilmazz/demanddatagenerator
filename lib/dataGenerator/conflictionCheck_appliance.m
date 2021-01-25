 %% بسم الله الرحمن الرحیم 

%% ## Check Work Time Confliction for Periodic & Continuous Appliances ##
% 24.01.2021, Ferhat Yılmaz

%% Description
%{
	Function to check work time confliction for the periodic and continuous apliances.
	Fill by -1 conflicted samples. Check for both electric vehicles and other appliances.
	Note for that, confliction rules valid for appliances and electric vehicles
	which already assigned work time. So, select appliances and electric vehicles
	randomly is playing an important role here.


>> Inputs:
	1. <endUser> : structure : The structure of the end-user
	2. <baseStructure> : structure : Base structure
	3. <applianceIndex> : integer : Index of the appliance for the end-user
	4. <applianceID> : integer : ID of the electric vehicle for the baseStructure
	5. <dayIndex> : integer : Day index
	6. <COUNT_WEEKS> : integer : Count of weeks
	7. <COUNT_SAMPLE_IN_DAY> : integer : Sample count in a day
	
<< Outputs:
	1. <applianceUsageArray> : array : Usage array belongs to the appliance
%}

%%
function applianceUsageArray = conflictionCheck_appliance(endUser, baseStructure, applianceIndex, applianceID, dayIndex,...
																													COUNT_WEEKS, COUNT_SAMPLE_IN_DAY)
	% Assign usage array of the appliance to <applianceUsageArray>
	applianceUsageArray = endUser.appliances(applianceIndex).usageArray;
	
	% Merge the usage array ans assign it to <mergedUsageArray>
	mergedUsageArray = reshape(transpose(applianceUsageArray), 1, COUNT_WEEKS*7*COUNT_SAMPLE_IN_DAY);
	
	% Determine <lowerPointer> and <upperPointer>
	lowerPointer = (dayIndex-1)*COUNT_SAMPLE_IN_DAY + 1;
	upperPointer = (dayIndex+1)*COUNT_SAMPLE_IN_DAY;
	
	% Firstly, check for confliction with electric vehicles
	if baseStructure.appliances(applianceID).evConflictionConstraint.case
		% Get IDs of conflicted electric vehicles
		conflictedEvIDs = baseStructure.appliances(applianceID).evConflictionConstraint.list;
		% Get electric vehicles IDs which are owned by the end-user
		endUserEvIDs = [endUser.EVs.evID];
		% For each conflicted electric vehicle
		for conflictedEv_idx = 1:numel(conflictedEvIDs)
			% Get ID of the conflicted electric vehicle
			conflictedEvID = conflictedEvIDs(conflictedEv_idx);
			% Check for the end-user has the conflicted electric vehicle
			if ismember(conflictedEvID, endUserEvIDs)
				% Get merged usage array of the conflicted electric vehicle
				conflictedMergedUsageArray = reshape(transpose(endUser.EVs(ismember(endUserEvIDs, conflictedEvID)).usageArray),...
																												1, COUNT_WEEKS*7*COUNT_SAMPLE_IN_DAY);
				% Assign -1 conflicted samples in interval <lowerPointer> and <upperPointer>
				mergedUsageArray(lowerPointer:upperPointer) = single(-1 * (conflictedMergedUsageArray(lowerPointer:upperPointer) > 0));
			end
		end
	end
	
	% Secondly, check for confliction with appliances
	if baseStructure.appliances(applianceID).applianceConflictionConstraint.case
		% Get IDs of conflicted appliances
		conflictedApplianceIDs = baseStructure.appliances(applianceID).applianceConflictionConstraint.list;
		% Get appliances' IDs whic are owned by the end-user
		endUserApplianceIDs = [endUsers.appliances.applianceID];
		% For each conflicted appliance
		for conflictedAppliance_idx = 1:numel(conflictedApplianceIDs)
			% Get ID of the conflicted appliance
			conflictedApplianceID = conflictedApplianceIDs(conflictedAppliance_idx);
			% Check for yhe end-user has the conflicted appliance
			if ismember(conflictedApplianceID, endUserApplianceIDs)
				% Get merged usage array of the conflicted appliance
				conflictedMergedUsageArray = reshape(transpose(endUser.appliances(ismember(endUserApplianceIDs, conflictedApplianceID)).usageArray),...
																												1, COUNT_WEEKS*7*COUNT_SAMPLE_IN_DAY);
				% Assign -1 conflicted samples in interval <lowerPointer> and <upperPointer>
				mergedUsageArray(lowerPointer:upperPointer) = single(-1 * (conflictedMergedUsageArray(lowerPointer:upperPointer) > 0));
			end
		end
	end
	
	% Reshap <mergedUsageArray> and assign it to <applianceUsageArray>
	applianceUsageArray = transpose(reshape(mergedUsageArray, COUNT_SAMPLE_IN_DAY, COUNT_WEEKS*7));
end
