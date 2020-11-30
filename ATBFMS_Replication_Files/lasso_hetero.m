
function [S_lasso,theta_lasso,yhat_lasso,S_post, theta_post, yhat_post]=lasso_hetero(y,x,alpha,c_tau); %#ok

%Lasso implementation for "heteroskedastic Lasso penalty loadings"
%Implementation based on Belloni, Chen, Chernozhukov, Hansen (2012)
%Initial penalty loadings are based on estimated regression residuals after
%partialling out 5 covariates most marginally correlated with y

%Initialize
[n,p]=size(x);
l=zeros(p,1);
x=zscore(x);
y=zscore(y);
Z=zeros(n,p);


    %Penalty Loadings
    R=corr(x,y);
    [~,maxR]=sort(abs(R),'descend');
    x_maxR = x(:,maxR(1:5));
    b_maxR=x_maxR\y;
    e = y-x_maxR*b_maxR;
    for j = 1:p
       l_temp = sum( x(:,j).^2.*e.^2 /n )^.5;
       l(j)=l_temp(1);
       Z(:,j) = x(:,j)/l(j);
    end
    
    %Estimate Lasso
    lambda = 2*c_tau*sqrt(1/n)*norminv(1-alpha/p);
    theta_lasso = lasso(Z, y , 'Lambda',lambda);
    S_lasso = abs(theta_lasso) > 0.0001;
    yhat_lasso = x*theta_lasso;
    S_post = S_lasso;
    theta_post = x(:,S_lasso)\y;
    yhat_post = x(:,S_lasso)*theta_post;
    e=y-Z(:,S_lasso)*theta_post;

    