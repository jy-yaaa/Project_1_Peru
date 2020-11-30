function Simulation_FSel_2020_Controls()


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Simulation study for "Analysis of Testing-Based Forward Model Selection"
%Controls Simulation

%Damian Kozbur
%2020

%Implemented for MATLAB R2018b

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Start timer
tic
print_times = 0;

%Initialize Display
disp(' ')
disp(' ')
disp('---------------------------------------------')
disp(' ')
disp(' Control Simulation for "Testing-Based Forward Model Selection" ')

disp(' ')


%Display Start time
disp('---------------------------------------------')
disp(' ')
disp('Simulation start time:')
disp(datetime('now'))


%Simulation Parameters
sim_max=1000;  %Total number of replications for each simulation
sim_id=0;    %Simulation ID number
sim_id_max=16; %Total number of simulations
rng(1)   %Random number generator seed


%Initialize



beta_Forward_I=zeros(sim_max,1);
lower_Forward_I=zeros(sim_max,1);
upper_Forward_I=zeros(sim_max,1); 

beta_Forward_II=zeros(sim_max,1);
lower_Forward_II=zeros(sim_max,1);
upper_Forward_II=zeros(sim_max,1); 


beta_Forward_III=zeros(sim_max,1);
lower_Forward_III=zeros(sim_max,1);
upper_Forward_III=zeros(sim_max,1); 

beta_Forward_IV=zeros(sim_max,1);
lower_Forward_IV=zeros(sim_max,1);
upper_Forward_IV=zeros(sim_max,1); 

beta_Lasso=zeros(sim_max,1);
lower_Lasso=zeros(sim_max,1);
upper_Lasso=zeros(sim_max,1); 

beta_Oracle=zeros(sim_max,1);
lower_Oracle=zeros(sim_max,1);
upper_Oracle=zeros(sim_max,1); 

beta_Lasso_CV=zeros(sim_max,1);
lower_Lasso_CV=zeros(sim_max,1);
upper_Lasso_CV=zeros(sim_max,1); 


    Bias_Forward_I=zeros(sim_id_max,1);
    Bias_Forward_II=zeros(sim_id_max,1);
    Bias_Forward_III=zeros(sim_id_max,1);
    Bias_Forward_IV=zeros(sim_id_max,1);
    Bias_Lasso=zeros(sim_id_max,1);
    Bias_Lasso_CV=zeros(sim_id_max,1);
    Bias_Oracle=zeros(sim_id_max,1);
    
    StDev_Forward_I=zeros(sim_id_max,1);
    StDev_Forward_II=zeros(sim_id_max,1);
    StDev_Forward_III=zeros(sim_id_max,1);
    StDev_Forward_IV=zeros(sim_id_max,1);
    StDev_Lasso=zeros(sim_id_max,1);
    StDev_Lasso_CV=zeros(sim_id_max,1);
    StDev_Oracle=zeros(sim_id_max,1);
    
    RMSE_Forward_I=zeros(sim_id_max,1);
    RMSE_Forward_II=zeros(sim_id_max,1);
    RMSE_Forward_III=zeros(sim_id_max,1);
    RMSE_Forward_IV=zeros(sim_id_max,1);
    RMSE_Lasso=zeros(sim_id_max,1);
    RMSE_Lasso_CV=zeros(sim_id_max,1);
    RMSE_Oracle=zeros(sim_id_max,1);
    
    Coverage_Forward_I=zeros(sim_id_max,1);
    Coverage_Forward_II=zeros(sim_id_max,1);
    Coverage_Forward_III=zeros(sim_id_max,1);
    Coverage_Forward_IV=zeros(sim_id_max,1);
    Coverage_Lasso=zeros(sim_id_max,1);
    Coverage_Lasso_CV=zeros(sim_id_max,1);
    Coverage_Oracle=zeros(sim_id_max,1);
    
    Length_Forward_I=zeros(sim_id_max,1);
    Length_Forward_II=zeros(sim_id_max,1);
    Length_Forward_III=zeros(sim_id_max,1);
    Length_Forward_IV=zeros(sim_id_max,1);
    Length_Lasso=zeros(sim_id_max,1);
    Length_Lasso_CV=zeros(sim_id_max,1);
    Length_Oracle=zeros(sim_id_max,1);

  if print_times == 1, disp(['Inititialization  complete: ',num2str(toc)]),end 

    
%Define Loop through the different simulation designs defined in paper
for cp = 2
for s = 6 
for b = [-.5,.5]
for heteroskedastic = [0,1] 
for n=[100,500]
       
%Problem Parameters 
p=n*cp;
alpha=.05;
c_tau=1.01;
thetaB1 = [b.^(0:(s-1))';zeros(p-s,1)]; 
thetaB2 = sin((1:p))';thetaB2((s+1):p)=0; 
sim_id=sim_id+1;
beta=1;


%Loop through simulation replications
for nsim = 1:sim_max

    %disp(num2str(nsim))  
    %if mod(nsim,10)==0, disp(num2str(nsim)),end
    
    %Generate Data - Control Selection
        T = chol (toeplitz (.5.^(0:(p-1) )  ));
        z= randn(n,p)*T;
        if heteroskedastic == 0; v=.5*randn(n,1); e=.5*randn(n,1);
        elseif heteroskedastic == 1, v=.5*randn(n,1).*(exp(.5*z*(.75.^((p-1):(-1):0)')));
            e=.5*randn(n,1).*(exp(.5*z*(.75.^((p-1):(-1):0)')));
        end
        x = z*thetaB2 + v;
        y=x*beta + z*thetaB1 + e;

                if print_times == 1, disp(['Data generation complete: ',num2str(toc)]), end
        
        
        
    %Estimate
        S_Forward_I_FS=fsel_hetero(x,z,alpha,c_tau,1);
        S_Forward_II_FS=fsel_hetero(x,z,alpha,c_tau,2);
        S_Forward_III_FS=fsel_hetero(x,z,alpha,c_tau,3);
        S_Forward_IV_FS=fsel_hetero(x,z,alpha,c_tau,4);
        S_Lasso_FS=lasso_hetero(x,z,alpha,c_tau);
        S_Lasso_CV_FS=lasso_CV(x,z); 
        
        
        if print_times == 1, disp(['Stage 1 selection complete: ',num2str(toc)]), end
        
        
        S_Forward_I_RF=fsel_hetero(y,z,alpha,c_tau,1);
        S_Forward_II_RF=fsel_hetero(y,z,alpha,c_tau,2);
        S_Forward_III_RF=fsel_hetero(y,z,alpha,c_tau,3);
        S_Forward_IV_RF=fsel_hetero(y,z,alpha,c_tau,4);
        S_Lasso_RF=lasso_hetero(y,z,alpha,c_tau);
        S_Lasso_CV_RF=lasso_CV(y,z);
        
        if print_times == 1, disp(['Stage 2 selection complete: ',num2str(toc)]), end
        
        
        S_Forward_I = union(S_Forward_I_FS,S_Forward_I_RF);
        S_Forward_II = union(S_Forward_II_FS,S_Forward_II_RF);
        S_Forward_III = union(S_Forward_III_FS,S_Forward_III_RF);
        S_Forward_IV = union(S_Forward_IV_FS,S_Forward_IV_RF);
        S_Lasso = union(S_Lasso_FS,S_Lasso_RF);
        S_Lasso_CV = union(S_Lasso_CV_FS,S_Lasso_CV_RF);
        
        S_Oracle = 1:s;
        
        [beta_Forward_I(nsim), lower_Forward_I(nsim), upper_Forward_I(nsim)] = Controls_estimate(y,x,z(:,S_Forward_I));
        [beta_Forward_II(nsim), lower_Forward_II(nsim), upper_Forward_II(nsim)] = Controls_estimate(y,x,z(:,S_Forward_II));
        [beta_Forward_III(nsim), lower_Forward_III(nsim), upper_Forward_III(nsim)] = Controls_estimate(y,x,z(:,S_Forward_III));
        [beta_Forward_IV(nsim), lower_Forward_IV(nsim), upper_Forward_IV(nsim)] = Controls_estimate(y,x,z(:,S_Forward_IV));
        [beta_Lasso(nsim), lower_Lasso(nsim), upper_Lasso(nsim)] = Controls_estimate(y,x,z(:,S_Lasso));
        [beta_Lasso_CV(nsim), lower_Lasso_CV(nsim), upper_Lasso_CV(nsim)] = Controls_estimate(y,x,z(:,S_Lasso_CV));
        [beta_Oracle(nsim), lower_Oracle(nsim), upper_Oracle(nsim)] = Controls_estimate(y,x,z(:,S_Oracle));
        

        if print_times == 1, disp(['Post-selection estimation complete: ',num2str(toc)]),end


end  

    %Record Results
       
    Bias_Forward_I(sim_id) = mean(beta - beta_Forward_I);
    Bias_Forward_II(sim_id) = mean(beta - beta_Forward_II);
    Bias_Forward_III(sim_id) = mean(beta - beta_Forward_III);
    Bias_Forward_IV(sim_id) = mean(beta - beta_Forward_IV);
    Bias_Lasso(sim_id) = mean(beta - beta_Lasso);
    Bias_Lasso_CV(sim_id) = mean(beta - beta_Lasso_CV);
    Bias_Oracle(sim_id) = mean(beta - beta_Oracle);
    
    StDev_Forward_I(sim_id) = std(beta - beta_Forward_I);
    StDev_Forward_II(sim_id) = std(beta - beta_Forward_II);
    StDev_Forward_III(sim_id) = std(beta - beta_Forward_III);
    StDev_Forward_IV(sim_id) = std(beta - beta_Forward_IV);
    StDev_Lasso(sim_id) = std(beta - beta_Lasso);
    StDev_Lasso_CV(sim_id) = std(beta - beta_Lasso_CV);
    StDev_Oracle(sim_id) = std(beta - beta_Oracle);
    
    RMSE_Forward_I(sim_id) = mean((beta - beta_Forward_I).^2);
    RMSE_Forward_II(sim_id) = mean((beta - beta_Forward_II).^2);
    RMSE_Forward_III(sim_id) = mean((beta - beta_Forward_III).^2);
    RMSE_Forward_IV(sim_id) = mean((beta - beta_Forward_IV).^2);
    RMSE_Lasso(sim_id) = mean((beta - beta_Lasso).^2);
    RMSE_Lasso_CV(sim_id) = mean((beta - beta_Lasso_CV).^2);
    RMSE_Oracle(sim_id) = mean((beta - beta_Oracle).^2);
    
    Coverage_Forward_I(sim_id) = mean(beta < upper_Forward_I & beta > lower_Forward_I);
    Coverage_Forward_II(sim_id) = mean(beta < upper_Forward_II & beta > lower_Forward_II);
    Coverage_Forward_III(sim_id) = mean(beta < upper_Forward_III & beta > lower_Forward_III);
    Coverage_Forward_IV(sim_id) = mean(beta < upper_Forward_IV & beta > lower_Forward_IV);
    Coverage_Lasso(sim_id) = mean(beta < upper_Lasso & beta > lower_Lasso);
    Coverage_Lasso_CV(sim_id) = mean(beta < upper_Lasso_CV & beta > lower_Lasso_CV);
    Coverage_Oracle(sim_id) = mean(beta < upper_Oracle & beta > lower_Oracle);
    
    Length_Forward_I(sim_id) = mean(upper_Forward_I - lower_Forward_I);
    Length_Forward_II(sim_id) = mean(upper_Forward_II -  lower_Forward_II);
    Length_Forward_III(sim_id) = mean(upper_Forward_III - lower_Forward_III);
    Length_Forward_IV(sim_id) = mean(upper_Forward_IV -  lower_Forward_IV);
    Length_Lasso(sim_id) = mean(upper_Lasso - lower_Lasso);
    Length_Lasso_CV(sim_id) = mean(upper_Lasso_CV -  lower_Lasso_CV);
    Length_Oracle(sim_id) = mean(upper_Oracle -  lower_Oracle);

%Display Results

disp('---------------------------------------------')
disp(' ')
if heteroskedastic ==1, disp(['Sim# ',num2str(sim_id),'    heteroskedastic, b = ',num2str(b),', n = ',num2str(n), ', p = ',num2str(p),', s0 = ',num2str(s),', reps = ',num2str(sim_max) ])
else disp(['Sim# ',num2str(sim_id),'    homoskedastic, b = ',num2str(b),', n = ',num2str(n), ', p = ',num2str(p),', s0 = ',num2str(s),', reps = ',num2str(sim_max)])
end
disp(' ')
disp(['Forward I:     ','Bias:  ',num2str((Bias_Forward_I(sim_id)), '%1.3f \t'  ),'  StDev:  ',num2str((StDev_Forward_I(sim_id)), '%1.3f \t' ),'  Length:  ',num2str((Length_Forward_I(sim_id)), '%1.3f \t' ),'  Coverage:  ',num2str((Coverage_Forward_I(sim_id)), '%1.3f \t')])
disp(['Forward II:    ','Bias:  ',num2str((Bias_Forward_II(sim_id)), '%1.3f \t' ),'  StDev:  ',num2str((StDev_Forward_II(sim_id)), '%1.3f \t'),'  Length:  ',num2str((Length_Forward_II(sim_id)), '%1.3f \t'),'  Coverage:  ',num2str((Coverage_Forward_II(sim_id)), '%1.3f \t')])
disp(['Forward III:   ','Bias:  ',num2str((Bias_Forward_III(sim_id)), '%1.3f \t'  ),'  StDev:  ',num2str((StDev_Forward_III(sim_id)), '%1.3f \t' ),'  Length:  ',num2str((Length_Forward_III(sim_id)), '%1.3f \t' ),'  Coverage:  ',num2str((Coverage_Forward_III(sim_id)), '%1.3f \t')])
disp(['Forward IV:    ','Bias:  ',num2str((Bias_Forward_IV(sim_id)), '%1.3f \t' ),'  StDev:  ',num2str((StDev_Forward_IV(sim_id)), '%1.3f \t'),'  Length:  ',num2str((Length_Forward_IV(sim_id)), '%1.3f \t'),'  Coverage:  ',num2str((Coverage_Forward_IV(sim_id)), '%1.3f \t')])
disp(['Post-Lasso:    ','Bias:  ',num2str((Bias_Lasso(sim_id)), '%1.3f \t'      ),'  StDev:  ',num2str((StDev_Lasso(sim_id)), '%1.3f \t'     ),'  Length:  ',num2str((Length_Lasso(sim_id)), '%1.3f \t'     ),'  Coverage:  ',num2str((Coverage_Lasso(sim_id)), '%1.3f \t')])
disp(['Lasso-CV:      ','Bias:  ',num2str((Bias_Lasso_CV(sim_id)), '%1.3f \t'   ),'  StDev:  ',num2str((StDev_Lasso_CV(sim_id)), '%1.3f \t'  ),'  Length:  ',num2str((Length_Lasso_CV(sim_id)), '%1.3f \t'  ),'  Coverage:  ',num2str((Coverage_Lasso_CV(sim_id)), '%1.3f \t')])
disp(['Oracle:        ','Bias:  ',num2str((Bias_Oracle(sim_id)), '%1.3f \t'     ),'  StDev:  ',num2str((StDev_Oracle(sim_id)), '%1.3f \t'    ),'  Length:  ',num2str((Length_Oracle(sim_id)), '%1.3f \t'    ),'  Coverage:  ',num2str((Coverage_Oracle(sim_id)), '%1.3f \t')])
disp(' ')

end


end
end
end
end

%{
%Save results
save Simulation_FSel2020_Controls_Results

%Print Simulation Table for LaTex

formatSpec_Forward_I =   'TBFMS I          & %4.3f & %4.3f & % 4.3f & %4.3f && %4.3f & %4.3f & % 4.3f & %4.3f \\\\ \n';
formatSpec_Forward_II =  'TBFMS II         & %4.3f & %4.3f & % 4.3f & %4.3f && %4.3f & %4.3f & % 4.3f & %4.3f \\\\ \n';
formatSpec_Forward_III = 'TBFMS III        & %4.3f & %4.3f & % 4.3f & %4.3f && %4.3f & %4.3f & % 4.3f & %4.3f \\\\ \n';
formatSpec_Forward_IV =  'TBFMS IIV        & %4.3f & %4.3f & % 4.3f & %4.3f && %4.3f & %4.3f & % 4.3f & %4.3f \\\\ \n';
formatSpec_Lasso =       'Post-Het-Lasso   & %4.3f & %4.3f & % 4.3f & %4.3f && %4.3f & %4.3f & % 4.3f & %4.3f \\\\ \n';
formatSpec_Lasso_CV =    'Lasso CV         & %4.3f & %4.3f & % 4.3f & %4.3f && %4.3f & %4.3f & % 4.3f & %4.3f \\\\ \n';
formatSpec_Oracle =      'Oracle           & %4.3f & %4.3f & % 4.3f & %4.3f && %4.3f & %4.3f & % 4.3f & %4.3f \\\\ \n';

fid = fopen('Simulation_FSel2020_Controls_Results_Table.txt','w');


fprintf(fid,'\\begin{table}[H] \\caption \n ');
fprintf(fid,'{Model \\textbf{\\em B} Simulation Results: Control Selection in Linear Model   } \n');
fprintf(fid,'\\begin{tabular*}{\\textwidth}{p{2.0cm} p{.9cm}  p{.9cm} p{.9cm} p{.9cm} p{.6cm} p{.9cm}  p{.9cm}  p{.9cm} p{.9cm} } \n');
fprintf(fid,'\\hline          \\hline                                                                  \\\\ \n');
fprintf(fid,'&			&  \\multicolumn{2}{c}{$n=100$}	&		& & 		& \\multicolumn{2}{c}{$n=500$}		&		\\\\   \\cline{2-5} \\cline{7-10} \\\\  \n');
fprintf(fid,'&	\\textcolor{white}{\\Big |}  Bias		& StDev		&	Length	&	Cover	& & Bias		& StDev		&	Length	&	Cover  \\\\   \n');

for sim_id = 1:2:7
    
    if     sim_id == 1,  fprintf(fid,'  \\\\  \\cline{2-10}     & \\multicolumn{9}{c}{A. Homoskedastic,   $s_0 = 6$, Alternating Sign  }\\\\ \\cline{2-10}  \\\\ \n ');
    elseif sim_id == 3,  fprintf(fid,' \\\\   \\cline{2-10}     & \\multicolumn{9}{c}{B. Heteroskedastic, $s_0 = 6$, Alternating Sign  }\\\\ \\cline{2-10}  \\\\ \n ');
    elseif sim_id == 5,  fprintf(fid,' \\\\   \\cline{2-10}     & \\multicolumn{9}{c}{C. Homoskedastic, $s_0 = 6$, Same Sign  }\\\\ \\cline{2-10} \\\\  \n ');
    elseif sim_id == 7,  fprintf(fid,'  \\\\  \\cline{2-10}     & \\multicolumn{9}{c}{D. Heteroskedastic, $s_0 = 6$, Same Sign  }\\\\ \\cline{2-10} \\\\  \n ');
    elseif sim_id == 9,  fprintf(fid,' \\\\   \\cline{2-10}     & \\multicolumn{9}{c}{E. Homoskedastic, $s_0 = 24$, Alternating Sign }\\\\ \\cline{2-10}  \\\\ \n ');
    elseif sim_id == 11, fprintf(fid,' \\\\   \\cline{2-10}     & \\multicolumn{9}{c}{F. Heteroskedastic, $s_0 = 24$, Alternating Sign  }\\\\ \\cline{2-10} \\\\  \n ');
    elseif sim_id == 13, fprintf(fid,' \\\\   \\cline{2-10}     & \\multicolumn{9}{c}{G. Homoskedastic, $s_0 = 24$, Same Sign  }\\\\ \\cline{2-10}  \\\\ \n ');
    elseif sim_id == 15, fprintf(fid,' \\\\  \\cline{2-10}     & \\multicolumn{9}{c}{H. Heteroskedastic, $s_0 = 24$, Same Sign  }\\\\ \\cline{2-10}  \\\\ \n ');
    end
    
A1 = [Bias_Forward_I(sim_id), StDev_Forward_I(sim_id),Length_Forward_I(sim_id),Coverage_Forward_I(sim_id)]; 
A2 = [Bias_Forward_I(sim_id+1), StDev_Forward_I(sim_id+1),Length_Forward_I(sim_id+1),Coverage_Forward_I(sim_id+1)];    
fprintf(fid,formatSpec_Forward_I,[A1,A2]);
B1 = [Bias_Forward_II(sim_id), StDev_Forward_II(sim_id),Length_Forward_II(sim_id),Coverage_Forward_II(sim_id)]; 
B2 = [Bias_Forward_II(sim_id+1), StDev_Forward_II(sim_id+1),Length_Forward_II(sim_id+1),Coverage_Forward_II(sim_id+1)];    
fprintf(fid,formatSpec_Forward_II,[B1,B2]);
BB1 = [Bias_Forward_III(sim_id), StDev_Forward_III(sim_id),Length_Forward_III(sim_id),Coverage_Forward_III(sim_id)]; 
BB2 = [Bias_Forward_III(sim_id+1), StDev_Forward_III(sim_id+1),Length_Forward_III(sim_id+1),Coverage_Forward_III(sim_id+1)];    
fprintf(fid,formatSpec_Forward_III,[BB1,BB2]);
BBB1 = [Bias_Forward_IV(sim_id), StDev_Forward_IV(sim_id),Length_Forward_IV(sim_id),Coverage_Forward_IV(sim_id)]; 
BBB2 = [Bias_Forward_IV(sim_id+1), StDev_Forward_IV(sim_id+1),Length_Forward_IV(sim_id+1),Coverage_Forward_IV(sim_id+1)];    
fprintf(fid,formatSpec_Forward_IV,[BBB1,BBB2]);
C1 = [Bias_Lasso(sim_id), StDev_Lasso(sim_id),Length_Lasso(sim_id),Coverage_Lasso(sim_id)]; 
C2 = [Bias_Lasso(sim_id+1), StDev_Lasso(sim_id+1),Length_Lasso(sim_id+1),Coverage_Lasso(sim_id+1)];    
fprintf(fid,formatSpec_Lasso,[C1,C2]);
D1 = [Bias_Lasso_CV(sim_id), StDev_Lasso_CV(sim_id),Length_Lasso_CV(sim_id),Coverage_Lasso_CV(sim_id)]; 
D2 = [Bias_Lasso_CV(sim_id+1), StDev_Lasso_CV(sim_id+1),Length_Lasso_CV(sim_id+1),Coverage_Lasso_CV(sim_id+1)];    
fprintf(fid,formatSpec_Lasso_CV,[D1,D2]);
E1 = [Bias_Oracle(sim_id), StDev_Oracle(sim_id),Length_Oracle(sim_id),Coverage_Oracle(sim_id)]; 
E2 = [Bias_Oracle(sim_id+1), StDev_Oracle(sim_id+1),Length_Oracle(sim_id+1),Coverage_Oracle(sim_id+1)];    
fprintf(fid,formatSpec_Oracle,[E1,E2]);
end
fprintf(fid,' \\\\ \\cline{1-10}	\n ');
fprintf(fid,'\\end{tabular*}	\n ');																								
fprintf(fid,'\\end{table}	\n ');	
fclose(fid);



%}



%Display End time
disp('---------------------------------------------')
disp(' ')
disp('Simulation end time:')
disp(datetime('now'))
disp( ' ')
disp('Total run time:')
disp(num2str(toc))
disp('---------------------------------------------')
disp(' ')

%Save Results

%Save results
%save Simulation_FSel_Controls_Results




%%% Auxiliary Functions - IV estimates
function [betahat,lb,ub]=Controls_estimate(y,x,z)
n=length(y); k=size(z,2)+1;  M = eye(n,n); if ~isempty(z), M = eye(n,n) - z*inv(z'*z)*z';end %#ok
Mx = M*x;
%My = M*y;

betahatall=[x,z]\y; betahat = betahatall(1);
H = [x,z]*inv([x,z]'*[x,z])*[x,z]';
eh = (y - [x,z]*betahatall)./(1 - diag(H));

V = inv(Mx'*Mx)*sum(Mx.^2.*eh.^2)*inv(Mx'*Mx); %#ok
se1 = sqrt(V(1,1));
lb = betahat - 1.96*se1; ub = betahat + 1.96*se1;


