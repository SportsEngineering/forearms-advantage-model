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
  real cda_neutral = mu[1];
  real cda_bracket_aero = mu[2];
  real cda_drop_aero = mu[3];
  real cda_upright = mu[4];
  real cda_forearms = mu[5];
  
  real baseline = cda_bracket_aero;
  real advantage_drop_aero = baseline - cda_drop_aero;
  real advantage_forearms = baseline - cda_forearms;
}
