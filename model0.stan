data {
  int<lower=0> N;      // number of CdA
  real<lower=0> y[N];  // CdA
  int<lower=0> position[N];
  int<lower=0> P;      // number of position
}

parameters {
  real<lower=0> mu[P];
  real<lower=0> sigma[P];
}

model {
  for (i in 1:N) {
    int p = position[i];
    y[i] ~ normal(mu[p], sigma[p]);
  }
}

generated quantities {
  real cda_neutral = mu[1];
  real cda_bracket_aero = mu[2];
  real cda_drop_aero = mu[3];
  real cda_upright = mu[4];
  real cda_forearms = mu[5];

  real baseline = cda_bracket_aero;
  real advantage_drop_aero = baseline - cda_drop_aero;
  real advantage_forearms = baseline - cda_forearms;
}
