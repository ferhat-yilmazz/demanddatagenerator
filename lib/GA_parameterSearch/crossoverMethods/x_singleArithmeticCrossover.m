 %% بسم الله الرحمن الرحیم 

%% ## Single Arithmetic Crossover ##
% 30.12.2020, Ferhat Yılmaz

%% Description
%{
	Function to apply "single arithmetic crossover". 2 offsprings will be generated
	after crossover.

	Note: Single arithmetic crossover method documentation is not covered in the script.

	>> Inputs:
	1. <parents> : array : Array for parents (2x[COUNT_GENES])
	2. <COUNT_GENES> : integer : Count of genes in each chromosome (count of parameters)

<< Outputs:
	1. <offsprings> : array : Generated offsprings
%}

%%
function offsprings = x_singleArithmeticCrossover(parents, COUNT_GENES)
	% Define <offsprings> array
	offsprings = single(zeros(2, COUNT_GENES));
	
	% Select <alpha> and <recombinationPoint> randomly
	alpha = rand();
	recombinationPoint = randi(COUNT_GENES);
	
	% Offspring-1
	% Select random parent and compy genes to the offspring except <recombinationPoint>
	offsprings(1, :) = datasample([parents(1,:); parents(2,:)], 1);
	% For <recombinationPoint> take arithmetic of parents with <alpha> weight
	offsprings(1, recombinationPoint) = (alpha*parents(1, recombinationPoint)) + ((1-alpha)*parents(2, recombinationPoint));
	
	% Offspring-2
	% Select random parent and compy genes to the offspring except <recombinationPoint>
	offsprings(2, :) = datasample([parents(1,:); parents(2,:)], 1);
	% For <recombibationPoint> take arithmetic of parents with <alpha> weight
	offsprings(2, recombinationPoint) = (alpha*parents(2, recombinationPoint)) + ((1-alpha)*parents(1, recombinationPoint));
end
