data {
  int<lower=0> N;
  real<lower=0> y[N];
  int<lower=0> POSITION[N];
  int<lower=0> P;
}

parameters {
  real<lower=0> mu[P];
  real<lower=0> sigma;
}

model {
  for (n in 1:N) {
    int position = POSITION[n];
    y[n] ~ normal(mu[position], sigma);
  }
}

generated quantities {
  real uci_legal = mean({mu[2], mu[3]});
  real uci_illegal = mu[5];

  real diff_illegal = uci_illegal - uci_legal;  // advantage forearms-on-bar
  real diff_legal = mu[2] - mu[3];  // bracket aero - drop aero
}
