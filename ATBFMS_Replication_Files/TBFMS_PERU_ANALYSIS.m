function TBFMS_PERU_ANALYSIS(SEtype,Baselinetype,y,d,keep_d,w,training)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function performs estimation for Generating Table 1 in the reference
%"Analysis of Testing-Based Forward Model Selection"
%This function is called by the m file "TBFMS_PERU_MASTER.m" 


%Sample size
n=size(y,1);
n1=sum(training);

%Process data
log_y = log(y*1000);

%Specify base set
if isequal(Baselinetype,'Base') 
    Sbase = keep_d;
else
    Sbase = [];
end

%Problem definition and size
z=[d,w];
p=size(z,2);

%Begin display
disp(' ')
disp(' ')
if isequal(SEtype,'hetero1'),disp('TBFMS I'),end
if isequal(SEtype,'hetero2'),disp('TBFMS II'),end
if isequal(SEtype,'heteroFitStreamlined'),disp('TBFMS III'),end
if isequal(SEtype,'homo'),disp('TBFMS IV'),end
disp(['Baseline type : ',Baselinetype])
disp(' ')

%Analysis for Outcome = Consumption
tic
[~,~,~,INMODEL]=stepwisefit_hetero((z(training==1,:)),(y(training==1,:)),'penter',.05/p,'premove',.999,'display','on','inmodel',Sbase,'SEtype',SEtype,'scale','off');
%In the case of 'hetero1', the default for c_tau is 1.01
[B,~,~,~] = regress(y(training==1),[ones(n1,1),z(training==1,INMODEL==1)]);
hat_y = [ones(n,1),z(:,INMODEL==1)] * B;
hat_s_y = sum(INMODEL)+1;
B_OLS = regress(y(training==1),[ones(n1,1), z(training==1 ,keep_d)]);
percapitahat_OLS = [ones(n,1),z(:,keep_d)] * B_OLS;

%Calculate MSEs
r2_OLS = (percapitahat_OLS(training == 0) - y(training==0 )).^2;
r2_TBFMS = (hat_y(training == 0 ) - y(training==0 )).^2;
r2_OLS_train = (percapitahat_OLS(training == 1) - y(training==1 )).^2;
r2_TBFMS_train = (hat_y(training == 1 ) - y(training==1 )).^2;
DeltaMSE = mean(r2_OLS) - mean(r2_TBFMS);
RelMSE   = (mean(r2_OLS) - mean(r2_TBFMS))/mean(r2_OLS);

%Hypothesis test
[~,P,CI]=ttest(r2_OLS, r2_TBFMS);

%Display results
disp(' ')
disp(' Outcome : y ')
disp(' ')
disp(['TBFMS hat s : ',num2str(hat_s_y)])
disp(['TBFMS MSE (Training) : ',num2str(nanmean( r2_TBFMS_train ))])
disp(['TBFMS MSE (Hold out) : ',num2str(nanmean(r2_TBFMS ))])
disp(' ')
disp('OLS hat s : 62')
disp(['OLS MSE (Training) : ',num2str(nanmean( r2_OLS_train  ))])
disp(['OLS MSE (Hold out) : ',num2str(nanmean(r2_OLS))])
disp(' ')       
disp(['Relative MSE : ', num2mstr(RelMSE)])
disp(['Delta MSE : ',num2str(DeltaMSE)])
disp(['P-value : ',num2str(P) ])
disp('Confidence interval :')
disp(CI)
disp(' ')
disp(['Analysis run time : ',num2str(toc)])
disp(' ')


%Analysis for Outcome = log(Consumption)
tic
[~,~,~,INMODEL]=stepwisefit_hetero((z(training==1 ,:)),(log_y(training==1 ,:)),'penter',.05/p,'premove',.999,'display','on','inmodel',Sbase,'SEtype',SEtype);
%In the case of 'hetero1', the default for c_tau is 1.01
B = regress(log_y(training==1 ),[ones(sum(training==1 ),1),z(training==1 ,INMODEL==1)]);
lncaphat = [ones(n,1),z(:,INMODEL==1)] * B;
hat_s_log_y = sum(INMODEL)+1;
B_OLS = regress(log_y(training==1),[ones(n1,1), z(training==1 ,keep_d)]);
lncaphat_OLS = [ones(n,1),z(:,keep_d)] * B_OLS;

%Calculate MSEs
r2_OLS = (lncaphat_OLS(training == 0 ) - log_y(training==0  )).^2;
r2_TBFMS = (lncaphat(training == 0 ) - log_y(training==0  )).^2;
r2_OLS_train = (lncaphat_OLS(training == 1 ) - log_y(training==1 )).^2;
r2_TBFMS_train = (lncaphat(training == 1 ) - log_y(training==1  )).^2;
DeltaMSE = mean(r2_OLS) - mean(r2_TBFMS);
RelMSE   = (mean(r2_OLS) - mean(r2_TBFMS))/mean(r2_OLS);

%Hypothesis testing
[~,P,CI]=ttest(r2_OLS, r2_TBFMS);

%Display results
disp(' ')
disp(' Outcome : log(y) ')
disp(' ')
disp(['TBFMS hat s : ',num2str(hat_s_log_y)])
disp(['TBFMS MSE (Training) : ',num2str(mean(r2_TBFMS_train))])
disp(['TBFMS MSE (Hold out) : ',num2str(mean(r2_TBFMS))])
disp(' ')
disp('OLS hat s : 62')
disp(['OLS MSE (Training) : ',num2str(mean(r2_OLS_train))])
disp(['OLS MSE (Hold out) : ',num2str(mean(r2_OLS))])
disp(' ')
disp(['Relative MSE : ',num2str(RelMSE)])
disp(['Delta MSE : ',num2str(DeltaMSE)])
disp(['P-value : ',num2str(P) ])
disp('Confidence interval :')
disp(CI)
disp(' ')
disp(['Analysis run time : ',num2str(toc)])
disp(' ')
disp(' ')










