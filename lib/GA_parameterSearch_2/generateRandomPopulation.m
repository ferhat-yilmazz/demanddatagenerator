 %% بسم الله الرحمن الرحیم 

%% ## Generate Random Population ##
% 09.11.2020, Ferhat Yılmaz

%% Description
%{
	Function to generate solution population randomly. Randomization
	method will accepted as parameter.

	>> Inputs:
	1. <chromosomeCount> : integer : Count of requested random number
	2. <geneCount> : integer : Minimum limit of random numbers
	3. <geneLowLimit> : integer : Lower limit of each coefficient
	4. <geneUpLimit> : integer : Upper limit of each coefficient
	5. <randMethod>: string : Randomization method

<< Outputs:
	1. <populationArray> : array : Array contains chromosomes
%}

%%
function populationArray = generateRandomPopulation(chromosomeCount, geneCount, geneLowLimit, geneUpLimit, randMethod)
	
	% Get all genes randomly
	randomGenes = getRandomVector(geneCount*chromosomeCount, geneLowLimit, geneUpLimit, randMethod);
	
	% Assign acquired genes to chromosomes
	populationArray = transpose(reshape(randomGenes, [geneCount, chromosomeCount]));
end
