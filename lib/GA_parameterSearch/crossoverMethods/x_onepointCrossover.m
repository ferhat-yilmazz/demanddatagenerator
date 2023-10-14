%% بسم الله الرحمن الرحیم 

%% ## Onepoint Crossover ##
% 03.01.2021, Ferhat Yılmaz

%% Description
%{
  Function to apply "onepoint crossover". 2 offsprings will be generated
  after crossover.

  Note: Onepoint crossover method documentation is not covered in the script.

  >> Inputs:
  1. <parents> : array : Array for parents (2x[COUNT_GENES])
  2. <COUNT_GENES> : integer : Count of genes in each chromosome (count of parameters)

<< Outputs:
  1. <offsprings> : array : Generated offsprings
%}

%%
function offsprings = x_onepointCrossover(parents, COUNT_GENES)
  % Define <offsprings> array
  offsprings = single(zeros(2, COUNT_GENES));
  
  % Select <crossoverPoint> randomly
  % The interval starts from 2; so its possible copy all genes from parents to
  % offsprings. We don't want it.
  crossoverPoint = randi([2,COUNT_GENES]);
  
  % Offspring-1
  offsprings(1,1:(crossoverPoint-1)) = parents(1, 1:(crossoverPoint-1));
  offsprings(1,crossoverPoint:end) = parents(2, crossoverPoint:end);
  % Offspring-2
  offsprings(2,1:(crossoverPoint-1)) = parents(2, 1:(crossoverPoint-1));
  offsprings(2,crossoverPoint:end) = parents(1, crossoverPoint:end);
end
