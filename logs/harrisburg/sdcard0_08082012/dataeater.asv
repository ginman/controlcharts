%**************************************************************************
% DATAEATER
%   This script will crawl through the subdirectories created by the OPTO22
%   PLC and assemble the data for each switch in a matrix
%**************************************************************************

clc;
clear;
figure(1);
clf;
figure(2);
clf;

rootlist = dir('*');
folderindex = 3; % start on the third folder 
numdayslogged = 0;

% find out how many days were logged
for i = 3 : numel(rootlist)
    if (rootlist(i).isdir)
        folderlist(numdayslogged+1) = rootlist(i);
        numdayslogged = numdayslogged + 1;
    end
end

% go into the first subfolder and create a list of switches
currentdir = folderlist(folderindex).name;
cd(currentdir);
swliststruct = dir('*');
swlist = cell(1,numel(swliststruct)-2);
%swlist(:) = {'test'};
cd ..;
for i = 1 : numel(swliststruct)-2
    swlist(i) = {swliststruct(i+2).name};
end

switchindex = 1;
numnormrecords = zeros(numel(swlist),1);
numrevrecords = zeros(numel(swlist),1);
numnormcritrecords = zeros(numel(swlist),1);
numrevcritrecords = zeros(numel(swlist),1);

for switchnum = 1 : numel(swlist)
    % count the number of switch movements for each direction
    for folderindex = 1 : numdayslogged
        currentdir = folderlist(folderindex).name;
        cd(currentdir);
        cd(char(swlist(switchindex)));
        %folderlist = dir('*');
        numnormrecords(switchnum) = numnormrecords(switchnum) + numel(dir('*N.TXT'));
        numrevrecords(switchnum) = numrevrecords(switchnum) + numel(dir('*R.TXT'));
        numnormcritrecords(switchnum) = numnormcritrecords(switchnum) + numel(dir('N*C_LOG.TXT'));
        numrevcritrecords(switchnum) = numrevcritrecords(switchnum) + numel(dir('R*C_LOG.TXT'));
        cd ..;
        cd ..;
    end

end

%make sure to fix this for more than one switch
swnormdata = zeros(numnormrecords(switchnum),200);
swrevdata = zeros(numrevrecords(switchnum),200);
swnormcrit = zeros(numnormcritrecords(switchnum),5);
swrevcrit = zeros(numrevcritrecords(switchnum),5);

normimportcounter = 1;
normcritimportcounter = 1;
revcritimportcounter = 1;
revimportcounter = 1;

for switchnum = 1 : numel(swlist)
    % create the imported waveform data matrix for each switch
    for folderindex = 1 : numdayslogged
        currentdir = folderlist(folderindex).name;
        cd(currentdir);
        cd(char(swlist(switchindex)));
%        folderlist = dir('*');
        loglist = dir('*N.txt');
        critloglist = dir('N*C_LOG.TXT');
        if (numel(critloglist) ~= 0)
            tempcritdata = importdata(critloglist.name);
            swnormcrit([normcritimportcounter:(normcritimportcounter+size(tempcritdata,1)-1)],:) = tempcritdata;
            normcritimportcounter = normcritimportcounter + size(tempcritdata,1);
        end
        
        for fileindex = 1 : numel(loglist)
            % import the file
            tempdata = importdata(loglist(fileindex).name);
            % put the data in the matrix
            if mean(tempdata.data) > 0
                swnormdata(normimportcounter,:) = tempdata.data;
                normimportcounter = normimportcounter + 1;
            end
        end
        cd ..;
        cd ..;
    
    end
    
end

for switchnum = 1 : numel(swlist)
    % create the imported waveform data matrix for each switch
    for folderindex = 1 : numdayslogged
        currentdir = folderlist(folderindex).name;
        cd(currentdir);
        cd(char(swlist(switchindex)));
%        folderlist = dir('*');
        loglist = dir('*R.txt');
        
        critloglist = dir('R*C_LOG.TXT');
        if (numel(critloglist) ~= 0)
            tempcritdata = importdata(critloglist.name);
            swrevcrit([revcritimportcounter:(revcritimportcounter+size(tempcritdata,1)-1)],:) = tempcritdata;
            revcritimportcounter = revcritimportcounter + size(tempcritdata,1);
        end
        
        for fileindex = 1 : numel(loglist)
            % import the file
            tempdata = importdata(loglist(fileindex).name);
            % put the data in the matrix
            if mean(tempdata.data) > 0
                swrevdata(revimportcounter,:) = tempdata.data;
                revimportcounter = revimportcounter + 1;
            end
        end
        cd ..;
        cd ..;
    
    end
    
end

%**************************************************************************
% FIND THE MEAN WAVEFORM
%**************************************************************************
normavgwaveform = zeros(1,200);

for i = 1:200
    normavgwaveform(i) = mean(swnormdata(:,i));
end

%**************************************************************************
% PLOT THE SAMPLED WAVEFORMS
%**************************************************************************
figure(1);
hold on;
xlabel('Sample Point Number');
ylabel('Current [A]');
title('Switch 97 Normal Movement Recorded Waveforms');
for i = 1:numnormrecords
    plot(swnormdata(i,:));
end
plot(normavgwaveform,'color','green');

figure(2);
hold on;
xlabel('Sample Point Number');
ylabel('Current [A]');
title('Switch 97 Normal Movement Recorded Waveforms');
for i = 1:numrevrecords
    plot(swrevdata(i,:),'color','red');
end

%**************************************************************************
% BUILD THE DISTRIBUTION FOR THE VALID WAVEFORMS
%************************************************************************** 
% these will have to be defined somehow in the future
% for now only the good logs are included
goodnorms = [1 2 4:6 15 16 18:31];
goodrevs = [1 2 4 5 8 10:18];

normlambda = zeros(2,4);
revlambda = zeros(2,4);

for i = 1:4
    normlambda(1,i) = mean(swnormcrit(goodnorms,i));
    normlambda(2,i) = var(swnormcrit(goodnorms,i));
    revlambda(1,i) = mean(swrevcrit(goodrevs,i));
    revlambda(2,i) = var(swrevcrit(goodrevs,i));
end

%**************************************************************************
% PLOT THE DISTRIBUTION FOR THE CRITERIA
%**************************************************************************
figure(3);
%title('Switch 97 Criteria Histogram',h3);
subplot(2,2,1);
hist(swnormcrit(goodnorms,2));
xlabel('Peak Current Value [A]');
ylabel('Frequency of Occurance');
title('Peak Value Histogram');

subplot(2,2,2);
hist(swnormcrit(goodnorms,3));
xlabel('Average Current Value [A]');
ylabel('Frequency of Occurance');
title('Average Value Histogram');

subplot(2,2,3);
hist(swnormcrit(goodnorms,4));
xlabel('Number of Samples in Plateau');
ylabel('Frequency of Occurance');
title('Plateau Length Histogram');

subplot(2,2,4);
hist(swnormcrit(goodnorms,5));
xlabel('Plateau Average Value [A]');
ylabel('Frequency of Occurance');
title('Plateau Average Current Value Histogram');

