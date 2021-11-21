 %% بسم الله الرحمن الرحیم 

%% ## Selection Operator ##
% 19.11.2021, Ferhat Yılmaz

%% Description
%{
	Function to represents selection operator of the genetic
	algorithm. 3-way tournament selection algorithm is used. 

	>> Inputs:
	1. <fitnessVector> : vector : Vector which contains fitness values
	2. <COUNT_CHROMOSOMES> : integer : Count of chromosomes(count of individuals in a population)
	3. <COUNT_CHOSENS> : integer : Count of chosens
	4. <COUNT_ELITES> : integer : Count of elites

<< Outputs:
	1. <chosens> : vector : IDs of chosen individuals
	2. <elistes> : vector : IDs of elistes individuals
%}

%%
function [chosens, elites] = selectionOperator(fitnessVector, COUNT_CHOSENS, COUNT_ELITES)
  % Define vector for chosens
	chosens = zeros(COUNT_CHOSENS, 1);
  
  % Firstly sort <fitnessVector> ascending order,
  % lower fitness value is better
  [sortedFitnessVector, sortedIDs] = sort(fitnessVector);
  
  % ## Elitism ##
  % -------------
  % Select elites as many as <COUNT_ELITES>
  if COUNT_ELITES > 0
    elites = sortedIDs(1:COUNT_ELITES);
  else
    elites = [];
  end
 
  % Remove elite chromosome IDs from list
  sortedIDs(ismember(sortedIDs, elites)) = [];
  
  % ## 3-way Tournament Selection ##
  % --------------------------------
  for chosen_index = 1:COUNT_CHOSENS
    % Determine <k> value
    if numel(sortedIDs) >= 3
      k = 3;
    elseif (numel(sortedIDs) < 3) && (numel(sortedIDs) > 0)
      k = numel(sortedIDs);
    else
      continue;
    end
    
    % Select as many as <k> ID from <sortedIDs>
    competitorIDs = sortedIDs(randperm(numel(sortedIDs), k));
    
    % Compare fitness values of <chosonCandidates> and select best
    winnerFitness = inf;
    for id_index = 1:numel(competitorIDs)
      if sortedFitnessVector(competitorIDs(id_index)) < winnerFitness
        winnerID = competitorIDs(id_index);
        winnerFitness = sortedFitnessVector(competitorIDs(id_index));
      end
    end
    
    % Remove <winnerID> from <sortedIDs>
    sortedIDs(ismember(sortedIDs, winnerID)) = [];
    % Add <winnerID> to <chosens> vector
    chosens(chosen_index) = winnerID;
  end
end
