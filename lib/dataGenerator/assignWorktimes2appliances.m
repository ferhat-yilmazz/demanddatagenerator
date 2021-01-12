 %% بسم الله الرحمن الرحیم 

%% ## Assign Worktimes of Appliances ##
% 11.10.2020, Ferhat Yılmaz

%% Description
%{
	Function to assign worktimes of appliances for each end-user.
	Each part of day select a time randomly. Check for confliction
	constraints, then calculate run probability. Then, select a number
	between 0-100 randomly. Compare run probability and selected
	random number. If random number is less than or equal to run
	probability, then the appliance will be run at the selected moment.

	If there is confliction, another time selection is not made.
	If the run probability is less than the selected random number,
	another operation is not made for the part of day.

	Appliances selected randomly from list to apply confliction
	rules fairly.

>> Inputs:
	1. <endUsers>: structure : A structure which describes end-users
	2. <appliancesData> : structure : "appliancesData.json" config structure
	3. <electricVehicles> : structure : "electricVehicles.json" config structure
	4. <initialCOnditions> : structure : "initialConditions.json" config structure

<< Outputs:
	1. <endUsers>: structure : A structure which describes the end-users
%}

%%
function endUsers = assignWorktimes2appliances(endUsers, appliancesData, initialConditions)
	% Get week count we will determine
	global COUNT_WEEKS;
	% Get sample count for a day
	global COUNT_SAMPLE_IN_DAY;
	% Get count of end-users
	global COUNT_END_USERS;
	% Get randomization method
	global RAND_METHOD;
	% Get global maximum operation duration limit
	global GLOB_MAX_OPERATION_LIMIT;
	% Get maximum count of EV battery statuses
	global BATTERY_LEVEL_RAND_LIMIT;

	% Get run intervals in a day
	runIntervals_daily = divideUsageVector(COUNT_SAMPLE_IN_DAY);
	
	% NOTE: In this function an iteration without iteration varible
	% used. Maybe there is incompability for lower versions of MATLAB.
	
	% Generate a random structure to select start sample of appliances
	randStructure_startSample = generateRandStructure(RAND_METHOD, 1, COUNT_SAMPLE_IN_DAY);
	% Generate a random structure to determine working duration
	% for periodic & non-continuous appliaces
	randStructure_operationDuration = generateRandStructure(RAND_METHOD, 1, GLOB_MAX_OPERATION_LIMIT);
	% Generate a random structure to get randomnumber between 0 and 100 for comparison with run
	% probability result. If the selected random number less or equal than run probability then
	% the appliance will run; otherwise will not.
	randStructure_4runProbability = generateRandStructure(RAND_METHOD, 1, 100);
	% Generate a random structure to select battery status of an EV
	randStructure_EVBatteryLevel = generateRandStructure(RAND_METHOD, 1, BATTERY_LEVEL_RAND_LIMIT);
	
	% For each end-user
	for user_index = 1:COUNT_END_USERS
		disp("enduser: " + string(user_index));
		% Get appliances list
		appliances = transpose(fieldnames(endUsers(user_index).appliances));
		% Re-sort appliances list randomly (PRNG)
		appliances = appliances(randperm(numel(appliances)));
		
		% Get EV list
		if isstruct(endUsers(user_index).ev)
			evList = cellstr(fieldnames(endUsers(user_index).ev));
		else
			evList = {};
		end
		
		% Select periodic and continuous appliances from given list
		for appliance = appliances
			if strcmp(appliancesData.(string(appliance)).operation.mode, 'periodic')
				if appliancesData.(string(appliance)).operation.continuity == 1
					% Assign worktimes to periodic & continuous appliances
					endUsers(user_index) = worktime_periodic_continuous(appliancesData, endUsers(user_index), appliance);
				end
			end
		end
		
		% For each week
		for week_index = 1:COUNT_WEEKS
			% Generate day vector randomly (PRNG)
			days = randperm(7);
			
			% For each day
			for runDay_index = days
				runDay = (week_index-1)*7 + runDay_index;
				% Re-sort daily run intervals randomly (PRNG)
				runIntervals = runIntervals_daily(:,randperm(numel(runIntervals_daily(1,:))));
				
				% For each part of day
				for runInterval = runIntervals
					% For each appliances
					for appliance = appliances
						% For each appliance there is three option:
						%		1."Periodic and Continuous Appliances": Check for confliction constraints. If there
						%			is any confliction for previously assigned appliances, the appliances cannot run
						%			at conflicted samples.
						%
						%		2. "Periodic and Non-Continuous Appliances": Firstly, select a start sample
						%			randomly. After that, check for run probability. If the appliance runable at
						%			selected sample, randomly assign run duration with given limits (global or local
						%			limits). Lastly, assign worktime to the appliance with parameters. Confliction check
						%			will made at worktime assignment function.
						%
						%		3. "Non-Periodic Appliances": Firstly, select a start sample randomly. After that,
						%			check for run probability. If it is positive, assign worktime. Confliction check
						%			will made at worktime assignment function.
						
						% Check for periodicity and continuity for the appliance
						periodicity = strcmp(appliancesData.(string(appliance)).operation.mode, 'periodic');
						if periodicity
							continuity = appliancesData.(string(appliance)).operation.continuity;
						else
							continuity = 0;
						end
						
						% OPTIONS
						% ######### NON-PERIODIC #########
						if (periodicity == 0)
							% Generate interval vector from <runInterval>
							intervalVector = runInterval(1):runInterval(2);
							
							% Get a start sample from given "run interval samples" randomly
							[randomStartSample, randStructure_startSample] = pickRandNumber(randStructure_startSample);
							randomStartSample = intervalVector(mod(randomStartSample, numel(intervalVector)) + 1);
							
							% Determine <runProbability>
							run_probability = determineRunProbability(appliancesData, endUsers(user_index), initialConditions, appliance, randomStartSample);
							% Get a random number to compare with <run_probability>
							[randomNum2compareRunProbability, randStructure_4runProbability] = pickRandNumber(randStructure_4runProbability);
							
							% If <randomNum2compareRunProbability> is less than or equal to <run_probability> the
							% appliance will run
							if randomNum2compareRunProbability <= run_probability
								endUsers(user_index) = worktime_nonPeriodic(appliancesData, endUsers(user_index), appliance, runDay, randomStartSample);
							end
						% ######### PERIODIC & NON-CONTINUOUS #########
						elseif (periodicity == 1 && continuity == 0)
							% Generate interval vector from <runInterval>
							intervalVector = runInterval(1):runInterval(2);
							
							% Get a start sample from given "run interval samples" randomly
							[randomStartSample, randStructure_startSample] = pickRandNumber(randStructure_startSample);
							randomStartSample = intervalVector(mod(randomStartSample, numel(intervalVector)) + 1);
							
							% Determine <runProbability>
							run_probability = determineRunProbability(appliancesData, endUsers(user_index), initialConditions, appliance, randomStartSample);
							% Get a random number to compare with <run_probability>
							[randomNum2compareRunProbability, randStructure_4runProbability] = pickRandNumber(randStructure_4runProbability);
							
							% If <randomNum2compareRunProbability> is less than or equal to <run_probability> the
							% appliance will run
							if randomNum2compareRunProbability <= run_probability
								% Select operation duration randomly
								% Be sure that operation duration is enough to run the appliance least one period
								runDuration_sample = duration2sample(double2duration(appliancesData.(string(appliance)).operation.runDuration, 'inf'), 'inf');
								waitDuration_sample = duration2sample(double2duration(appliancesData.(string(appliance)).operation.waitDuration, 'inf'), 'inf');
								onePeriod_sample = runDuration_sample + waitDuration_sample;
								while true
									[randomOperationDuration, randStructure_operationDuration] = pickRandNumber(randStructure_operationDuration);
									if randomOperationDuration >= runDuration_sample
										% Limit the <operationDuration>
										% If there is maximum operation limit belongs to the appliance, <operationDuration> updated with
										% this limit
										applianceOperationLimit = duration2sample(double2duration(appliancesData.(string(appliance)).operation.maxOperationLimit, 'inf'), 'inf');
										
										if (applianceOperationLimit >= onePeriod_sample) && (randomOperationDuration > applianceOperationLimit)
											randomOperationDuration = applianceOperationLimit;
										elseif (applianceOperationLimit ~= 0) && (applianceOperationLimit < onePeriod_sample)
											error('appliancesData.json:' + string(appliance) + ' <maxOperationLimit> error!');
										end
										
										break;
									end
								end
								
								% Assign woktime to the appliance
								endUsers(user_index) = worktime_periodic_nonContinous(appliancesData, endUsers(user_index), appliance, runDay, randomStartSample, randomOperationDuration);
							end
						% ######### PERIODIC % CONTINUOUS #########
						elseif (periodicity == 1 && continuity == 1)
							conflictionCheck4periodic_continuous(appliancesData, endUsers(user_index), appliance, runDay, runInterval);
						else
							error('<appliancesData.json>:' + string(appliance) + ' operation <mode> and/or <continuity> undefined!');
						end
					end
				end
				% ######### ELECTRIC VEHICLE WORKTIME ASSIGNMENT #########
				% For each EV, select a battery level randomly; then assign worktime according to battery
				% level. Run duration determined by battery level and charger power.
				for evModel = evList
					batteryLevels = endUsers(user_index).ev.(string(evModel)).chargeLevelPercentage.value;
					batteryLevel_chooseFormat = endUsers(user_index).ev.(string(evModel)).chargeLevelPercentage.format;

					% Choose battery status randomly
					if strcmp(batteryLevel_chooseFormat, 'interval')
						assert(numel(batteryLevels) == 2, 'electrictVehicles.json:' + string(evModel) + ' <chargeLevelPercentage.format> error!');
						assert(batteryLevels(1) <= batteryLevels(2), 'electrictVehicles.json:' + string(evModel) + ' <chargeLevelPercentage.value> error!');

						batteryLevel_vector = batteryLevels(1):batteryLevels(2);
						[randomBatteryLevel, randStructure_EVBatteryLevel] = pickRandNumber(randStructure_EVBatteryLevel);
						randomBatteryLevel = batteryLevel_vector(mod(randomBatteryLevel, numel(batteryLevel_vector)) + 1);
					elseif strcmp(batteryLevel_chooseFormat, 'choice')
						assert(numel(batteryLevels) >= 1, 'electrictVehicles.json:' + string(evModel) + ' <chargeLevelPercentage.value> error!');

						[randomBatteryLevel, randStructure_EVBatteryLevel] = pickRandNumber(randStructure_EVBatteryLevel);
						randomBatteryLevel = batteryLevels(mod(randomBatteryLevel, numel(batteryLevels)) + 1);
					else
						error('electrictVehicles.json:' + string(evModel) + ' <chargeLevelPercentage.format> undefined!');
					end

					% Assign worktime to the EV if <randomBatteryLevel> is not 100; else charging is not
					% neccessary.
					if randomBatteryLevel ~= 100
						endUsers(user_index) = worktime_ev(evModel, endUsers(user_index), runDay, randomBatteryLevel);
					end
				end
				% Reset daily usage counter for each appliance belong to the end-user
				endUsers(user_index) = resetApplianceUsageCounter(endUsers(user_index), 'duc');
			end
			% Reset weekly usage counter for each appliance belong to the end-user
			endUsers(user_index) = resetApplianceUsageCounter(endUsers(user_index), 'wuc');
		end
	end
end
