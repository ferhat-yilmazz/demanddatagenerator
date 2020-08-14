 %% بسم الله الرحمن الرحیم 

%% ## Random Number Structure ##
% 07.08.2020, Ferhat Yılmaz

%% Description
%{
	Function to generate random number structure. Structure
	has 3 items: Random number pool, index,randomization
	method (PRNG or TRNG), and lower/upper limits of random numbers. 
	Random number pool filled with random numbers. Index is specify
	count of remained random number in pool. Randomization method indicates which
	method is used to get random numbers.
	Random numbers must be an integer in the range [-1e9, 1e9].

>> Inputs:
	1. <method> : string :  randomization method

<< Outputs:
	1. <randStructure> : structure : random number structure
%}

%%
function randStructure = generateRandStructure(method, lowerNumber, upperNumber)
	% Initialize structure
	randStructure = struct;
	
	% Initialize variables
	randStructure.pool = 0;
	randStructure.index = 0;
	
	% Check metod name is valid
	msg = 'Invalid method name';
	assert((strcmp(method,'TRNG') || strcmp(method, 'PRNG')), msg);
	
	% Assign method name after check
	randStructure.method = method;
	
	% Check for limit parameters are integer
	msg = '<lowerNumber> and <upperNumber> must be integers';
	assert(ceil(lowerNumber) == floor(lowerNumber), msg);
	assert(ceil(upperNumber) == floor(upperNumber), msg);
	% Check for <lowerNumber> less than <upperNumber>
	msg = '<lowerNumber> must be less than <upperNumber>';
	assert((lowerNumber < upperNumber), msg);
	% Check for limits are in the range [-1e9, 1e9]
	msg = 'Number must be in the range [-1e9, 1e9]';
	assert(((lowerNumber >= -1e9) && (upperNumber <= 1e9)), msg);
	
	% After checks assign <lowerNumber> and <upperNumber>
	randStructure.lowerNumber = lowerNumber;
	randStructure.upperNumber = upperNumber;
end
