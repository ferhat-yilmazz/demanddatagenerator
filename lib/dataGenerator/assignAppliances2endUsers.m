 %% بسم الله الرحمن الرحیم 

%% ## Assign Appliances to End-Users ##
% 15.08.2020, Ferhat Yılmaz

%% Description
%{
	Function to assign appliances to end-users randomly. However randomization,
	there may be appliances which must never owed or which must always
	owned. Similarly, there are dependent appliances. These conditions
	must be considered.
	As an output, <endUsers> structure returns with appliances assigned
	for each user.

>> Inputs:
	1. <appliancesData> : structure : "appliancesData.json" config structure
	2. <electricVehicles> : structure . "electricVehicles.json" config structure
	4. <endUsers>: structure : A structure which describes the end-users
	5. <randMethod> : string :  Randomization method (PRNG or TRNG)

<< Outputs:
	1. <endUsers> : structure : random number structure
%}

%%
function endUsers = assignAppliances2endUsers(appliancesData, electricVehicles, endUsers)
	% Get count of end-users
	global COUNT_END_USERS;
	% Get rand method
	global RAND_METHOD;
	% Get count of weeks
	global COUNT_WEEKS;
	% Determine count of days
	countDays = COUNT_WEEKS*7;
	% Get names of appliances
	allAppliances = fieldnames(appliancesData);
	
	% Get names of electric vehicles
	% (Electric vehicles are assigned to end-users as independent from
	% other appliances. If an electric vehicle assigned, its charger assigned
	% automatically, too)
	evList = fieldnames(electricVehicles);
	
	% Generate randStructure to use in assignment of appliances
	randStructure_applianceAssignment = generateRandStructure(RAND_METHOD, 0, 1);
	
	% For each end-user
	for i = 1:COUNT_END_USERS
		% Check for 'always' and 'never' appliances
		[endUsers(i), checkedAppliances] = checkAlwaysNever(appliancesData, endUsers(i), allAppliances, countDays);


		% Seperate appliances as <dependentAppliances> and <independentAppliances>
		[independentAppliances, dependentAppliances] = separateAppliances(checkedAppliances, appliancesData);
		
		% Respectively assign appliances: firstly electric vehicles,
		% secondly independent appliances,
		% and finally dependent appliances
		
		% Check for end-user can have EV. There is three possiblities:
		% 1. haveEV:0 >> End-user exactly does not have an EV
		% 2. haveEV:1 >> End-user can have an EV (it is possible)
		% 3. haveEV:2 >> End-user exactly has an EV
		switch endUsers(i).properties.haveEV
			case 0
				% End-user exactly does not have an EV
				endUsers(i).ev = [];
			case 1
				% End-user can have an EV
				% Select a random bit
				[randNumber, randStructure_applianceAssignment] = pickRandNumber(randStructure_applianceAssignment);
				if randNumber
					% Select an EV from the list, randomly (PRNG is used for this)
					selectedEV = datasample(evList, 1);
					endUsers(i).ev.(string(selectedEV)) = electricVehicles.(string(selectedEV));
					% Assign usage vector
					endUsers(i).ev.(string(selectedEV)).charger.usageArray = repmat(generateUsageVector(),countDays,1);
				end
			case 2
				% End-user exactly have an EV
				% Select an EV from the list, randomly (PRNG is used for this)
				selectedEV = datasample(evList, 1);
				endUsers(i).ev.(string(selectedEV)) = electricVehicles.(string(selectedEV));
				% Assign usage vector
				endUsers(i).ev.(string(selectedEV)).charger.usageArray = repmat(generateUsageVector(),countDays,1);
		end

		% Assign independent appliances randomly
		for index = 1:numel(independentAppliances)
			[randNumber, randStructure_applianceAssignment] = pickRandNumber(randStructure_applianceAssignment);
			if randNumber
				% Assign usage vector
				endUsers(i).appliances.(string(independentAppliances(index))).usageArray =...
																																			repmat(generateUsageVector(),countDays,1);
				% Assign <duc> (dailyUsageCount), and <wuc> (weeklyUsageCount) if the appliance is not
				% continuous
				% Assing <tuc> (total usage count)
				if strcmp(appliancesData.(string(independentAppliances(index))).operation.mode, 'periodic')
					continuity = appliancesData.(string(independentAppliances(index))).operation.continuity;
				else
					continuity = 0;
				end

				if ~(continuity)
					endUsers(i).appliances.(string(independentAppliances(index))).duc = uint16(0);
					endUsers(i).appliances.(string(independentAppliances(index))).wuc = uint16(0);
				end
				endUsers(i).appliances.(string(independentAppliances(index))).tuc = uint16(0);
			end
		end
		
		% Assign dependent appliances randomly
		for index = 1:numel(dependentAppliances)
			dependencies = transpose(cellstr(appliancesData.(string(dependentAppliances(index))).dependency.list));
			% Check for the end-user have all dependecies
			dependencyCheckVector = ismember(dependencies, fieldnames(endUsers(i).appliances));
			if sum(dependencyCheckVector) == numel(dependencyCheckVector)
				[randNumber, randStructure_applianceAssignment] = pickRandNumber(randStructure_applianceAssignment);
				if randNumber
					% Assign usage vector
					endUsers(i).appliances.(string(dependentAppliances(index))).usageArray =...
																																			repmat(generateUsageVector(),countDays,1);
					% Assign <duc> (dailyUsageCount), and <wuc> (weeklyUsageCount) if the appliance is not
					% continuous
					% Assing <tuc> (total usage count)
					if strcmp(appliancesData.(string(dependentAppliances(index))).operation.mode, 'periodic')
						continuity = appliancesData.(string(dependentAppliances(index))).operation.continuity;
					else
						continuity = 0;
					end

					if ~(continuity)
						endUsers(i).appliances.(string(dependentAppliances(index))).duc = uint16(0);
						endUsers(i).appliances.(string(dependentAppliances(index))).wuc = uint16(0);
					end
					endUsers(i).appliances.(string(dependentAppliances(index))).tuc = uint16(0);
				end
			end
		end
	end
end