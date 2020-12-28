 %% بسم الله الرحمن الرحیم 

%% ## Fitness Function ##
% 02.12.2020, Ferhat Yılmaz

%% Description
%{
	It is fitness function which used in genetic algorithm
	computation for parameter search. Each weeks each day and
	each part of day run probability will be calculated. Only appliance
	confliction constraints are not considered.

	>> Inputs:
	1. <endUserTypeStruct> : structure : Structure of the end-user type
	2. <appliance> : string: Name of the appliance
	3. <chromosome> : vector : A solution or an individual

<< Outputs:
	1. <fitnessValue> : integer : Fitness value of the applied solution
%}

%%
function fitnessValue = fitnessFunction(endUserTypeStruct, appliance, chromosome)
	% Count of weeks
	global COUNT_WEEKS;
	% Get randomization method
	global RAND_METHOD;
	% Get sample period
	global SAMPLE_PERIOD;
	% Get global maximum run duration limit
	global GLOB_MAX_OPERATION_LIMIT;
	% Get count sample in day
	global COUNT_SAMPLE_IN_DAY;
	
	% Define "daily usage count"(duc) and "weekly usage count"(wuc)
	wuc = single(0);
	duc = single(0);
	% Define total runtime sample
	trs = single(0);
	% Define daily run intervals
	runIntervals_daily = divideUsageVector(COUNT_SAMPLE_IN_DAY);
	
	% For each week
	for week_index = 1:COUNT_WEEKS
		% Define days of a week in random sort
		dayList = uint16(randperm(7));
		
		% For each day
		for day_index = dayList
			% Update <day_index> according to week
			runDay = (week_index-1)*7 + day_index;
			% Sort run intervals randomly
			runIntervals = runIntervals_daily(:,randperm(numel(runIntervals_daily(1,:))));

			% For each run interval
			for runInterval = runIntervals
				% Select a sample randomly (PRNG) from runInterval (it is start sample of the appliance)
				startSample = datasample(runInterval(1):runInterval(2), 1);
				% Check constraints, it is possible to run at selected sample for the appliance or not
				if endUserTypeStruct.appliances.(string(appliance)).usageArray(runDay,startSample)

					%{
						###############################################
						########## DETERMINE RUN PROBABILITY ##########

																									Apliance Needs Operator
																						_________________|_________________
																						|																	|
																			(TRUE)|																	|(FALSE)
																						|																	|
																End-User Have Job Schedule	  					   # E+N #
																	__________|__________                    
																	|										|
														(TRUE)|										|(FALSE)
																	|										|
														Start Time Located     # E+N #
															in Job Times												
														______|______																** E: Employed count					 
														|						|																** N: Nonemployed count
											(TRUE)|						|(FALSE)
														|						|									
													# N #      # E+N #

					%}

					% Get conditions
					cond1 = logical(endUserTypeStruct.appliances.(string(appliance)).needOperator);
					cond2 = logical(endUserTypeStruct.jobSchedule.case);
					cond3 = ismember(runDay, endUserTypeStruct.jobSchedule.workDays) &&...
																		isInInterval(startSample, endUserTypeStruct.jobSchedule.lowerSample, endUserTypeStruct.jobSchedule.upperSample);
					% According to diagram at above, determine run probability
					if cond1 && cond2 && cond3
						runProbability = (endUserTypeStruct.nonemployedCount * chromosome(1)) - (duc * chromosome(2)) - (wuc * chromosome(3));
					else
						runProbability = ((endUserTypeStruct.nonemployedCount + endUserTypeStruct.employedCount) * chromosome(1))...
																																																		- (duc * chromosome(2)) - (wuc * chromosome(3));
					end
					% ###############################################

					% Select a random number between [0,100] (TRNG or PRNG)
					randomRunNumber = getRandomVector(1, 0, 100, RAND_METHOD);

					% Check for the appliance can run or not
					if randomRunNumber <= runProbability
						% Increase <duc> and <wuc> values by 1
						duc = duc + 1;
						wuc = wuc + 1;

						% Convert start sample according to <day_index>
						startSample = (runDay-1)*COUNT_SAMPLE_IN_DAY + startSample;

						%{
							#########################################
							########## ASSIGN RUN DURATION ##########

																					Appliance Operation Mode
																	____________________|____________________
																	|																				|
																	|																				|
																	|																				|
													# Non-Periodic #													 # Periodic #
																	|																				|
																	|																				|
																	|																				|
															Run The Appliance									Select Runtime Duration
															 One Cycle		  										  		Randomly
																	|																		(Limited)
																	|																				|
																	|_______________________________________|
																											|
																											|
																											|
																		Assign Runtime Duration To Usage Array



						%}

						if strcmp(endUserTypeStruct.appliances.(string(appliance)).operation.mode, 'periodic')
							% Specify limits of random value of runtimeduration
							minLimit = duration2sample(timeVector2duration(endUserTypeStruct.appliances.(string(appliance)).operation.runDuration, 'inf')...
																			+ timeVector2duration(endUserTypeStruct.appliances.(string(appliance)).operation.waitDuration, 'inf'), 'inf');
							applianceMaxOperationLimit = duration2sample(timeVector2duration(endUserTypeStruct.appliances.(string(appliance))...
																																																			 .operation.maxOperationLimit, 'inf'), 'inf');
							if applianceMaxOperationLimit >= minLimit
								maxLimit = applianceMaxOperationLimit;
							else
								maxLimit = GLOB_MAX_OPERATION_LIMIT;
							end

							% Select runtime duration randomly according to limits
							runtimeSample = randi([minLimit maxLimit]);
							
						elseif strcmp(endUserTypeStruct.appliances.(string(appliance)).operation.mode, 'non-periodic')
							% Determine runtime sample
							runtimeSample = duration2sample(timeVector2duration(endUserTypeStruct.appliances.(string(appliance))...
																																																						 .operation.runDuration, 'inf'), 'inf');
						else
							error('appliancesData.json:' + string(appliance) + ' <operation.mode> undefined!');
						end

						% Assign runtime to usage array
						endUserTypeStruct.appliances.(string(appliance)).usageArray =...
															assignRunDuration2UsageArray(endUserTypeStruct.appliances.(string(appliance)).usageArray, startSample, runtimeSample);
						% Increase <trs> by runtime sample
						trs = trs + single(runtimeSample);
						% #########################################
					end
				end
			end
			% Reset <duc> for each new day
			duc = single(0);
		end
		% Reset <wuc> for each new day
		wuc = single(0);
	end
	% #############################################
	% ########## DETERMINE FITNESS VALUE ##########
	% Get real usage value of the appliance in minutes for the end-user type (weekly usage)
	endUserType_userCount = endUserTypeStruct.nonemployedCount + endUserTypeStruct.employedCount;
	
	% Determine real weekly usage value
	remainedPerson = endUserType_userCount - endUserTypeStruct.appliances.(string(appliance)).weeklyRunInReal.personCount;
	if remainedPerson > 0
		realWeeklyUsageInMinute = minutes(timeVector2duration(endUserTypeStruct.appliances.(string(appliance)).weeklyRunInReal.value, 'inf'));
		% Add duration for each remained person
		realWeeklyUsageInMinute = double(realWeeklyUsageInMinute +...
		 (remainedPerson * (minutes(timeVector2duration(endUserTypeStruct.appliances.(string(appliance)).weeklyRunInReal.additionEachPerson, 'inf')))));
	elseif remainedPerson == 0
			realWeeklyUsageInMinute = double(minutes(timeVector2duration(endUserTypeStruct.appliances.(string(appliance)).weeklyRunInReal.value, 'inf')));
	elseif remainedPerson < 0
		realWeeklyUsageInMinute = double((endUserType_userCount/endUserTypeStruct.appliances.(string(appliance)).weeklyRunInReal.personCount) *...
																			 minutes(timeVector2duration(endUserTypeStruct.appliances.(string(appliance)).weeklyRunInReal.value, 'inf')));
	end
	
	% Determine virtual weekly usage value
	virtualWeeklyUsageInMinute = double(trs * SAMPLE_PERIOD);
	
	% Compare real values and determined values, then return matching percentage
	fitnessValue = abs(((virtualWeeklyUsageInMinute-realWeeklyUsageInMinute)/realWeeklyUsageInMinute) * 100);
	% #############################################
end
