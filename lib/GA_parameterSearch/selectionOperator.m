 %% بسم الله الرحمن الرحیم 

%% ## Selection Operator ##
% 26.12.2020, Ferhat Yılmaz

%% Description
%{
	Function to represents selection operator of the genetic
	algorithm. Enhanced wheel roulette method will be used.
	Different version of the CPD has applied. 

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
function [chosens, elites] = selectionOperator(fitnessVector, COUNT_CHROMOSOMES, COUNT_CHOSENS, COUNT_ELITES)
	% Define vector for chosens
	chosens = zeros(COUNT_CHOSENS, 1);
	% Define vector for elites
	% elites = zero(1, COUNT_ELITES);  % (UNNECESSARY)
	
	% Build cumulative probability distribution vector
	cpdVector = [zeros(COUNT_CHROMOSOMES, 1), zeros(COUNT_CHROMOSOMES, 1), (fitnessVector), (1:COUNT_CHROMOSOMES)'];
	% Sort <cpdVector> according to fitness value (ascending)
	cpdVector = sortrows(cpdVector, 3);
		
	% Firstly, assign elite chromosomes
	elites = cpdVector(1:COUNT_ELITES, 4);
	
	for chosen_index = 1:COUNT_CHOSENS
		% Calculate probability of each fitness value. Then modify it,
		% so lower fitness value must have grater probability 
		cpdVector(:,2) = numel(cpdVector(:,3)) ./ (cpdVector(:,3) + 1);
		cpdVector(:,2) = cpdVector(:,2)./sum(cpdVector(:,2));
		
		% Build CPD column
		lastProbability = 0;
		for row_index = 1:numel(cpdVector(:,1))
			cpdVector(row_index,1) = lastProbability + cpdVector(row_index,2);
			lastProbability = cpdVector(row_index,1);
		end
		
		% Select a random number in range (0,1)
		randomPoint = rand();
		
		% Decide which chromosome ID (<cpdVector(:,4)>) selected according
		% to CPD (<cdfVector(:,1)>)
		for row_index = 1:numel(cpdVector(:,1))
			% Compare selected random number and CPD column
			if randomPoint < cpdVector(row_index,1)
				chosens(chosen_index) = cpdVector(row_index, 4);
				break;
			end
		end
		% Remove selected chromosome ID and its data from <cpdVector>
		cpdVector(row_index, :) = [];
	end
end
