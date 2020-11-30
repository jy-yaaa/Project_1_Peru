function []=TBFMS_PERU_MASTER()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function is the main function for Generating Table 1 in the reference
%"Analysis of Testing-Based Forward Model Selection"
%This function requires the file 'peru_matlab_export.csv' to exist in the
%working directory.
%This function makes several calls to the m file "TBFMS_PERU_ANALYSIS.m" which performs
%estimation


%clc
clear

%Initialize Display
disp(' ')
disp(' ')
disp('---------------------------------------------')
disp(' ')
disp(' Empirical Analysis : Peru Anti-Poverty Programs ')
disp(' "Testing-Based Forward Model Selection" ')
disp(' September 2019 ')
disp(' ')
disp('Start time:')
disp(datetime('now'))
disp(' ')
disp(' ')

%Read data
PeruData=readtable('peru_matlab_export.csv');
log_y=table2array(PeruData(:,1));
d=table2array(PeruData(:,2:73));
training=table2array(PeruData(:,74));
y=table2array(PeruData(:,75))/1000;
poor=table2array(PeruData(:,76));
h_hhsize=table2array(PeruData(:,77));


%Find rows with NaN
missing_row= any(isnan([d,y,poor,h_hhsize]),2);

%Interaction expansion
w=big_bool_interact(d);
s_w = nanstd(w(training==1,:));
w = w(:,s_w > .03);

%Take out rows with missing values
y=y(missing_row~=1,:);d=d(missing_row~=1,:);w=w(missing_row~=1,:);training = training(missing_row~=1,:);poor = poor(missing_row~=1,:);h_hhsize=h_hhsize(missing_row~=1,:);

%Sample size
n=size(y,1);
n1=sum(training);
n0=n-n1;

%Notes about the type of interaction used
InteractionNotes = '2nd order and, or, xor; 3rd order and ';

%Oringinal variables, thinned to be full rank
keep_d = setdiff(1:72,[8,15,21,29,36,43,52,57,62,66,73]-1);

%residualize w away from d
eta=[ones(n1,1),d(training==1,keep_d)]\w(training==1,:); w_resid = w - [ones(n,1),d(:,keep_d)]*eta;


%Display problem summary 
disp(' ')
disp(' ')
disp('-----------------------------------------------------------')
disp('-----------------------------------------------------------')
disp('Peru Poverty Targeting Analysis')
disp(' ' )
disp([' Interaction Notes : ',InteractionNotes])
disp(' ')
disp(' ')
disp(['Sample size : nTraining = ',num2str(n1),', nHoldout = ',num2str(n0),', n = ',num2str(n)])
disp(['Problem size: , p = 62, # interaction = ', num2str(size(w,2))])
disp(' ')
disp(' ')
disp('-----------------------------------------------------------')
disp(' ')
disp('y Distribution summary description (unconditional) ')
disp('             q05         q50          q95         mean       st dev      var  ')
disp(' ')
disp(['y (.10^3)  : ',num2str([ quantile(y,[.05,.5,.95]), mean(y), std(y), var(y) ])])
disp(['log y      : ',num2str([ quantile(log_y,[.05,.5,.95]), mean(log_y), std(log_y), var(log_y) ])])
disp(' ')
disp('-----------------------------------------------------------')


%Run analyses
TBFMS_PERU_ANALYSIS('hetero1','Base',y,d,keep_d,w_resid,training)
TBFMS_PERU_ANALYSIS('hetero2','Base',y,d,keep_d,w,training)
TBFMS_PERU_ANALYSIS('heteroFitStreamlined','Base',y,d,keep_d,w,training)
TBFMS_PERU_ANALYSIS('homo','Base',y,d,keep_d,w,training)

%Display end time
disp('End time:')
disp(datetime('now'))


% Fucntion for generating all 2rd order symmetric boolean interactions
function boolData = bool_interact(X)
[n, p] = size(X);
boolData = zeros(n,2*p*(p-1)/2);
k=1;
for col1 = 1:p
    for col2 = (col1+1):p
        col12Data= [...
             (X(:,col1)==1 & X(:,col2) == 1),...
             (X(:,col1) ~= X(:,col2) ),...
             (X(:,col1)==1 | X(:,col2) == 1)];
        boolData(:,k:(k+size(col12Data,2)-1)) = col12Data;
k=k+size(col12Data,2);
    end
end

% Function for generating all 3rd order "and" interactions + all 2nd order symmetric boolean functions  
function bigboolData = big_bool_interact(X)
[n, p] = size(X);
bigboolData = zeros(n,1*p*(p-1)*(p-2)/6);
k=1;
for col1 = 1:p
    for col2 = (col1+1):p
        for col3 = (col2+1):p
        col12Data= [...
             (X(:,col1)==1 & X(:,col2) == 1 & X(:,col3) == 1),...
             ];
          
        bigboolData(:,k:(k+size(col12Data,2)-1)) = col12Data;
k=k+size(col12Data,2);
        end
    end
end
bigboolData = [bigboolData,bool_interact(X)];






