 %% بسم الله الرحمن الرحیم 

%% ## Assign a Type to End-Users ##
% 14.08.2020, Ferhat Yılmaz

%% Description
%{
	Assign a type to end-users. Types are selected from
	<baseStructure.endUserTypes>

	When assigning types to end-users, if wish 'TRNG' can be used.

>> Inputs:
	1. <endUsers> : structure : The structure which contains the end-users
	2. <baseStructure> : structure : Base structure
	3. <COUNT_END_USERS> : integer : Count of end-users
	4. <RAND_METHOD> : string :  Randomization method (PRNG or TRNG)

<< Outputs:
	1. <endUsers>: structure : The structure which contains the end-users
%}

%%
function endUsers = assignType2endUsers(endUsers, baseStructure, COUNT_END_USERS, RAND_METHOD)
	% Get count of end-user types
	endUserTypeCount = size(baseStructure.endUserTypes, 2);
	
	% Define random structure for end-user type
	if COUNT_END_USERS < 9999
		poolSize = COUNT_END_USERS;
	else
		poolSize = 9999;
	end
	rand4endUserTypes = generateRandStructure(1, endUserTypeCount, RAND_METHOD, poolSize);
	
	% Assign type for each end-user
	for i = 1:COUNT_END_USERS
		% Pick a random number
		[randTypeID,rand4endUserTypes] = pickRandNumber(rand4endUserTypes);
		% Assign typeID to the end-user
		endUsers(i).typeID = randTypeID;
		% Assign type to the end-user
		% endUsers(i).type = baseStructure.endUserTypes(randTypeID).type;
	end
end
