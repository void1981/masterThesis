%% toStart
%%% Plot FASTOutputs
clear; clc; close all;
addpath(genpath(pwd));
set(groot, 'defaultAxesLineWidth', 1,'defaultLineLineWidth', 2,'defaultLineLineJoin', "round") % 'defaultAxesFontSize', 12

%%% Call DAC file 1, 2, 3
[DACStep, DACOutputNameS,ChanUnitS,DescStrS] = ReadFASTtext('DACStep.out');
[DAC14, DACOutputName1,ChanUnit1,DescStr1] = ReadFASTtext('DAC14.out');
[DAC16, DACOutputName2,ChanUnit2,DescStr2] = ReadFASTtext('DAC16.out');
[DAC18, DACOutputName3,ChanUnit3,DescStr3] = ReadFASTtext('DAC18.out');
[DAC20, DACOutputName4,ChanUnit4,DescStr4] = ReadFASTtext('DAC20.out');
%%% Call ROSCO file 1, 2, 3
[ROSCOStep, ROSCOOutputNameS,UnitS,DescROSCOS] = ReadFASTtext('ROSCOStep.out');
[ROSCO14, ROSCOOutputName1,Unit1,DescROSCO1] = ReadFASTtext('ROSCO14.out');
[ROSCO16, ROSCOOutputName2,Unit2,DescROSCO2] = ReadFASTtext('ROSCO16.out');
[ROSCO18, ROSCOOutputName3,Unit3,DescROSCO3] = ReadFASTtext('ROSCO18.out');
[ROSCO20, ROSCOOutputName4,Unit4,DescROSCO4] = ReadFASTtext('ROSCO20.out');

%%% Define Outlist

time   = DAC14(:,strcmp(DACOutputName1, 'Time'));      % Time
Tmax =time(end);
timestep   = DACStep(:,strcmp(DACOutputNameS, 'Time'));      % Time
Tmaxstep =timestep(end);
Wind1VelX = find(strcmp(DACOutputNameS, 'Wind1VelX'));      % Wind speed
Wave1Elev = find(strcmp(DACOutputNameS, 'Wave1Elev'));      % Wave elevation
BldPitch1 = find(strcmp(DACOutputNameS, 'BldPitch1'));      % Blade 1 pitch angle (position)

RootMyb1  = find(strcmp(DACOutputNameS, 'RootMyb1'));       % Blade flapwise moment
TwrBsMyt  = find(strcmp(DACOutputNameS, 'TwrBsMyt'));       % Tower fore-aft bending moment

PtfmTDxt  = find(strcmp(DACOutputNameS, 'PtfmTDxt'));       % Platform horizontal surge displacement
PtfmPitch = find(strcmp(DACOutputNameS, 'PtfmPitch'));      % Platform pitch tilt angular (rotational) displacement

RotPwr    = find(strcmp(DACOutputNameS, 'RotPwr'));         % Rotor power
RotSpeed  = find(strcmp(DACOutputNameS, 'RotSpeed'));       % Rotor speed
GenSpeed  = find(strcmp(DACOutputNameS, 'GenSpeed'));       % Generator speed

RootMxb1  = find(strcmp(DACOutputNameS, 'RootMxb1'));       % Blade edgewise moment
TwrBsMxt  = find(strcmp(DACOutputNameS, 'TwrBsMxt'));       % Tower side-to-side bending moment

GenTq     = find(strcmp(DACOutputNameS, 'GenTq'));
GenPwr    = find(strcmp(DACOutputNameS, 'GenPwr'));


%%%% For one case DAC&ROSCO %%%%
%% Plot wind speed, Wave elevation, and pitch angle
figure('Name', 'wind speed, Wave elevation, and pitch angle')

subplot(1,3,1)
plot(timestep, ROSCOStep(:,Wind1VelX),'r');
hold on
plot(timestep, DACStep(:,Wind1VelX),'b');
hold off
xlabel('Time [s]')
ylabel('Speed [m/s]')
title('a) Hub-height step wind')
subtitle('wind speed 14-22 m/s', 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on

subplot(1,3,2)
plot(timestep, ROSCOStep(:,Wave1Elev),'r');
hold on
plot(timestep, DACStep(:,Wave1Elev),'b');
hold off
xlabel('Time [s]')
ylabel('Elevation [m]')
title('b) Regular wave')
subtitle('mean elevation 4 m, direction 0°, cycle/50 sec', 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on

subplot(1,3,3)
DAC = plot(timestep, DACStep(:,BldPitch1),'b');
hold on
ROSCO = plot(timestep, ROSCOStep(:,BldPitch1),'r');
hold off
meanDAC = mean(DACStep(:,BldPitch1));
meanROSCO = mean(ROSCOStep(:,BldPitch1));
stdDAC = std(DACStep(:,BldPitch1));
stdROSCO = std(ROSCOStep(:,BldPitch1));
xlabel('Time [s]')
ylabel('Angle [deg]')
title('c) Blade pitch angle')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmaxstep 0 23])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

%% Plot Blade flapwise moment, and Tower fore-aft bending moment
figure('Name', 'Blade flapwise moment, and Tower fore-aft bending moment')

subplot(1,2,1)
ROSCO = plot(timestep, ROSCOStep(:,RootMyb1),'r');
hold on
DAC = plot(timestep, DACStep(:,RootMyb1),'b');
hold off
meanDAC = mean(DACStep(:,RootMyb1));
meanROSCO = mean(ROSCOStep(:,RootMyb1));
stdDAC = std(DACStep(:,RootMyb1));
stdROSCO = std(ROSCOStep(:,RootMyb1));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('a) Blade flapwise')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmaxstep 500 9500])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(1,2,2)
DAC = plot(timestep, DACStep(:,TwrBsMyt),'b');
hold on
ROSCO = plot(timestep, ROSCOStep(:,TwrBsMyt),'r');
hold off
meanDAC = mean(DACStep(:,TwrBsMyt));
meanROSCO = mean(ROSCOStep(:,TwrBsMyt));
stdDAC = std(DACStep(:,TwrBsMyt));
stdROSCO = std(ROSCOStep(:,TwrBsMyt));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('b) Tower fore-aft')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmaxstep 0 95000])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

%% Plot Blade edgewise moment, and Tower side-to-side bending moment
figure('Name', 'Blade edgewise moment, and Tower side-to-side bending moment')

subplot(1,2,1)
ROSCO = plot(timestep, ROSCOStep(:,RootMxb1),'r');
hold on
DAC = plot(timestep, DACStep(:,RootMxb1),'b');
hold off
meanDAC = mean(DACStep(:,RootMxb1));
meanROSCO = mean(ROSCOStep(:,RootMxb1));
stdDAC = std(DACStep(:,RootMxb1));
stdROSCO = std(ROSCOStep(:,RootMxb1));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('a) Blade edgewise')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(1,2,2)
DAC = plot(timestep, DACStep(:,TwrBsMxt),'b');
hold on
ROSCO = plot(timestep, ROSCOStep(:,TwrBsMxt),'r');
hold off
meanDAC = mean(DACStep(:,TwrBsMxt));
meanROSCO = mean(ROSCOStep(:,TwrBsMxt));
stdDAC = std(DACStep(:,TwrBsMxt));
stdROSCO = std(ROSCOStep(:,TwrBsMxt));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('b) Tower side-to-side')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmaxstep 2500 8000])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

%% Plot Generator power, rotor speed, and generator speed
figure('Name', 'Rotor power, rotor speed, and generator speed')

subplot(1,3,1)
DAC = plot(timestep, DACStep(:,RotPwr)*0.944,'b');
hold on
ROSCO = plot(timestep, ROSCOStep(:,RotPwr)*0.944 ,'r');
hold off
meanDAC = mean(DACStep(:,RotPwr)*0.944);
meanROSCO = mean(ROSCOStep(:,RotPwr)*0.944);
stdDAC = std(DACStep(:,RotPwr)*0.944);
stdROSCO = std(ROSCOStep(:,RotPwr)*0.944);
xlabel('Time [s]')
ylabel('Power [kW]')
title('a) Generator power')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 200 4300 5500])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(1,3,2)
ROSCO = plot(timestep, ROSCOStep(:,RotSpeed),'r');
hold on
DAC = plot(timestep, DACStep(:,RotSpeed),'b');
hold off
meanDAC = mean(DACStep(:,RotSpeed));
meanROSCO = mean(ROSCOStep(:,RotSpeed));
stdDAC = std(DACStep(:,RotSpeed));
stdROSCO = std(ROSCOStep(:,RotSpeed));
xlabel('Time [s]')
ylabel('Speed [rpm]')
title('b) Rotor speed')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(1,3,3)
ROSCO = plot(timestep, ROSCOStep(:,GenSpeed),'r');
hold on
DAC = plot(timestep, DACStep(:,GenSpeed),'b');
hold off
meanDAC = mean(DACStep(:,GenSpeed));
meanROSCO = mean(ROSCOStep(:,GenSpeed));
stdDAC = std(DACStep(:,GenSpeed));
stdROSCO = std(ROSCOStep(:,GenSpeed));
xlabel('Time [s]')
ylabel('Speed [rpm]')
title('c) Generator speed')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

%% Plot Platform horizontal surge displacement, and Platform pitch tilt angular displacement
figure('Name', 'Platform horizontal surge displacement, and Platform pitch tilt angular displacement')

subplot(1,2,1)
DAC = plot(timestep, DACStep(:,PtfmTDxt),'b');
hold on
ROSCO = plot(timestep, ROSCOStep(:,PtfmTDxt),'r');
hold off
meanDAC = mean(DACStep(:,PtfmTDxt));
meanROSCO = mean(ROSCOStep(:,PtfmTDxt));
stdDAC = std(DACStep(:,PtfmTDxt));
stdROSCO = std(ROSCOStep(:,PtfmTDxt));
xlabel('Time [s]')
ylabel('Displacement [m]')
title('a) Platform surge displacement')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(1,2,2)
DAC = plot(timestep, DACStep(:,PtfmPitch),'b');
hold on
ROSCO = plot(timestep, ROSCOStep(:,PtfmPitch),'r');
hold off
meanDAC = mean(DACStep(:,PtfmPitch));
meanROSCO = mean(ROSCOStep(:,PtfmPitch));
stdDAC = std(DACStep(:,PtfmPitch));
stdROSCO = std(ROSCOStep(:,PtfmPitch));
xlabel('Time [s]')
ylabel('Angle [deg]')
title('b) Platform pitch tilt angle')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

%%%% For three cases DAC&ROSCO %%%%

%% Plot wind speed, Wave elevation, and pitch angle
figure('Name', 'wind speed, Wave elevation, and pitch angle 3')

subplot(3,3,1)
plot(time, ROSCO14(:,Wind1VelX),'r');
hold on
plot(time, DAC14(:,Wind1VelX),'b');
hold off
xlabel('Time [s]')
ylabel('Speed [m/s]')
title('a1) Hub-height stochastic wind')
subtitle('mean speed 14 m/s with TI 5 %', 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on

subplot(3,3,2)
plot(time, ROSCO16(:,Wind1VelX),'r');
hold on
plot(time, DAC16(:,Wind1VelX),'b')
hold off
xlabel('Time [s]')
ylabel('Speed [m/s]')
title('a2) Hub-height stochastic wind')
subtitle('mean speed 16 m/s with TI 10 %', 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on

subplot(3,3,3)
plot(time, ROSCO18(:,Wind1VelX),'r')
hold on
plot(time, DAC18(:,Wind1VelX),'b')
hold off
xlabel('Time [s]')
ylabel('Speed [m/s]')
title('a3) Hub-height stochastic wind')
subtitle('mean speed 18 m/s with TI 15 %', 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on

subplot(3,3,4)
plot(time, ROSCO14(:,Wave1Elev),'r')
hold on
plot(time, DAC14(:,Wave1Elev),'b')
hold off
xlabel('Time [s]')
ylabel('Elevation [m]')
title('b1) Irregular wave')
subtitle('mean elevation 3 m, direction 0°', 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on

subplot(3,3,5)
plot(time, ROSCO16(:,Wave1Elev),'r')
hold on
plot(time, DAC16(:,Wave1Elev),'b')
hold off
xlabel('Time [s]')
ylabel('Elevation [m]')
title('b2) Irregular wave')
subtitle('mean elevation 4 m, direction 180°', 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on

subplot(3,3,6)
plot(time, ROSCO18(:,Wave1Elev),'r')
hold on
plot(time, DAC18(:,Wave1Elev),'b')
hold off
xlabel('Time [s]')
ylabel('Elevation [m]')
title('b3) Irregular wave')
subtitle('mean elevation 5 m, direction 0°', 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on

subplot(3,3,7)
plot(time, DAC14(:,BldPitch1),'b')
hold on
plot(time, ROSCO14(:,BldPitch1),'r')
hold off
meanDAC = mean(DAC14(:,BldPitch1));
meanROSCO = mean(ROSCO14(:,BldPitch1));
stdDAC = std(DAC14(:,BldPitch1));
stdROSCO = std(ROSCO14(:,BldPitch1));
xlabel('Time [s]')
ylabel('Angle [deg]')
title('c1) Blade pitch angle')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(3,3,8)
DAC = plot(time, DAC16(:,BldPitch1),'b');
hold on
ROSCO = plot(time, ROSCO16(:,BldPitch1),'r');
hold off
meanDAC = mean(DAC16(:,BldPitch1));
meanROSCO = mean(ROSCO16(:,BldPitch1));
stdDAC = std(DAC16(:,BldPitch1));
stdROSCO = std(ROSCO16(:,BldPitch1));
xlabel('Time [s]')
ylabel('Angle [deg]')
title('c2) Blade pitch angle')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(3,3,9)
DAC = plot(time, DAC18(:,BldPitch1),'b');
hold on
ROSCO = plot(time, ROSCO18(:,BldPitch1),'r');
hold off
meanDAC = mean(DAC18(:,BldPitch1));
meanROSCO = mean(ROSCO18(:,BldPitch1));
stdDAC = std(DAC18(:,BldPitch1));
stdROSCO = std(ROSCO18(:,BldPitch1));
xlabel('Time [s]')
ylabel('Angle [deg]')
title('c3) Blade pitch angle')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax 5 25])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

%% Plot Blade flapwise moment, and Tower fore-aft bending moment
figure('Name', 'Blade flapwise moment, and Tower fore-aft bending moment 3')

subplot(2,3,1)
DAC = plot(time, DAC14(:,RootMyb1),'b');
hold on
ROSCO = plot(time, ROSCO14(:,RootMyb1),'r');
hold off
meanDAC = mean(DAC14(:,RootMyb1));
meanROSCO = mean(ROSCO14(:,RootMyb1));
stdDAC = std(DAC14(:,RootMyb1));
stdROSCO = std(ROSCO14(:,RootMyb1));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('a1) Blade flapwise')
subtitle({'wind: 14 m/s, wave: 3 m',['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(2,3,2)
ROSCO = plot(time, ROSCO16(:,RootMyb1),'r');
hold on
DAC = plot(time, DAC16(:,RootMyb1),'b');
hold off
meanDAC = mean(DAC16(:,RootMyb1));
meanROSCO = mean(ROSCO16(:,RootMyb1));
stdDAC = std(DAC16(:,RootMyb1));
stdROSCO = std(ROSCO16(:,RootMyb1));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('a2) Blade flapwise')
subtitle({'wind: 16 m/s, wave: 4 m',['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax 0 10000])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(2,3,3)
ROSCO = plot(time, ROSCO18(:,RootMyb1),'r');
hold on
DAC = plot(time, DAC18(:,RootMyb1),'b');
hold off
meanDAC = mean(DAC18(:,RootMyb1));
meanROSCO = mean(ROSCO18(:,RootMyb1));
stdDAC = std(DAC18(:,RootMyb1));
stdROSCO = std(ROSCO18(:,RootMyb1));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('a3) Blade flapwise')
subtitle({'wind: 18 m/s, wave: 5 m',['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax -1000 10000])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(2,3,4)
DAC = plot(time, DAC14(:,TwrBsMyt),'b');
hold on
ROSCO = plot(time, ROSCO14(:,TwrBsMyt),'r');
hold off
meanDAC = mean(DAC14(:,TwrBsMyt));
meanROSCO = mean(ROSCO14(:,TwrBsMyt));
stdDAC = std(DAC14(:,TwrBsMyt));
stdROSCO = std(ROSCO14(:,TwrBsMyt));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('b1) Tower fore-aft')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(2,3,5)
DAC = plot(time, DAC16(:,TwrBsMyt),'b');
hold on
ROSCO = plot(time, ROSCO16(:,TwrBsMyt),'r');
hold off
meanDAC = mean(DAC16(:,TwrBsMyt));
meanROSCO = mean(ROSCO16(:,TwrBsMyt));
stdDAC = std(DAC16(:,TwrBsMyt));
stdROSCO = std(ROSCO16(:,TwrBsMyt));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('b2) Tower fore-aft')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(2,3,6)
ROSCO = plot(time, ROSCO18(:,TwrBsMyt),'r');
hold on
DAC = plot(time, DAC18(:,TwrBsMyt),'b');
hold off
meanDAC = mean(DAC18(:,TwrBsMyt));
meanROSCO = mean(ROSCO18(:,TwrBsMyt));
stdDAC = std(DAC18(:,TwrBsMyt));
stdROSCO = std(ROSCO18(:,TwrBsMyt));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('b3) Tower fore-aft')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

%% Plot Blade edgewise moment, and Tower side-to-side bending moment
figure('Name', 'Blade edgewise moment, and Tower side-to-side bending moment 3')

subplot(2,3,1)
ROSCO = plot(time, ROSCO14(:,RootMxb1),'r');
hold on
DAC = plot(time, DAC14(:,RootMxb1),'b');
hold off
meanDAC = mean(DAC14(:,RootMxb1));
meanROSCO = mean(ROSCO14(:,RootMxb1));
stdDAC = std(DAC14(:,RootMxb1));
stdROSCO = std(ROSCO14(:,RootMxb1));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('a1) Blade edgewise')
subtitle({'wind: 14 m/s, wave: 3 m',['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(2,3,2)
ROSCO = plot(time, ROSCO16(:,RootMxb1),'r');
hold on
DAC = plot(time, DAC16(:,RootMxb1),'b');
hold off
meanDAC = mean(DAC16(:,RootMxb1));
meanROSCO = mean(ROSCO16(:,RootMxb1));
stdDAC = std(DAC16(:,RootMxb1));
stdROSCO = std(ROSCO16(:,RootMxb1));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('a2) Blade edgewise')
subtitle({'wind: 16 m/s, wave: 4 m',['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(2,3,3)
ROSCO = plot(time, ROSCO18(:,RootMxb1),'r');
hold on
DAC = plot(time, DAC18(:,RootMxb1),'b');
hold off
meanDAC = mean(DAC18(:,RootMxb1));
meanROSCO = mean(ROSCO18(:,RootMxb1));
stdDAC = std(DAC18(:,RootMxb1));
stdROSCO = std(ROSCO18(:,RootMxb1));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('a3) Blade edgewise')
subtitle({'wind: 18 m/s, wave: 5 m',['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(2,3,4)
DAC = plot(time, DAC14(:,TwrBsMxt),'b');
hold on
ROSCO = plot(time, ROSCO14(:,TwrBsMxt),'r');
hold off
meanDAC = mean(DAC14(:,TwrBsMxt));
meanROSCO = mean(ROSCO14(:,TwrBsMxt));
stdDAC = std(DAC14(:,TwrBsMxt));
stdROSCO = std(ROSCO14(:,TwrBsMxt));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('b1) Tower side-to-side')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(2,3,5)
ROSCO = plot(time, ROSCO16(:,TwrBsMxt),'r');
hold on
DAC = plot(time, DAC16(:,TwrBsMxt),'b');
hold off
meanDAC = mean(DAC16(:,TwrBsMxt));
meanROSCO = mean(ROSCO16(:,TwrBsMxt));
stdDAC = std(DAC16(:,TwrBsMxt));
stdROSCO = std(ROSCO16(:,TwrBsMxt));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('b2) Tower side-to-side')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(2,3,6)
ROSCO = plot(time, ROSCO18(:,TwrBsMxt),'r');
hold on
DAC = plot(time, DAC18(:,TwrBsMxt),'b');
hold off
meanDAC = mean(DAC18(:,TwrBsMxt));
meanROSCO = mean(ROSCO18(:,TwrBsMxt));
stdDAC = std(DAC18(:,TwrBsMxt));
stdROSCO = std(ROSCO18(:,TwrBsMxt));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('b3) Tower side-to-side')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

%% Plot rotor power, rotor speed, and generator speed
figure('Name', 'Rotor power, rotor speed, and generator speed 3')

subplot(3,3,1)
DAC = plot(time, DAC14(:,RotPwr)*.944,'b');
hold on
ROSCO = plot(time, ROSCO14(:,RotPwr)*0.944,'r');
hold off
meanDAC = mean(DAC14(:,RotPwr)*.944);
meanROSCO = mean(ROSCO14(:,RotPwr)*0.944);
stdDAC = std(DAC14(:,RotPwr)*.944);
stdROSCO = std(ROSCO14(:,RotPwr)*0.944);
xlabel('Time [s]')
ylabel('Power [kW]')
title('a1) Generator power')
subtitle({'wind: 14 m/s, wave: 3 m',['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax 3800 5800])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(3,3,2)
ROSCO = plot(time, ROSCO16(:,RotPwr)*.944,'r');
hold on
DAC = plot(time, DAC16(:,RotPwr)*.944,'b');
hold off
meanDAC = mean(DAC16(:,RotPwr)*.944);
meanROSCO = mean(ROSCO16(:,RotPwr)*0.944);
stdDAC = std(DAC16(:,RotPwr)*.944);
stdROSCO = std(ROSCO16(:,RotPwr)*0.944);
xlabel('Time [s]')
ylabel('Power [kW]')
title('a2) Generator power')
subtitle({'wind: 16 m/s, wave: 4 m',['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax 4400 5500])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(3,3,3)
ROSCO = plot(time, ROSCO18(:,RotPwr)*.944,'r');
hold on
DAC = plot(time, DAC18(:,RotPwr)*.944,'b');
hold off
meanDAC = mean(DAC18(:,RotPwr)*.944);
meanROSCO = mean(ROSCO18(:,RotPwr)*0.944);
stdDAC = std(DAC18(:,RotPwr)*.944);
stdROSCO = std(ROSCO18(:,RotPwr)*0.944);
xlabel('Time [s]')
ylabel('Power [kW]')
title('a3) Generator power')
subtitle({'wind: 18 m/s, wave: 5 m',['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax 4000 5800])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(3,3,4)
DAC = plot(time, DAC14(:,RotSpeed),'b');
hold on
ROSCO = plot(time, ROSCO14(:,RotSpeed),'r');
hold off
meanDAC = mean(DAC14(:,RotSpeed));
meanROSCO = mean(ROSCO14(:,RotSpeed));
stdDAC = std(DAC14(:,RotSpeed));
stdROSCO = std(ROSCO14(:,RotSpeed));
xlabel('Time [s]')
ylabel('Speed [m/s]')
title('b1) Rotor speed')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(3,3,5)
ROSCO = plot(time, ROSCO16(:,RotSpeed),'r');
hold on
DAC = plot(time, DAC16(:,RotSpeed),'b');
hold off
meanDAC = mean(DAC16(:,RotSpeed));
meanROSCO = mean(ROSCO16(:,RotSpeed));
stdDAC = std(DAC16(:,RotSpeed));
stdROSCO = std(ROSCO16(:,RotSpeed));
xlabel('Time [s]')
ylabel('Speed [m/s]')
title('b2) Rotor speed')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(3,3,6)
ROSCO = plot(time, ROSCO18(:,RotSpeed),'r');
hold on
DAC = plot(time, DAC18(:,RotSpeed),'b');
hold off
meanDAC = mean(DAC18(:,RotSpeed));
meanROSCO = mean(ROSCO18(:,RotSpeed));
stdDAC = std(DAC18(:,RotSpeed));
stdROSCO = std(ROSCO18(:,RotSpeed));
xlabel('Time [s]')
ylabel('Speed [m/s]')
title('b3) Rotor speed')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(3,3,7)
DAC = plot(time, DAC14(:,GenSpeed),'b');
hold on
ROSCO = plot(time, ROSCO14(:,GenSpeed),'r');
hold off
meanDAC = mean(DAC14(:,GenSpeed));
meanROSCO = mean(ROSCO14(:,GenSpeed));
stdDAC = std(DAC14(:,GenSpeed));
stdROSCO = std(ROSCO14(:,GenSpeed));
xlabel('Time [s]')
ylabel('Speed [m/s]')
title('c1) Generator speed')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(3,3,8)
ROSCO = plot(time, ROSCO16(:,GenSpeed),'r');
hold on
DAC = plot(time, DAC16(:,GenSpeed),'b');
hold off
meanDAC = mean(DAC16(:,GenSpeed));
meanROSCO = mean(ROSCO16(:,GenSpeed));
stdDAC = std(DAC16(:,GenSpeed));
stdROSCO = std(ROSCO16(:,GenSpeed));
xlabel('Time [s]')
ylabel('Speed [m/s]')
title('c2) Generator speed')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(3,3,9)
ROSCO = plot(time, ROSCO18(:,GenSpeed),'r');
hold on
DAC = plot(time, DAC18(:,GenSpeed),'b');
hold off
meanDAC = mean(DAC18(:,GenSpeed));
meanROSCO = mean(ROSCO18(:,GenSpeed));
stdDAC = std(DAC18(:,GenSpeed));
stdROSCO = std(ROSCO18(:,GenSpeed));
xlabel('Time [s]')
ylabel('Speed [m/s]')
title('c3) Generator speed')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

%% Plot Platform horizontal surge displacement, and Platform pitch tilt angular displacement
figure('Name', 'Platform horizontal surge displacement, and Platform pitch tilt angular displacement 3')

subplot(2,3,1)
ROSCO = plot(time, ROSCO14(:,PtfmTDxt),'r');
hold on
DAC = plot(time, DAC14(:,PtfmTDxt),'b');
hold off
meanDAC = mean(DAC14(:,PtfmTDxt));
meanROSCO = mean(ROSCO14(:,PtfmTDxt));
stdDAC = std(DAC14(:,PtfmTDxt));
stdROSCO = std(ROSCO14(:,PtfmTDxt));
xlabel('Time [s]')
ylabel('Displacement [m]')
title('a1) Platform surge displacement')
subtitle({'wind: 14 m/s, wave: 3 m',['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(2,3,2)
ROSCO = plot(time, ROSCO16(:,PtfmTDxt),'r');
hold on
DAC = plot(time, DAC16(:,PtfmTDxt),'b');
hold off
meanDAC = mean(DAC16(:,PtfmTDxt));
meanROSCO = mean(ROSCO16(:,PtfmTDxt));
stdDAC = std(DAC16(:,PtfmTDxt));
stdROSCO = std(ROSCO16(:,PtfmTDxt));
xlabel('Time [s]')
ylabel('Displacement [m]')
title('a2) Platform surge displacement')
subtitle({'wind: 16 m/s, wave: 4 m',['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(2,3,3)
ROSCO = plot(time, ROSCO18(:,PtfmTDxt),'r');
hold on
DAC = plot(time, DAC18(:,PtfmTDxt),'b');
hold off
meanDAC = mean(DAC18(:,PtfmTDxt));
meanROSCO = mean(ROSCO18(:,PtfmTDxt));
stdDAC = std(DAC18(:,PtfmTDxt));
stdROSCO = std(ROSCO18(:,PtfmTDxt));
xlabel('Time [s]')
ylabel('Displacement [m]')
title('a3) Platform surge displacement')
subtitle({'wind: 18 m/s, wave: 5 m',['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(2,3,4)
DAC = plot(time, DAC14(:,PtfmPitch),'b');
hold on
ROSCO = plot(time, ROSCO14(:,PtfmPitch),'r');
hold off
meanDAC = mean(DAC14(:,PtfmPitch));
meanROSCO = mean(ROSCO14(:,PtfmPitch));
stdDAC = std(DAC14(:,PtfmPitch));
stdROSCO = std(ROSCO14(:,PtfmPitch));
xlabel('Time [s]')
ylabel('Angle [deg]')
title('b1) Platform pitch tilt angle')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(2,3,5)
DAC = plot(time, DAC16(:,PtfmPitch),'b');
hold on
ROSCO = plot(time, ROSCO16(:,PtfmPitch),'r');
hold off
meanDAC = mean(DAC16(:,PtfmPitch));
meanROSCO = mean(ROSCO16(:,PtfmPitch));
stdDAC = std(DAC16(:,PtfmPitch));
stdROSCO = std(ROSCO16(:,PtfmPitch));
xlabel('Time [s]')
ylabel('Angle [deg]')
title('b2) Platform pitch tilt angle')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(2,3,6)
ROSCO = plot(time, ROSCO18(:,PtfmPitch),'r');
hold on
DAC = plot(time, DAC18(:,PtfmPitch),'b');
hold off
meanDAC = mean(DAC18(:,PtfmPitch));
meanROSCO = mean(ROSCO18(:,PtfmPitch));
stdDAC = std(DAC18(:,PtfmPitch));
stdROSCO = std(ROSCO18(:,PtfmPitch));
xlabel('Time [s]')
ylabel('Angle [deg]')
title('b3) Platform pitch tilt angle')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

%%%% 20m/s %%%%

%% Plot wind speed, Wave elevation, and pitch angle
figure('Name', 'wind speed, Wave elevation, and pitch angle 20')

subplot(1,3,1)
plot(time, ROSCO20(:,Wind1VelX),'r');
hold on
plot(time, DAC20(:,Wind1VelX),'b');
hold off
xlabel('Time [s]')
ylabel('Speed [m/s]')
title('a) Hub-height stochastic wind')
subtitle('mean speed 20 m/s with TI 5 %', 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on

subplot(1,3,2)
plot(time, ROSCO20(:,Wave1Elev),'r')
hold on
plot(time, DAC20(:,Wave1Elev),'b')
hold off
xlabel('Time [s]')
ylabel('Elevation [m]')
title('b) Irregular wave')
subtitle('mean elevation 4 m, direction 0°', 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on

subplot(1,3,3)
DAC = plot(time, DAC20(:,BldPitch1),'b');
hold on
ROSCO = plot(time, ROSCO20(:,BldPitch1),'r');
hold off
meanDAC = mean(DAC20(:,BldPitch1));
meanROSCO = mean(ROSCO20(:,BldPitch1));
stdDAC = std(DAC20(:,BldPitch1));
stdROSCO = std(ROSCO20(:,BldPitch1));
xlabel('Time [s]')
ylabel('Angle [deg]')
title('c) Blade pitch angle')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax 10 23])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

%% Plot Blade flapwise moment, and Tower fore-aft bending moment
figure('Name', 'Blade flapwise moment, and Tower fore-aft bending moment 20')

subplot(1,3,1)
ROSCO = plot(time, ROSCO20(:,RootMyb1),'r');
hold on
DAC = plot(time, DAC20(:,RootMyb1),'b');
hold off
meanDAC = mean(DAC20(:,RootMyb1));
meanROSCO = mean(ROSCO20(:,RootMyb1));
stdDAC = std(DAC20(:,RootMyb1));
stdROSCO = std(ROSCO20(:,RootMyb1));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('a) Blade flapwise')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax 0 8000])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(1,3,2)
ROSCO = plot(time, ROSCO20(:,TwrBsMyt),'r');
hold on
DAC = plot(time, DAC20(:,TwrBsMyt),'b');
hold off
meanDAC = mean(DAC20(:,TwrBsMyt));
meanROSCO = mean(ROSCO20(:,TwrBsMyt));
stdDAC = std(DAC20(:,TwrBsMyt));
stdROSCO = std(ROSCO20(:,TwrBsMyt));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('b) Tower fore-aft')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax 0 80000])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(1,3,3)
ROSCO = plot(time, ROSCO20(:,PtfmPitch),'r');
hold on
DAC = plot(time, DAC20(:,PtfmPitch),'b');
hold off
meanDAC = mean(DAC20(:,PtfmPitch));
meanROSCO = mean(ROSCO20(:,PtfmPitch));
stdDAC = std(DAC20(:,PtfmPitch));
stdROSCO = std(ROSCO20(:,PtfmPitch));
xlabel('Time [s]')
ylabel('Angle [deg]')
title('c) Platform pitch tilt angle')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax 0 2])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

%% Plot Generator power, rotor speed, and generator speed
figure('Name', 'Rotor power, rotor speed, and generator speed 20')

subplot(1,3,1)
ROSCO = plot(time, ROSCO20(:,RotPwr)*0.944 ,'r');
hold on
DAC = plot(time, DAC20(:,RotPwr)*0.944,'b');
hold off
meanDAC = mean(DAC20(:,RotPwr)*0.944);
meanROSCO = mean(ROSCO20(:,RotPwr)*0.944);
stdDAC = std(DAC20(:,RotPwr)*0.944);
stdROSCO = std(ROSCO20(:,RotPwr)*0.944);
xlabel('Time [s]')
ylabel('Power [kW]')
title('a) Generator power')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax 4600 5400])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(1,3,2)
ROSCO = plot(time, ROSCO20(:,RotSpeed),'r');
hold on
DAC = plot(time, DAC20(:,RotSpeed),'b');
hold off
meanDAC = mean(DAC20(:,RotSpeed));
meanROSCO = mean(ROSCO20(:,RotSpeed));
stdDAC = std(DAC20(:,RotSpeed));
stdROSCO = std(ROSCO20(:,RotSpeed));
xlabel('Time [s]')
ylabel('Speed [rpm]')
title('b) Rotor speed')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax 11 13])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(1,3,3)
ROSCO = plot(time, ROSCO20(:,GenSpeed),'r');
hold on
DAC = plot(time, DAC20(:,GenSpeed),'b');
hold off
meanDAC = mean(DAC20(:,GenSpeed));
meanROSCO = mean(ROSCO20(:,GenSpeed));
stdDAC = std(DAC20(:,GenSpeed));
stdROSCO = std(ROSCO20(:,GenSpeed));
xlabel('Time [s]')
ylabel('Speed [rpm]')
title('c) Generator speed')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax 1100 1250])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})


%% Plot 20m/s
figure('Name', 'wind speed 20')

subplot(3,3,1)
plot(time, ROSCO20(:,Wind1VelX),'r');
hold on
plot(time, DAC20(:,Wind1VelX),'b');
hold off
xlabel('Time [s]')
ylabel('Speed [m/s]')
title('a) Hub-height stochastic wind')
subtitle('mean speed 20 m/s with TI 5 %', 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on

subplot(3,3,2)
plot(time, ROSCO20(:,Wave1Elev),'r')
hold on
plot(time, DAC20(:,Wave1Elev),'b')
hold off
xlabel('Time [s]')
ylabel('Elevation [m]')
title('b) Irregular wave')
subtitle('mean elevation 4 m, direction 0°', 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
grid on

subplot(3,3,3)
DAC = plot(time, DAC20(:,BldPitch1),'b');
hold on
ROSCO = plot(time, ROSCO20(:,BldPitch1),'r');
hold off
meanDAC = mean(DAC20(:,BldPitch1));
meanROSCO = mean(ROSCO20(:,BldPitch1));
stdDAC = std(DAC20(:,BldPitch1));
stdROSCO = std(ROSCO20(:,BldPitch1));
xlabel('Time [s]')
ylabel('Angle [deg]')
title('c) Blade pitch angle')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax 10 23])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(3,3,4)
ROSCO = plot(time, ROSCO20(:,RootMyb1),'r');
hold on
DAC = plot(time, DAC20(:,RootMyb1),'b');
hold off
meanDAC = mean(DAC20(:,RootMyb1));
meanROSCO = mean(ROSCO20(:,RootMyb1));
stdDAC = std(DAC20(:,RootMyb1));
stdROSCO = std(ROSCO20(:,RootMyb1));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('d) Blade flapwise')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax 0 8000])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(3,3,5)
ROSCO = plot(time, ROSCO20(:,TwrBsMyt),'r');
hold on
DAC = plot(time, DAC20(:,TwrBsMyt),'b');
hold off
meanDAC = mean(DAC20(:,TwrBsMyt));
meanROSCO = mean(ROSCO20(:,TwrBsMyt));
stdDAC = std(DAC20(:,TwrBsMyt));
stdROSCO = std(ROSCO20(:,TwrBsMyt));
xlabel('Time [s]')
ylabel('Bending moment [kN-m]')
title('e) Tower fore-aft')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax 0 80000])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(3,3,6)
ROSCO = plot(time, ROSCO20(:,PtfmPitch),'r');
hold on
DAC = plot(time, DAC20(:,PtfmPitch),'b');
hold off
meanDAC = mean(DAC20(:,PtfmPitch));
meanROSCO = mean(ROSCO20(:,PtfmPitch));
stdDAC = std(DAC20(:,PtfmPitch));
stdROSCO = std(ROSCO20(:,PtfmPitch));
xlabel('Time [s]')
ylabel('Angle [deg]')
title('f) Platform pitch tilt angle')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax 0 2])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(3,3,7)
ROSCO = plot(time, ROSCO20(:,RotPwr)*0.944 ,'r');
hold on
DAC = plot(time, DAC20(:,RotPwr)*0.944,'b');
hold off
meanDAC = mean(DAC20(:,RotPwr)*0.944);
meanROSCO = mean(ROSCO20(:,RotPwr)*0.944);
stdDAC = std(DAC20(:,RotPwr)*0.944);
stdROSCO = std(ROSCO20(:,RotPwr)*0.944);
xlabel('Time [s]')
ylabel('Power [kW]')
title('g) Generator power')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax 4600 5400])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(3,3,8)
ROSCO = plot(time, ROSCO20(:,RotSpeed),'r');
hold on
DAC = plot(time, DAC20(:,RotSpeed),'b');
hold off
meanDAC = mean(DAC20(:,RotSpeed));
meanROSCO = mean(ROSCO20(:,RotSpeed));
stdDAC = std(DAC20(:,RotSpeed));
stdROSCO = std(ROSCO20(:,RotSpeed));
xlabel('Time [s]')
ylabel('Speed [rpm]')
title('h) Rotor speed')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax 11 13])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

subplot(3,3,9)
ROSCO = plot(time, ROSCO20(:,GenSpeed),'r');
hold on
DAC = plot(time, DAC20(:,GenSpeed),'b');
hold off
meanDAC = mean(DAC20(:,GenSpeed));
meanROSCO = mean(ROSCO20(:,GenSpeed));
stdDAC = std(DAC20(:,GenSpeed));
stdROSCO = std(ROSCO20(:,GenSpeed));
xlabel('Time [s]')
ylabel('Speed [rpm]')
title('i) Generator speed')
subtitle({['ROSCO: mean = ' num2str(meanROSCO) ', Std. Dev. = ' num2str(stdROSCO)], ...
    ['DAC: mean = ' num2str(meanDAC) ', Std. Dev. = ' num2str(stdDAC)]}, 'FontWeight', 'normal', 'Color', 'blue', 'HorizontalAlignment', 'center')
axis([0 Tmax 1100 1250])
grid on
legend([ROSCO DAC],{'ROSCO','DAC'})

%% Save figures
figlist = findall(0,'type','figure');
save_dir = fullfile(pwd, 'figures');
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end
for i = 1:numel(figlist)
    fig_title = get(figlist(i),'Name');
    if ~isempty(fig_title)
    %set(figlist(i), 'Position', get(0, 'Screensize')); % set figure to fullscreen
    figname = sprintf('%s.png', fig_title);
    figname = fullfile(save_dir, figname);
    %saveas(figlist(i), figname);
    exportgraphics(figlist(i), figname,'Resolution','600');
    end
end

%close all;
