 %% بسم الله الرحمن الرحیم 

%% ## Blend-alpha Crossover (BLX-alpha) ##
% 02.01.2021, Ferhat Yılmaz

%% Description
%{
  Function to apply "blend-alpha crossover". 1 offspring will be generated
  after crossover.

  Note: Blend-alpha crossover method documentation is not covered in the script.

  >> Inputs:
  1. <parents> : array : Array for parents (2x[COUNT_GENES])
  2. <COUNT_GENES> : integer : Count of genes in each chromosome (count of parameters)

<< Outputs:
  1. <offsprings> : array : Generated offsprings
%}

%%
function offsprings = x_blxAlphaCrossover(parents, COUNT_GENES)
  % Define <offsprings> array
  offsprings = single(zeros(1, COUNT_GENES));
  
  %{
    i: index of gene
    max_i = max(p1_i, p2_i)
    min_i = min(p1_i, p2_i)
    d = max_i - min_i
    alpha = 0.5
    offspring_i = random in interval [(min_i - d*alpha), (max_i + d*alpha)]
  %}
  % Define <alpha> as 0.5
  alpha = 0.5;
  
  for gene_index = 1:COUNT_GENES
    min_i = min([parents(1,gene_index), parents(2, gene_index)]);
    max_i = max([parents(1,gene_index), parents(2, gene_index)]);
    d = max_i - min_i;
    
    % Define range
    range_min = min_i - d*alpha;
    range_max = max_i + d*alpha;
    
    % Assign offspring gene
    offsprings(1, gene_index) = (range_max-range_min)*rand() + range_min;
    
    % DEBUG
    % fprintf("\ngene: %i ## alpha = %f ## d = %f ## range_min = %f ## range_max = %f ##", gene_index, alpha, d, range_min, range_max);
  end
end
