 %% بسم الله الرحمن الرحیم 

%% ## Fitness Function ##
% 02.12.2020, Ferhat Yılmaz

%% Description
%{
  It is fitness function which used in genetic algorithm
  computation for parameter search. Each weeks each day and
  each part of day run probability will be calculated. Only appliance
  confliction constraints are not considered.

  >> Inputs:
  1. <endUserTypeStruct> : structure : Structure of the end-user type
  2. <applianceID> : ineger: Appliance ID (according to the endUserTypeStruct)
  3. <chromosome> : vector : A solution or an individual
  4. <SAMPLE_PERIOD> : integer : Sample period in minutes
  5. <COUNT_SAMPLE_IN_DAY> : integer : Sample count in a day
  6. <COUNT_WEEKS> : interger : Week count
  7. <DAY_PIECE> : integer : Count of day pieces
  8. <GLOB_MAX_OPERATION_LIMIT> : integer : Global maximum run duration limit in sample

<< Outputs:
  1. <fitnessValue> : integer : Fitness value of the applied solution
%}

%%
function fitnessValue = fitnessFunction(endUserTypeStruct,...
                                        applianceID,...
                                        chromosome,...
                                        SAMPLE_PERIOD,...
                                        COUNT_SAMPLE_IN_DAY,...
                                        COUNT_WEEKS,...
                                        DAY_PIECE,...
                                        GLOB_MAX_OPERATION_LIMIT)
  
  % Define "daily usage count"(duc) and "weekly usage count"(wuc)
  wuc = single(0);
  duc = single(0);
  % Define total runtime sample
  trs = single(0);
  % Define daily run intervals
  runIntervals_daily = divideUsageVector(COUNT_SAMPLE_IN_DAY, DAY_PIECE);
  
  % For each week
  for week_index = 1:COUNT_WEEKS
    % Define days of a week in random sort
    dayList = uint16(randperm(7));
    
    % For each day
    for day_index = dayList
      % Update <day_index> according to week
      runDay = (week_index-1)*7 + day_index;
      % Sort run intervals randomly
      runIntervals = runIntervals_daily(:,randperm(numel(runIntervals_daily(1,:))));

      % For each run interval
      for runInterval = runIntervals
        % Select a sample randomly (PRNG) from runInterval (it is start sample of the appliance)
        startSample = datasample(runInterval(1):runInterval(2), 1);
        % Check constraints, it is possible to run at selected sample for the appliance or not
        if endUserTypeStruct.appliances(applianceID).usageArray(runDay,startSample)

          %{
            ###############################################
            ########## DETERMINE RUN PROBABILITY ##########

                                                  Apliance Needs Operator
                                            _________________|_________________
                                            |                                  |
                                      (TRUE)|                                  |(FALSE)
                                            |                                  |
                                End-User Have Job Schedule                 # E+N #
                                  __________|__________                    
                                  |                    |
                            (TRUE)|                    |(FALSE)
                                  |                    |
                            Start Time Located     # E+N #
                              in Job Times                        
                            ______|______                                ** E: Employed count           
                            |            |                                ** N: Nonemployed count
                      (TRUE)|            |(FALSE)
                            |            |                  
                          # N #      # E+N #

          %}

          % Get conditions
          cond1 = logical(endUserTypeStruct.appliances(applianceID).needOperator);
          cond2 = logical(endUserTypeStruct.jobSchedule.case);
          if cond2
            cond3 = ismember(runDay, endUserTypeStruct.jobSchedule.workDays) &&...
                              isInInterval(startSample, endUserTypeStruct.jobSchedule.lowerSample, endUserTypeStruct.jobSchedule.upperSample);
          else
            cond3 = false;
          end
          % According to diagram at above, determine run probability
          if cond1 && cond2 && cond3
            runProbability = (endUserTypeStruct.nonemployedCount * chromosome(1)) - (duc * chromosome(2)) - (wuc * chromosome(3));
          else
            runProbability = ((endUserTypeStruct.nonemployedCount + endUserTypeStruct.employedCount) * chromosome(1))...
                                                                                                    - (duc * chromosome(2)) - (wuc * chromosome(3));
          end
          % ###############################################

          % Select a random number between [0,100] (TRNG or PRNG)
          randomRunNumber = getRandomVector(1, 1, 100, 'PRNG');

          % Check for the appliance can run or not
          if randomRunNumber <= runProbability
            % Increase <duc> and <wuc> values by 1
            duc = duc + 1;
            wuc = wuc + 1;

            % Convert start sample according to <day_index>
            startSample = single((runDay-1)*COUNT_SAMPLE_IN_DAY + startSample);

            %{
              #########################################
              ########## ASSIGN RUN DURATION ##########

                                          Appliance Operation Mode
                                  ____________________|____________________
                                  |                                        |
                                  |                                        |
                                  |                                        |
                          # Non-Periodic #                           # Periodic #
                                  |                                        |
                                  |                                        |
                                  |                                        |
                              Run The Appliance                  Select Runtime Duration
                               One Cycle                                Randomly
                                  |                                    (Limited)
                                  |                                        |
                                  |_______________________________________|
                                                      |
                                                      |
                                                      |
                                    Assign Runtime Duration To Usage Array



            %}

            if strcmp(endUserTypeStruct.appliances(applianceID).operation.mode, 'periodic')
              % Specify limits of random value of runtimeduration
              minLimit = duration2sample(timeVector2duration(endUserTypeStruct.appliances(applianceID).operation.runDuration,...
                                                             'inf',...
                                                             SAMPLE_PERIOD)...
                                         + timeVector2duration(endUserTypeStruct.appliances(applianceID).operation.waitDuration,...
                                                               'inf',...
                                                               SAMPLE_PERIOD),...
                                         'inf',...
                                         SAMPLE_PERIOD);
              applianceMaxOperationLimit = duration2sample(timeVector2duration(endUserTypeStruct.appliances(applianceID)...
                                                                                                                    .operation.maxOperationLimit,...
                                                                               'inf',...
                                                                               SAMPLE_PERIOD),...
                                                           'inf',...
                                                           SAMPLE_PERIOD);
              if applianceMaxOperationLimit >= minLimit
                maxLimit = applianceMaxOperationLimit;
              else
                maxLimit = GLOB_MAX_OPERATION_LIMIT;
              end
                            
              % Select runtime duration randomly according to limits
              runtimeSample = randi([minLimit maxLimit]);
              
              % Sure that <runtimeSamle> can divided "runDuration + waitDuration" exactly
              if mod(runtimeSample, minLimit) ~= 0
                runtimeSample = runtimeSample - (mod(runtimeSample, minLimit));
              end
              
            elseif strcmp(endUserTypeStruct.appliances(applianceID).operation.mode, 'non-periodic')
              % Determine runtime sample
              runtimeSample = duration2sample(timeVector2duration(endUserTypeStruct.appliances(applianceID).operation.runDuration,...
                                                                  'inf',...
                                                                  SAMPLE_PERIOD),...
                                              'inf',...
                                              SAMPLE_PERIOD);
            else
              error('appliancesData.json:' + string(appliance) + ' <operation.mode> undefined!');
            end

            % Assign runtime to usage array
            endUserTypeStruct.appliances(applianceID).usageArray =...
                                    assignRunDuration2UsageArray(endUserTypeStruct.appliances(applianceID).usageArray,...
                                                                 startSample,...
                                                                 runtimeSample,...
                                                                 COUNT_SAMPLE_IN_DAY,...
                                                                 COUNT_WEEKS);
            % Increase <trs> by runtime sample
            trs = trs + single(runtimeSample);
            % #########################################
          end
        end
      end
      % Reset <duc> for each new day
      duc = single(0);
    end
    % Reset <wuc> for each new day
    wuc = single(0);
  end
  % #############################################
  % ########## DETERMINE FITNESS VALUE ##########
  % Get real usage value of the appliance in minutes for the end-user type (weekly usage)
  endUserType_userCount = endUserTypeStruct.nonemployedCount + endUserTypeStruct.employedCount;
  
  % Determine real weekly usage value
  remainedPerson = endUserType_userCount - endUserTypeStruct.appliances(applianceID).weeklyRunInReal.personCount;
  if remainedPerson > 0
    realWeeklyUsageInMinute = minutes(timeVector2duration(endUserTypeStruct.appliances(applianceID).weeklyRunInReal.value, 'inf', SAMPLE_PERIOD));
    % Add duration for each remained person
    realWeeklyUsageInMinute = double(realWeeklyUsageInMinute +...
     (remainedPerson * (minutes(timeVector2duration(endUserTypeStruct.appliances(applianceID).weeklyRunInReal.additionEachPerson,...
                                                    'inf',...
                                                    SAMPLE_PERIOD)))));
  elseif remainedPerson == 0
      realWeeklyUsageInMinute = double(minutes(timeVector2duration(endUserTypeStruct.appliances(applianceID).weeklyRunInReal.value,...
                                                                   'inf',...
                                                                   SAMPLE_PERIOD)));
  elseif remainedPerson < 0
    realWeeklyUsageInMinute = double((endUserType_userCount/endUserTypeStruct.appliances(applianceID).weeklyRunInReal.personCount) *...
                                       minutes(timeVector2duration(endUserTypeStruct.appliances(applianceID).weeklyRunInReal.value,...
                                                                   'inf',...
                                                                   SAMPLE_PERIOD)));
  end
  
  % Determine virtual weekly usage value
  virtualWeeklyUsageInMinute = double(trs * SAMPLE_PERIOD);
  
  % Compare real values and determined values, then return matching percentage
  fitnessValue = abs(((virtualWeeklyUsageInMinute-realWeeklyUsageInMinute)/realWeeklyUsageInMinute) * 100);
  % #############################################
end
