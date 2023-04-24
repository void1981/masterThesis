function [MBC, matData, FAST_linData, VTK] = fx_mbc3( FileNames, ModeVizFileName ) 
% MBC: Multi-Blade Coordinate Transformation for a turbine with 3-blade rotor
%
% Developed by Gunjit Bir, NREL (303-384-6953, gunjit_bir@nrel.gov)
%
% Last update: 08/30/2006
%    29-Jan-2018  - B. Jonkman, Envision Energy & J. Jonkman, NREL
%    7-Feb-2019   - B. Jonkman, Envision Energy & J. Jonkman, Nick Johnson, NREL (first-order states) 
%----------------------------------------------------------------------------------------
%
% Objectives:
% 1. Given state-space matrices (A,B) and output matrices (C,D), defined partly in the
%    rotating frame and partly in the fixed frame, transform these matrices to the fixed
%    coordinate frame using multi-blade coordinate transformation (MBC). The transformned
%    matrices are MBC.A, MBC.B, MBC.C, and MBC.D.
%
% 2. Azimuth-average the MBC.A matrix and compute its eigenvalues and eigenvectors.  The
%    eigenvectors, referred to the fixed coordinates, are presented in both complex and
%    amplitude-phase forms. The eigenvalues, also referred to the fixed coordinates, are
%    presented in complex and damping-ratio/damped-frequency forms.
%
% ***Disclaimer: This code is still in the developmental stage and no guarantee is given
%    as to its proper functioning or accuracy of its results.
%
% ------------ INPUTS   
% FileNames           : names of the linearization matrices from FAST
% --------------------- OUTPUTS ----------------------------------------------------
% MBC.A,MBC.B         : state-space matrices transformed to the fixed frame
% MBC.C,MBC.D         : output matrices transformed to the fixed frame
% -----------------------------------------------------------------------------------------
%**NOTE 1: All inputs and output matrices may not be present.  For example, user may supply or may be interested
%          in multi-blade coordinate transformation of A matrix only.  In this case, only MBC.A matrix along with
%          fixed-frame eigensolution will be genertaed as outputs.  The code checks for consistency and completness
%          of selected inputs and generates associated outputs.
%
% Equation numbers are from this document: https://nwtc.nrel.gov/system/files/MBC3.pdf
% -----------------------------------------------------------------------------------------

% fprintf( '\n  Running %s\n\n', 'mbc3 (v2.0, 29-Jan-2018)' );

[matData, FAST_linData] = fx_getMats(FileNames);

MBC.DescStates = matData.DescStates; % save this in the MBC type for possible campbell_diagram processing later 
MBC.ndof2 = matData.ndof2;
MBC.ndof1 = matData.ndof1;
MBC.RotSpeed_rpm = mean(matData.Omega)*(30/pi); %rad/s to rpm
if isfield(matData,'WindSpeed')
    MBC.WindSpeed = mean(matData.WindSpeed);
end

%%  nb = 3; % number of blades required for MBC3
%% ---------- Multi-Blade-Coordinate transformation -------------------------------------------
[new_seq_dof2, ~, nb]  = get_new_seq(matData.RotTripletIndicesStates2,matData.ndof2); % these are the first ndof2 states (not "first time derivative" states); these values are used to calculate matrix transformations
[new_seq_dof1, ~, nb2] = get_new_seq(matData.RotTripletIndicesStates1,matData.ndof1); % these are the first-order ndof1 states; these values are used to calculate matrix transformations
new_seq_states = [new_seq_dof2;  new_seq_dof2+matData.ndof2;  new_seq_dof1+matData.NumStates2]; % combine the second-order states, including "first time derivatives", with first-order states (assumes ordering of displacements and velocities in state matrices); these values are used to calculate matrix transformations 
     % second-order NonRotating q2, second-order Rotating q2, 
     % second-order NonRotating q2_dot, second-order Rotating q2_dot, 
     % first-order NonRotating q1, first-order Rotating q1
nb = max(nb,nb2);     
if (nb==0)    
    disp(['*** fx_mbc3: no states were found. Setting number of blades to 0. Skipping MBC3 ***'] )
    nb = 0;
end

if nb == 3
    MBC.performedTransformation = true;
    
    if matData.n_RotTripletStates2 + matData.n_RotTripletStates1 < 1
        error('*** There are no rotating states. MBC transformation, therefore, cannot be performed.');
        % perhaps just warn and perform eigenanalysis anyway?
    end
    if(matData.n_RotTripletStates2*nb > matData.ndof2)
        error('**ERROR: the rotating second-order dof exceeds the total num of second-order dof');
    elseif(matData.n_RotTripletStates1*nb > matData.ndof1)
        error('**ERROR: the rotating first-order dof exceeds the total num of first-order dof');
    end

    [new_seq_inp] = get_new_seq(matData.RotTripletIndicesCntrlInpt,matData.NumInputs);
    [new_seq_out] = get_new_seq(matData.RotTripletIndicesOutput,matData.NumOutputs);


    n_FixFrameStates2 = matData.ndof2      - matData.n_RotTripletStates2*nb;  % fixed-frame second-order dof
    n_FixFrameStates1 = matData.ndof1      - matData.n_RotTripletStates1*nb;  % fixed-frame first-order dof
    n_FixFrameInputs  = matData.NumInputs  - matData.n_RotTripletInputs*nb;   % fixed-frame control inputs
    n_FixFrameOutputs = matData.NumOutputs - matData.n_RotTripletOutputs*nb;  % fixed-frame outputs

    if ( size(matData.Omega) ~= matData.NAzimStep)
       error('**ERROR: the size of Omega vector must equal matData.NAzimStep, the num of azimuth steps');
    end
    if ( size(matData.OmegaDot) ~= matData.NAzimStep)
       error('**ERROR: the size of OmegaDot vector must equal matData.NAzimStep, the num of azimuth steps');
    end

    % begin azimuth loop 
    for iaz = matData.NAzimStep:-1:1  
        %(loop backwards so we don't reallocate memory each time [i.e. variables with iaz index aren't getting larger each time])

        % compute azimuth positions of blades:
        az = matData.Azimuth(iaz)*pi/180.0 + 2*pi/nb* (0:(nb-1)) ; % Eq. 1, azimuth in radians

        % get rotor speed squared
        OmegaSquared = matData.Omega(iaz)^2;

        % compute transformation matrices
        cos_col = cos(az(:));
        sin_col = sin(az(:));

        tt  = [ones(3,1), cos_col, sin_col];        % Eq. 9, t_tilde
        ttv = get_tt_inverse(sin_col, cos_col);     % inverse of tt (computed analytically in function below)
        tt2 = [zeros(3,1), -sin_col,  cos_col];     % Eq. 16 a, t_tilde_2
        tt3 = [zeros(3,1), -cos_col, -sin_col];     % Eq. 16 b, t_tilde_3

        %---
        T1 = eye(n_FixFrameStates2);                % Eq. 11 for second-order states only
        for ii = 1:matData.n_RotTripletStates2
            T1 = blkdiag(T1, tt);
        end

        T1v = eye(n_FixFrameStates2);               % inverse of T1
        for ii = 1:matData.n_RotTripletStates2
            T1v = blkdiag(T1v, ttv);
        end

        T2 = zeros(n_FixFrameStates2);              % Eq. 14  for second-order states only
        for ii = 1:matData.n_RotTripletStates2
            T2 = blkdiag(T2, tt2);
        end

        %---    
        T1q = eye(n_FixFrameStates1);               % Eq. 11 for first-order states (eq. 8 in MBC3 Update document)
        for ii = 1:matData.n_RotTripletStates1
            T1q = blkdiag(T1q, tt);
        end

        T1qv = eye(n_FixFrameStates1);              % inverse of T1q
        for ii = 1:matData.n_RotTripletStates1
            T1qv = blkdiag(T1qv, ttv);
        end

        T2q = zeros(n_FixFrameStates1);             % Eq. 14 for first-order states (eq.  9 in MBC3 Update document)
        for ii = 1:matData.n_RotTripletStates1
            T2q = blkdiag(T2q, tt2);
        end

    %     T1qc = eye(matData.NumHDInputs);            % inverse of T1q   


        %---
        T3 = zeros(n_FixFrameStates2);              % Eq. 15
        for ii = 1:matData.n_RotTripletStates2
            T3 = blkdiag(T3, tt3);
        end

        %---
        T1c = eye(n_FixFrameInputs);                % Eq. 21
        for ii = 1:matData.n_RotTripletInputs
            T1c = blkdiag(T1c, tt);
        end

        T1ov = eye(n_FixFrameOutputs);              % inverse of Tlo (Eq. 23)
        for ii = 1:matData.n_RotTripletOutputs
            T1ov = blkdiag(T1ov, ttv);
        end

    % mbc transformation of first-order matrices
    %  if ( MBC.EqnsOrder == 1 ) % activate later

        if isfield(matData,'A')
                % Eq. 29
            MBC.A(new_seq_states,new_seq_states,iaz) = ...
                      blkdiag(T1v, T1v, T1qv) * ...
                   (  matData.A(new_seq_states,new_seq_states,iaz) * ...
                      [T1,                                         zeros(matData.ndof2),                   zeros(matData.ndof2, matData.ndof1); ...
                      matData.Omega(iaz)*T2,                       T1,                                     zeros(matData.ndof2, matData.ndof1); ...
                      zeros(matData.ndof1, matData.ndof2),         zeros(matData.ndof1, matData.ndof2),    T1q] ...
                      ...
                    - [matData.Omega(iaz)*T2,                      zeros(matData.ndof2),                   zeros(matData.ndof2, matData.ndof1); ...
                      OmegaSquared*T3 + matData.OmegaDot(iaz)*T2,  2*matData.Omega(iaz)*T2,                zeros(matData.ndof2, matData.ndof1); ...
                      zeros(matData.ndof1, matData.ndof2),         zeros(matData.ndof1, matData.ndof2),    matData.Omega(iaz)*T2q] ...
                   );

        end


        if isfield(matData,'B')
                % Eq. 30
            MBC.B(new_seq_states,new_seq_inp,iaz) = blkdiag(T1v, T1v, T1qv) * matData.B(new_seq_states,new_seq_inp,iaz) * T1c;
        end

        if isfield(matData,'C')
                % Eq. 31
            MBC.C(new_seq_out, new_seq_states, iaz) = ...
                         T1ov * matData.C(new_seq_out,new_seq_states,iaz) * ...
                         [T1,                                  zeros(matData.ndof2),                 zeros(matData.ndof2, matData.ndof1); ...
                         matData.Omega(iaz)*T2,                T1,                                   zeros(matData.ndof2, matData.ndof1); ...
                         zeros(matData.ndof1, matData.ndof2),  zeros(matData.ndof1,  matData.ndof2), T1q];                 
        end

        if isfield(matData,'D')
               % Eq. 32
            MBC.D(new_seq_out,new_seq_inp,iaz) = T1ov * matData.D(new_seq_out,new_seq_inp,iaz) * T1c;
        end


    end   % end of azimuth loop

else
    disp([' fx_mbc3 WARNING: Number of blades is ' num2str(nb) ', not 3. MBC transformation was not performed.'] )
    MBC.performedTransformation = false;
    
    % initialize matrices     
    if isfield(matData,'A')
        MBC.A = matData.A; % initalize matrix
    end
    if isfield(matData,'B')
        MBC.B = matData.B; % initalize matrix
    end
    if isfield(matData,'C')
        MBC.C = matData.C; % initalize matrix
    end
    if isfield(matData,'D')
        MBC.D = matData.D; % initalize matrix
    end
     
end    

%% ------------- Eigensolution and Azimuth Averages -------------------------
if isfield(MBC,'A')
    MBC.AvgA = mean(MBC.A,3); % azimuth-average of azimuth-dependent MBC.A matrices
    [MBC.eigSol, EigenVects_save] = eiganalysis(MBC.AvgA,matData.ndof2, matData.ndof1);
    
    %% save eigenvectors (doing inverse of MBC3) for VTK visualization in FAST
    if nargout > 3 || nargin > 1
        [VTK] = formatModesForViz(MBC, matData, nb, EigenVects_save);
        if nargin > 1
            writeModesForViz(VTK, ModeVizFileName)
        end        
    end
    
end

if isfield(MBC,'B')
    MBC.AvgB = mean(MBC.B,3); % azimuth-average of azimuth-dependent MBC.B matrices
end

if isfield(MBC,'C')
    MBC.AvgC = mean(MBC.C,3); % azimuth-average of azimuth-dependent MBC.C matrices
end

if isfield(MBC,'D')
    MBC.AvgD = mean(MBC.D,3); % azimuth-average of azimuth-dependent MBC.D matrices
end

%   disp('  ');
%   disp(' Multi-Blade Coordinate transformation completed ');
%-----------------------------------------------------------
return;
end

%% ------------------------------------------------------------------------
% compute the inverse of tt = [ones(3,1), cos_col, sin_col]
function [ttv] = get_tt_inverse(sin_col, cos_col)

    c1 = cos_col(1);
    c2 = cos_col(2);
    c3 = cos_col(3);
    
    s1 = sin_col(1);
    s2 = sin_col(2);
    s3 = sin_col(3);

    
    ttv = [ c2*s3 - s2*c3,  c3*s1 - s3*c1, c1*s2 - s1*c2
               s2 - s3 ,       s3 - s1,       s1 - s2
               c3 - c2 ,       c1 - c3,       c2 - c1 ] / (1.5*sqrt(3));

    return
end

%% ------------------------------------------------------------------------
% create a sequence where the non-rotating values are first, and are then 
% followed by the rotating series with b1, b2, b3 triplets:
function [new_seq, nRotTriplets, nb] = get_new_seq(rot_triplet,ntot)
%  rot_triplet is size n x 3

    [nRotTriplets,nb] = size(rot_triplet);
    
    if(nb ~= 3 && nRotTriplets ~= 0 && ntot~= 0)
        disp('**ERROR: the number of column vectors in the rotating triplet must equal 3, the num of blades');
        new_seq = (1:ntot)';
    else
        non_rotating = true(ntot,1);
        non_rotating(rot_triplet(:)) = false; % if they are rotating, set them false;

        new_seq = [find(non_rotating); reshape( rot_triplet', numel(rot_triplet), 1)];
    end
    return
    
end

%% ------------------------------------------------------------------------
function [VTK] = formatModesForViz(MBC, matData, nb, EigenVects_save)

    %% Get data required for VTK visualization:
    % % % MBC.eigSol.EigenVects_save(:,SortedFreqIndx)       
    nAzimuth          = length(matData.Azimuth)
    [nStates, nModes] = size(EigenVects_save)

    [~, SortedFreqIndx] = sort(MBC.eigSol.NaturalFreqs_Hz);    
    
    %put these in order of natural frequency:
    VTK.NaturalFreq_Hz = MBC.eigSol.NaturalFreqs_Hz(  SortedFreqIndx);
    VTK.DampedFreq_Hz  = MBC.eigSol.DampedFreqs_Hz(   SortedFreqIndx);
    VTK.DampingRatio   = MBC.eigSol.DampRatios(       SortedFreqIndx);
        x_eig          =            EigenVects_save(:,SortedFreqIndx); % nStates x nModes
    % Adopt a convention such that the real part of the first state is positive (arbitrary)
    S = sign(real(x_eig(1,:)));
    x_eig = S .* x_eig;
    VTK.x_eig          = repmat( x_eig, 1, 1, nAzimuth);

    if (MBC.performedTransformation)
        % inverse MBC3 (Eq. 4, to move from collective, sine, cosine back to blade 1, blade 2, blade 3):
        dof1_offset = MBC.ndof2*2;

        for iaz=1:nAzimuth
            % MBC3 transformation matrices
            az = matData.Azimuth(iaz)*pi/180.0 + 2*pi/nb* (0:(nb-1)) ; % Eq. 1, azimuth in radians
            tt = [ones(3,1), cos(az(:)), sin(az(:))];                % Eq. 9, t_tilde
            % MBC on second order states
            I3_2nd = matData.RotTripletIndicesStates2
            for i2 = 1:size(I3_2nd,1)
                i3x    = I3_2nd(i2,:);
                i3xdot = I3_2nd(i2,:)+MBC.ndof2;
                VTK.x_eig(i3x   , :, iaz) = tt * x_eig(i3x   ,:);
                VTK.x_eig(i3xdot, :, iaz) = tt * x_eig(i3xdot,:);
            end
            % MBC on first order states
            I3_1st = matData.RotTripletIndicesStates1
            for i1 = 1:length(I3_1st)
                i3x = I3_1st(i1,:)+dof1_offset
                %q1:
                VTK.x_eig(i3x,:,iaz) = tt * x_eig(i3x, :);
            end

        end
    end
    % put this in order states are stored in FAST
    I = matData.StateOrderingIndx;
    VTK.x_desc = MBC.DescStates(I);          % nStates
    VTK.x_eig = VTK.x_eig(I,:,:);            % nStates x nModes x nAzimuth
    VTK.x_eig_magnitude = abs(  VTK.x_eig);  % nStates x nModes x nAzimuth
    VTK.x_eig_phase     = angle(VTK.x_eig);  % nStates x nModes x nAzimuth
    

return;
end

%% ------------------------------------------------------------------------
function writeModesForViz(VTK, ModeVizFileName, nModesOut, nDigits)
    % write binary file that will be read by OpenFAST to export modes to VTK

    % Default arguments
    if ~exist('nModesOut','var'); nModesOut = -1; end
    if ~exist('nDigits',  'var'); nDigits   = -1; end


    fileFmt = 'float64'; %8-byte real numbers

    [nStates, nModes, nLinTimes] = size(VTK.x_eig_magnitude);
%     if nModesOut==-1
%         nModesOut=nModes;
%     end
    nModesOut = nModes

    %------- HACK
    %VTK.NaturalFreq_Hz =  VTK.NaturalFreq_Hz *0 +1;
    %VTK.DampingRatio   =  VTK.DampingRatio   *0 +2;
    %VTK.DampedFreq_Hz  =  VTK.DampedFreq_Hz  *0 +3;
    %for iMode = 1:nModes
    %    VTK.x_eig_magnitude(:,iMode,:) = iMode;
    %    VTK.x_eig_phase(    :,iMode,:) = iMode;
    %    VTK.x_eig_magnitude(3,iMode,:) = 12;
    %    VTK.x_eig_phase(    5,iMode,:) = 11;
    %end
    %nModes=1
    % --- Reduce differences python/Matlab by rounding
%     if nDigits>0
%         res = 10^nDigits;
%         VTK.NaturalFreq_Hz =  round(VTK.NaturalFreq_Hz * res)/res;
%         VTK.DampingRatio   =  round(VTK.DampingRatio   * res)/res;
%         VTK.DampedFreq_Hz  =  round(VTK.DampedFreq_Hz  * res)/res;
%         VTK.x_eig_magnitude = round(VTK.x_eig_magnitude* res)/res;
%         VTK.x_eig_phase     = round(VTK.x_eig_phase    * res)/res;
%     end

    % --- Write to disk
    fid = fopen(ModeVizFileName,'w');
    if fid < 1
        error(['Invalid file: ' ModeVizFileName])
    end
    fwrite(fid, 1,        'int32' ); % write a file identifier in case we ever change this format
    fwrite(fid, nModesOut,'int32' ); % number of modes (for easier file reading)
    fwrite(fid, nStates,  'int32' ); % number of states (for easier file reading)
    fwrite(fid, nLinTimes,'int32' ); % number of azimuths (i.e., LinTimes) (for easier file reading)
    % Freq and damping (not used in the FAST visualization algorithm)
    fwrite(fid, VTK.NaturalFreq_Hz, fileFmt);
    fwrite(fid, VTK.DampingRatio,   fileFmt);
    fwrite(fid, VTK.DampedFreq_Hz,  fileFmt);
    % Writing data mode by mode
    for iMode = 1:nModesOut
        fwrite(fid, VTK.x_eig_magnitude(:,iMode,:), fileFmt);
        fwrite(fid, VTK.x_eig_phase(    :,iMode,:), fileFmt);
    end
    fclose(fid);

    fprintf('Written:    %s\n',ModeVizFileName);
   
return;
end
