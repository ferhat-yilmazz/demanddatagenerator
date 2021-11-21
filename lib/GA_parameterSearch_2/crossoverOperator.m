 %% بسم الله الرحمن الرحیم 

%% ## Crossover Operator ##
% 20.11.2021, Ferhat Yılmaz

%% Description
%{
	Function to crossover chromosomes and generate new population. Also
	selected elites will be included in the new generation without any operation.

	For crossover operation, SBX (Simulated Binary Crossover) will be used. In SBX,
  we need two parents and we'll get two offsprings. Sure, all parents in the pool
  must participate crossover operation. The goal is to reach total needed offspring
  count. Some parents may join to crossover multiple times, it's random.

	>> Inputs:
	1. <chosenChromosomes> : array : Chosen chromosomes array which specified
																	 after selection operation
	2. <COUNT_GENES> : integer : Count of genes in each chromosome (count of parameters) 
	3. <COUNT_CHOSENS> : integer : Count of chosens
	4. <COUNT_OFFSPRINGS> : integer : Count of offsprings 

<< Outputs:
	1. <offsprings> : array : Array contains new generation chromosomes
%}

%%
function offsprings = crossoverOperator(chosenChromosomes, COUNT_GENES, COUNT_CHOSENS, COUNT_OFFSPRINGS)
  % Determine count of parents to reach <COUNT_OFFSPRINGS>
  % According to SBX, there is 2 offsprings for each parent
  parentsCount = uint16(floor(COUNT_OFFSPRINGS/2)) + uint16(mod(COUNT_OFFSPRINGS, 2));
  
  % Define <offsprings> array
	% It must be in size as <COUNT_OFFSPRINGS>
	offsprings = single(zeros(parentsCount*2, COUNT_GENES));
  
  
	% Generate parents randomly
  assert(COUNT_CHOSENS >= 2, "There is not enough chosen chromosome to generate a parent!");
  parentsVector = uint16(mod(randperm(parentsCount*2), single(COUNT_CHOSENS)) + 1);
  parentsArray = transpose(reshape(parentsVector, [2, parentsCount]));
	
  % Crossover operation for generated parents
  parent_idx = 1;
  offspring_idx = 1;
  while parent_idx <= parentsCount
    % Get mates chromosomes
    mate1_chromosome = chosenChromosomes(parentsArray(parent_idx, 1), :);
    mate2_chromosome = chosenChromosomes(parentsArray(parent_idx, 2), :);
    % Crossover
    offsprings(offspring_idx:(offspring_idx+1), :) = x_sbxCrossover([mate1_chromosome; mate2_chromosome], COUNT_GENES);
    
    % Increase loop variables
    parent_idx = parent_idx + 1;
    offspring_idx = offspring_idx + 2;
  end
  
  % Trim <offsprings> array if it has extra chromosome
  if size(offsprings, 1) > COUNT_OFFSPRINGS
    offsprings(randi(size(offsprings, 1)), :) = [];
  end
end
