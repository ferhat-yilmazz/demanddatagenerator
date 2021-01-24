 %% بسم الله الرحمن الرحیم 

%% ## Check Work Time Conflictiın for EVs ##
% 23.01.2021, Ferhat Yılmaz

%% Description
%{
	Function to check work time confliction for the electric vehicles.
	Fill by -1 conflicted appliances. Note for that, confliction rules
	valid for appliances and electric vehicles which already assigned
	work time. So, select appliances and electric vehicles randomly is
	playing an important role here.

>> Inputs:
	1. <endUser> : structure : The structure of the end-user
	2. <baseStructure> : structure : Base structure
	3. <evIndex> : integer : Index of the electric vehicle for the end-user
	4. <evID> : integer : ID of the electric vehicle for the baseStructure
	4. <dayIndex> : integer : Day index
	5. <dayPartIndex> : array : Index of the day part
	6. <COUNT_WEEKS> : integer : Count of weeks
	7. <COUNT_SAMPLE_IN_DAY> : integer : Sample count in a day
	
<< Outputs:
	1. <evUsageArray> : array : Usage array belongs to the EV
%}

%%
function evUsageArray = conflictionCheck_ev(endUser, baseStructure, evIndex, evID, dayIndex, dayPartIndex, COUNT_WEEKS, COUNT_SAMPLE_IN_DAY)
	% Assign the usage array of the electric vehichle to <evUsageArray>
	evUsageArray = endUser.EVs(evIndex).usageArray;
	
	% Merge the usage array of charger of the electric vehicle
	mergedUsageArray = reshape(transpose(evUsageArray), 1, COUNT_WEEKS*7*COUNT_SAMPLE_IN_DAY);
	
	% Determine <lowerPointer> and <upperPointer>
	lowerPointer = (dayIndex-1)* COUNT_SAMPLE_IN_DAY + dayPartIndex(1);
	upperPointer = (dayIndex-1)*COUNT_SAMPLE_IN_DAY + dayPartIndex(2);
	
	% Firstly, check for confliction with other electric vehicles
	if baseStructure.electricVehicles(evID).charger.evConflictionConstraint.case
		% Get IDs of conflicted electric vehicles
		conflictedEvIDs = baseStructure.electricVehicles(evID).charger.evConflictionConstraint.list;
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
	if baseStructure.electricVehicles(ID).charger.applianceConflictionConstraint.case
		% Get IDs of conflicted appliances
		conflictedApplianceIDs = baseStructure.baseStructure.electricVehicles(ID).charger.applianceConflictionConstraint.list;
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
	
	% Reshap <mergedUsageArray> and assign it to <evUsageArray>
	evUsageArray = transpose(reshape(mergedUsageArray, COUNT_SAMPLE_IN_DAY, COUNT_WEEKS*7));
end
