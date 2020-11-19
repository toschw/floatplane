// Following Carpenter et al. 2016 p. 16
data {
  int<lower=0> J; // number of lakes (or groups)
  int<lower=0> y[J]; // number of flights from elodea-invaded sources into lake j
  int<lower=0> n[J]; // number of total flights into lake j (number of trials)
}
parameters {
  real logit_theta[J]; // chance of successful elodea-introduction flight into lake j
  real logit_lambda; // prior mean chance of success
  real<lower=0.0> lambda_sd; // total prior count
}
transformed parameters {
  real<lower=0,upper=1> lambda; // prior mean chance of success
  real<lower=0,upper=1> theta[J]; // chance of successful elodea-introduction flight into lake j
  lambda = inv_logit(logit_lambda);
  for(j in 1:J) {
    theta[j] = inv_logit(logit_theta[j]);
  }
//  real<lower=0> alpha; // prior success count
//  real<lower=0> beta; // prior failure count
//  alpha = lambda * kappa;   //alpha parameter for the prior
//  beta = (1 - lambda) * kappa;  //beta parameter for the prior
}
model {
  logit_lambda ~ normal(0,1); // hyperprior .. uniform (0,1)
  //kappa ~ normal(0, 1); // half-normal on kappa
  lambda_sd ~ student_t(3,0,2);
  //kappa ~ pareto(0.1,1.5); // hyperprior was uniform(0.1,5) for results as of 04/30/20 creating datafit1, pareto(0.1,1.5) creating datafit2, uniform(0,1) in Carpenter et al.
  logit_theta ~ normal(logit_lambda,lambda_sd); // prior for the probability p that lake j is invaded
  y ~ binomial(n,theta); // likelihood for flights
  //Both alpha and beta are transformed parameters and since they are on the right side of the samplinga smapling statement don't require a Jacobian adjustment (Carpenter et al.2016)
}
generated quantities {
  //real<lower=0,upper=1> theta[J] = beta_rng(y + alpha, n - y + beta);
  real<lower=0,upper=1> avg; // avg success
  int<lower=0,upper=1> above_avg[J]; // true if theta[j] > mean(theta), meaning the posterior prob. that a given destination is above-average in terms of the elodea introduction rate
  int<lower=1,upper=J> rnk[J]; // rank of j
  int<lower=0,upper=1> highest[J]; // true if j is highest rank
  avg = mean(theta);
    for (j in 1:J)
    above_avg[j] = (theta[j] > avg);
    for (j in 1:J) {
    rnk[j] = rank(theta,j) + 1;
    highest[j] = rnk[j] == 1;
  }
}
