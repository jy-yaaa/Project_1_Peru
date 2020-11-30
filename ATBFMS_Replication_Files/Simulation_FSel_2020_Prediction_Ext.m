function Simulation_FSel_2020_Prediction_Ext()


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Extended Simulation study for "Analysis of Testing-Based Forward Model Selection"
%Extended prediction simulation for appendix
%Damian Kozbur, 2020

%Implemented on MATLAB R2018b

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%Initialize Display
disp(' ')
disp(' ')
disp('---------------------------------------------')
disp(' ')
disp(' Extended Prediction Simulation for "Testing-Based Forward Model Selection" ')
disp('   ')
disp(' ')
%Display Start time
disp('Simulation start time:')
disp(datetime('now'))
disp(' ')
disp(' ')


%Simulation Parameters
sim_max=1000;  %Total number of replications for each simulation
sim_id=0;    %Simulation ID number

%Initialize
SE_forward_I=zeros(sim_max,1);
SE_forward_II=zeros(sim_max,1);
SE_forward_III=zeros(sim_max,1);
SE_forward_IV=zeros(sim_max,1);
SE_lasso=zeros(sim_max,1);
SE_post=zeros(sim_max,1);
SE_lasso_CV=zeros(sim_max,1); 
SE_oracle=zeros(sim_max,1);  
St_forward_I=zeros(sim_max,1); 
St_forward_II=zeros(sim_max,1);
St_forward_III=zeros(sim_max,1); 
St_forward_IV=zeros(sim_max,1);
St_lasso=zeros(sim_max,1);
St_post=zeros(sim_max,1);
St_lasso_CV=zeros(sim_max,1);
St_oracle=zeros(sim_max,1);
Sp_forward_I=zeros(sim_max,1); 
Sp_forward_II=zeros(sim_max,1);
Sp_forward_III=zeros(sim_max,1); 
Sp_forward_IV=zeros(sim_max,1);
Sp_lasso=zeros(sim_max,1);
Sp_post=zeros(sim_max,1);
Sp_lasso_CV=zeros(sim_max,1);
Sp_oracle=zeros(sim_max,1);
Sc_forward_I=zeros(sim_max,1); 
Sc_forward_II=zeros(sim_max,1);
Sc_forward_III=zeros(sim_max,1); 
Sc_forward_IV=zeros(sim_max,1);
Sc_lasso=zeros(sim_max,1);
Sc_post=zeros(sim_max,1);
Sc_lasso_CV=zeros(sim_max,1);
Sc_oracle=zeros(sim_max,1);  
mean_Sc_forward_I = zeros(5,1);
mean_Sc_forward_II= zeros(5,1);
mean_Sc_forward_III = zeros(5,1);
mean_Sc_forward_IV= zeros(5,1);
mean_Sc_post = zeros(5,1);
mean_Sc_lasso_CV = zeros(5,1);
mean_Sc_Oracle = zeros(5,1);
mean_SE_forward_I = zeros(5,1);
mean_SE_forward_II= zeros(5,1);
mean_SE_forward_III = zeros(5,1);
mean_SE_forward_IV= zeros(5,1);
mean_SE_post = zeros(5,1);
mean_SE_lasso_CV = zeros(5,1);
mean_SE_Oracle = zeros(5,1);
mean_St_forward_I = zeros(5,1);
mean_St_forward_II= zeros(5,1);
mean_St_forward_III = zeros(5,1);
mean_St_forward_IV= zeros(5,1);
mean_St_post= zeros(5,1);
mean_St_lasso_CV= zeros(5,1);
mean_St_Oracle= zeros(5,1);
mean_Sp_forward_I= zeros(5,1);
mean_Sp_forward_II= zeros(5,1);
mean_Sp_forward_III= zeros(5,1);
mean_Sp_forward_IV= zeros(5,1);
mean_Sp_post= zeros(5,1);
mean_Sp_lasso_CV= zeros(5,1);
mean_Sp_Oracle= zeros(5,1);



%Define Loop through the different simulation designs defined in paper
for b = [-.5,.5]
for heteroskedastic = [0,1] 
for cp = 2
for s = 6 

    
    
for n=[100,500]
    
    
%Problem Parameters 
p=n*cp;
alpha=.05;
c_tau=1.01;
theta = [b.^(0:(s-1))';zeros(p-s,1)]; 
sim_id=sim_id+1;





%Loop through simulation replications
for nsim = 1:sim_max
rng(nsim)
    %Generate Data
        T = chol (toeplitz (.5.^(0:(p-1) )  ));
        x= randn(n,p)*T;
        if heteroskedastic == 0; e=.5*randn(n,1);
        elseif heteroskedastic == 1, e=.5*randn(n,1).*(exp(.5*x*(.75.^((p-1):(-1):0)')));
        end
        y = x*theta + e;

    %Estimate
        [S_forward_I,theta_forward_I,yhat_forward_I]=fsel_hetero(y,x,alpha,c_tau,1);
        [S_forward_II,theta_forward_II,yhat_forward_II]=fsel_hetero(y,x,alpha,c_tau,2);
        [S_forward_III,theta_forward_III,yhat_forward_III]=fsel_hetero(y,x,alpha,c_tau,3);
        [S_forward_IV,theta_forward_IV,yhat_forward_IV]=fsel_hetero(y,x,alpha,c_tau,4);
        [S_lasso,theta_lasso,yhat_lasso,S_post, theta_post,yhat_post]=lasso_hetero(y,x,alpha,c_tau);
        [S_lasso_CV,theta_lasso_CV,yhat_lasso_CV,S_post_CV, theta_post_CV,yhat_post_CV]=lasso_CV(y,x); %#ok
        S_oracle = 1:s;theta_oracle = (x(:,S_oracle)\y);  yhat_oracle = x(:,S_oracle)*theta_oracle; 
        
    %Record Results
        ybar=x*theta;
        SE_forward_I(nsim) = std(ybar - yhat_forward_I);
        SE_forward_II(nsim) = std(ybar - yhat_forward_II);
        SE_forward_III(nsim) = std(ybar - yhat_forward_III);
        SE_forward_IV(nsim) = std(ybar - yhat_forward_IV);
        SE_lasso(nsim) = std( ybar - yhat_lasso);
        SE_post(nsim) = std( ybar - yhat_post);
        SE_lasso_CV(nsim) = std( ybar - yhat_lasso_CV);
        SE_oracle(nsim) = std( ybar - yhat_oracle);
        
        theta_forward_I_full = zeros(p,1); theta_forward_I_full(S_forward_I) = theta_forward_I;
        theta_forward_II_full = zeros(p,1); theta_forward_II_full(S_forward_II) = theta_forward_II;
        theta_forward_III_full = zeros(p,1); theta_forward_III_full(S_forward_III) = theta_forward_III;
        theta_forward_IV_full = zeros(p,1); theta_forward_IV_full(S_forward_IV) = theta_forward_IV;
        theta_lasso_full = theta_lasso;
        theta_post_full = zeros(p,1); theta_post_full(S_post) = theta_post; 
        theta_lasso_CV_full = theta_lasso_CV;
        theta_oracle_full = zeros(p,1); theta_oracle_full(S_oracle) = theta_oracle;
        
        St_forward_I(nsim) = norm(theta - theta_forward_I_full);
        St_forward_II(nsim) = norm(theta - theta_forward_II_full);
        St_forward_III(nsim) = norm(theta - theta_forward_III_full);
        St_forward_IV(nsim) = norm(theta - theta_forward_IV_full);
        St_lasso(nsim) = norm(theta - theta_lasso_full);
        St_post(nsim) = norm(theta - theta_post_full);
        St_lasso_CV(nsim) = norm(theta - theta_lasso_CV_full);
        St_oracle(nsim) = norm(theta - theta_oracle_full);
        
        Sp_forward_I(nsim) = length(S_forward_I); 
        Sp_forward_II(nsim) = length(S_forward_II); 
        Sp_forward_III(nsim) = length(S_forward_III); 
        Sp_forward_IV(nsim) = length(S_forward_IV); 
        Sp_lasso(nsim) = sum(S_lasso);
        Sp_post(nsim) = sum(S_post);
        Sp_lasso_CV(nsim) = sum(S_lasso_CV);
        Sp_oracle(nsim) = length(S_oracle);

        
        Sc_forward_I(nsim) = sum(theta_forward_I_full(1:s) ~=0 );
        Sc_forward_II(nsim) = sum(theta_forward_II_full(1:s) ~=0 );
        Sc_forward_III(nsim) = sum(theta_forward_III_full(1:s) ~=0 );
        Sc_forward_IV(nsim) = sum(theta_forward_IV_full(1:s) ~=0 );
        Sc_lasso(nsim) = sum( theta_lasso_full(1:s) ~=0 );
        Sc_post(nsim) = sum( theta_post_full(1:s) ~=0 );
        Sc_lasso_CV(nsim) = sum(theta_lasso_CV_full(1:s) ~=0 );
        Sc_oracle(nsim) = sum(theta_oracle_full(1:s) ~=0 );

end  


%Display Results
disp('---------------------------------------------')
disp(' ')
if heteroskedastic ==1, disp(['Sim# ',num2str(sim_id),'    heteroskedastic, b = ',num2str(b),', n = ',num2str(n), ', p = ',num2str(p),', s0 = ',num2str(s),', reps = ',num2str(sim_max) ])
else disp(['Sim# ',num2str(sim_id),'    homoskedastic, b = ',num2str(b),', n = ',num2str(n), ', p = ',num2str(p),', s0 = ',num2str(s),', reps = ',num2str(sim_max)])
end
disp(' ')
disp(['Forward I:     ','MPEN:  ',num2str(mean(SE_forward_I), '%1.3f \t'),'  RMSE:  ',num2str(mean(St_forward_I), '%1.3f \t'), '  MNCS:  ',num2str(mean(Sp_forward_I), '%1.3f \t'),'  MSSS:  ',num2str(mean(Sp_forward_I), '%1.3f \t')])
disp(['Forward II:    ','MPEN:  ',num2str(mean(SE_forward_II), '%1.3f \t'),'  RMSE:  ',num2str(mean(St_forward_II), '%1.3f \t'),'  MNCS:  ',num2str(mean(Sc_forward_II), '%1.3f \t'),'  MSSS:  ',num2str(mean(Sp_forward_II), '%1.3f \t')])
disp(['Forward III:   ','MPEN:  ',num2str(mean(SE_forward_III), '%1.3f \t'),'  RMSE:  ',num2str(mean(St_forward_III), '%1.3f \t'), '  MNCS:  ',num2str(mean(Sp_forward_III), '%1.3f \t'),'  MSSS:  ',num2str(mean(Sp_forward_III), '%1.3f \t')])
disp(['Forward IV:    ','MPEN:  ',num2str(mean(SE_forward_IV), '%1.3f \t'),'  RMSE:  ',num2str(mean(St_forward_IV), '%1.3f \t'),'  MNCS:  ',num2str(mean(Sc_forward_IV), '%1.3f \t'),'  MSSS:  ',num2str(mean(Sp_forward_IV), '%1.3f \t')])
disp(['Post-Lasso:    ','MPEN:  ',num2str(mean(SE_post), '%1.3f \t'),    '  RMSE:  ',num2str(mean(St_post), '%1.3f \t'),'  MNCS:  ',num2str(mean(Sc_post), '%1.3f \t'),'  MSSS:  ',num2str(mean(Sp_post), '%1.3f \t')])
disp(['Lasso-CV:      ','MPEN:  ',num2str(mean(SE_lasso_CV), '%1.3f \t'),     '  RMSE:  ',num2str(mean(St_lasso_CV), '%1.3f \t'),'  MNCS:  ',num2str(mean(Sc_lasso_CV), '%1.3f \t'),'  MSSS:  ',num2str(mean(Sp_lasso_CV), '%1.3f \t')])
disp(['Oracle:        ','MPEN:  ',num2str(mean(SE_oracle), '%1.3f \t'),   '  RMSE:  ',num2str(mean(St_oracle), '%1.3f \t'),'  MNCS:  ',num2str(mean(Sc_oracle), '%1.3f \t'),'  MSSS:  ',num2str(mean(Sp_oracle), '%1.3f \t')])
disp(' ')


%Aggregate data over n = 100:500
mean_SE_forward_I(floor(n/100)) = mean(SE_forward_I);
mean_SE_forward_II(floor(n/100)) = mean(SE_forward_II);
mean_SE_forward_III(floor(n/100)) = mean(SE_forward_III);
mean_SE_forward_IV(floor(n/100)) = mean(SE_forward_IV);
mean_SE_post(floor(n/100)) = mean(SE_post);
mean_SE_lasso_CV(floor(n/100)) = mean(SE_lasso_CV);
mean_SE_Oracle(floor(n/100)) = mean(SE_oracle);

mean_St_forward_I(floor(n/100)) = mean(St_forward_I);
mean_St_forward_II(floor(n/100)) = mean(St_forward_II);
mean_St_forward_III(floor(n/100)) = mean(St_forward_III);
mean_St_forward_IV(floor(n/100)) = mean(St_forward_IV);
mean_St_post(floor(n/100)) = mean(St_post);
mean_St_lasso_CV(floor(n/100)) = mean(St_lasso_CV);
mean_St_Oracle(floor(n/100)) = mean(St_oracle);

mean_Sc_forward_I(floor(n/100)) = mean(Sc_forward_I);
mean_Sc_forward_II(floor(n/100)) = mean(Sc_forward_II);
mean_Sc_forward_III(floor(n/100)) = mean(Sc_forward_III);
mean_Sc_forward_IV(floor(n/100)) = mean(Sc_forward_IV);
mean_Sc_post(floor(n/100)) = mean(Sc_post);
mean_Sc_lasso_CV(floor(n/100)) = mean(Sc_lasso_CV);
mean_Sc_Oracle(floor(n/100)) = mean(Sc_oracle);

mean_Sp_forward_I(floor(n/100)) = mean(Sp_forward_I);
mean_Sp_forward_II(floor(n/100)) = mean(Sp_forward_II);
mean_Sp_forward_III(floor(n/100)) = mean(Sp_forward_III);
mean_Sp_forward_IV(floor(n/100)) = mean(Sp_forward_IV);
mean_Sp_post(floor(n/100)) = mean(Sp_post);
mean_Sp_lasso_CV(floor(n/100)) = mean(Sp_lasso_CV);
mean_Sp_Oracle(floor(n/100)) = mean(Sp_oracle);









end


end
end
end
end


disp('---------------------------------------------')
disp(' ')
disp(' ')
%Display End time
disp('Simulation end time:')
disp(datetime('now'))
disp(' ')
disp(' ')
disp('---------------------------------------------')
disp('  ')
disp('   ')



%Save results
%save Simulation_FSel_Predict_Results_Ext



