%%%Forward Selection as described in "Analysis of Testing-Based Forward Model
%%%Selection"
%%%for Heteroskedastic Disturbances
%This function is called in the simulation studies only
%This function calls stepwisefit_hetero

function [S,theta,yhat]=fsel_hetero(y,x,alpha,c_tau,type) 
[n,p]=size(x);



if type == 1
[~,~,~,S]=stepwisefit_hetero(zscore(x),zscore(y),'penter',alpha/p,'premove',.999999,'display','off','SEtype','hetero1','ctau',c_tau);

S=find(S==1);
if isempty(S)
    theta = []; yhat = zeros(n,1);
else
theta = x(:,S)\y;
yhat = x(:,S)*theta;
end



elseif type == 2
[~,~,~,S]=stepwisefit_hetero(x,y,'penter',alpha/p,'premove',.999999,'display','off','SEtype','hetero2');

S=find(S==1);
if isempty(S)
    theta = []; yhat = zeros(n,1);
else
theta = x(:,S)\y;
yhat = x(:,S)*theta;
end



elseif type == 3
[~,~,~,S]=stepwisefit_hetero(x,y,'penter',alpha/p,'premove',.999999,'display','off','SEtype','HeteroFitStreamline');

S=find(S==1);
if isempty(S)
    theta = []; yhat = zeros(n,1);
else
theta = x(:,S)\y;
yhat = x(:,S)*theta;
end



elseif type == 4
[~,~,~,S]=stepwisefit_hetero(x,y,'penter',alpha/p,'premove',.999999,'display','off','SEtype','homo');

S=find(S==1);
if isempty(S)
    theta = []; yhat = zeros(n,1);
else
theta = x(:,S)\y;
yhat = x(:,S)*theta;
end

end
    
    
    
    
    