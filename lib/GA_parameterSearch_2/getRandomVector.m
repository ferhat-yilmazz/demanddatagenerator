 %% بسم الله الرحمن الرحیم 

%% ## Get Random Number List ##
% 09.11.2020, Ferhat Yılmaz

%% Description
%{
	Function to get random number list as count as requested.
	Randomization method is a parameter: 'TRNG' or 'PRNG'.

	>> Inputs:
	1. <vectorSize> : integer : Count of requested random number
	2. <minLimit> : integer : Minimum limit of random numbers
	3. <maxLimit> : integer : Maximum limit of random numbers
	4. <randMethod> : string :  Randomization method.

<< Outputs:
	1. <randVector> : vector : Vectors of generated random numbers
%}

%%
function randVector = getRandomVector(vectorSize, minLimit, maxLimit, randMethod)
	% Add path of TRNG function
	addpath('../trueRandom/');
	
	switch randMethod
		case 'TRNG'
			try
				randVector = single(truerand(1, vectorSize, minLimit, maxLimit));
			catch ME
				warning(ME.message);
				warning('PRNG will be used as randomization method!');
				randVector = single(randi([minLimit, maxLimit], 1, vectorSize));
			end
		case 'PRNG'
			randVector = single(randi([minLimit, maxLimit], 1, vectorSize));
		otherwise
				error('Undefined randomization method is given.');
	end
end
