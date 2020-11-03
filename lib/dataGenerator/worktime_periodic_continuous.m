 %% بسم الله الرحمن الرحیم 

%% ## Assign Worktime for Periodic & Continuous Appliances ##
% 15.10.2020, Ferhat Yılmaz

%% Description
%{
	Function to assign worktime for the given periodic and continous appliance.
	These appliances run all day with given wait/run durations periodically. All
	days will be merged and considered as one timeline. There is no need
	run probability check!

>> Inputs:
	1. <appliancesData> : structure : "appliancesData.json" config structure 
	2. <endUser>: structure : Structure of the end-user
	3. <appliance> : string : Name of the appliance to assign worktime
	
<< Outputs:
	1. <endUser>: structure : Structure of the end-user
%}

%%
function endUser = worktime_periodic_continuous(appliancesData, endUser, appliance)
	% Get count of week
	global COUNT_WEEKS;
	% Get count of sample in a day
	global COUNT_SAMPLE_IN_DAY;
	% Get runDuration and waitDuration of the appliance and convert to sample
	runDuration_sample = duration2sample(double2duration(appliancesData.(string(appliance)).operation.runDuration));
	waitDuration_sample = duration2sample(double2duration(appliancesData.(string(appliance)).operation.waitDuration));
	
	% Merge all usage vectors in the usage array
	% Unused samples (because constraints) are signed by -1
	mergedUsageVector = reshape(transpose(endUser.appliances.(string(appliance)).usageArray),...
															1, COUNT_WEEKS*7*COUNT_SAMPLE_IN_DAY);
														
	% Get power value of charger
	valueList = transpose(appliancesData.(string(appliance)).power.value);
	valueFormat = appliancesData.(string(appliance)).power.format;
	if strcmp(valueFormat, 'choice')
		assert(numel(valueList) > 0, 'appliancesData.json:' + string(appliance) + ' <power.value> error!');
		powerValue = datasample(valueList, 1);
	elseif strcmp(valueFormat, 'interval')
		assert((numel(valueList) == 2) && (valueList(1) <= valueList(2)),...
																													'appliancesData.json:' + string(appliance) + ' <power.value> error!')
		powerValue = datasample(valueList(1):valueList(2), 1);
	else
		error('appliancesData.json:' + string(appliance) + ' <power.format> undefined!');
	end
	
	% Assign worktime; it is assumed that usage of the appliance start at first sample
	% If <runDuration> == 1 and <waitDuration> == 0; then the appliance runs non-stop
	if (runDuration_sample == 1) && (waitDuration_sample == 0)
		mergedUsageVector(mergedUsageVector ~= -1) = single(powerValue);
	elseif (runDuration_sample > 0) && (waitDuration_sample >= 0)
		periodLength = runDuration_sample+waitDuration_sample;
		periodCount = floor(numel(mergedUsageVector)/periodLength);
		remainedSample = mod(numel(mergedUsageVector), periodLength);
		
		% As many as count of period, the appliance runs and waits
		for step = 1:periodCount
			% Define a pointer which points first sample of period
			startPointer = ((step-1)*periodLength) + 1;
			% Define a pointer which points last sample of period
			endPointer = step*periodLength;
			
			% Check for there is not -1 along period
			if ~ismember(-1,mergedUsageVector(startPointer:endPointer))
				mergedUsageVector(startPointer:startPointer+runDuration_sample-1) = single(powerValue);
				% FIXME: Maybe following line is unneccessary
				% mergedUsageVector(startPointer+runDuration_sample:endPointer) = single(0);
			end
		end
		
		% Consider remained samples
		if remainedSample >= runDuration_sample
			if ~ismember(-1, mergedUsageVector(end-remainedSample+1:end-remainedSample+runDuration_sample))
				mergedUsageVector(end-remainedSample+1:end-remainedSample+runDuration_sample) = single(powerValue);
			end
		else
			if ~ismember(-1, mergedUsageVector(end-remainedSample+1:end))
				mergedUsageVector(end-remainedSample+1:end) = single(powerValue);
			end
		end
	else
		% If <runDuration> has another value, return error
		error('appliancesData.json:' + string(appliance) + ' <runDuration> or <waitDuration> contains undefined value!');
	end
	
	% Reshape merged usage vector to usage array
	endUser.appliances.(string(appliance)).usageArray = transpose(reshape(mergedUsageVector,...
																																COUNT_SAMPLE_IN_DAY, COUNT_WEEKS*7));
end
