 %% بسم الله الرحمن الرحیم 

%% ## Plot-4 ##
% 16.02.2021, Ferhat Yılmaz

%% Description
%{
	Plot-4 describes comparison of each type for each day.
	Totally there are 7 graphs.

>> Inputs:
	1. <endUsersData>
	2. <endUserProfileCount>

<< Outputs:
	1. <figure>
%}

%%
function plot_4(endUsersData, endUserProfileCount)
	% Define x-axis
	xAx = duration('00:00', 'InputFormat', 'hh:mm', 'Format', 'hh:mm')...
				:duration('00:05', 'InputFormat', 'hh:mm', 'Format', 'hh:mm')...
				:duration('23:55', 'InputFormat', 'hh:mm', 'Format', 'hh:mm');
	
	% Define xtick values
	tickAx = duration('00:00', 'InputFormat', 'hh:mm', 'Format', 'hh:mm')...
					 :duration('01:00', 'InputFormat', 'hh:mm', 'Format', 'hh:mm')...
					 :duration('23:00', 'InputFormat', 'hh:mm', 'Format', 'hh:mm');
	
	tickslabel_x = cellstr(string(tickAx));
	
	% Define ytick values
	tickAy = 0:0.2:2.0;
	tickslabel_y = cellstr(string(tickAy));

	% Define colors
	colors = [0 0.4470 0.7410;
						0.8500 0.3250 0.0980;
						0.9290 0.6940 0.1250;
						0.4940 0.1840 0.5560;
						0.4660 0.6740 0.1880;
						0.3010 0.7450 0.9330;
						0.6350 0.0780 0.1840];
	
	% Define days
	% dayList = {'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'};
	% Define index
	% indexLetters = {'(a) ', '(b) ', '(c) ', '(d) ', '(e) ', '(f) ', '(g) '};
	
	% For each day
	for day_idx = 1:7
		% Define mean array
		meanArray = zeros(5,288);
		% For each type
		for profile_idx = 1:endUserProfileCount
			% Find indexes belongs to the type
			typeIndex = find([endUsersData.typeID] == profile_idx);
			% Find mean of the day
			meanVector = zeros(1,288);
			for index_idx = 1:numel(typeIndex)
				meanVector(1,:) = meanVector(1,:) + endUsersData(typeIndex(index_idx)).totalUsage(day_idx, :);
			end
			meanVector = meanVector ./ numel(typeIndex);
			% Convert kW
			meanArray(profile_idx,:) = meanVector ./ 1000;
		end
		% Plot
		%subplot(4,2,day_idx);
		figure();
		ax = gca;
		
		% Color Plot
		hold on;
		plot(tickAx, meanArray(1,ismember(xAx, tickAx)), 'Color', colors(1,:), 'LineWidth', 2.2, 'LineStyle', '-.', 'Marker', 'o', 'MarkerSize', 8);
		plot(tickAx, meanArray(2,ismember(xAx, tickAx)), 'Color', colors(2,:), 'LineWidth', 2.2, 'LineStyle', '-.', 'Marker', '+', 'MarkerSize', 8);
		plot(tickAx, meanArray(3,ismember(xAx, tickAx)), 'Color', colors(3,:), 'LineWidth', 2.2, 'LineStyle', '-.', 'Marker', '*', 'MarkerSize', 8);
		plot(tickAx, meanArray(4,ismember(xAx, tickAx)), 'Color', colors(5,:), 'LineWidth', 2.2, 'LineStyle', '-.', 'Marker', 'x', 'MarkerSize', 8);
		plot(tickAx, meanArray(5,ismember(xAx, tickAx)), 'Color', colors(7,:), 'LineWidth', 2.2, 'LineStyle', '-.', 'Marker', '^', 'MarkerSize', 8);
		hold off;
		
		% Gray Plot
% 		hold on;
% 		plot(tickAx, meanArray(1,ismember(xAx, tickAx)), 'Color', 'k', 'LineStyle', '-', 'LineWidth', 1);
% 		plot(tickAx, meanArray(2,ismember(xAx, tickAx)), 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1);
% 		plot(tickAx, meanArray(3,ismember(xAx, tickAx)), 'Color', 'k', 'LineStyle', ':', 'LineWidth', 1);
% 		plot(tickAx, meanArray(4,ismember(xAx, tickAx)), 'Color', 'k', 'LineStyle', '-.', 'LineWidth', 1);
% 		plot(tickAx, meanArray(5,ismember(xAx, tickAx)), 'Color', 'y', 'LineStyle', '-', 'LineWidth', 1);
% 		hold off;
		
		% title(strcat(indexLetters(day_idx), dayList(day_idx)));
		
		% ylabel('kW');
		% xlabel('Hours');
		
		yticks(tickAy);
		yticklabels(tickslabel_y);
		ax.YLim = [0, 2.0];
		
		xticks(tickAx);
		xticklabels(tickslabel_x);
		xtickangle(45);
		
% 		grid on;
% 		set(gca, 'GridLineStyle', ':', 'GridAlpha', 1, 'GridColor', '#2F4F4F');
		
		set(gca, 'Fontsize', 16, 'FontName', 'Times');
			
		if day_idx == 1
			hleg1 = legend({' u_1 ', ' u_2 ', ' u_3 ', ' u_4 ', ' u_5 '}, 'Orientation', 'horizontal');
			hleg1.FontSize = 28;
			hleg1.NumColumns = 7;
		end
	end

end
