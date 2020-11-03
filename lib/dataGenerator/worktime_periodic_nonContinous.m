 %% بسم الله الرحمن الرحیم 

%% ## Assign Worktime for Periodic & non-Continous Appliances ##
% 18.10.2020, Ferhat Yılmaz

%% Description
%{
	Function to assign worktime for the given periodic and
	non-continuous appliance. Run probability control is not included.
	Only confliction constraints will be checked.	
	The appliance will not run at confliction times if there is.

>> Inputs:
	1. <appliancesData> : structure : "appliancesData.json" config structure 
	2. <endUser>: structure : Structure of the end-user
	3. <appliance> : string : Name of the appliance to assign worktime
	4. <runDay>: integer : Day number which the appliance run
	5. <startSample> : integer : The sample which appliance start working
	6. <operationDuration> : Duration of run of the appliance in sample
	
<< Outputs:
	1. <endUser>: structure : Structure of the the end-user
%}

%%
function endUser = worktime_periodic_nonContinous(appliancesData, endUser, appliance, runDay, startSample, operationDuration)
	% Get count of week
	global COUNT_WEEKS;
	% Get count of sample in a day
	global COUNT_SAMPLE_IN_DAY;
	
	% Define a control bit to check the appliance worked or not
	applianceIsWorked = false;
	
	% Reshape the <usageArray> to <mergedUsageVector>
	mergedUsageVector = reshape(transpose(endUser.appliances.(string(appliance)).usageArray), 1, COUNT_WEEKS*7*COUNT_SAMPLE_IN_DAY);
	totalSampleCount = numel(mergedUsageVector);
	% Get <runDuration> and <waitDuration> in sample 
	runDuration_sample = duration2sample(double2duration(appliancesData.(string(appliance)).operation.runDuration));
	waitDuration_sample = duration2sample(double2duration(appliancesData.(string(appliance)).operation.waitDuration));
	onePeriod_sample = runDuration_sample + waitDuration_sample;
	
	% Get power value of the appliance
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
	% According to type of the appliance, change sign of <powerValue>
	% Type 0 => Consumer
	% Type 1 => Producer
	if appliancesData.(string(appliance)).type
		powerValue = -powerValue;
	end
	
	% Determine <startPointer> and <endPointer> 
	startPointer = (runDay-1)*COUNT_SAMPLE_IN_DAY + startSample;
	endPointer = startPointer + onePeriod_sample - 1;
	
	% Check for 'out of index'; update <operationDuration> against to risk
	if (startPointer+operationDuration-1) > totalSampleCount
		operationDuration = totalSampleCount - startPointer + 1;
	end
	
	% Check that is there any confliction constraint for the appliance
	if appliancesData.(string(appliance)).constraints.conflictionConstraint.case
		conflictAppliances = transpose(cellstr(appliancesData.(string(appliance)).constraints.conflictionConstraint.list));
		% Be sure <conflictAppliances> are not empty
		assert(~isempty(conflictAppliances), 'appliancesData.json:' + string(appliance) +...
																				 ' constraints <conflictionConstraint> configuration error!');
		
		% For each conflict appliance which owned by the end-user
		for conflictAppliance = conflictAppliances
			if isfield(endUser.appliances, string(conflictAppliance))
				conflictAppliance_mergedUsageVector = reshape(transpose(endUser.appliances.(string(conflictAppliance)).usageArray),...
																																																					1, COUNT_WEEKS*7*COUNT_SAMPLE_IN_DAY);
				mergedUsageVector(conflictAppliance_mergedUsageVector(startPointer:(startPointer+operationDuration-1)) > 0) = single(-1);
			end
		end	
	end
	
	% Until <operationDuration> less than or equal to 0
	% (or if detected the appliance already running)
	while  operationDuration >= runDuration_sample
		% Consider length of the <operationDuration>
		if endPointer > totalSampleCount
			operationDuration = 0;
			% Move <endPointer> to last sample of the <mergedUsageVector>
			endPointer = totalSampleCount;
			% Update <runDuration> against risk of out of vector index
			if (endPointer-startPointer+1)< runDuration_sample
				runDuration_sample = startPointer-endPointer+1;
			end
		end
		
		% Consider conflicted samples
		if all(mergedUsageVector(startPointer:endPointer) ~= -1)
			% Consider if the appliance already running
			if any(mergedUsageVector(startPointer:endPointer) > 0)
				break;
			else
				% Insert worktime
				mergedUsageVector(startPointer:(startPointer+runDuration_sample-1)) = single(powerValue);
				% mergedUsageVector((startPointer+runDuration_sample):(startPointer+runDuration_sample+waitDuration_sample-1)) = single(0);
				
				% Specify that the appliance worked
				applianceIsWorked = true;
				
				startPointer = startPointer + onePeriod_sample;
				endPointer = startPointer + onePeriod_sample - 1;
			end
		else
			startPointer = startPointer + onePeriod_sample;
			endPointer = startPointer + onePeriod_sample - 1;
		end
		
		% Decrease <operationDuration>
		operationDuration = operationDuration - onePeriod_sample;
	end
	
	% Reshape <mergedUsageVector> to <usageArray>
	endUser.appliances.(string(appliance)).usageArray = transpose(reshape(mergedUsageVector, COUNT_SAMPLE_IN_DAY, COUNT_WEEKS*7));
	
	% Increase by 1 <duc> and <wuc> if the appliance worked
	if applianceIsWorked
		endUser.appliances.(string(appliance)).duc = endUser.appliances.(string(appliance)).duc + uint16(1);
		endUser.appliances.(string(appliance)).wuc = endUser.appliances.(string(appliance)).wuc + uint16(1);
		endUser.appliances.(string(appliance)).tuc = endUser.appliances.(string(appliance)).tuc + uint16(1);
	end
end
