 %% بسم الله الرحمن الرحیم 

%% ## Plot-1 ##
% 13.02.2021, Ferhat Yılmaz

%% Description
%{
	Plot-1 describes data for 7 days for each end-user
	type. So, there are 5 different plots.

>> Inputs:
	1. <endUsersData>
	2. <endUserProfileCount>

<< Outputs:
	1. <figure>
%}

%%
function plot_1(endUsersData, endUserProfileCount)
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
	tickAy = 0:0.20:2.0;
	ticks_y = cellstr(string(tickAy));
	
	% Define colors
	colors = [0 0.4470 0.7410;
						0.8500 0.3250 0.0980;
						0.9290 0.6940 0.1250;
						0.4940 0.1840 0.5560;
						0.4660 0.6740 0.1880;
						0.3010 0.7450 0.9330;
						0.6350 0.0780 0.1840];
	
	% Define days
	dayList = {'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'};
	
	% For each end-user type
	for profile_idx = 1:endUserProfileCount
		% Determine means of same days for the end-user type
		meanArray = meanDays(endUsersData, profile_idx);
		
		% Open subplot
		% subplot(subplot_row, subplot_col, profile_idx);
		f = figure;
		
		% Color Plot
		hold on
		plot(tickAx, meanArray(1,ismember(xAx, tickAx)), 'Color', colors(1,:), 'LineWidth', 2, 'LineStyle', '-.', 'Marker', 'o', 'MarkerSize', 8);
		plot(tickAx, meanArray(2,ismember(xAx, tickAx)), 'Color', colors(2,:), 'LineWidth', 2, 'LineStyle', '-.', 'Marker', 'x', 'MarkerSize', 8);
		plot(tickAx, meanArray(3,ismember(xAx, tickAx)), 'Color', colors(3,:), 'LineWidth', 2, 'LineStyle', '-.', 'Marker', '+', 'MarkerSize', 8);
		plot(tickAx, meanArray(4,ismember(xAx, tickAx)), 'Color', colors(4,:), 'LineWidth', 2, 'LineStyle', '-.', 'Marker', '*', 'MarkerSize', 8);
		plot(tickAx, meanArray(5,ismember(xAx, tickAx)), 'Color', colors(5,:), 'LineWidth', 2, 'LineStyle', '-.', 'Marker', '>', 'MarkerSize', 8);
		plot(tickAx, meanArray(6,ismember(xAx, tickAx)), 'Color', colors(6,:), 'LineWidth', 2, 'LineStyle', '-.', 'Marker', '<', 'MarkerSize', 8);
		plot(tickAx, meanArray(7,ismember(xAx, tickAx)), 'Color', colors(7,:), 'LineWidth', 2, 'LineStyle', '-.', 'Marker', '^', 'MarkerSize', 8);
		hold off
		
		% Gray Plot
% 		hold on
% 		plot(tickAx, meanArray(1,ismember(xAx, tickAx)), 'Color', 'k', 'LineStyle', '-', 'LineWidth', 1);
% 		plot(tickAx, meanArray(2,ismember(xAx, tickAx)), 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1);
% 		plot(tickAx, meanArray(3,ismember(xAx, tickAx)), 'Color', 'k', 'LineStyle', '-.', 'LineWidth', 1);
% 		plot(tickAx, meanArray(4,ismember(xAx, tickAx)), 'Color', 'k', 'LineStyle', ':', 'LineWidth', 1);
% 		plot(tickAx, meanArray(5,ismember(xAx, tickAx)), 'Color', 'r', 'LineStyle', '-', 'LineWidth', 1);
% 		plot(tickAx, meanArray(6,ismember(xAx, tickAx)), 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1);
% 		plot(tickAx, meanArray(7,ismember(xAx, tickAx)), 'Color', 'r', 'LineStyle', '-.', 'LineWidth', 1);
% 		hold off
		
		ax = gca;
		
% 		grid on;
% 		set(gca, 'GridLineStyle', ':', 'GridAlpha', 1, 'GridColor', '#2F4F4F');
		
		% title(strcat(indexList(profile_idx), 'User Profile-', string(profile_idx)));
		
		%ylabel('kW');
		%xlabel('Hours');
		
		yticks(tickAy);
		yticklabels(ticks_y);
		ax.YLim = [0, 2];
		
		xticks(tickAx);
		xticklabels(ticks_x);
		xtickangle(45);
		
		set(gca, 'Fontsize', 16, 'FontName', 'Times');
		
		if profile_idx == 1
			hleg1 = legend(dayList, 'Orientation', 'horizontal');
			hleg1.FontSize = 17;
			hleg1.NumColumns = 7;
		end
	end
end
