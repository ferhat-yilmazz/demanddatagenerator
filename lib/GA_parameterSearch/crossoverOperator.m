 %% بسم الله الرحمن الرحیم 

%% ## Crossover Operator ##
% 28.12.2020, Ferhat Yılmaz

%% Description
%{
  Function to crossover chromosomes and generate new population. Also
  selected elites will contain to the new generation without any operation.

  There are a few crossover method. It is randomly selected what will used
  method. Some methods generate one offspring and some of them generate more
  than one. There is a pool for offsprings, all generated off springs will
  be collected in the pool. At the end of the crossover operation, missing
  chromosomes of the new generation will be supplemented by offsprings in the
  pools (They are randomly selected). If they are not enough, then new offsprings
  will be generated.

  Mates selected randomly. At first stage it will sure that all mates participated
  to crossover operation. Second stage (if necessary) mates selected randomly.

  >> Inputs:
  1. <chosenChromosomes> : array : Chosen chromosomes array which specified
                                   after selection operation
  2. <chosensFitness> : array : Fitness values of chosen choromosomes respectively
  3. <COUNT_GENES> : integer : Count of genes in each chromosome (count of parameters) 
  4. <COUNT_CHROMOSOMES> : integer : Count of chromosomes(count of individuals in a population)
  5. <COUNT_CHOSENS> : integer : Count of chosens
  6. <COUNT_OFFSPRINGS> : integer : Count of offsprings 
  7. <CROSSOVER_METHODS> : cell array : Name list of crossover methods

<< Outputs:
  1. <newPopulation> : array : Array contains new generation chromosomes
%}

%%
function newPopulation = crossoverOperator(chosenChromosomes,...
                                           chosensFitness,...
                                           COUNT_GENES,...
                                           COUNT_CHROMOSOMES,...
                                           COUNT_CHOSENS,...
                                           COUNT_OFFSPRINGS,...
                                           CROSSOVER_METHODS)
  % Build array for new generation
  newPopulation = single(zeros(COUNT_CHROMOSOMES, COUNT_GENES));
  
  % Define offspring pool vector
  % It must be in size as COUNT_OFFSPRINGS
  offspringPool = single(zeros(COUNT_OFFSPRINGS, COUNT_GENES));
  offspring_index = 1;
  
  % Check for count of chosens, even or odd. If it is odd, make double
  % one of them randomly. So, we want to participate all chosens at first
  % stage.
  if mod(COUNT_CHOSENS, 2) == 1
    matePool = [1:COUNT_CHOSENS, datasample((1:COUNT_CHOSENS), 1)];
  else
    matePool = (1:COUNT_CHOSENS);
  end
  
  % Build <twins> array. It represents mates which crossed randomly
  twins = transpose(reshape(datasample(matePool, numel(matePool), 'Replace', false),2, numel(matePool)/2));
  
  % ############ 1st STAGE #################
  % For each twins, generate offspring by crossover operation
  for twins_index = 1:size(twins,1)
    % Assign parents
    parents = [chosenChromosomes(twins(twins_index, 1), :); chosenChromosomes(twins(twins_index, 2), :)];
    parentFitness = [chosensFitness(twins(twins_index, 1)); chosensFitness(twins(twins_index, 2))];
    
    % Select crossover method randomly and apply
    crossoverMethodFile = datasample(CROSSOVER_METHODS, 1);
    [~, crossoverMethod, ~] = fileparts(crossoverMethodFile.name);
    
    % Check for paramter count of the selected method  
    switch nargin(string(crossoverMethod))
      case 2
        offsprings = feval(crossoverMethod, parents, COUNT_GENES);
      case 3
        offsprings = feval(crossoverMethod, parents, parentFitness, COUNT_GENES);
      otherwise
        error("<crossoverOperator>: Crossover method parameter count error");
    end
    
    % Add each offspring if <offspringPool> is avaible
    for i = 1:size(offsprings,1)
      % Check for <offspring_index>
      if offspring_index <= COUNT_OFFSPRINGS
        offspringPool(offspring_index,:) = offsprings(i,:);
        offspring_index = offspring_index + 1;
      end
    end
    
    % If <offspringPool> fulled, break
    if offspring_index > COUNT_OFFSPRINGS
      break;
    end
  end
  % ########################################
  
  % ############ 2nd STAGE #################
  while offspring_index <= COUNT_OFFSPRINGS
    % Assign parents
    randChromosomeIDs = datasample((1:COUNT_CHOSENS), 2, 'Replace', false);
    parents = chosenChromosomes(randChromosomeIDs,:);
    parentFitness = chosensFitness(randChromosomeIDs);
    
     % Select crossover method randomly and apply
    crossoverMethodFile = datasample(CROSSOVER_METHODS, 1);
    [~, crossoverMethod, ~] = fileparts(crossoverMethodFile.name);
    
    % Check for paramter count of the selected method  
    switch nargin(string(crossoverMethod))
      case 2
        offsprings = feval(crossoverMethod, parents, COUNT_GENES);
      case 3
        offsprings = feval(crossoverMethod, parents, parentFitness, COUNT_GENES);
      otherwise
        error("<crossoverOperator>: Crossover method parameter count error");
    end
    
    % Add each offspring if <offspringPool> is avaible
    for i = 1:size(offsprings,1)
      % Check for <offspring_index>
      if offspring_index <= COUNT_OFFSPRINGS
        offspringPool(offspring_index,:) = offsprings(i,:);
        offspring_index = offspring_index + 1;
      end
    end
  end
  
  % Assign offsprings to <newPopulation>
  newPopulation(1:COUNT_OFFSPRINGS, :) = offspringPool;
end
