 %% بسم الله الرحمن الرحیم 

%% ## Assign Worktime for Periodic & non-Continous Appliances ##
% 18.10.2020, Ferhat Yılmaz

%% Description
%{
	Function to assign worktime for the given periodic and
	non-continuous appliance. Run probability control is not included.
	Only confliction constraints will be checked.	
	The appliance will not run if there is confliction during work time, although
	it passed run probability check.

>> Inputs:
	1. <appliancesData> : structure : "appliancesData.json" config structure 
	2. <endUser>: structure : Structure of the end-user
	3. <appliance> : string : Name of the appliance to assign worktime
	4. <runDay>: integer : Day number which the appliance run
	5. <startSample> : integer : The sample which appliance start working
	
<< Outputs:
	1. <endUser>: structure : Structure of the the end-user

%}

%%
function endUser = worktime_nonPeriodic(appliancesData, endUser, appliance, runDay, startSample)
	% Get count of week
	global COUNT_WEEKS;
	% Get count of sample in a day
	global COUNT_SAMPLE_IN_DAY;
	
	% Define a control bit to check the appliance worked or not
	applianceIsWorked = false;
	
	% Reshape the <usageArray> to <mergedUsageVector>
	mergedUsageVector = reshape(transpose(endUser.appliances.(string(appliance)).usageArray), 1, COUNT_WEEKS*7*COUNT_SAMPLE_IN_DAY);
	totalSampleCount = numel(mergedUsageVector);
	
	% Get <runDuration> of the appliance
	runDuration_sample = duration2sample(double2duration(appliancesData.(string(appliance)).operation.runDuration));
	
	% Determine <startPointer> and <endPointer>
	startPointer = (runDay-1)*COUNT_SAMPLE_IN_DAY + startSample;
	endPointer = startPointer + runDuration_sample - 1;
	
	% Check for 'out of index'; update <operationDuration> against to risk
	if endPointer > totalSampleCount
		endPointer = totalSampleCount;
	end
	
	% Check for is there <conflictAppliances>
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
				mergedUsageVector(conflictAppliance_mergedUsageVector(startPointer:endPointer) == 1) = single(-1);
			end
		end
	end
	
	% Consider that is there conflicted samples
	if ~ismember(-1, mergedUsageVector(startPointer:endPointer))
		% Consider for over run
		if ~ismember(1, mergedUsageVector(startPointer:endPointer))
			% Insert worktime
			mergedUsageVector(startPointer:endPointer) = single(1);
			
			% Specify that the appliance worked
			applianceIsWorked = true;
		end
	end
	
	% Reshape the <mergedUsageVector> to <usageArray>
	endUser.appliances.(string(appliance)).usageArray = transpose(reshape(mergedUsageVector, COUNT_SAMPLE_IN_DAY, COUNT_WEEKS*7));
	
	% Increase by 1 <duc> and <wuc> if the appliance worked
	if applianceIsWorked
		endUser.appliances.(string(appliance)).duc = endUser.appliances.(string(appliance)).duc + uint16(1);
		endUser.appliances.(string(appliance)).wuc = endUser.appliances.(string(appliance)).wuc + uint16(1);
	end
end
