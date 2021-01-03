 %% بسم الله الرحمن الرحیم 

%% ## Simulated Binary Crossover (SBX) ##
% 30.12.2020, Ferhat Yılmaz

%% Description
%{
	Function to apply "simulated binary crossover". 2 offsprings will be generated
	after crossover.

	Note: Simulated binary crossover method documentation is not covered in the script.

	>> Inputs:
	1. <parents> : array : Array for parents (2x[COUNT_GENES])

<< Outputs:
	1. <offsprings> : array : Generated offsprings
%}

%%
function offsprings = x_sbxCrossover(parents)
	% Count of genes in each chromosome (count of parameters)
	global COUNT_GENES;
	
	% Define <offsprings> array
	offsprings = single(zeros(2, COUNT_GENES));
	
	%{
		We can get an offspring that is far away from parent if we use small values for <n>.
		However, using upper values would result in an offspring that is very close to parent.
		A close offspring is good for fine tuning while a far away offspring is useful for
		escaping local optima. In other words, the variable <n> is responsible for the
		peakedness of the distributions. 
	%}
	n = single(13); % Arbitrary selected according to remark at above
	% Select <u> randomly
	u = single(rand());
	
	% Determine <beta>
	if u <= 0.5
		beta = (2*u)^(1/(n+1));
	else
		beta = (1/(2*(1-u)))^(1/(n+1));
	end
	
	% Offspring-1
	offsprings(1,:) = 0.5*(((1+beta)*parents(1,:)) + ((1-beta)*parents(2, :)));
	% Offspring-2
	offsprings(2,:) = 0.5*(((1-beta)*parents(1,:)) + ((1+beta)*parents(2, :)));
	
	% DEBUG
	%fprintf("\nn: %f, u: %f, beta: %f\n", n, u, beta);
end
