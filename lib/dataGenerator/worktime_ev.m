 %% بسم الله الرحمن الرحیم 

%% ## Assign Worktime for EVs ##
% 27.10.2020, Ferhat Yılmaz

%% Description
%{
	Function to assign worktime for the given EV. For EVs there
	is no "run probability" calculation. Important point is that
	battery level of the EV. It is selected randomly. Run duration of
	the charger determined according to battery level (selected randomly)
	and power of the charger.

>> Inputs:
	1. <electricVehicles> : structure : "electricVehicles.json" config structure 
	2. <endUser>: structure : Structure of the end-user
	3. <ev> : string : Name of the EV to assign worktime
	4. <runDay>: integer : Day number which the EV run
	5. <batteryLevel> : integer : The level of the battery belongs to the EV
	
<< Outputs:
	1. <endUser>: structure : Structure of the end-user
%}

%%
function endUser = worktime_ev(evModel, endUser, runDay, batteryLevel)
	% Get count of week
	global COUNT_WEEKS;
	% Get count of sample in a day
	global COUNT_SAMPLE_IN_DAY;
	%global db1;
	%global db2;
	%global db3;
	
	% Reshape <usageArray> to <mergedUsageVector>
	mergedUsageVector = reshape(transpose(endUser.ev.(string(evModel)).charger.usageArray), 1, COUNT_WEEKS*7*COUNT_SAMPLE_IN_DAY);
	totalSampleCount = numel(mergedUsageVector);
	
	% Determine limits of possible work samples
	% There are 2 options: With/without workTimeConstaint
	if endUser.ev.(string(evModel)).charger.constraints.workTimeConstraint.case
		lowerTime_sample = duration2sample(double2duration(endUser.ev.(string(evModel)).charger.constraints.workTimeConstraint.lowerTime, '24h'), '24h');
		upperTime_sample = duration2sample(double2duration(endUser.ev.(string(evModel)).charger.constraints.workTimeConstraint.upperTime, '24h'), '24h');
		if lowerTime_sample >= upperTime_sample
			lowerLimit = ((runDay-1)*COUNT_SAMPLE_IN_DAY) + lowerTime_sample;
			upperLimit = (runDay*COUNT_SAMPLE_IN_DAY) + upperTime_sample;
		else
			lowerLimit = ((runDay-1)*COUNT_SAMPLE_IN_DAY) + lowerTime_sample;
			upperLimit = (runDay*COUNT_SAMPLE_IN_DAY) + upperTime_sample;
		end
		% Check for out of index
		if upperLimit > totalSampleCount
			upperLimit = totalSampleCount;
		end
	else
		lowerLimit = (runDay-1)*COUNT_SAMPLE_IN_DAY;
		upperLimit = (runDay)*COUNT_SAMPLE_IN_DAY;
	end
	
	% Get power value of charger
	valueList = transpose(endUser.ev.(string(evModel)).charger.power.value);
	valueFormat = endUser.ev.(string(evModel)).charger.power.format;
	if strcmp(valueFormat, 'choice')
		assert(numel(valueList) > 0, 'electrictVehicles.json:' + string(evModel) + ' <chargeLevelPercentage.value> error!');
		powerValue = datasample(valueList, 1);
	elseif strcmp(valueFormat, 'interval')
		assert((numel(valueList) == 2) && (valueList(1) <= valueList(2)),...
																													'electrictVehicles.json:' + string(evModel) + ' <chargeLevelPercentage.value> error!')
		powerValue = datasample(valueList(1):valueList(2), 1);
	else
		error('electrictVehicles.json:' + string(evModel) + ' <chargeLevelPercentage.format> undefined!');
	end
	
	% Calculate <runDuration_sample> of the charger
	batteryEmpty = ((100-batteryLevel)/100)*endUser.ev.(string(evModel)).batteryCapacity;
	runDuration_sample = duration2sample(hours(batteryEmpty/powerValue), 'inf');
	
	% Consider confliction constraints
	% If there is confliction constraint
	if endUser.ev.(string(evModel)).charger.constraints.conflictionConstraint.case
		% Get appliances which conflict
		conflictAppliances = transpose(cellstr(endUser.ev.(string(evModel)).charger.constraints.conflictionConstraint.list));
		% Be sure <conflictAppliances> is not empty
		assert(~isempty(conflictAppliances), 'electricVehicles.json:' + string(evModel) + ' <conflictionConstraint> configuration error!');
		
		% For each <conflictAppliances> which owned by the end-user, fill by -1 conflicted samples
		for conflictAppliance = conflictAppliances
			if isfield(endUser.appliances, string(conflictAppliance))
				conflictAppliance_mergedUsageVector = reshape(transpose(endUser.appliances.(string(conflictAppliance)).usageArray),...
																																																					1, COUNT_WEEKS*7*COUNT_SAMPLE_IN_DAY);
				mergedUsageVector(conflictAppliance_mergedUsageVector(lowerLimit:upperLimit) > 0) = single(-1);
			end
		end
	end
	
	%db1 = endUser;
	%db2 = runDay;
	%db3 = batteryLevel;
	% NOTE: This alagorithm aims that the EV fully charged if there is possibility
	% Select <startSample> randomly; consider <runDuration>
	possibleSamplesVector = find(mergedUsageVector == 0);
	possibleSamplesVector = possibleSamplesVector((possibleSamplesVector >=lowerLimit) & (possibleSamplesVector <= upperLimit));
	% If element count of <possibleSamplesVector> less than or equal to <runDuration_sample>,
	% then the EV will charged for all possible samples
	if numel(possibleSamplesVector) <= runDuration_sample
		% Assign worktime for this option
		mergedUsageVector(mergedUsageVector(lowerLimit:upperLimit) == 0) = single(powerValue);
	else
		offsetSamples = possibleSamplesVector(1:(end-runDuration_sample+1));
		% Select a <startSample> randomly (PRNG)
		startSample = datasample(offsetSamples, 1);
		% Index of <startSample>
		startSample_index = find(possibleSamplesVector == startSample);
		% Assign worktime for this option
		mergedUsageVector(possibleSamplesVector(startSample_index:startSample_index+runDuration_sample-1)) = single(powerValue);
	end
	 
	% Reshape <mergedUsageVector> to <usageArray>
	endUser.ev.(string(evModel)).charger.usageArray = transpose(reshape(mergedUsageVector, COUNT_SAMPLE_IN_DAY, COUNT_WEEKS*7));
end
