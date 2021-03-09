data {
  int<lower=0> N;
  real<lower=0> CdA[N];
  int<lower=0> Position[N];
  int<lower=0> N_Position;
}

parameters {
  real<lower=0> mu[N_Position];
  real<lower=0> sigma;
}

model {
  for (i in 1:N) {
    CdA[i] ~ normal(mu[Position[i]], sigma);
  }
}

generated quantities {
  real diff_illegal = mu[5] - mean({mu[2], mu[3]});  // UCI illegal - UCI legals
  real diff_legal = mu[2] - mu[3];  // bracket aero - drop aero
}
