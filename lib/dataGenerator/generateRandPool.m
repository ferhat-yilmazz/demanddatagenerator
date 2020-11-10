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

<< Outputs:
	1. <randStructure> : structure : random number structure
%}

%%
function randStructure = generateRandPool(randStructure)
	% Size is designated as 9999 because of "truerand()" limits
	size = 500;
	
	% Check randomization method from structure
	randMethod = randStructure.method;
	
	switch randMethod
		% If method is TRNG
		case 'TRNG'
			% Handle web connection errors
			try
				randStructure.pool = truerand(1, size, randStructure.lowerNumber, randStructure.upperNumber);
				randStructure.index = size;
			catch ME
				warning(ME.message);
				warning('PRNG will be used.');
				randStructure.pool = randi([randStructure.lowerNumber, randStructure.upperNumber], 1, size);
				randStructure.index = size;
			end
		% If method is PRNG
		case 'PRNG'
			randStructure.pool = randi([randStructure.lowerNumber, randStructure.upperNumber], 1, size);
			randStructure.index = size;
		% Otherwise
		otherwise
			msg = 'Randomization method  is undefined.';
			error(msg);
end
