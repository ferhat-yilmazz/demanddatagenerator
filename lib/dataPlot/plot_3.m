 %% بسم الله الرحمن الرحیم 

%% ## Plot-3 ##
% 13.02.2021, Ferhat Yılmaz

%% Description
%{
  Plot-3 describes RMS of avarage data for each end-user type.

>> Inputs:
  1. <endUsersData>
  2. <endUserProfileCount>

<< Outputs:
  1. <figure>
%}

%%
function plot_3(endUsersData, endUserProfileCount)
  % Define rms array
  rmsVector = zeros(7,5);
  
  % For each day
  for day_idx = 1:7
    % For each type
    for profile_idx = 1:endUserProfileCount
      % Find indexes belongs to the type
      typeIndex = find([endUsersData.typeID] == profile_idx);
      % Find mean of the day
      dayUsageArray = zeros(numel(typeIndex),288);
      for index_idx = 1:numel(typeIndex)
        dayUsageArray(index_idx,:) = endUsersData(typeIndex(index_idx)).totalUsage(day_idx, :);
      end
      meanVector = mean(dayUsageArray);
      % Convert kW
      meanVector = meanVector ./ 1000;
      
      % Assign rms of mean of daily usage
      rmsVector(day_idx, profile_idx) = rms(meanVector);
    end
  end
  
  % Define x-axis
  xAx = 1:7;
  
  % Bar graph
  b = bar(xAx, rmsVector, 'barwidth', 0.9);
  
  % Assign colors
  b(1).FaceColor = [0 0.4470 0.7410];
  b(2).FaceColor = [0.8500 0.3250 0.0980];
  b(3).FaceColor = [0.9290 0.6940 0.1250];
  b(4).FaceColor = [0.4660 0.6740 0.1880];
  b(5).FaceColor = [0.6350 0.0780 0.1840];
  
  % For gray image pattern: applyhatch()
  % cmap = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250; 0.4660 0.6740 0.1880; 0.6350 0.0780 0.1840];
  
  % Define tips
%   for i = 1:5
%     text(b(i).XEndPoints,b(i).YEndPoints,(arrayfun(@(d)  strcat('.', string(fix(b(i).YData(d)*1000))), (1:7))),...
%       'HorizontalAlignment','center', 'VerticalAlignment','bottom', 'FontSize', 8);
%   end
  
  xticklabels({'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'});
  %xtickangle(45);
  
%   grid on;
%   set(gca, 'GridLineStyle', ':', 'GridAlpha', 1, 'GridColor', '#2F4F4F');
  
  set(gca, 'Fontsize', 16, 'FontName', 'Times');
  
  % title('RMS for Each Day');
  % xlabel('Days');
  % ylabel('RMS (kW)');
  
  hleg1 = legend({' u_1 ', ' u_2 ', ' u_3 ', ' u_4 ', ' u_5 '}, 'Orientation', 'horizontal');
  hleg1.FontSize = 20;
end
