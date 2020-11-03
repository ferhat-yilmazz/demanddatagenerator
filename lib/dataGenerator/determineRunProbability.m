 %% بسم الله الرحمن الرحیم 

%% ## Determine Run Probability ##
% 07.10.2020, Ferhat Yılmaz

%% Description
%{
	Function to determine run probability of the apliance.

>> Inputs:
	1. <appliancesData> : structure : "appliancesData.json" config structure
	2. <endUser>: structure : Structure of the end-user
	3. <initialConditions> : structure : "initialConditions.json" config structure
	4. <startSample> : integer :  Randomly selected start time (discrete; sample)

<< Outputs:
	1. <probability> : matrix : Generated usage vector
%}

%%
function runProbability = determineRunProbability(appliancesData, endUser, initialConditions, appliance, startSample)
	% TODO: Apply formula to get run probability.
	runProbability = randi(100);
end
