clear; clc;

maxNumMember = 99; % 80;
maxNumNode   = 9;
maxNumMode   = 99;

out = fopen('SubDyn_Output_Params.f90','w');

fprintf(out,'%s\n','module SubDyn_Output_Params');
fprintf(out,'%s\n','   use NWTC_Library');
fprintf(out,'%s\n','');
fprintf(out,'%s\n','   ! Indices for computing output channels:');
fprintf(out,'%s\n','   ! NOTES: ');
fprintf(out,'%s\n','   !    (1) These parameters are in the order stored in "OutListParameters.xlsx"');
fprintf(out,'%s\n','   !    (2) Array AllOuts() must be dimensioned to the value of the largest output parameter');
fprintf(out,'%s\n','   IMPLICIT                         NONE');
fprintf(out,'%s\n','');
fprintf(out,'%s\n','   PUBLIC');
fprintf(out,'%s\n','');
fprintf(out,'%s\n','   !  Time: ');
fprintf(out,'%s\n','   INTEGER, PARAMETER             :: Time      =     0');
fprintf(out,'%s\n','');

outIdx = 0;
allOutNames = cell(0,0);

AllChannels{1}.Category = 'Member Forces';
AllChannels{1}.channels = {'FKxe','FKye','FKze','FMxe','FMye','FMze',...
    'MKxe','MKye','MKze','MMxe','MMye','MMze'};
AllChannels{1}.units = {'(N)','(N)','(N)','(N)','(N)','(N)','(N)',...
    '(N*m)','(N*m)','(N*m)','(N*m)','(N*m)','(N*m)'};
AllChannels{1}.SubCatIdx = [1,1,1,2,2,2,1,1,1,2,2,2];
AllChannels{1}.SubCatNames = {'MNfmKe','MNfmMe'};
AllChannels{1}.MemberNumber = true;

AllChannels{2}.Category = 'Displacements';
AllChannels{2}.channels = {'TDxss','TDyss','TDzss','RDxe','RDye','RDze'};
AllChannels{2}.units = {'(m)','(m)','(m)','(rad)','(rad)','(rad)'};
AllChannels{2}.SubCatIdx = [1,1,1,2,2,2];
AllChannels{2}.SubCatNames = {'MNTDss','MNRDe'};
AllChannels{2}.MemberNumber = true;

AllChannels{3}.Category = 'Accelerations';
AllChannels{3}.channels = {'TAxe','TAye','TAze','RAxe','RAye','RAze'};
AllChannels{3}.units = {'(m/s^2)','(m/s^2)','(m/s^2)','(rad/s^2)','(rad/s^2)','(rad/s^2)'};
AllChannels{3}.SubCatIdx = [1,1,1,1,1,1];
AllChannels{3}.SubCatNames = {'MNTRAe'};
AllChannels{3}.MemberNumber = true;

AllChannels{4}.Category = 'Reactions';
Prefix = transpose(repmat({'React';'Intf'},1,6));
AllChannels{4}.channels = strcat( reshape(Prefix,1,[]),repmat({'FXss','FYss','FZss','MXss','MYss','MZss'},1,2));
AllChannels{4}.units = repmat({'(N)','(N)','(N)','(N*m)','(N*m)','(N*m)'},1,2);
AllChannels{4}.MemberNumber = false;

AllChannels{5}.Category = 'Interface Deflections';
AllChannels{5}.channels = strcat('Intf',{'TDXss','TDYss','TDZss','RDXss','RDYss','RDZss'});
AllChannels{5}.units = {'(m)','(m)','(m)','(rad)','(rad)','(rad)'};
AllChannels{5}.MemberNumber = false;

AllChannels{6}.Category = 'Interface Accelerations';
AllChannels{6}.channels = strcat('Intf',{'TAXss','TAYss','TAZss','RAXss','RAYss','RAZss'});
AllChannels{6}.units = {'(m/s^2)','(m/s^2)','(m/s^2)','(rad/s^2)','(rad/s^2)','(rad/s^2)'};
AllChannels{6}.MemberNumber = false;

AllChannels{7}.Category = 'Modal Parameters';
ModeNums = num2str((1:maxNumMode)','%02.0f');
Prefix = transpose(repmat({'SSqm';'SSqmd';'SSqmdd'},1,maxNumMode));
AllChannels{7}.channels = strcat(reshape(Prefix,[],1), repmat(ModeNums,3,1));
AllChannels{7}.units = reshape( transpose(repmat({'(-)';'(1/s)';'(1/s^2)'},1,maxNumMode)), [], 1);
AllChannels{7}.MemberNumber = false;


for iCategory = 1:length(AllChannels)
    fprintf(out,'%s\n','');
    fprintf(out,'%s%s%s\n', '   ! ', AllChannels{iCategory}.Category, ':');
    fprintf(out,'%s\n','');

    for channelNo = 1:length( AllChannels{iCategory}.channels )
        channel = AllChannels{iCategory}.channels{channelNo};

        if AllChannels{iCategory}.MemberNumber
            for member = 1:maxNumMember
                for node = 1:maxNumNode
                    outIdx = outIdx + 1;
                    outName = pad(['M' pad(num2str(member),2,'left','0') 'N' num2str(node) channel],10);
                    allOutNames = [allOutNames {outName}];
                    line = ['   INTEGER(IntKi), PARAMETER      :: ' outName '= ' pad(num2str(outIdx),5,'left')];
                    fprintf(out,'%s\n',line);
                end %node
            end %member
        else
            outIdx = outIdx + 1;
            outName = pad(channel,10);
            allOutNames = [allOutNames {outName}];
            line = ['   INTEGER(IntKi), PARAMETER      :: ' outName '= ' pad(num2str(outIdx),5,'left')];
            fprintf(out,'%s\n',line);         
        end

    end %channelNo
end %iCategory

MaxOutPts = outIdx;

fprintf(out,'%s\n',''); fprintf(out,'%s\n','');
fprintf(out,'%s\n','   ! The maximum number of output channels which can be output by the code.');
fprintf(out,'%s\n',['   ! INTEGER(IntKi), PARAMETER    :: MaxOutPts = ' num2str(outIdx)]);
fprintf(out,'%s\n','');
fprintf(out,'%s\n','   ! End of code generated by Matlab script');
fprintf(out,'%s\n','');


for iCategory = 1:length(AllChannels)
    if AllChannels{iCategory}.MemberNumber
    
        for iSubCat = 1:length( AllChannels{iCategory}.SubCatNames )
            channelsIdx = AllChannels{iCategory}.SubCatIdx == iSubCat;
            channels = reshape( AllChannels{iCategory}.channels(channelsIdx), 1, [] );


    
            fprintf(out,'%s',['   INTEGER, PARAMETER             :: ' AllChannels{iSubCat}.SubCatNames '(', num2str(length(channels)), ',' num2str(maxNumNode) ',' num2str(maxNumMember) ') = reshape((/']);
            indent = '';
            for member = 1:maxNumMember
                for node = 1:maxNumNode
                    for channelNo = 1:length(channels)
                        channel = channels{channelNo};
                        line = [indent 'M' pad(num2str(member),2,'left','0') 'N' num2str(node) channel ','];
                    end
                    
                    if member == maxNumMember && node == maxNumNode
                        line = [line(1:end-1) '/),(/' num2str(length(channels)) ',' num2str(maxNumNode) ',' num2str(maxNumMember) '/))'];
                    else
                        line = [line ' & '];
                    end
                    fprintf(out,'%s\n',line);
            
                    indent = '                                                                ';
                end
            end

            fprintf(out,'%s\n','   '); fprintf(out,'%s\n','  '); fprintf(out,'%s\n','   ');
        end %iSubCat

    end %if memberNumber
end %iCategory
        

fprintf(out,'%s\n','');
fprintf(out,'%s\n','      INTEGER, PARAMETER             :: ReactSS(6)   =  (/ReactFXss, ReactFYss, ReactFZss, &');
fprintf(out,'%s\n','                                                          ReactMXss, ReactMYss, ReactMZss/)');
fprintf(out,'%s\n','      INTEGER, PARAMETER             :: IntfSS(6)    =  (/IntfFXss,  IntfFYss,  IntfFZss , &');
fprintf(out,'%s\n','                                                          IntfMXss,  IntfMYss,  IntfMZss/)');
fprintf(out,'%s\n','      INTEGER, PARAMETER             :: IntfTRss(6)  =  (/IntfTDXss, IntfTDYss, IntfTDZss, &');
fprintf(out,'%s\n','                                                          IntfRDXss, IntfRDYss, IntfRDZss/)');
fprintf(out,'%s\n','      INTEGER, PARAMETER             :: IntfTRAss(6) =  (/IntfTAXss, IntfTAYss, IntfTAZss, &');
fprintf(out,'%s\n','                                                          IntfRAXss, IntfRAYss, IntfRAZss/)');
fprintf(out,'%s\n',' ');

allOutNamesSorted = sort(allOutNames);

entryPerLine = 7;

halfOutIdx = ceil(outIdx/2);
fprintf(out,'%s\n',['   CHARACTER(10), PARAMETER  :: ValidParamAry1(' num2str(halfOutIdx) ') =  (/ &                  ! This lists the names of the allowed parameters, which must be sorted alphabetically']);
ctr = 0;
while ctr<halfOutIdx
    is = ctr+1;
    if (ctr+entryPerLine) >= halfOutIdx
        ie = halfOutIdx;
        bLastLine = true;
    else
        ie = ctr+entryPerLine;
        bLastLine = false;
    end
    line = '                               ';
    for j = is:ie
        line = [line '"' pad(strtrim(upper(allOutNamesSorted{j})),10) '",'];
    end
    if bLastLine
        line = [line(1:end-1) '/)'];
    else
        line = [line ' &'];
    end
    fprintf(out,'%s\n',line);
    ctr = ctr+entryPerLine;
end

fprintf(out,'%s\n',['   CHARACTER(10), PARAMETER  :: ValidParamAry2(' num2str(outIdx-halfOutIdx) ') =  (/ &                  ! This lists the names of the allowed parameters, which must be sorted alphabetically']);
ctr = halfOutIdx;
while ctr<outIdx
    is = ctr+1;
    if (ctr+entryPerLine) >= outIdx
        ie = outIdx;
        bLastLine = true;
    else
        ie = ctr+entryPerLine;
        bLastLine = false;
    end
    line = '                               ';
    for j = is:ie
        line = [line '"' pad(strtrim(upper(allOutNamesSorted{j})),10) '",'];
    end
    if bLastLine
        line = [line(1:end-1) '/)'];
    else
        line = [line ' &'];
    end
    fprintf(out,'%s\n',line);
    ctr = ctr+entryPerLine;
end
fprintf(out,'%s\n',['   CHARACTER(10), PARAMETER  :: ValidParamAry(' num2str(outIdx) ') =  [ValidParamAry1,ValidParamAry2]']);

fprintf(out,'%s\n','');
fprintf(out,'%s\n',['   INTEGER(IntKi), PARAMETER :: ParamIndxAry1(' num2str(halfOutIdx) ') =  (/ &                            ! This lists the index into AllOuts(:) of the allowed parameters ValidParamAry(:)']);
ctr = 0;
while ctr<halfOutIdx
    is = ctr+1;
    if (ctr+entryPerLine) >= halfOutIdx
        ie = halfOutIdx;
        bLastLine = true;
    else
        ie = ctr+entryPerLine;
        bLastLine = false;
    end
    line = '                               ';
    for j = is:ie
        line = [line pad(strtrim(allOutNamesSorted{j}),10,'left') ','];
    end
    if bLastLine
        line = [line(1:end-1) '/)'];
    else
        line = [line ' &'];
    end
    fprintf(out,'%s\n',line);
    ctr = ctr+entryPerLine;
end
fprintf(out,'%s\n',['   INTEGER(IntKi), PARAMETER :: ParamIndxAry2(' num2str(outIdx-halfOutIdx) ') =  (/ &                            ! This lists the index into AllOuts(:) of the allowed parameters ValidParamAry(:)']);
ctr = halfOutIdx;
while ctr<outIdx
    is = ctr+1;
    if (ctr+entryPerLine) >= outIdx
        ie = outIdx;
        bLastLine = true;
    else
        ie = ctr+entryPerLine;
        bLastLine = false;
    end
    line = '                               ';
    for j = is:ie
        line = [line pad(strtrim(allOutNamesSorted{j}),10,'left') ','];
    end
    if bLastLine
        line = [line(1:end-1) '/)'];
    else
        line = [line ' &'];
    end
    fprintf(out,'%s\n',line);
    ctr = ctr+entryPerLine;
end
fprintf(out,'%s\n',['   INTEGER(IntKi), PARAMETER :: ParamIndxAry(' num2str(outIdx) ') =  [ParamIndxAry1,ParamIndxAry2]']);

fprintf(out,'%s\n','');
fprintf(out,'%s\n',['   CHARACTER(ChanLen), PARAMETER :: ParamUnitsAry1(' num2str(halfOutIdx) ') =  (/ &                     ! This lists the units corresponding to the allowed parameters']);
ctr = 0;
while ctr<halfOutIdx
    is = ctr+1;
    if (ctr+entryPerLine) >= halfOutIdx
        ie = halfOutIdx;
        bLastLine = true;
    else
        ie = ctr+entryPerLine;
        bLastLine = false;
    end
    line = '                               ';
    for j = is:ie
        
        unit = '';
        if contains(allOutNamesSorted{j},{'FK','FM','IntfF','ReactF'})
            unit = '(N)';
        elseif contains(allOutNamesSorted{j},{'MK','MM','IntfM','ReactM'})
            unit = '(N*m)';
        elseif contains(allOutNamesSorted{j},'TA')
            unit = '(m/s^2)';
        elseif contains(allOutNamesSorted{j},'RA')
            unit = '(rad/s^2)';
        elseif contains(allOutNamesSorted{j},'TD')
            unit = '(m)';
        elseif contains(allOutNamesSorted{j},'RD')
            unit = '(rad)';
        elseif contains(allOutNamesSorted{j},'SSqmdd')
            unit = '(1/s^2)';
        elseif contains(allOutNamesSorted{j},'SSqmd')
            unit = '(1/s)';
        elseif contains(allOutNamesSorted{j},'SSqm')
            unit = '(--)';
        end

        unit = pad(unit,10);
        line = [line '"' unit '",'];
    end
    if bLastLine
        line = [line(1:end-1) '/)'];
    else
        line = [line ' &'];
    end
    fprintf(out,'%s\n',line);
    ctr = ctr+entryPerLine;
end

fprintf(out,'%s\n',['   CHARACTER(ChanLen), PARAMETER :: ParamUnitsAry2(' num2str(outIdx-halfOutIdx) ') =  (/ &                     ! This lists the units corresponding to the allowed parameters']);
ctr = halfOutIdx;
while ctr<outIdx
    is = ctr+1;
    if (ctr+entryPerLine) >= outIdx
        ie = outIdx;
        bLastLine = true;
    else
        ie = ctr+entryPerLine;
        bLastLine = false;
    end
    line = '                               ';
    for j = is:ie
        
        unit = '';
        if contains(allOutNamesSorted{j},{'FK','FM','IntfF','ReactF'})
            unit = '(N)';
        elseif contains(allOutNamesSorted{j},{'MK','MM','IntfM','ReactM'})
            unit = '(N*m)';
        elseif contains(allOutNamesSorted{j},'TA')
            unit = '(m/s^2)';
        elseif contains(allOutNamesSorted{j},'RA')
            unit = '(rad/s^2)';
        elseif contains(allOutNamesSorted{j},'TD')
            unit = '(m)';
        elseif contains(allOutNamesSorted{j},'RD')
            unit = '(rad)';
        elseif contains(allOutNamesSorted{j},'SSqmdd')
            unit = '(1/s^2)';
        elseif contains(allOutNamesSorted{j},'SSqmd')
            unit = '(1/s)';
        elseif contains(allOutNamesSorted{j},'SSqm')
            unit = '(--)';
        end

        unit = pad(unit,10);
        line = [line '"' unit '",'];
    end
    if bLastLine
        line = [line(1:end-1) '/)'];
    else
        line = [line ' &'];
    end
    fprintf(out,'%s\n',line);
    ctr = ctr+entryPerLine;
end
fprintf(out,'%s\n',['   CHARACTER(ChanLen), PARAMETER :: ParamUnitsAry(' num2str(outIdx) ') = [ParamUnitsAry1,ParamUnitsAry2]']);

fprintf(out,'%s\n','');
fprintf(out,'%s\n','');
fprintf(out,'%s\n','! End of code generated by Matlab script');
fprintf(out,'%s\n','end module SubDyn_Output_Params');

fclose(out);