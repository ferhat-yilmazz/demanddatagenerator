 %% بسم الله الرحمن الرحیم 

%% ## Get Random List Stats ##
% 06.10.2020, Ferhat Yılmaz

%% Description
%{
	Function to get stats of list which generated randomly.
	List consist 9999 elemets from 0 to 100. Results
	will printed such that count of elements less than
	100, counts of elements less than 99 and so on.

>> Inputs:
	1. <method> : string : Method of randomization
<< Outputs:
	1. <figure> : figure : Bar plot of results
	2. <stats> : array : Statistic array
%}

%%
function stats = randomStats(method)
	% Initialize a random structure
	randStructure = generateRandStructure(method, 0, 100);
	% Generate random pool for the random structure (size 9999)
	randStructure = generateRandPool(randStructure);
	
	stats = zeros(1,100);
	% Get stats for generated pool
	for i = 1:100
		count = numel(randStructure.pool(randStructure.pool <= i));
		stats(i) = round(count * (100/9999));
	end
	figure
	title('Statistics of Generated Random Pool')
	xlabel('<=')
	ylabel('Percentage')
	bar(stats, 0.4)
end
