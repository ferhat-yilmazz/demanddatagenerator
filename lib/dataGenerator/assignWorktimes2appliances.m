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
	1. <endUsers> : structure : The structure which contains the end-users
	2. <baseStructure> : structure : Base structure
	3. <COUNT_SAMPLE_IN_DAY> : integer : Sample count in a day
	4. <COUNT_END_USERS> : integer : Count of end-users
	5. <COUNT_WEEKS> : integer : Count of weeks
	6. <COUNT_DAYS> : integer : Count of the days
	7. <DAY_PIECE> : integer : Count of pieces of a day

<< Outputs:
	1. <endUsers>: structure : The structure which contains the end-users
%}

%%
function endUsers = assignWorktimes2appliances(endUsers, baseStructure,runProbabilityParameters, defaultCoefficients,...
																							 SAMPLE_PERIOD, COUNT_SAMPLE_IN_DAY, COUNT_END_USERS, COUNT_WEEKS, DAY_PIECE)
	% Determine part index' of a usage vector
	dayPartIndex = divideUsageVector(COUNT_SAMPLE_IN_DAY, DAY_PIECE);
	
	% For each end-user (parfor optional)
	parfor endUser_idx = 1:COUNT_END_USERS
		fprintf("«« End-User: %5d worktime assignment process... »»\n", endUser_idx);
		% Get user type ID
		endUserTypeID = endUsers(endUser_idx).typeID;
		% Get count of EVs
		evsCount = size(endUsers(endUser_idx).EVs, 2);
		% Get count of appliances
		appliancesCount = size(endUsers(endUser_idx).appliances, 2);
		
		% Merge <evIndexList> and <applianceIndexList>; but multiply <evIndexList> by -1
		% to avoid uncertainty
		mergedAppEvList = [(1:appliancesCount) -(1:evsCount)];
		
		% ## Assign work times for other appliances ##
		% For each week
		for week_idx = 1:COUNT_WEEKS
			% Get list of week days random sorted
			dayList = uint8(randperm(7));
			% For each day
			for day_idx = 1:7
				% Day in week
				dayNumber = dayList(day_idx);
				% Determine day index
				dayIndex = single((week_idx-1)*7 + dayNumber);
				% Randomly sort <mergedAppEvList> for each day
				mergedAppEvList = mergedAppEvList(randperm(numel(mergedAppEvList)));
				% For each appliance in the list <mergedAppEvList>
				for applianceEV_idx = 1:numel(mergedAppEvList)
					% Get index of the selection
					applianceIndex = mergedAppEvList(applianceEV_idx);
					% Check for it is an EV or an appliance
					if applianceIndex < 0
						% ####### ELECTRIC VEHICLE #######
						% Take absolute value of <applianceIndex> to find <evIndex>
						evIndex = abs(applianceIndex);
						% It is a electric vehicle, get evID
						evID = endUsers(endUser_idx).EVs(evIndex).evID;
						% Now check for confliction issue; if there is conflicted
						% appliances, fill by -1 intersection samples in the electric vehicle
						% charger usage array
						endUsers(endUser_idx).EVs(evID).usageArray = conflictionCheck(endUsers(endUser_idx), baseStructure, 'e', evID, evIndex, dayIndex,...
																																						 1, COUNT_SAMPLE_IN_DAY, COUNT_WEEKS, COUNT_SAMPLE_IN_DAY);
						% Select battery level randomly (options specified in "electricvehicles.json" configuraiton file)
						randBatteryLevel = chooseValue(baseStructure.electricVehicles(evID).chargeLevelPercentage.value,...
																						 baseStructure.electricVehicles(evID).chargeLevelPercentage.format);
						% Assign work time for the EV
						endUsers(endUser_idx).EVs(evIndex) = worktime_ev(baseStructure, endUsers(endUser_idx).EVs(evIndex),...
																																			 dayIndex, randBatteryLevel, SAMPLE_PERIOD, COUNT_WEEKS, COUNT_SAMPLE_IN_DAY);
						% ################################
					elseif applianceIndex > 0
						% ####### APPLIANCE #######
						% Get list of day part index' random sorted
						dayPartList = dayPartIndex(:, randperm(size(dayPartIndex, 2)));
						% Get applianceID
						applianceID = endUsers(endUser_idx).appliances(applianceIndex).applianceID;
						% Get periodicity and continuity values of the appliance
						periodicity = baseStructure.appliances(applianceID).operation.periodicity;
						continuity = baseStructure.appliances(applianceID).operation.continuity;
						% Determine type of the appliance:
						%		* Non-periodic
						%		* Periodic & Non-continuous
						%		* Periodic & Continuous
						if ~periodicity
							% <<<<<<< NON-PERIODIC >>>>>>>
							% Check confliction issue for the "periodic and non-continuous" appliance
							endUsers(endUser_idx).appliances(applianceIndex).usageArray = conflictionCheck(endUsers(endUser_idx), baseStructure,...
																					  	'a', applianceID, applianceIndex, dayIndex, 1, COUNT_SAMPLE_IN_DAY, COUNT_WEEKS, COUNT_SAMPLE_IN_DAY);
							% Each part of day
							for part_idx = 1:size(dayPartList, 2)
								% Select a run sample randomly in the interval
								randomStartSample = randi([dayPartList(1, part_idx) dayPartList(2, part_idx)]);
								% Determine probability to work the appliance at the selected sample
								runProbability = determineRunProbability(endUserTypeID, baseStructure, endUsers(endUser_idx).appliances(applianceIndex),...
																												 runProbabilityParameters, defaultCoefficients.runprobabilityParameters,...
																												 dayNumber, randomStartSample);
								% Assign work time for the "non-periodic" appliance if conditions satisfied
								if runProbability >= randi([1 100])
									endUsers(endUser_idx).appliances(applianceIndex) = worktime_nonPeriodic(baseStructure,...
																																													endUsers(endUser_idx).appliances(applianceIndex),...
																																													dayIndex, randomStartSample,...
																																													COUNT_WEEKS, COUNT_SAMPLE_IN_DAY);
								end
							end
						elseif periodicity && ~continuity
							% <<<<<<< PERIODIC & NON-CONTINUOUS >>>>>>>
							% Check confliction issue for the "periodic and non-continuous" appliance
							endUsers(endUser_idx).appliances(applianceIndex).usageArray = conflictionCheck(endUsers(endUser_idx), baseStructure,...
																					  	'a', applianceID, applianceIndex, dayIndex, 1, COUNT_SAMPLE_IN_DAY, COUNT_WEEKS, COUNT_SAMPLE_IN_DAY);
							% Each part of day
							for part_idx = 1:size(dayPartList, 2)
								% Select a run sample randomly ib the interval
								randomStartSample = randi([dayPartList(1, part_idx) dayPartList(2, part_idx)]);
								% Determine probability to work the appliance at the selected sample
								runProbability = determineRunProbability(endUserTypeID, baseStructure, endUsers(endUser_idx).appliances(applianceIndex),...
																												 runProbabilityParameters, defaultCoefficients.runprobabilityParameters,...
																												 dayNumber, randomStartSample);
								% Determine operation duration randomly if the condition satisfied
								if runProbability >= randi([1 100])
									% Determine limits of operation
									minDuration = baseStructure.appliances(applianceID).operation.runDuration + baseStructure.appliances(applianceID).operation.waitDuration;
									maxDuration = baseStructure.appliances(applianceID).operation.maxOperationLimit;
									
									% Select duration randomly
									operationDuration = randi([minDuration maxDuration]);
									
									% Sure that <runtimeSamle> can divided "runDuration + waitDuration" exactly
									if mod(operationDuration, minDuration) ~= 0
										operationDuration = operationDuration - (mod(operationDuration, minDuration));
									end
									
									% Assign worktime of the appliance with <randomStartSample> and <runDuration>
									endUsers(endUser_idx).appliances(applianceIndex) = worktime_periodic_nonContinous(baseStructure,...
																																		 endUsers(endUser_idx).appliances(applianceIndex), dayIndex,...
																																		 randomStartSample, operationDuration, COUNT_WEEKS, COUNT_SAMPLE_IN_DAY);
								end
							end
						elseif periodicity && continuity
							% <<<<<<< PERIODIC & CONTINUOUS >>>>>>>
							% Check confliction issue for the "periodic and continuous" appliance
							endUsers(endUser_idx).appliances(applianceIndex).usageArray = conflictionCheck(endUsers(endUser_idx), baseStructure,...
																					  	'a', applianceID, applianceIndex, dayIndex, 1, COUNT_SAMPLE_IN_DAY, COUNT_WEEKS, COUNT_SAMPLE_IN_DAY);
							% Assign worktime for the periodic & non-continuous apliance
							endUsers(endUser_idx).appliances(applianceIndex) = worktime_periodic_continuous(baseStructure,...
																																 endUsers(endUser_idx).appliances(applianceIndex), dayIndex,...
																																 COUNT_WEEKS, COUNT_SAMPLE_IN_DAY);
						else
							error(strcat("<assignWorkTimes2appliances> : ", "ApplianceID: ", string(applianceID), " operation mode undefined"));
						end
					% ################################
					else
						error("<assignWorkTimes2appliances> : Appliance/EV index for any end-user cannot be zero");
					end
				end
				% Reset <duc> for appliances belong to the end-user
				endUsers(endUser_idx).appliances = resetApplianceUsageCounter(endUsers(endUser_idx).appliances, 'duc');
			end
			% Reset <wuc> for appliances belong to the end-user
			endUsers(endUser_idx).appliances = resetApplianceUsageCounter(endUsers(endUser_idx).appliances, 'wuc');
		end
	end
end
