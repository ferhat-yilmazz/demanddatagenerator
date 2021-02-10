 %% بسم الله الرحمن الرحیم 

%% ## Random Number Pool ##
% 10.08.2020, Ferhat Yılmaz

%% Description
%{
	Function to generate vectorial pool filled by random
	numbers with given method. Vector size designated as
	9999 because of "truerand()" limit.

>> Inputs:
	1. <randStructure> : structure :  random number structure
	2. <poolSize> : integer : Size is random pool (limited by 9999)

<< Outputs:
	1. <randStructure> : structure : random number structure
%}

%%
function randStructure = generateRandPool(randStructure, poolSize)
	% Check for size less than 10,000
	assert(poolSize < 10000, "<generateRandPool> : <poolSize> must less than 10,000");
	
	% Check randomization method from structure
	randMethod = randStructure.method;
	
	switch randMethod
		% If method is TRNG
		case 'TRNG'
			% Handle web connection errors
			try
				randStructure.pool = truerand(1, poolSize, randStructure.lowerNumber, randStructure.upperNumber);
				randStructure.index = poolSize;
			catch ME
				warning(ME.message);
				warning('PRNG will be used.');
				randStructure.pool = randi([randStructure.lowerNumber, randStructure.upperNumber], 1, poolSize);
				randStructure.index = poolSize;
			end
		% If method is PRNG
		case 'PRNG'
			randStructure.pool = randi([randStructure.lowerNumber, randStructure.upperNumber], 1, poolSize);
			randStructure.index = poolSize;
		% Otherwise
		otherwise
			msg = 'Randomization method  is undefined.';
			error(msg);
end
