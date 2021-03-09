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
  real diff_illegal = mean({mu[2], mu[3]}) - mu[5];  // UCI legals - illegal
  real diff_legal = mu[3] - mu[2];  // drop aero - bracket aero
}
