% Chapter 5: creating the images for Chapter 5 of my PhD Thesis.
% (c) Joachim Ganseman, october 2017

% NOTE: run this file while inside the 'tests' folder in Matlab for correct path

clear;
addpath(genpath('../'));     % add subdirectories to path. 

PRINTTOFILE = 0;

%% Part 0: plot the different beta divergences
% use equations in definition, substitute y=1 

deuc = @(x) (x.^2 -2.*x +1);
dkl = @(x) (x.*log(x) -x +1);
dis = @(x) (x -log(x) -1);

%note: Matlab2Tikz cannot handle fplot
%note: labels repositioned as tikz and matlab fonts differ.

figure;
%fplot(deuc, [0, 5], 'black');
plot(0:0.01:4.5, feval(deuc, 0:0.01:4.5), 'black');
%text(4.1,9,texlabel('d_{EUC}(x|y=1) = x^2 - 2x + 1'));
text(0.2,9,texlabel('d_{EUC}(x|y=1) = x^2 - 2x + 1'));
hold on;
%fplot(dkl, [0, 10], 'red');
plot(0:0.01:8.5, feval(dkl, 0:0.01:8.5), 'red');
text(5.5, 8.4,texlabel('d_{KL}(x|y=1) = x log(x) - x + 1'));
hold on;
%fplot(dis, [0, 10], 'blue');
plot(0:0.01:10, feval(dis, 0:0.01:10), 'blue');
text(6,2.8,texlabel('d_{IS}(x|y=1) = x - log(x) - 1'));
hold off;
grid on;
%limit plot height to y=10
ylim([0 10]);

%% if wanted, print to file
if PRINTTOFILE
    filename = '../../../thesis/images/chapter5/betafig.tex';
    matlab2tikz('height', '\figureheight', 'width', '\figurewidth', 'filename', filename, 'relativeDataPath', '.')
end

%% plot alpha distances in the same way
%dkl = @(x) (x.*log(x) -x +1);               %KL, alpha = 1.0
%dhell = @(x) -4.*(x.^0.5 -0.5.*x -0.5);      %Hellinger, alpha=0.5
dhell = @(x) 2.*(x.^0.5 -1).^2;
%dpear = @(x) (x.^2 -2.*x +1)./2.0;           %Pearson, alpha = 2.0
dpear = @(x) ((x-1).^2)./2;
%dkldual = @(x) (log(1.0./x) +x -1);            %KL dual, alpha = 0
dkldual = @(x) -log(x) +x -1; 
dneyman = @(x) (1./x + x -2)./2.0;               %Neyman X^2 , alpha = -1

figure;
plot(0:0.01:6, feval(dpear, 0:0.01:6), 'blue');
hold on;
plot(0:0.01:9, feval(dkl, 0:0.01:9), 'red');
hold on;
plot(0:0.01:11, feval(dhell, 0:0.01:11), 'black');
hold on;
plot(0:0.01:14, feval(dkldual, 0:0.01:14), 'green');
hold on;
plot(0:0.01:14, feval(dneyman, 0:0.01:14), 'magenta');
hold off;
grid on;
legend(...
    {'$d_{Pearson}(x|y=1) = \frac{1}{2}(x-1)^2$',...    %\alpha = 2 :  
    '$d_{KL}(x|y=1) = x log(x) - x + 1$',...                %\alpha = 1 : 
    '$d_{Hellinger}(x|y=1) = 2 (\sqrt{x} -1)^2$',...  %\alpha = 0.5 : 
    '$d_{KLdual}(x|y=1) = x -log(x) -1$',...     %\alpha = 0 :
    '$d_{Neyman}(x|y=1) = \frac{1}{2} (\frac{1}{x} +x -2)$'},...     %\alpha = 0 :
    'Interpreter', 'latex', 'Location', 'southeast')
ylim([0 10]); %limit plot height to y=10

if PRINTTOFILE
    filename = '../../../thesis/images/chapter5/alphafig.tex';
    matlab2tikz('height', '\figureheight', 'width', '\figurewidth', 'filename', filename, 'relativeDataPath', '.')
end


%% Part 1: find a good plot of the plotBetaNMF test (testing optimal beta/power for NMF). 
% arguments: mean, median, stddev, (min, max) 
% (note: min, max currently not working due to data generation error in plotBetaNMF_3)

disp('display bss_eval metrics separating C4-E4-G4 piano chord w/ beta-nmf.')
make33grid('nmf-beta-test4-chord1-base48.mat', 'median', 'beta');

%%
disp('display bss_eval metrics separating C5-E5-G5 piano chord w/ beta-nmf.')
make33grid('nmf-beta-test4-chord1-base60.mat', 'median', 'beta');

%%
disp('display bss_eval metrics separating C6-E6-G6 piano chord w/ beta-nmf.')
make33grid('nmf-beta-test4-chord1-base72.mat', 'median', 'beta');

%%
disp('display bss_eval metrics separating C4-E4-G4 piano chord w/ alpha-nmf.')
make33grid('nmf-alpha-test1-chord1-base48.mat', 'median', 'alpha');

%%
disp('display bss_eval metrics separating C5-E5-G5 piano chord w/ alpha-nmf.')
make33grid('nmf-alpha-test1-chord1-base60.mat', 'median', 'alpha');

%%
disp('display bss_eval metrics separating C6-E6-G6 piano chord w/ alpha-nmf.')
make33grid('nmf-alpha-test1-chord1-base72.mat', 'median', 'alpha');

%% Turns out, best course of action is probably to display all SDR graphs. 
% SIR roughly corresponds, but is less tight/strict. 
% SAR is erratic, can go anywhere.

% moved to separate function at the bottom of this file
disp('display mean beta-nmf SDR test results.')
make33sdrbeta('mean', PRINTTOFILE);

%% moved to separate function at the bottom of this file
disp('display mean alpha-nmf SDR test results.')
make33sdralpha('mean', PRINTTOFILE);


%%
% ================================================================== %

% make a 3x3 grid of the SDR, SIR and SAR variables in given .mat file

function make33grid(variablename, whattoplot, usedalg)

load(variablename);

% set up as: arpeggiated mix of 3 sources from MAPS dataset
% for each power 0.5:0.1:2.5, for each beta 0.0:0.1:2.5, 3 SDR values [1;2;3]
% try to plot as 3 separate 3D plots

switch whattoplot
    case 'max'
        maketable = cell2mat(mySDRmax);
    case 'min'
        maketable = cell2mat(mySDRmin);
    case 'mean'
        maketable = cell2mat(mySDRmean);
    case 'median'
        maketable = cell2mat(mySDRmedian);
    case 'stddev'
        maketable = cell2mat(mySDRstddev);
    otherwise
        maketable = cell2mat(mySDR);% cat(1,mySDR{:})); % put into tabular format
end        

source1sdr = maketable(1:3:end, :)';
source2sdr = maketable(2:3:end, :)';
source3sdr = maketable(3:3:end, :)';

%only keep values larger than 0
source1sdr = max(0, source1sdr);
source2sdr = max(0, source2sdr);
source3sdr = max(0, source3sdr);

%display max value
%max(source1sdr(:)) 
% keep within the maximum and 5 dB below that?
% source1sdr = max(max(source1sdr(:))-5.0, source1sdr);

%some variables for plot details
nrcontours = 20;
myfontsize=10;

%% if necessary create new figure
figure;

%% plot these as a 3d mesh/contour plot

%
s1ax = subplot(3, 3, 1);
contourf(source1sdr, nrcontours);
colorbar;
title('C SDR', 'fontsize', myfontsize);
grid on;
ylabel(usedalg);
% draw line of maxima along x-axis
[~, xmaxes] = max(source1sdr);
hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
% draw line of maxima along y-axis
[~, ymaxes] = max(source1sdr');
hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;

%
s2ax = subplot(3, 3, 2);
contourf(source2sdr, nrcontours);
colorbar;
title('E SDR', 'fontsize', myfontsize);
grid on;
% draw line of maxima along x-axis
[~, xmaxes] = max(source2sdr);
hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
% draw line of maxima along y-axis
[~, ymaxes] = max(source2sdr');
hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;

%
s3ax = subplot(3, 3, 3);
contourf(source3sdr, nrcontours);
colorbar;
title('G SDR', 'fontsize', myfontsize);
grid on;
% draw line of maxima along x-axis
[~, xmaxes] = max(source3sdr);
hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
% draw line of maxima along y-axis
[~, ymaxes] = max(source3sdr');
hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;

%% plot SIR

switch whattoplot
    case 'max'
        maketable = cell2mat(mySIRmax);
    case 'min'
        maketable = cell2mat(mySIRmin);
    case 'mean'
        maketable = cell2mat(mySIRmean);
    case 'median'
        maketable = cell2mat(mySIRmedian);
    case 'stddev'
        maketable = cell2mat(mySIRstddev);
    otherwise
        maketable = cell2mat(mySIR); %cat(1,mySIR{:})); % put into tabular format
end
source1sir = maketable(1:3:end, :)';
source2sir = maketable(2:3:end, :)';
source3sir = maketable(3:3:end, :)';

%only keep values larger than 0
source1sir = max(0, source1sir);
source2sir = max(0, source2sir);
source3sir = max(0, source3sir);

s4ax = subplot(3, 3, 4);
contourf(source1sir, nrcontours);
colorbar;
title('C SIR', 'fontsize', myfontsize);
grid on;
ylabel(usedalg);
% draw line of maxima along x-axis
[~, xmaxes] = max(source1sir);
hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
% draw line of maxima along y-axis
[~, ymaxes] = max(source1sir');
hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;

%
s5ax = subplot(3, 3, 5);
contourf(source2sir, nrcontours);
colorbar;
title('E SIR', 'fontsize', myfontsize);
grid on;
% draw line of maxima along x-axis
[~, xmaxes] = max(source2sir);
hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
% draw line of maxima along y-axis
[~, ymaxes] = max(source2sir');
hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;

%
s6ax = subplot(3, 3, 6);
contourf(source3sir, nrcontours);
colorbar;
title('G SIR', 'fontsize', myfontsize);
grid on;
% draw line of maxima along x-axis
[~, xmaxes] = max(source3sir);
hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
% draw line of maxima along y-axis
[~, ymaxes] = max(source3sir');
hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;

%% plot SAR

switch whattoplot
    case 'max'
        maketable = cell2mat(mySARmax);
    case 'min'
        maketable = cell2mat(mySARmin);
    case 'mean'
        maketable = cell2mat(mySARmean);
    case 'median'
        maketable = cell2mat(mySARmedian);
    case 'stddev'
        maketable = cell2mat(mySARstddev);
    otherwise
        maketable = cell2mat(mySAR); %cat(1,mySAR{:})); % put into tabular format
end

source1sar = maketable(1:3:end, :)';
source2sar = maketable(2:3:end, :)';
source3sar = maketable(3:3:end, :)';

%only keep values larger than 0
source1sar = max(0, source1sar);
source2sar = max(0, source2sar);
source3sar = max(0, source3sar);

s7ax = subplot(3, 3, 7);
contourf(source1sar, nrcontours);
colorbar;
title('C SAR', 'fontsize', myfontsize);
grid on;
ylabel(usedalg);
xlabel('exponent');
% draw line of maxima along x-axis
[~, xmaxes] = max(source1sar);
hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
% draw line of maxima along y-axis
[~, ymaxes] = max(source1sar');
hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;

%
s8ax = subplot(3, 3, 8);
contourf(source2sar, nrcontours);
colorbar;
title('E SAR', 'fontsize', myfontsize);
grid on;
xlabel('exponent');
% draw line of maxima along x-axis
[~, xmaxes] = max(source2sar);
hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
% draw line of maxima along y-axis
[~, ymaxes] = max(source2sar');
hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;

%
s9ax = subplot(3, 3, 9);
contourf(source3sar, nrcontours);
colorbar;
title('G SAR', 'fontsize', myfontsize);
grid on;
xlabel('exponent');
% draw line of maxima along x-axis
[~, xmaxes] = max(source3sar);
hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
% draw line of maxima along y-axis
[~, ymaxes] = max(source3sar');
hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;

%% set axes

switch usedalg
    case 'beta'
        set([s1ax, s2ax, s3ax, s4ax, s5ax, s6ax, s7ax, s8ax, s9ax],...
        'BoxStyle','full','Layer','top','YMinorTick','on','YTick',...
        [1 6 11 16 21 26],'YTickLabel',{'0.0','0.5','1.0','1.5','2.0','2.5'},...
        'XMinorTick','on','XTick',[1 6 11 16 21],'XTickLabel',...
        {'0.5','1.0','1.5','2.0','2.5'});
    case 'alpha'
        set([s1ax, s2ax, s3ax, s4ax, s5ax, s6ax, s7ax, s8ax, s9ax],...
        'BoxStyle','full','Layer','top','YMinorTick','on','YTick',...
        [1 5 9 13],'YTickLabel',{'-1.0','0.0','1.0', '2.0'},...
        'XMinorTick','on','XTick',[1 3 5 7 9],'XTickLabel',...
        {'0.5','1.0','1.5','2.0','2.5'});
    otherwise %default to beta
        set([s1ax, s2ax, s3ax, s4ax, s5ax, s6ax, s7ax, s8ax, s9ax],...
        'BoxStyle','full','Layer','top','YMinorTick','on','YTick',...
        [1 6 11 16 21 26],'YTickLabel',{'0.0','0.5','1.0','1.5','2.0','2.5'},...
        'XMinorTick','on','XTick',[1 6 11 16 21],'XTickLabel',...
        {'0.5','1.0','1.5','2.0','2.5'});
end

end %function make33grid


%%
% ================================================================== %

% make a 3x3 grid of all SDR variables in given .mat file, with color bar 
% separately at the bottom. (To export to EPS and then include in TeX)

function make33sdrbeta(whattoplot, PRINTTOFILE)

colormin = 0;
% to decide maximum of color bar, check:
% max(max([ source1sdr source2sdr source3sdr source4sdr source5sdr source6sdr source7sdr source8sdr source9sdr ] ))
colormax = 23;

load('nmf-beta-test4-chord1-base48.mat');
switch whattoplot
    case 'max'
        maketable = cell2mat(mySDRmax);
    case 'min'
        maketable = cell2mat(mySDRmin);
    case 'mean'
        maketable = cell2mat(mySDRmean);
    case 'median'
        maketable = cell2mat(mySDRmedian);
    case 'stddev'
        maketable = cell2mat(mySDRstddev);
    otherwise
        maketable = cell2mat(mySDR);% cat(1,mySDR{:})); % put into tabular format
end  
source1sdr = maketable(1:3:end, :)'; source1sdr = max(colormin, source1sdr);
source2sdr = maketable(2:3:end, :)'; source2sdr = max(colormin, source2sdr);
source3sdr = maketable(3:3:end, :)'; source3sdr = max(colormin, source3sdr);
load('nmf-beta-test4-chord1-base60.mat');
switch whattoplot
    case 'max'
        maketable = cell2mat(mySDRmax);
    case 'min'
        maketable = cell2mat(mySDRmin);
    case 'mean'
        maketable = cell2mat(mySDRmean);
    case 'median'
        maketable = cell2mat(mySDRmedian);
    case 'stddev'
        maketable = cell2mat(mySDRstddev);
    otherwise
        maketable = cell2mat(mySDR);% cat(1,mySDR{:})); % put into tabular format
end  
source4sdr = maketable(1:3:end, :)'; source4sdr = max(colormin, source4sdr);
source5sdr = maketable(2:3:end, :)'; source5sdr = max(colormin, source5sdr);
source6sdr = maketable(3:3:end, :)'; source6sdr = max(colormin, source6sdr);
load('nmf-beta-test4-chord1-base72.mat');
switch whattoplot
    case 'max'
        maketable = cell2mat(mySDRmax);
    case 'min'
        maketable = cell2mat(mySDRmin);
    case 'mean'
        maketable = cell2mat(mySDRmean);
    case 'median'
        maketable = cell2mat(mySDRmedian);
    case 'stddev'
        maketable = cell2mat(mySDRstddev);
    otherwise
        maketable = cell2mat(mySDR);% cat(1,mySDR{:})); % put into tabular format
end  
source7sdr = maketable(1:3:end, :)'; source7sdr = max(colormin, source7sdr);
source8sdr = maketable(2:3:end, :)'; source8sdr = max(colormin, source8sdr);
source9sdr = maketable(3:3:end, :)'; source9sdr = max(colormin, source9sdr);

nrcontours = 20;
myfontsize = 9;
figure1 = figure;
axes1 = axes('Parent',figure1);
sprows = 4;
spcols = 3;

s1ax = subplot(sprows, spcols, 1);
contourf(source1sdr, nrcontours);
title(['C4 (MIDI:48) ' whattoplot ' SDR'], 'fontsize', myfontsize); ylabel('Beta'); %xlabel('exponent');
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source1sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source1sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
grid on; caxis([colormin colormax]); %colorbar;

s2ax = subplot(sprows, spcols, 2);
contourf(source2sdr, nrcontours);
title(['E4 (MIDI:52) ' whattoplot ' SDR'], 'fontsize', myfontsize); %ylabel('Beta'); xlabel('exponent');
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source2sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source2sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
grid on; caxis([colormin colormax]); %colorbar;

s3ax = subplot(sprows, spcols, 3);
contourf(source3sdr, nrcontours);
title(['G4 (MIDI:55) ' whattoplot ' SDR'], 'fontsize', myfontsize); %ylabel('Beta'); xlabel('exponent');
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source3sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source3sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
grid on; caxis([colormin colormax]); %colorbar;

s4ax = subplot(sprows, spcols, 4);
contourf(source4sdr, nrcontours);
title(['C5 (MIDI:60) ' whattoplot ' SDR'], 'fontsize', myfontsize); ylabel('Beta'); %xlabel('exponent');
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source4sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source4sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
grid on; caxis([colormin colormax]); %colorbar;

s5ax = subplot(sprows, spcols, 5);
contourf(source5sdr, nrcontours);
title(['E5 (MIDI:64) ' whattoplot ' SDR'], 'fontsize', myfontsize); %ylabel('Beta'); xlabel('exponent');
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source5sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source5sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
grid on; caxis([colormin colormax]); %colorbar;

s6ax = subplot(sprows, spcols, 6);
contourf(source6sdr, nrcontours);
title(['G5 (MIDI:67) ' whattoplot ' SDR'], 'fontsize', myfontsize); %ylabel('Beta'); xlabel('exponent');
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source6sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source6sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
grid on; caxis([colormin colormax]); %colorbar;

s7ax = subplot(sprows, spcols, 7);
contourf(source7sdr, nrcontours);
title(['C6 (MIDI:72) ' whattoplot ' SDR'], 'fontsize', myfontsize); ylabel('Beta'); xlabel('exponent');
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source7sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source7sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
grid on; caxis([colormin colormax]); %colorbar;

s8ax = subplot(sprows, spcols, 8);
contourf(source8sdr, nrcontours);
title(['E6 (MIDI:76) ' whattoplot ' SDR'], 'fontsize', myfontsize); xlabel('exponent'); %ylabel('Beta');
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source8sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source8sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
grid on; caxis([colormin colormax]); %colorbar('southoutside')

s9ax = subplot(sprows, spcols, 9);
contourf(source9sdr, nrcontours);
title(['G6 (MIDI:79) ' whattoplot ' SDR'], 'fontsize', myfontsize); xlabel('exponent'); %ylabel('Beta');
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source9sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source9sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
grid on; caxis([colormin colormax]); %colorbar('Ticks',[0,5,10,15,20,25]); 

% set/link axes
set([s1ax, s2ax, s3ax, s4ax, s5ax, s6ax, s7ax, s8ax, s9ax],...
    'BoxStyle','full','Layer','top','YMinorTick','on','YTick',...
    [1 6 11 16 21 26],'YTickLabel',{'0.0','0.5','1.0','1.5','2.0','2.5'},...
    'XMinorTick','on','XTick',[1 6 11 16 21],'XTickLabel',...
    {'0.5','1.0','1.5','2.0','2.5'});
linkaxes([s1ax, s2ax, s3ax, s4ax, s5ax, s6ax, s7ax, s8ax, s9ax],'xy');

% put colorbar in new row
s11ax = subplot(sprows, spcols, 11);
axis off; caxis([colormin colormax]);
colorbar('northoutside', 'Ticks',[0,5,10,15,20,25]);

%% if wanted, print to file
if PRINTTOFILE
    filename = '../../../thesis/images/chapter5/betafig.tex';
    matlab2tikz('height', '\figureheight', 'width', '\figurewidth', 'filename', filename, 'relativeDataPath', '.')
end

%% Just for the fun of it, plot the average across all notes
source10sdr = (source1sdr+source2sdr+source3sdr+source4sdr+source5sdr+source6sdr+source7sdr+source8sdr+source9sdr)./9.0;
figure2 = figure;
contourf(source10sdr, nrcontours);
title([whattoplot ' SDR across 9 different notes']); ylabel('beta'); xlabel('exponent');
xticks(1:5:21); xticklabels({'0.5', '1.0', '1.5', '2.0', '2.5'});
yticks(1:5:26); yticklabels({'0.0', '0.5', '1.0', '1.5', '2.0', '2.5'});
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source10sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source10sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
% draw 1/x curve
dinv = @(x) 1./x;
hold on; plot(1:0.1:21, feval(dinv, 0.5:0.01:2.5).*10+1, '--b', 'LineWidth', 1); hold off;
grid on; colorbar;

%% if wanted, print to file
if PRINTTOFILE
    filename = ['../../../thesis/images/chapter5/betavsexponent' whattoplot '.tex'];
    matlab2tikz('height', '\figureheight', 'width', '\figurewidth', 'filename', filename, 'relativeDataPath', '.')
end

end %function make33sdrbeta

% make a 3x3 grid of all SDR variables in given .mat file, with color bar 
% separately at the bottom. (To export to EPS and then include in TeX)

function make33sdralpha(whattoplot, PRINTTOFILE)

colormin = 0;
% to decide maximum of color bar, check:
% max(max([ source1sdr source2sdr source3sdr source4sdr source5sdr source6sdr source7sdr source8sdr source9sdr ] ))
colormax = 23;

load('nmf-alpha-test1-chord1-base48.mat');
switch whattoplot
    case 'max'
        maketable = cell2mat(mySDRmax);
    case 'min'
        maketable = cell2mat(mySDRmin);
    case 'mean'
        maketable = cell2mat(mySDRmean);
    case 'median'
        maketable = cell2mat(mySDRmedian);
    case 'stddev'
        maketable = cell2mat(mySDRstddev);
    otherwise
        maketable = cell2mat(mySDR);% cat(1,mySDR{:})); % put into tabular format
end  
source1sdr = maketable(1:3:end, :)'; source1sdr = max(colormin, source1sdr);
source2sdr = maketable(2:3:end, :)'; source2sdr = max(colormin, source2sdr);
source3sdr = maketable(3:3:end, :)'; source3sdr = max(colormin, source3sdr);
load('nmf-alpha-test1-chord1-base60.mat');
switch whattoplot
    case 'max'
        maketable = cell2mat(mySDRmax);
    case 'min'
        maketable = cell2mat(mySDRmin);
    case 'mean'
        maketable = cell2mat(mySDRmean);
    case 'median'
        maketable = cell2mat(mySDRmedian);
    case 'stddev'
        maketable = cell2mat(mySDRstddev);
    otherwise
        maketable = cell2mat(mySDR);% cat(1,mySDR{:})); % put into tabular format
end  
source4sdr = maketable(1:3:end, :)'; source4sdr = max(colormin, source4sdr);
source5sdr = maketable(2:3:end, :)'; source5sdr = max(colormin, source5sdr);
source6sdr = maketable(3:3:end, :)'; source6sdr = max(colormin, source6sdr);
load('nmf-alpha-test1-chord1-base72.mat');
switch whattoplot
    case 'max'
        maketable = cell2mat(mySDRmax);
    case 'min'
        maketable = cell2mat(mySDRmin);
    case 'mean'
        maketable = cell2mat(mySDRmean);
    case 'median'
        maketable = cell2mat(mySDRmedian);
    case 'stddev'
        maketable = cell2mat(mySDRstddev);
    otherwise
        maketable = cell2mat(mySDR);% cat(1,mySDR{:})); % put into tabular format
end  
source7sdr = maketable(1:3:end, :)'; source7sdr = max(colormin, source7sdr);
source8sdr = maketable(2:3:end, :)'; source8sdr = max(colormin, source8sdr);
source9sdr = maketable(3:3:end, :)'; source9sdr = max(colormin, source9sdr);

nrcontours = 20;
myfontsize = 9;
figure1 = figure;
axes1 = axes('Parent',figure1);
sprows = 4;
spcols = 3;

s1ax = subplot(sprows, spcols, 1);
contourf(source1sdr, nrcontours);
title(['C4 (MIDI:48) ' whattoplot ' SDR'], 'fontsize', myfontsize); ylabel('Alpha'); %xlabel('exponent');
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source1sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source1sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
grid on; caxis([colormin colormax]); %colorbar;

s2ax = subplot(sprows, spcols, 2);
contourf(source2sdr, nrcontours);
title(['E4 (MIDI:52) ' whattoplot ' SDR'], 'fontsize', myfontsize); %ylabel('Alpha'); xlabel('exponent');
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source2sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source2sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
grid on; caxis([colormin colormax]); %colorbar;

s3ax = subplot(sprows, spcols, 3);
contourf(source3sdr, nrcontours);
title(['G4 (MIDI:55) ' whattoplot ' SDR'], 'fontsize', myfontsize); %ylabel('Alpha'); xlabel('exponent');
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source3sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source3sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
grid on; caxis([colormin colormax]); %colorbar;

s4ax = subplot(sprows, spcols, 4);
contourf(source4sdr, nrcontours);
title(['C5 (MIDI:60) ' whattoplot ' SDR'], 'fontsize', myfontsize); ylabel('Alpha'); %xlabel('exponent');
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source4sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source4sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
grid on; caxis([colormin colormax]); %colorbar;

s5ax = subplot(sprows, spcols, 5);
contourf(source5sdr, nrcontours);
title(['E5 (MIDI:64) ' whattoplot ' SDR'], 'fontsize', myfontsize); %ylabel('Alpha'); xlabel('exponent');
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source5sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source5sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
grid on; caxis([colormin colormax]); %colorbar;

s6ax = subplot(sprows, spcols, 6);
contourf(source6sdr, nrcontours);
title(['G5 (MIDI:67) ' whattoplot ' SDR'], 'fontsize', myfontsize); %ylabel('Alpha'); xlabel('exponent');
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source6sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source6sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
grid on; caxis([colormin colormax]); %colorbar;

s7ax = subplot(sprows, spcols, 7);
contourf(source7sdr, nrcontours);
title(['C6 (MIDI:72) ' whattoplot ' SDR'], 'fontsize', myfontsize); ylabel('Alpha'); xlabel('exponent');
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source7sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source7sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
grid on; caxis([colormin colormax]); %colorbar;

s8ax = subplot(sprows, spcols, 8);
contourf(source8sdr, nrcontours);
title(['E6 (MIDI:76) ' whattoplot ' SDR'], 'fontsize', myfontsize); xlabel('exponent'); %ylabel('Alpha');
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source8sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source8sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
grid on; caxis([colormin colormax]); %colorbar('southoutside')

s9ax = subplot(sprows, spcols, 9);
contourf(source9sdr, nrcontours);
title(['G6 (MIDI:79) ' whattoplot ' SDR'], 'fontsize', myfontsize); xlabel('exponent'); %ylabel('Alpha');
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source9sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source9sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
grid on; caxis([colormin colormax]); %colorbar('Ticks',[0,5,10,15,20,25]); 

% set/link axes
set([s1ax, s2ax, s3ax, s4ax, s5ax, s6ax, s7ax, s8ax, s9ax],...
        'BoxStyle','full','Layer','top','YMinorTick','on','YTick',...
        [1 5 9 13],'YTickLabel',{'-1.0','0.0','1.0', '2.0'},...
        'XMinorTick','on','XTick',[1 3 5 7 9],'XTickLabel',...
        {'0.5','1.0','1.5','2.0','2.5'});
linkaxes([s1ax, s2ax, s3ax, s4ax, s5ax, s6ax, s7ax, s8ax, s9ax],'xy');

% put colorbar in new row
s11ax = subplot(sprows, spcols, 11);
axis off; caxis([colormin colormax]);
colorbar('northoutside', 'Ticks',[0,5,10,15,20,25]);

%% if wanted, print to file
if PRINTTOFILE
    filename = '../../../thesis/images/chapter5/alphafig.tex';
    matlab2tikz('height', '\figureheight', 'width', '\figurewidth', 'filename', filename, 'relativeDataPath', '.')
end

%% Just for the fun of it, plot the average across all notes
source10sdr = (source1sdr+source2sdr+source3sdr+source4sdr+source5sdr+source6sdr+source7sdr+source8sdr+source9sdr)./9.0;
figure2 = figure;
contourf(source10sdr, nrcontours);
title([whattoplot ' SDR across 9 different notes']); ylabel('alpha'); xlabel('exponent');
xticks([1 3 5 7 9]); xticklabels({'0.5', '1.0', '1.5', '2.0', '2.5'});
yticks([1 5 9 13]); yticklabels({'-1.0','0.0','1.0', '2.0'});
% draw lines of maxima along x and y-axis
[~, xmaxes] = max(source10sdr); hold on; plot( 1:1:size(xmaxes,2) , xmaxes, 'red', 'LineWidth', 1.0, 'Marker', '*'); hold off;
[~, ymaxes] = max(source10sdr'); hold on; plot( ymaxes , 1:1:size(ymaxes,2), 'green', 'LineWidth', 1.0, 'Marker', 'd'); hold off;
% draw 1/x curve
dinv = @(x) 1./x;
%hold on; plot(1:0.1:21, feval(dinv, 0.5:0.01:2.5).*10+1, '--b', 'LineWidth', 1); hold off;
grid on; colorbar;

%% if wanted, print to file
if PRINTTOFILE
    filename = ['../../../thesis/images/chapter5/betavsexponent' whattoplot '.tex'];
    matlab2tikz('height', '\figureheight', 'width', '\figurewidth', 'filename', filename, 'relativeDataPath', '.')
end

end %function make33sdralpha

