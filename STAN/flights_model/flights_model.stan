// Following Carpenter et al. 2016 p. 16
data {
  int<lower=0> J; // number of lakes
  int<lower=0> y[J]; // number of flights from elodea-infested sources into lake j
  int<lower=0> n[J]; // number of total flights into lake j (number of trials)
}
parameters {
  real<lower=0,upper=1> theta[J]; // chances of success
  real<lower=0,upper=1> lambda; // prior mean chance of success
  real<lower=0.1> kappa; // prior count
}
transformed parameters {
  real<lower=0> alpha; // prior success count
  real<lower=0> beta; // prior failure count
  alpha = lambda* kappa;   //alpha parameter for the prior
  beta =   (1 - lambda)* kappa;  //beta parameter for the prior
}
model {
  lambda ~ uniform(0,1); // hyperprior
  kappa ~ uniform(0.1,5); // hyperprior was ~pareto(0.1,1.5)uniform(0,1) in Carpenter et al.
  theta ~ beta(alpha,beta); // prior for the probability p that lake j is invaded
  y ~ binomial(n,theta); // likelihood for flights
  
}
generated quantities {
  real<lower=0,upper=1> avg; // avg success
  int<lower=0,upper=1> above_avg[J]; // true if j is above avg
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
