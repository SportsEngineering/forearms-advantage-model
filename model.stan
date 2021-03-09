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
  real diff_illegal = mu[5] - mean({mu[2], mu[3]});  // UCI illegal - UCI legals
  real diff_legal = mu[2] - mu[3];  // bracket aero - drop aero
}
