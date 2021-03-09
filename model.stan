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
  real baseline = mu[2];
  real diff_drop_aero = mu[3] - baseline;  // Drop-aero - Bracket-aero
  real diff_forearms = mu[5] - baseline;  // Forearms - Bracket-aero
}
