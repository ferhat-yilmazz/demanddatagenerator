 %% بسم الله الرحمن الرحیم 

%% ## Assign a Type to End-Users ##
% 14.08.2020, Ferhat Yılmaz

%% Description
%{
	Assign a type to users. Types are selected from
	"residentalTypes.json" configuration file.
	Assignment process is made random. (PRNG or TRNG)
	<structure_endUsers> must be defined before call
	of the function.

>> Inputs:
	1. <residentalTypes> : structure : "residentalTypes.json" config structure
	2. <structure_endUsers>: structure : A structure which describes end-users
	3. <randMethod> : string :  Randomization method (PRNG or TRNG)

<< Outputs:
	1. <endUsers> : structure : random number structure
%}

%%
function endUsers = assignType2endUsers(residentalTypes, endUsers, randMethod)
	% Get count of end-users
	global COUNT_END_USERS
	
	% Get name of user types from <residentalTypes>
	typeList = fieldnames(residentalTypes);
	
	% Initialize random structure to assign user types
	% Upper limit of random numbers is determined
	% according to count of type
	randStructure_userTypeAssignment = generateRandStructure(randMethod, 1, numel(typeList));
	
	% Assign type for each end-user, randomly
	for i = 1:COUNT_END_USERS
		% Pick a random number
		[randNumber,randStructure_userTypeAssignment] = pickRandNumber(randStructure_userTypeAssignment);
		% Assign randomly selected type to end-user
		endUsers(i).type = string(typeList(randNumber));
		% Assign properties of the related type, to end-user structure
		endUsers(i).properties = residentalTypes.(endUsers(i).type);
	end
end
