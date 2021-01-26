 %% بسم الله الرحمن الرحیم 

%% ## Confliction Check ##
% 25.01.2021, Ferhat Yılmaz

%% Description
%{
	Function to check work time confliction for the electric vehicles and appliances.
	Fill conflicted samples by -1. Note for that, confliction rules
	valid for appliances and electric vehicles which already assigned
	work time. So, selection of appliances and electric vehicles randomly is
	playing an important role here.

	TODO: Not tested.

>> Inputs:
	1. <endUser> : structure : The structure of the end-user
	2. <baseStructure> : structure : Base structure
	3. <objectType> : char : Object type: "appliance" ('a') or "electric vehicle" ('e')  
	3. <objectIndex> : integer : Index of the electric vehicle for the end-user
	4. <objectID> : integer : ID of the electric vehicle for the baseStructure
	5. <dayIndex> : integer : Day index
	6. <lowLimitSample> : integer : Lower limit of interval (cannot exceeds sample count in a day)
	7. <upLimitSample> : integer : Upper limit of interval (cannot exceeds sample count in a day)
	8. <COUNT_WEEKS> : integer : Count of weeks
	9. <COUNT_SAMPLE_IN_DAY> : integer : Sample count in a day
	
<< Outputs:
	1. <objectUsageArray> : array : Usage array belongs to the EV
%}

%%
function objectUsageArray = conflictionCheck(endUser, baseStructure, objectType, objectID, objectIndex, dayIndex, lowLimitSample, upLimitSample,...
																						 COUNT_WEEKS, COUNT_SAMPLE_IN_DAY)
																					 
	% Be sure that <lowerLimitSample> and <upperLimitSample> are in interval of (0, COUNT_SAMPLE_INDAY]																				 
	assert(((lowLimitSample * upLimitSample) > 0) && (lowLimitSample <= COUNT_SAMPLE_IN_DAY) && (upLimitSample <= COUNT_SAMPLE_IN_DAY),...
				"<conflictionCheck> : <lowLimitSample> and <upLimitiSample> must be in interval (0, COUnT_SAMPLE_IN_DAY]");
	
	% Determine <lowerPointer> and <upperPointer>
	if lowLimitSample < upLimitSample
		lowerPointer = ((dayIndex-1) * COUNT_SAMPLE_IN_DAY) + lowLimitSample;
		upperPointer = ((dayIndex-1) * COUNT_SAMPLE_IN_DAY) + upLimitSample;
	else
		lowerPointer = ((dayIndex-1) * COUNT_SAMPLE_IN_DAY) + lowLimitSample;
		upperPointer = ((dayIndex) * COUNT_SAMPLE_IN_DAY) + upLimitSample;
	end
	
	% Check for <upperPointer> is not out of index
	if upperPointer > (COUNT_WEEKS * 7 * COUNT_SAMPLE_IN_DAY)
		upperPointer = COUNT_WEEKS * COUNT_SAMPLE_IN_DAY;
	end
	
	% Get appliance IDs which owned by the end-user
	if isempty(endUser.appliances)
		endUserApplianceIDs = [];
	else
		endUserApplianceIDs = [endUser.appliances.applianceID];
	end
	% Get electric vehicle IDs which owned by the end-user
	if isempty(endUser.EVs)
		endUserEvIDs = [];
	else
		endUserEvIDs = [endUser.EVs.evID];
	end
	
	% Divide function into 2 part:
	%		* for appliances
	%		* for electric vehicles
	switch objectType
		
		% ####### APPLIANCES #######
		case 'a'
			% Define <objectUsageArray>
			objectUsageArray = endUser.appliances(objectIndex).usageArray;
			% Merge the usage array ans assign it to <mergedUsageArray>
			mergedUsageArray = reshape(transpose(objectUsageArray), 1, COUNT_WEEKS*7*COUNT_SAMPLE_IN_DAY);
			
			% Firstly, check for confliction with electric vehicles
			if baseStructure.appliances(objectID).evConflictionConstraint.case
				% Get IDs of conflicted electric vehicles
				conflictedEvIDs = baseStructure.appliances(objectID).evConflictionConstraint.list;
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
			if baseStructure.appliances(objectID).applianceConflictionConstraint.case
				% Get IDs of conflicted appliances
				conflictedApplianceIDs = baseStructure.appliances(objectID).applianceConflictionConstraint.list;
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
			
		% ####### ELECTRIC VEHICLES #######
		case 'e'
			% Define <objectUsageArray>
			objectUsageArray = endUser.EVs(objectIndex).usageArray;
			% Merge the usage array ans assign it to <mergedUsageArray>
			mergedUsageArray = reshape(transpose(objectUsageArray), 1, COUNT_WEEKS*7*COUNT_SAMPLE_IN_DAY);
			
			% Firstly, check for confliction with electric vehicles
			if baseStructure.electricVehicles(objectID).charger.evConflictionConstraint.case
				% Get IDs of conflicted electric vehicles
				conflictedEvIDs = baseStructure.electricVehicles(objectID).charger.evConflictionConstraint.list;
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
			if baseStructure.electricVehicles(objectID).charger.applianceConflictionConstraint.case
				% Get IDs of conflicted appliances
				conflictedApplianceIDs = baseStructure.electricVehicles(objectID).charger.applianceConflictionConstraint.list;
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
		otherwise
			error("<conflictionCheck> : <objectType> undefined");
	end
	
	% Reshap <mergedUsageArray> and assign it to <applianceUsageArray>
	objectUsageArray = transpose(reshape(mergedUsageArray, COUNT_SAMPLE_IN_DAY, COUNT_WEEKS*7));
end
