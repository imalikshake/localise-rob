function [botSim] = localise(botSim,map,target)
%This function returns botSim, and accepts, botSim, a map and a target.
%LOCALISE Template localisation function

%% setup code
%you can modify the map to take account of your robots configuration space
modifiedMap = map; %you need to do this modification yourself
botSim.setMap(modifiedMap);
scanConfig = 12;
botSim.setScanConfig(botSim.generateScanConfig(scanConfig));
nanvalue = 1000;
%generate some random particles inside the map
num = 500; % number of particles
particles(num,1) = BotSim; %how to set up a vector of objects
resamples(num,1) = BotSim;
% noise = [0.1, 0.1, 0.1];
noise = [0.3 0.45 0.07];
% noise = [0 0 0];
gridSize = 5;
impact = 0;
prevTarget = 0;
% r =round(linspace(1,num,(num/20)));
for i = 1:num
    particles(i) = BotSim(modifiedMap,noise);  %each particle should use the same map as the botSim object
    particles(i).randomPose(0); %spawn the particles in random locations
    resamples(i) = BotSim(modifiedMap,noise); 
    resamples(i).randomPose(0);
    resamples(i).setScanConfig(botSim.generateScanConfig(scanConfig));
    particles(i).setScanConfig(botSim.generateScanConfig(scanConfig));
end

%% Localisation code
maxNumOfIterations = 100;
n = 0;
scans = [];
damp = 0.3/num;
minx = min(map(:,1));
miny = min(map(:,2));
x=max(map(:,1));
y=max(map(:,2));
% 
graph = containers.Map('KeyType', 'char', 'ValueType', 'double');
points = [];
%Create graph
for i=minx:x+1
    for j=miny:y+1
        if mod(i-1,gridSize) == 0 && mod(j-1,gridSize) == 0 && botSim.pointInsideMap([i-1 j-1]) == 1
            c = [i-1 j-1];
            points = cat(1, points, c);
            coord = c2str([i-1 j-1]);
            graph(coord) = 0;
        end
    end
end
rtarget = round(target,-1);
graph(c2str(rtarget)) = 2;
converged = 0; %The filter has not converged yet
wavefront(graph,rtarget,gridSize,botSim);
% printWaves(graph,gridSize);
while(converged == 0 && n < maxNumOfIterations) %%particle filter loop
    n = n+1; %increment the current number of iterations
    botScan = botSim.ultraScan(); %get a scan from the real robot.
    r = randi([1 num],1,round(num/10));

    %% Write code for updating your particles scans
   for i = 1:num
       a = particles(i).ultraScan();
       a(isnan(a))= nanvalue;
       scans(i,:) = a;
   end

   
   if n < 5
        damp = 1/num;
   else
        damp = 0.2/num;
    end
      
%% Write code for scoring your particles  
    [weights, particles] = orientationProb(particles,scans,botScan,nanvalue,n);
   weights = weights ./ sum(weights);
   weights = weights + damp;
   weights = weights ./ sum(weights);
    %% Write code for resampling your particles
   csum = cumsum(weights);
   for i = 1:num
       j=1;
       p = rand(1,1);
       while(csum(j)<p)
           j=j+1;
       end
      resamples(i).setBotPos(particles(j).getBotPos());
      resamples(i).setBotAng(particles(j).getBotAng());
   end
   particles = resamples;
   
    %% Write code to check for convergence   
    convergence = 0; 
    angleSum = 0;
    for i=1:num
        convergence = convergence + (weights(i) * particles(i).getBotPos());
        angleV = [cos(particles(i).getBotAng()) sin(particles(i).getBotAng())];
        angleSum = angleSum + (weights(i) * angleV);
    end
    angleR = atan2(angleSum(2),angleSum(1));
    %% Write code to take a percentage of your particles and respawn in randomised locations (important for robustness) 
     for i = 1:length(r)
         indx = r(i);
         particles(indx).randomPose(0);
     end
    %% Write code to decide how to move next
    %% Direction and movement.
    move = moveToTarget(convergence,graph,gridSize,botSim,target);
    initDiff = move - convergence;
    initTurn = atan2(initDiff(2),initDiff(1)) - angleR;
    initMove = distance(move,convergence);

    %% If close to target, move slower.
    targetDistance = norm([target(1) - convergence(1), target(2) - convergence(2)]);

    if (targetDistance < 10)
        initDiff = target - convergence;
        initTurn = atan2(initDiff(2),initDiff(1)) - angleR;
        initMove = distance(target,convergence);
        initMove = initMove/2;
    end
    
    [minV, minI] = max(botScan);
    if n < 5
        initTurn = (minI-1) * 2*pi/scanConfig;
        initMove = minV/10;
    end
    %% If approaching wall
    if (botScan(1) - 5 < initMove)
        display('Wall approaching. Reducing movement');
       impact = impact + 1;
       initMove = initMove - impact ;
    else
        impact = 0 ;
    end
    %% Move bot
       
   if initMove > 4 && targetDistance > 40
    initMove = initMove * 2;
   end
   
    botSim.turn(initTurn);
    botSim.move(initMove);
    
    for i =1:num %for all the particles. 
        particles(i).turn(initTurn); %turn the particle in the same way as the real robot
        particles(i).move(initMove); %move the particle in the same way as the real robot
    end
    
    %% If outside, move back in
    inside = botSim.insideMap();
    while ~inside
        botSim.move(-initMove);
        for i = 1:num
            particles(i).move(-initMove);
        end
        inside = botSim.insideMap();
        display('Bot reversing');
    end
    
    %% Convergence check
    if targetDistance < 3
        if n > 10 && prevTarget == 1 
            converged = 1;
        else 
            prevTarget = 1;
        end
    end

% Drawing
%     only draw if you are in debug mode or it will be slow during marking
     if 1
         hold off; %the drawMap() function will clear the drawing when hold is off
         botSim.drawMap(); %drawMap() turns hold back on again, so you can draw the bots
         botSim.drawBot(10,'g'); %draw robot with line length 30 and green
         plot(target(1),target(2),'r.','MarkerSize',20);
         plot(convergence(1),convergence(2),'g.','MarkerSize',40);
         plot(move(1),move(2),'r.','MarkerSize',40);
         grid minor
%          botSim.drawScanConfig();
         for i =1:num
             if mod(i,50) == 0
              particles(i).drawBot(10); %draw particle with line length 3 and default color
             end
         end
         drawnow;
     end
end
end
