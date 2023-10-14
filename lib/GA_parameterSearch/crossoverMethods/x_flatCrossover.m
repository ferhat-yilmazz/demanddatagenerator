 %% بسم الله الرحمن الرحیم 

%% ## Flat Crossover ##
% 02.01.2021, Ferhat Yılmaz

%% Description
%{
  Function to apply "flat crossover". 1 offspring will be generated
  after crossover.

  Note: Flat crossover method documentation is not covered in the script.

  >> Inputs:
  1. <parents> : array : Array for parents (2x[COUNT_GENES])
  2. <COUNT_GENES> : integer : Count of genes in each chromosome (count of parameters)

<< Outputs:
  1. <offsprings> : array : Generated offsprings
%}

%%
function offsprings = x_flatCrossover(parents, COUNT_GENES)  
  % Define <offsprings> array
  offsprings = single(zeros(1, COUNT_GENES));
  
  %{
    This crossover is the same as BLX-alpha crossover when <alpha> = 0
  %}
  
  for gene_index = 1:COUNT_GENES
    
    % Define range
    range_min = min([parents(1,gene_index), parents(2, gene_index)]);
    range_max = max([parents(1,gene_index), parents(2, gene_index)]);
    
    % Assign offspring gene
    offsprings(1, gene_index) =range_min + rand()*(range_max-range_min);
    
    % DEBUG
    %fprintf("\ngene: %i ## range_min = %f ## range_max = %f ## offspring(gene) = %f", gene_index, range_min, range_max, offsprings(1, gene_index));
  end
end
