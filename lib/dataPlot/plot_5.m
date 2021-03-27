 %% بسم الله الرحمن الرحیم 

%% ## Plot-5 ##
% 20.02.2021, Ferhat Yılmaz

%% Description
%{
	Plot-5 describes all data generated seperated according to
	consumer profiles. Each profile have 2k data.

>> Inputs:
	1. <endUsersData>
	2. <endUserProfileCount>

<< Outputs:
	1. <figure>
%}

%%
function plot_5(endUsersData, endUserProfileCount)
	% Define x-axis
	xAx = duration('00:00', 'InputFormat', 'hh:mm', 'Format', 'hh:mm')...
				:duration('00:05', 'InputFormat', 'hh:mm', 'Format', 'hh:mm')...
				:duration('23:55', 'InputFormat', 'hh:mm', 'Format', 'hh:mm');
	
	% Define xtick values
	tickAx = duration('00:00', 'InputFormat', 'hh:mm', 'Format', 'hh:mm')...
					 :duration('01:00', 'InputFormat', 'hh:mm', 'Format', 'hh:mm')...
					 :duration('23:00', 'InputFormat', 'hh:mm', 'Format', 'hh:mm');
	
	ticks_x = cellstr(string(tickAx));
	
	% Define ytick values
	tickAy = 0:0.5:5;
	ticks_y = cellstr(string(tickAy));
	
	% Define colors
% 	colors = [0 0.4470 0.7410;
% 						0.8500 0.3250 0.0980;
% 						0.9290 0.6940 0.1250;
% 						0.4660 0.6740 0.1880;
% 						0.6350 0.0780 0.1840];
	
	% Define days
	% dayList = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
	
	% Determine subplot count
	% Column defined as 2
	% subplot_col = 2;
	% subplot_row = ceil(endUserProfileCount/subplot_col);
	
	% Define plotArray % ODD count plot
	% h = zeros(1,5);

	
	% For each end-user type
	for type_idx = 1:endUserProfileCount
		% Get data belong to the end-user type
		indexVector = find([endUsersData.typeID] == type_idx);
		
		meanArray = zeros(numel(indexVector), 288);
		
		% For each index
		for index_idx = 1:numel(indexVector)
			meanArray(index_idx, :) = mean(endUsersData(indexVector(index_idx)).totalUsage);
			% Turn to kW
			meanArray(index_idx, :) = meanArray(index_idx, :) ./ 1000;
		end
		
		% Open subplot
		%h(type_idx) = subplot(subplot_row, subplot_col, type_idx);
		figure;
		
		% Plot
		plot(tickAx, meanArray(:,ismember(xAx, tickAx)), 'LineWidth', 2); % 'Color', colors(type_idx,:)
	
		ax = gca;
		
		%title(strcat('User Profile-', string(type_idx)));
		
		%ylabel('kW');
		%xlabel('Hours');
		
		yticks(tickAy);
		yticklabels(ticks_y);
		ax.YLim = [0, 5];
		
		xticks(tickAx);
		xticklabels(ticks_x);
		xtickangle(45);
		
% 		grid on;
% 		set(gca, 'GridLineStyle', ':', 'GridAlpha', 1, 'GridColor', '#2F4F4F');
		
		set(gca, 'Fontsize', 16, 'FontName', 'Times');
	end
		
% 	pos = get(h,'Position');
% 	new = mean(cellfun(@(v)v(1),pos(1:2)));
% 	set(h(5),'Position',[new,pos{end}(2:end)])
	
	%hleg1 = legend({'Type-1', 'Type-2', 'Type-3', 'Type4', 'Type5'}, 'Orientation', 'horizontal');
	%hleg1.FontSize = 12;
	%hleg1.NumColumns = 2;
end
