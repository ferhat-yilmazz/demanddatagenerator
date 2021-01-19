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
	1. <endUser> : structure : The structure of the end-user
	2. <baseStructure> : structure : Base structure
	3. <evIndex> : integer : Index of the electric vehicle for the end-user
	4. <evID> : integer : ID of the electric vehicle for the baseStructure
	4. <dayIndex> : integer : Day index
	5. <batteryLevel> : integer : Selected battery level
	6. <COUNT_WEEKS> : integer : Count of weeks
	7. <COUNT_SAMPLE_IN_DAY> : integer : Sample count in a day
	
<< Outputs:
	1. <evUsageArray> : array : Usage array of the EV
%}

%%
function evUsageArray = worktime_ev(endUser, baseStructure, evIndex, evID, dayIndex, batteryLevel, COUNT_WEEKS, COUNT_SAMPLE_IN_DAY)
	% Assign the usage array of the electric vehichle to <evUsageArray>
	evUsageArray = endUser.EVs(evIndex).usageArray;
	
	% Firstly determine charge duration according to inserted <batteryLevel> parameter
	if batteryLevel == 100
		% If it is already full (i.e 100) than return and do nothing
		return;
	elseif (batteryLevel < 0) || (batteryLevel > 100)
		% If it grater than 100 or less than zero return error
		error("<worktime_ev> : <batteryLevel> must be in range [0,100]");
	else
		% It is aimed to charge battery until it is full
		lackBatteryLevel = baseStructure.electricVehicles(evID).batteryCapacity * (1- (batteryLevel/100));
		% Select charger power in specified "electricVehicles.json" configuration file
		chargerPower = chooseValue(baseStructure.electricVehicles(evID).charger.power.value,...
															 baseStructure.electricVehicles(evID).charger.power.format);
		% Determine how many sample takes to charge battery fully
		chargeDuration = duration2sample(hours(lackBatteryLevel/chargerPower), 'inf');
	end
	
	% Merge the usage array of charger of the electric vehicle
	mergedUsageArray = reshape(transpose(evUsageArray), 1, COUNT_WEEKS*7*COUNT_SAMPLE_IN_DAY);
	
	% Determine <lowerPointer> and <upperPointer>
	lowerPointer = (dayIndex-1)* COUNT_SAMPLE_IN_DAY + 1;
	upperPointer = (dayIndex)*COUNT_SAMPLE_IN_DAY;
	
	% Find possible <startPointer> and <endPointer> according to <chargeDuration>
	% Find runable samples
	runableSamples = find(mergedUsageArray == 0);
	runableSamples = runableSamples((runableSamples >= lowerPointer) & (runableSamples <= upperPointer));
	% Check for <runableSamples> is fit to <chargeDuration>
	if sum(runableSamples) <= chargeDuration
		% Assign <startPointer>
		startPointer = 1;
		% Assign <endPointer>
		endPointer = numel(runableSamples);
	else
		possibleStartPointers = 1:(numel(runableSamples)-chargeDuration+1);
		% Select on of them randomly and assign as <startPointer>
		randStartPointerIndex = randi(numel(possibleStartPointers));
		startPointer = possibleStartPointers(randStartPointerIndex);
		% Assign <endPinter>
		endPointer = startPointer + chargeDuration - 1;
	end
	
	% Assign usage interval with <chargerPower>
	mergedUsageArray(runableSamples(startPointer:endPointer)) = chargerPower;
	
	% Reshap <mergedUsageArray> and assign it to <evUsageArray>
	evUsageArray = transpose(reshape(mergedUsageArray, COUNT_SAMPLE_IN_DAY, COUNT_WEEKS*7));
end
