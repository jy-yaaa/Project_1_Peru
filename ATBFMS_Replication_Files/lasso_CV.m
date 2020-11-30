%Lasso with simple penalty
function [S_lasso,theta_lasso,yhat_lasso,S_post, theta_post, yhat_post]=lasso_CV(y,x); %#ok
    
    
    [theta_lasso,lassoSTATS] =  lasso(x, y , 'CV',10);
    theta_lasso = theta_lasso(:, lassoSTATS.IndexMinMSE);
    S_lasso = abs(theta_lasso) > 0.001;
    yhat_lasso = x*theta_lasso;
    S_post = S_lasso;
    theta_post = x(:,S_lasso)\y;
    yhat_post = x(:,S_lasso)*theta_post;

        