data {
  int<lower=0> N;
  real<lower=0> Y[N];
  int<lower=0> POSITION[N];
  int<lower=0> P;
}

parameters {
  real<lower=0> mu[P];
  real<lower=0> sigma;
  real<lower=0> rider_mu;
  real<lower=0> rider_sigma;
}

model {
  for (p in 1:P) {
    mu[p] ~ normal(rider_mu, rider_sigma);
  }
  for (n in 1:N) {
    int position = POSITION[n];
    Y[n] ~ normal(mu[position], sigma);
  }
}

generated quantities {
  real base_line = mean({mu[2], mu[3]});
  real advantage = mu[5] - base_line;  // advantage forearms-on-bar
  real diff_legal = mu[3] - mu[2];  // drop aero - bracket aero
}