 %% بسم الله الرحمن الرحیم 

%% ## Divide Usage Vector as many as Day Pieces ##
% 26.09.2020, Ferhat Yılmaz

%% Description
%{
	Function to divide the usage vector as many as
	given day pieces count. Returns part index in array

>> Inputs:
	1. <usageVectorSize> : integer : Size of usage vector
	
<< Outputs:
	1. <partIndex> : array : Index array represents parts of usage vector.
%}

%%
function partIndex = divideUsageVector(usageVectorSize)
	% Get count of day pieces
	global DAY_PIECE;
	
	% Check for count of parts less than or equal to size of usage vector
	msg = 'Count of day pieces must less than or equal to size of the usage vector!';
	assert(DAY_PIECE <= usageVectorSize, msg);
	
	% Check for count of day piece si sub-multible of numel(usageVector)
	% If not, add it last part
	md = mod(usageVectorSize, DAY_PIECE);
	
	% Get minimum size of each part
	minSize = (usageVectorSize-md)/DAY_PIECE;
	
	% Initialize part index vector
	partIndex = zeros(DAY_PIECE,2);
	
	for p = 1:DAY_PIECE
		partIndex(p,:) = [minSize*(p-1)+1, minSize*(p)];
	end
	
	% Add remains (if there is)
	partIndex(end,2) = partIndex(end,2) + md;
end
