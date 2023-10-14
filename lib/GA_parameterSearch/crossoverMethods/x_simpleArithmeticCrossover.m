 %% بسم الله الرحمن الرحیم 

%% ## Simple Arithmetic Crossover ##
% 30.12.2020, Ferhat Yılmaz

%% Description
%{
  Function to apply "simple arithmetic crossover". 2 offsprings will be generated
  after crossover.

  Note: Simple arithmetic crossover method documentation is not covered in the script.

  >> Inputs:
  1. <parents> : array : Array for parents (2x[COUNT_GENES])
  2. <COUNT_GENES> : integer : Count of genes in each chromosome (count of parameters)

<< Outputs:
  1. <offsprings> : array : Generated offsprings
%}

%%
function offsprings = x_simpleArithmeticCrossover(parents, COUNT_GENES)
  % Define <offsprings> array
  offsprings = single(zeros(2, COUNT_GENES));
  
  % Select <alpha> and <recombinationPoint> randomly
  alpha = rand();
  recombinationPoint = randi(COUNT_GENES-1); % Thus, all of genes cannot coppied
  
  % Offspring-1
  % Select random parent and compy genes to the offspring until <recombinationPoint>
  offsprings(1, 1:recombinationPoint) = datasample([parents(1,1:recombinationPoint); parents(2,1:recombinationPoint)], 1);
  % For other gene(s) take arithmetic of parents with <alpha> weight
  offsprings(1, (recombinationPoint+1):end) = (alpha*parents(1, (recombinationPoint+1):end)) + ((1-alpha)*parents(2, (recombinationPoint+1):end));
  
  % Offspring-2
  % Select random parent and compy genes to the offspring until <recombinationPoint>
  offsprings(2, 1:recombinationPoint) = datasample([parents(1,1:recombinationPoint); parents(2,1:recombinationPoint)], 1);
  % For other gene(s) take arithmetic of parents with <alpha> weight
  offsprings(2, (recombinationPoint+1):end) = (alpha*parents(2, (recombinationPoint+1):end)) + ((1-alpha)*parents(1, (recombinationPoint+1):end));
end
