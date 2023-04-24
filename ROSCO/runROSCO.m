%% Run ROSCO with Simulink using ROSCO.mdl
% This script will run a single FAST simulation with the ROSCO Simulink
clear all; close all; clc;
addpath(genpath(pwd));
[this_dir,~,~] = fileparts(mfilename('fullpath'));

%% Compile FAST for use with simulink & mex using openfast docs
fast.FAST_SFuncDir     = this_dir;  %%%% NEED FOR SIMULINK
fast.FAST_InputFile    = '5MW_ITIBarge_DLL_WTurb_WavesIrr.fst';   % FAST input file (ext=.fst)
fast.FAST_directory    = this_dir;   % Path to fst directory files

%% Simulink Parameters
% Model
simu.SimModel           = fullfile(this_dir,'Simulink','ROSCO');

% Script for loading parameters
simu.ParamScript        = fullfile(this_dir,'Utilities','load_ROSCO_params');

%% Simulink Setup
[ControlScriptPath,ControScript] = fileparts(simu.ParamScript);
addpath(ControlScriptPath);

%% Read FAST Files & Load ROSCO Params from DISCON.IN
[Param,Cx] = ReadWrite_FAST(fast);

% Simulation Parameters
simu.TMax   = Param.FP.Val{contains(Param.FP.Label,'TMax')};
simu.dt   = Param.FP.Val{contains(Param.FP.Label,'DT')};
[R,F] = feval(ControScript,Param,simu);

%% Premake OutList for Simulink
OutList= {'Time'};
OutList2 = {'Time'};
OutList2 = [OutList2;
    Param.IWP.OutList;
    Param.EDP.OutList;
    Param.HDP.OutList;
    Param.SvDP.OutList;
    ];

for iOut = 2:length(OutList2)
    OutList = [OutList;OutList2{iOut}(1:end)];
end

for iOut2 = 1:length(OutList)
OutList{iOut2}=strrep(OutList{iOut2},'"','');
end
iOut = iOut2;


%% Exectute FAST

% Using Simulink/S_Func
FAST_InputFileName = [fast.FAST_directory,filesep,fast.FAST_InputFile];
TMax               = simu.TMax;

SimulinkModel = simu.SimModel;

Out         = sim(SimulinkModel, 'StopTime', num2str(simu.TMax));
sigsOut     = get(Out,'sigsOut');   %internal control signals

%% Get OutData

SFuncOutStr = '.SFunc';

% Try text first, then binary
[OutData,OutList] = ReadFASTtext([fast.FAST_directory,filesep,fast.FAST_InputFile(1:end-4),SFuncOutStr,'.out']);
if isempty(OutData)
    [OutData,OutList] = ReadFASTbinary([fast.FAST_directory,filesep,fast.FAST_InputFile(1:end-4),SFuncOutStr,'.outb']);
end

% Dump data to structure
for i = 1:length(OutList)
    simout.(OutList{i}) = OutData(:,i);
end

%% Plot
% Pl_FastPlots(simout)


%% Plot FASTOutputs
set(groot, 'defaultAxesLineWidth', 1,'defaultLineLineWidth', 2,'defaultLineLineJoin', "round")

%% Call OpenFAST file matlab
[Channels, DACOutputName, ChanUnit,DescStr] = ReadFASTtext('5MW_ITIBarge_DLL_WTurb_WavesIrr.SFunc.out');
time = Channels(:,find(strcmp(DACOutputName, 'Time')));

%% Define Outlist
Wind1VelX = find(strcmp(DACOutputName, 'Wind1VelX'));
Wave1Elev = find(strcmp(DACOutputName, 'Wave1Elev'));
BldPitch1 = find(strcmp(DACOutputName, 'BldPitch1'));
RootMxb1  = find(strcmp(DACOutputName, 'RootMxb1'));
RootMyb1  = find(strcmp(DACOutputName, 'RootMyb1'));
TwrBsMxt  = find(strcmp(DACOutputName, 'TwrBsMxt'));
TwrBsMyt  = find(strcmp(DACOutputName, 'TwrBsMyt'));
PtfmTDxt  = find(strcmp(DACOutputName, 'PtfmTDxt'));
RotPwr    = find(strcmp(DACOutputName, 'RotPwr'));
RotSpeed  = find(strcmp(DACOutputName, 'RotSpeed'));
GenTq     = find(strcmp(DACOutputName, 'GenTq'));
GenPwr    = find(strcmp(DACOutputName, 'GenPwr'));
GenSpeed  = find(strcmp(DACOutputName, 'GenSpeed'));

%% All in one
figure('Name', 'All in one')
subplot(4,3,1)
plot(time, Channels(:,Wind1VelX))
ylabel([DACOutputName(Wind1VelX) ChanUnit(Wind1VelX)])
xlabel('Time (s)')
title('Wind Speed')
grid on

subplot(4,3,2)
plot(time, Channels(:,Wave1Elev))
ylabel([DACOutputName(Wave1Elev) ChanUnit(Wave1Elev)])
xlabel('Time (s)')
title('Wave elevation')
grid on

subplot(4,3,3)
plot(time, Channels(:,PtfmTDxt))
ylabel([DACOutputName(PtfmTDxt) ChanUnit(PtfmTDxt)])
xlabel('Time (s)')
title('Platform horizontal surge displacement') %% pitch rotation (rad/s)
grid on

subplot(4,3,4)
plot(time, Channels(:,BldPitch1))
ylabel([DACOutputName(BldPitch1) ChanUnit(BldPitch1)])
xlabel('Time (s)')
title('Blade pitch angle')
grid on

subplot(4,3,5)
plot(time, Channels(:,RootMyb1))
ylabel([DACOutputName(RootMyb1) ChanUnit(RootMyb1)])
xlabel('Time (s)')
title('Blade flapwise bending moment')
grid on

subplot(4,3,6)
plot(time, Channels(:,TwrBsMyt))
ylabel([DACOutputName(TwrBsMyt) ChanUnit(TwrBsMyt)])
xlabel('Time (s)')
title('Tower fore-aft bending moment')
grid on

subplot(4,3,7)
plot(time, Channels(:,RotSpeed))
ylabel([DACOutputName(RotSpeed) ChanUnit(RotSpeed)])
xlabel('Time (s)')
title('Rotor azimuth angular speed') %%no
grid on

subplot(4,3,8)
plot(time, Channels(:,RootMxb1))
ylabel([DACOutputName(RootMxb1) ChanUnit(RootMxb1)])
xlabel('Time (s)')
title('Blade edgewise bending moment')
grid on

subplot(4,3,9)
plot(time, Channels(:,TwrBsMxt))
ylabel([DACOutputName(TwrBsMxt) ChanUnit(TwrBsMxt)])
xlabel('Time (s)')
title('Tower side-to-side bending moment')
grid on

subplot(4,3,10)
plot(time, Channels(:,RotPwr))
ylabel([DACOutputName(RotPwr) ChanUnit(RotPwr)])
xlabel('Time (s)')
title('Rotor power')
grid on

subplot(4,3,11)
plot(time, Channels(:,GenTq))
ylabel([DACOutputName(GenTq) ChanUnit(GenTq)])
xlabel('Time (s)')
title('Electrical generator torque') %%no
grid on

subplot(4,3,12)
plot(time, Channels(:,GenSpeed))
ylabel([DACOutputName(GenSpeed) ChanUnit(GenSpeed)])
xlabel('Time (s)')
title('Generator speed')
grid on


