 %% بسم الله الرحمن الرحیم 

%% ## Mutation Operator ##
% 21.11.2021, Ferhat Yılmaz

%% Description
%{
	Function to realise mutation process fo population. Non-uniform mutation
  method will be used. Thus, there will be increasing mutation rate for each
  generation. Two chromosomes will be selected random for mutation.

  Formulation of non-uniform mutation:
  
    x_new = x + t * (x_max - x_min) * (1 - r^((1-g/g_max)^b))
    
    x_new   : new value of gene
    x       : old value of gene
    t       : random number in set {1,-1}
    x_max   : maximum value of gene in current polulation
    x_min   : minimum value of gene in cuurent population
    r       : random number in interval [0,1]
    g       : current generetion count
    g_max   : maximum generation count
    b       : design parameter (selected as 1)

	>> Inputs:
	1. <offsprings>             : array   : Offspring array which contains new generated chromosomes
	2. <currentGenerationCount> : double : Currently generation count
  3. <totalGenerationCOunt>   : double : Total generation count
  4. <designParameter>        : double  : Design parameter used in the formule
  4. <COUNT_GENES>            : integer : Count of genes in each chromosome (count of parameters)
	5. <COUNT_OFFSPRINGS>       : integer : Count of offspring chromosomes

<< Outputs:
	1. <offsprings> : array     : Mutant offsprings array
%}

%%
function offsprings = mutationOperator(offsprings, currentGenerationCount, totalGenerationCount, designParameter, COUNT_GENES, COUNT_OFFSPRINGS)
	% Find maximum end minimum values for each gene
  maxValues = single(zeros(1, COUNT_GENES));
  minValues = single(zeros(1, COUNT_GENES));
  
  for gene_idx = 1:COUNT_GENES
    maxValues(1, gene_idx) = max(offsprings(:, gene_idx));
    minValues(1, gene_idx) = min(offsprings(:, gene_idx));
  end
  
  % Select two chromosome random to mutate
  mutants = uint16(randperm(COUNT_OFFSPRINGS, 2));
  
  % Mutate selected chromosomes
  for mutants_idx = 1:numel(mutants)% Determine change rate according to formula at above
    % For each gene
    for gene_idx = 1:COUNT_GENES
      % Determine change rate according to formula at above
      changeRate = single(randi([-1, 1])  * (maxValues(1, gene_idx) - minValues(1, gene_idx))...
                                          * (1 - rand()^((1 - (currentGenerationCount / totalGenerationCount))^designParameter)));
      % Mutate the gene
      offsprings(mutants(mutants_idx), gene_idx) = offsprings(mutants(mutants_idx), gene_idx) + changeRate;
    end
  end
  
end
