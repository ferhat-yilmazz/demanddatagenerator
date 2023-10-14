 %% بسم الله الرحمن الرحیم 

%% ## Plot-2 ##
% 13.02.2021, Ferhat Yılmaz

%% Description
%{
  Plot-2 describes avarage data for each end-user type.

>> Inputs:
  1. <endUsersData>
  2. <endUserProfileCount>

<< Outputs:
  1. <figure>
%}

%%
function plot_2(endUsersData, endUserProfileCount)
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
  tickAy = 0:0.1:2;
  ticks_y = cellstr(string(tickAy)); % {'0.0', '0.5', '1.0', '1.5', '2.0', '2.5', '3.0'};
  
  % Define colors
  colors = [0 0.4470 0.7410;
            0.8500 0.3250 0.0980;
            0.9290 0.6940 0.1250;
            0.4660 0.6740 0.1880;
            0.6350 0.0780 0.1840];
  
  legendText = {' u_1 ', ' u_2 ', ' u_3 ', ' u_4 ', ' u_5 '};
  
  % Figure
  figure('Name', 'Means of All Consumers');
  hold on
  
  for profile_idx = 1:endUserProfileCount
    % Get index of the type
    indexVector = find([endUsersData.typeID] == profile_idx);
    
    meanArray = zeros(numel(indexVector), 288);
    
    % For each index
    for index_idx = 1:numel(indexVector)
      meanArray(index_idx, :) = mean(endUsersData(indexVector(index_idx)).totalUsage);
    end
    
    % Find mean of usage of the end-user
    meanVector = mean(meanArray);
    
    % Turn to kW
    meanVector = meanVector ./ 1000;
    
    % Color Plot
    switch profile_idx
      case 1
        plot(tickAx, meanVector(ismember(xAx, tickAx)), 'Color', colors(1,:), 'LineWidth', 3, 'LineStyle', '-.', 'Marker', 'o', 'MarkerSize', 8);
      case 2
        plot(tickAx, meanVector(ismember(xAx, tickAx)), 'Color', colors(2,:), 'LineWidth', 3, 'LineStyle', '-.', 'Marker', '+', 'MarkerSize', 8);
      case 3
        plot(tickAx, meanVector(ismember(xAx, tickAx)), 'Color', colors(3,:), 'LineWidth', 3, 'LineStyle', '-.', 'Marker', '*', 'MarkerSize', 8);
      case 4
        plot(tickAx, meanVector(ismember(xAx, tickAx)), 'Color', colors(4,:), 'LineWidth', 3, 'LineStyle', '-.', 'Marker', 'x', 'MarkerSize', 8);
      case 5
        plot(tickAx, meanVector(ismember(xAx, tickAx)), 'Color', colors(5,:), 'LineWidth', 3, 'LineStyle', '-.', 'Marker', '^', 'MarkerSize', 8);
      otherwise
        error('Undefined end-user type ID');
    end
    
    % Gray Plot
%     switch profile_idx
%       case 1
%         plot(tickAx, meanVector(ismember(xAx, tickAx)), 'Color', 'k', 'LineStyle', '-', 'LineWidth', 1.5);
%       case 2
%         plot(tickAx, meanVector(ismember(xAx, tickAx)), 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5);
%       case 3
%         plot(tickAx, meanVector(ismember(xAx, tickAx)), 'Color', 'k', 'LineStyle', ':', 'LineWidth', 1.5);
%       case 4
%         plot(tickAx, meanVector(ismember(xAx, tickAx)), 'Color', 'k', 'LineStyle', '-.', 'LineWidth', 1.5);
%       case 5
%         plot(tickAx, meanVector(ismember(xAx, tickAx)), 'Color', 'y', 'LineStyle', '-', 'LineWidth', 1.5);
%       otherwise
%         error('Undefined end-user type ID');
%     end
    
  end
  ax = gca;
  
%   grid on;
%   set(gca, 'GridLineStyle', ':', 'GridAlpha', 1, 'GridColor', '#2F4F4F');
%   
  %title('Avarage Data for Each Type of End-User Load Profile');

  % ylabel('Power [kW]');
  % xlabel('Hours');

  yticks(tickAy);
  yticklabels(ticks_y);
  ax.YLim = [0, 2];

  xticks(tickAx);
  xticklabels(ticks_x);
  xtickangle(45);
      
  set(gca, 'Fontsize', 16, 'FontName', 'Times');
  
  hleg1 = legend(legendText, 'Orientation', 'horizontal');
  hleg1.NumColumns = 5;
  hleg1.FontSize = 20;
end
