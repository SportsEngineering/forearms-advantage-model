data {
  int<lower=0> N;
  real<lower=0> CdA[N];
  int<lower=0> M;
  int<lower=0> GROUP[N];
}

parameters {
  real<lower=0> mu[M];
  real<lower=0> sigma;
  real<lower=0> rider_mu;
  real<lower=0> rider_sigma;
}

model {
  for (m in 1:M) {
    mu[m] ~ normal(rider_mu, rider_sigma);
  }
  for (n in 1:N) {
    CdA[n] ~ normal(mu[GROUP[n]], sigma);
  }
}

generated quantities {
  real base_line = mean({mu[2], mu[3]});
  real diff_illegal = base_line - mu[5];
  real diff_legal = mu[3] - mu[2];  // braket aero - drop aero
}