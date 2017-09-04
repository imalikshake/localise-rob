clf;        %clears figures
clc;        %clears console
clear;      %clears workspace
axis equal; %keeps the x and y scale the same
% map=[0,0;60,0;60,45;45,45;45,59;106,59;106,105;0,105];  %default map
% map= [-30,0;-30,40;30,40;30,60;5,60;45,90;85,60;60,60;60,40;120,40;120,60;95,60;135,90;175,60;150,60;150,40;210,40;210,60;185,60;225,90;265,60;240,60;240,40;300,40;300,0];
map = [0,0;60,0;60,50;100,50;70,0;110,0;150,80;30,80;30,40;0,80]; %long map
% grid = 10;
% map=[0,0;20,0;25,35;30,0;50,0;30,70;0,70];
% botSim = BotSim(map,[0.01,0.005,0]);  %sets up a botSim object a map, and debug mode on.
botSim = BotSim(map,[0,0,0]);  %sets up a botSim object a map, and debug mode on.
botSim.drawMap();
drawnow;
botSim.randomPose(10); %puts the robot in a random position at least 10cm away from a wall
start = [10,10];
target= [40,10];
% target = botSim.getRndPtInMap(10);  %gets random target.
% start = botSim.getBotPos();


tic %starts timer

%your localisation function is called here.
returnedBot = localise(botSim,map,target); %Where the magic happens

resultsTime = toc %stops timer

%calculated how far away your robot is from the target.
resultsDis =  distance(target, returnedBot.getBotPos())