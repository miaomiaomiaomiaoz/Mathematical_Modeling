
function main_1()
% Initialize variables
    totalTime = 0;
    maxOutput = 0;
    optimalPath = [];
    RGVPosition = 1; % Assuming RGV starts at position 1
    CNCProcessingTime = zeros(1, 8); % Time required for each CNC to process a workpiece
    CNCWorkStatus = zeros(1, 8); % 1 if CNC is processing, 0 if not
    %materialDemandPoints = [1,2,3,4,5,6,7,8]; % List of material demand points (CNC machine locations)
    Tz = [28,31];
    Tq = 25;% Time for RGV to prepare for the next movement
    
    
    while totalTime <= 28800
% Step 1: Calculate the shortest time required to move to the next material demand point
        [shortestTime,nextCNC] = calculateShortestTime(RGVPosition, CNCWorkStatus, CNCProcessingTime);

% Step 2: Calculate the time required to comply with scheduling requirements

% Step 3: Move RGV to the next material demand point
        moveTime = shortestTime;
        totalTime = totalTime + moveTime;
        RGVPosition = nextCNC;
        
        [CNCProcessingTime, ~] = Timing(CNCProcessingTime, CNCWorkStatus, moveTime);

% Step 4: Perform RGV material loading/unloading operations and update CNC status
        totalTime = totalTime + Tz(2-mod(RGVPosition,2));
        
        [CNCProcessingTime, CNCWorkStatus] = Timing(CNCProcessingTime, CNCWorkStatus, Tz(2-mod(RGVPosition,2)));
        
        CNCProcessingTime(RGVPosition) = eps;
        CNCWorkStatus(RGVPosition) = 1;
        
        
% Step 5
        totalTime = totalTime + Tq;
        maxOutput = maxOutput + 1;
        optimalPath = [optimalPath; RGVPosition];
        
        [CNCProcessingTime, CNCWorkStatus] = Timing(CNCProcessingTime, CNCWorkStatus, Tq);

% Step 6: Update total time and check if it exceeds 8 hours
        if totalTime <= 28800
            % Update the max output and optimal path if needed
        else
            break; % Exit the loop if the total time exceeds 8 hours
        end
    end

% Output the results
    fprintf('Maximum material output: %d\n', maxOutput);
    fprintf('Optimal path: %s\n', mat2str(optimalPath));
end




function [shortestTime, nextCNC] = calculateShortestTime(RGVPosition, CNCWorkStatus, CNCProcessingTime)
    % Implement the logic to calculate the shortest time to move to the next material demand point
    % (You need to consider the distances between RGVPosition and each CNC, as well as the CNC work status)
    % Return the shortestTime and the nextCNC index.
    Tj = 580;
    Tz = [28,31];
    Time = zeros(1,8);
    for n = 1:8
        if CNCWorkStatus(n) == 0
            Time(n) = calculateMovingTime(RGVPosition,n) + Tz(2-mod(n,2));
        else
            Time1 = calculateMovingTime(RGVPosition,n) + Tz(2-mod(n,2));
            Time2 = Tj-CNCProcessingTime(n) + Tz(2-mod(n,2));
            Time(n) = max(Time1, Time2);
        end
    end
    [shortestTime, nextCNC] = min(Time);
    shortestTime = shortestTime - Tz(2-mod(nextCNC,2));
end




function [MovingTime] = calculateMovingTime(RGVPosition,n)
    if(abs(((RGVPosition+mod(RGVPosition,2))/2-1)-((n+mod(n,2))/2-1))==0)
        MovingTime=0;
    elseif(abs(((RGVPosition+mod(RGVPosition,2))/2-1)-((n+mod(n,2))/2-1))==1)
        MovingTime=20;
    elseif(abs(((RGVPosition+mod(RGVPosition,2))/2-1)-((n+mod(n,2))/2-1))==2)
        MovingTime=33;
    else,MovingTime=46;
    end
end




function [CNCProcessingTime, CNCWorkStatus] = Timing(CNCProcessingTime, CNCWorkStatus, T)
    Tj = 580;
    CNCProcessingTime = CNCProcessingTime + T .* CNCWorkStatus;
    %if(~CNCProcessingTime)
    %    CNCProcessingTime = CNCProcessingTime + T;
    %end
    for i = 1:8
        if CNCProcessingTime(i) >= Tj
            CNCProcessingTime(i) = 0;
            CNCWorkStatus(i) = 0;
        end
    end
end