data {
  int<lower=0> N;      // number of CdA
  real<lower=0> y[N];  // CdA
  int<lower=0> position[N];
  int<lower=0> P;      // number of position
}

parameters {
  real<lower=0> rider;
  real<lower=0> sigma;
  real<lower=-1, upper=1> effect[P];
  real<lower=0> effect_sigma;
}

model {
  rider ~ normal(0, 1);
  sigma ~ normal(0, 1);
  effect_sigma ~ normal(0, 1);

  for (i in 1:P) {
    effect[i] ~ normal(0, effect_sigma);
  }
  for (i in 1:N) {
    int p = position[i];
    y[i] ~ normal(rider + effect[p], sigma);
  }
}

generated quantities {
  real cda_neutral = rider + effect[1];
  real cda_bracket_aero = rider + effect[2];
  real cda_drop_aero = rider + effect[3];
  real cda_upright = rider + effect[4];
  real cda_forearms = rider + effect[5];
  
  real baseline = cda_bracket_aero;
  real advantage_drop_aero = baseline - cda_drop_aero;
  real advantage_forearms = baseline - cda_forearms;
}
