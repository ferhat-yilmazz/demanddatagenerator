 %% بسم الله الرحمن الرحیم 

%% ## Remove Given Element from Given List ##
% 18.08.2020, Ferhat Yılmaz

%% Description
%{
	Function to a item from given list. Return list again.

>> Inputs:
	1. <item> : string : An item to remove from list
	2. <list> : cellArray : A list includes items

<< Outputs:
	1. <list> : cellArray : A list includes items
%}

%%
function list = removeItemFromCellArray(item, list)
	% Find index of item
	index = cellfun(@(x) isequal(x, string(item)), list);
	
	% Remove the item at related index
	list(index) = [];
end
