%% DAC controller
clear all; close all; clc;
addpath(genpath(pwd));

%% Define OpenFAST file 
FAST_InputFileName = '5MW_ITIBarge_DLL_WTurb_WavesIrr.fst';
TMax = 600;
PC_MaxPit = 1.570796;       % Maximum pitch rate (in absolute value) (rad)
PC_MinPit = 0.0;            % Minimum pitch setting in pitch controller (rad)
PC_MaxRat = 0.1396263;      % Max pitch rate (rad/s)

%% Define OutList
OutList = cell(27, 1);
OutList{1,1} = 'Time';OutList{2,1} = 'Wind1VelX';OutList{3,1} = 'BldPitch1';OutList{4,1} = 'RootMxb1';OutList{5,1} = 'RootMxb2';OutList{6,1} = 'RootMxb3';
OutList{7,1} = 'RootMyb1';OutList{8,1} = 'RootMyb2';OutList{9,1} = 'RootMyb3';OutList{10,1} = 'TwrBsMxt';OutList{11,1} = 'TwrBsMyt';OutList{12,1} = 'TwrBsMzt';OutList{13,1} = 'PtfmTDxt';
OutList{14,1} = 'RotPwr';OutList{15,1} = 'RotSpeed';OutList{16,1} = 'Azimuth';OutList{17,1} = 'GenSpeed';OutList{18,1} = 'NcIMURAys';OutList{19,1} = 'NcIMUTAxs';OutList{20,1} = 'RootMyc1';
OutList{21,1} = 'RootMyc2';OutList{22,1} = 'RootMyc3';OutList{23,1} = 'PtfmPitch';OutList{24,1} = 'PtfmRAyt';OutList{25,1} = 'GenPwr';OutList{26,1} = 'GenTq';OutList{27,1} = 'Wave1Elev';
%% Uncertain models
[this_dir,~,~] = fileparts(mfilename('fullpath'));

FileNames={'5MW_ITIBarge_DLL_WTurb_WavesIrr.1.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.2.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.3.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.4.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.5.lin',...
    '5MW_ITIBarge_DLL_WTurb_WavesIrr.6.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.7.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.8.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.9.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.10.lin',...
    '5MW_ITIBarge_DLL_WTurb_WavesIrr.11.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.12.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.13.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.14.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.15.lin',...
    '5MW_ITIBarge_DLL_WTurb_WavesIrr.16.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.17.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.18.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.19.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.20.lin',...
    '5MW_ITIBarge_DLL_WTurb_WavesIrr.21.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.22.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.23.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.24.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.25.lin',...
    '5MW_ITIBarge_DLL_WTurb_WavesIrr.26.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.27.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.28.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.29.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.30.lin',...
    '5MW_ITIBarge_DLL_WTurb_WavesIrr.31.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.32.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.33.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.34.lin','5MW_ITIBarge_DLL_WTurb_WavesIrr.35.lin',...
    '5MW_ITIBarge_DLL_WTurb_WavesIrr.36.lin'};

[MBC,Lindata] = fx_mbc3(fullfile(this_dir,'linearizationFiles',FileNames));

%% MBC transformation
AvgA=MBC.AvgA;
AvgB=MBC.AvgB;
AvgBd=MBC.AvgB;
AvgC=MBC.AvgC;
AvgD=MBC.AvgD;
AvgDd=MBC.AvgD;

%% Remove unnecessary states, inputs, and outputs
AvgA(3,:)=[];                   % Remove row 3 
AvgA(:,3)=[];                   % Remove column 3 
A_a=AvgA;

AvgB(3,:)=[];                   % Remove row 3
AvgB(:,[1:1:3 7:1:67])=[];      % Remove columns 1-3,7-67
B_a=AvgB;

AvgBd(3,:)=[];                  % Remove row 3
AvgBd(:,2:1:67)=[];             % Remove columns 2-66 67=wave evaluation
Bd_a=AvgBd;

AvgC(:,3)=[];                   % Remove column 3
C_a=AvgC;

AvgD(:,[1:1:3 7:1:67])=[];      % Remove columns 1-3,7-66 67=wave evaluation
D_a=AvgD;

AvgDd(:,2:1:67)=[];             % Remove columns 2-66 67=wave evaluation
Dd_a=AvgDd;

%% Define diminsions of each matrix
NStates=size(A_a,1);            % number of states (13)
NInps=size(B_a,2);              % number of inputs (3)
NOuts=size(C_a,1);              % number of outputs (5)
NdInps=size(Bd_a,2);            % number of disturbance inputs
Ndstates=size(Dd_a,2);          % number of disturbance states

%% Adding actuator dynamics
To=0.3;                                                                       
B_dd=[1/To, 0, 0;0, 1/To, 0; 0, 0, 1/To];
A_dd=[-1/To, 0, 0;0, -1/To, 0; 0, 0, -1/To];
C_dd=eye(3,3);

%% Adding them to matrices
A_a=[A_a,B_a*C_dd;zeros(size(A_dd,1),size(A_a,2)),A_dd];
B_a=[zeros(NStates,NInps);B_dd];
C_a=[C_a,zeros(size(C_a,1),size(C_dd,2))];
Bd_a=[Bd_a;zeros(size(A_dd,1),size(Bd_a,2))];

%% Openloop eigenvalues of A
eig_openloop_A=eig(A_a);

%% New dimensions
NStates=size(A_a,1);
NInps=size(B_a,2);
NOuts=size(C_a,1);

%% Disturbances model
D_d = zeros(Ndstates);
H_d = eye(Ndstates);
A_e = [A_a, Bd_a * H_d; zeros(size(D_d,1),size(A_a,1)), D_d];
B_e = [B_a;zeros(size(D_d,1),size(B_a,2))];
C_e = [C_a,zeros(size(C_a,1),Ndstates)];
D_e = D_a;

%% Check the controllability
rnk = rank(ctrb(A_a,B_a), 0);
if rnk == size(A_a,1)
disp(' (A, B) controllable');
else
disp([' (A, B) uncontrollable, rank = ', num2str(rnk), ' < ',num2str(size(A_a,1))]);
error(' Cannot continue!')
end

%% Check observability
rnk = rank(obsv(A_e,C_e), 0);
if rnk == size(A_e,1)
disp(' (A_e, C_e) observable');
else
disp([' (A_e, C_e) unobservable, rank = ', num2str(rnk), ' < ',num2str(size(A_e,1))]);
error(' Cannot continue!')
end

%% Design poles for the feedback controller gain matrix Kx using LQR
Q=eye(NStates);        %% Q matrix

Q(1,1)   = 1e-1;       %% Platform pitch tilt rotation DOF
Q(2,2)   = 1e-2;       %% 1st tower fore-aft bending mode DOF
Q(3,3)   = 1e-1;       %% Drivetrain rotational-flexibility DOF
Q(4,4)   = 1e-2;       %% 1st flapwise bending-mode DOF of blade 1 %%
Q(5,5)   = 1e-2;       %% 1st flapwise bending-mode DOF of blade 2 %%
Q(6,6)   = 1e-2;       %% 1st flapwise bending-mode DOF of blade 3 %%
Q(7,7)   = 1e-2;       %% First time derivative of Platform pitch tilt rotation DOF
Q(8,8)   = 1e-4;       %% First time derivative of 1st tower fore-aft bending mode DOF
Q(9,9)   = 1e+2;       %% First time derivative of Variable speed generator DOF %%
Q(10,10) = 1e-2;       %% First time derivative of Drivetrain rotational-flexibility DOF
Q(11,11) = 1e-3;       %% First time derivative of 1st flapwise bending-mode DOF of blade 1
Q(12,12) = 1e-3;       %% First time derivative of 1st flapwise bending-mode DOF of blade 2
Q(13,13) = 1e-3;       %% First time derivative of 1st flapwise bending-mode DOF of blade 3
Q(14,14) = 1e+0;       %% Actuator dynamics 1
Q(15,15) = 1e+0;       %% Actuator dynamics 2
Q(16,16) = 1e+0;       %% Actuator dynamics 3

R=eye(NInps);          %% R matrix

R(1,1)  = 1e-3;        %% Blade 1 pitch command
R(2,2)  = 1e-0;        %% Blade 2 pitch command
R(3,3)  = 1e-0;        %% Blade 3 pitch command

[Kx, S, E]=lqr(A_a, B_a, Q, R);

%% Closed-loop eigenvalues of A
eig_closedloop_A = eig(A_a-B_a*Kx);

%% Kronecker Product
F=[A_a,B_a;C_a,D_a];
J=[Bd_a*H_d;zeros(size(C_a,1),size(Bd_a*H_d,2))];
KS=pinv(kron(eye(Ndstates),F)+kron(D_d,eye(size(F))))*(-J);
Kd=KS(NStates+1:end)+Kx*KS(1:NStates);

%% Observer based controller gain K
K=-[Kx,Kd];

%% Kalman estimator gain

QE=eye(NStates+Ndstates);   %% Disturbances covariances

QE(1,1)   = 1e+0;           %% Platform pitch tilt rotation DOF
QE(2,2)   = 1e-3;           %% 1st tower fore-aft bending mode DOF
QE(3,3)   = 1e-6;           %% Drivetrain rotational-flexibility DOF
QE(4,4)   = 1e+4;           %% 1st flapwise bending-mode DOF of blade 1 %%
QE(5,5)   = 1e+4;           %% 1st flapwise bending-mode DOF of blade 2 %%
QE(6,6)   = 1e+4;           %% 1st flapwise bending-mode DOF of blade 3 %%
QE(7,7)   = 1e+0;           %% First time derivative of Platform pitch tilt rotation DOF
QE(8,8)   = 1e+1;           %% First time derivative of 1st tower fore-aft bending mode DOF
QE(9,9)   = 1e+1;           %% First time derivative of Variable speed generator DOF %%
QE(10,10) = 1e+1;           %% First time derivative of Drivetrain rotational-flexibility DOF
QE(11,11) = 1e+1;           %% First time derivative of 1st flapwise bending-mode DOF of blade 1
QE(12,12) = 1e+1;           %% First time derivative of 1st flapwise bending-mode DOF of blade 2
QE(13,13) = 1e+1;           %% First time derivative of 1st flapwise bending-mode DOF of blade 3
QE(14,14) = 1e+0;           %% Actuator dynamics 1
QE(15,15) = 1e+0;           %% Actuator dynamics 2
QE(16,16) = 1e+0;           %% Actuator dynamics 3
QE(17,17) = 1e+1;           %% Wind disturbance

RE=eye(NOuts);              %% Noises covariances

RE(1,1)  = 1e+0;            %% Angular speed of the high-speed shaft and generator
RE(2,2)  = 1e+0;            %% Blade 1 flapwise moment
RE(3,3)  = 1e+0;            %% Blade 2 flapwise moment
RE(4,4)  = 1e+0;            %% Blade 3 flapwise moment
RE(5,5)  = 1e+0;            %% Nacelle inertial measurement unit translational acceleration


eig = [eig_openloop_A eig_closedloop_A];

%% prefilter
v = -pinv((C_a * inv(A_a - B_a*Kx))* B_a);

%% Simulation model
sim('DACSimulink.mdl',[0,TMax]);
