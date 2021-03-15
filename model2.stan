data {
  int<lower=0> N;
  real<lower=0> CdA[N];
  int<lower=0> Position[N];
  int<lower=0> N_Position;

}

parameters {
  real<lower=0> rider;
  real<lower=0> sigma;
  real effect[N_Position];
  real<lower=0> effect_sigma;
}

model {
  for (i in 1:N_Position) {
    effect[i] ~ normal(0, effect_sigma);
  }

  for (i in 1:N) {
    CdA[i] ~ normal(rider + effect[Position[i]], sigma);
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
