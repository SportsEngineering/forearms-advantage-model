library(rstan)
library(bayesplot)


df <- read.csv("data.csv", stringsAsFactors=FALSE)
positions <- c("Newtral", "Bracket-aero", "Drop-aero", "Upright", "Forearms")
df$Position <- factor(df$Position, levels=positions)
model_data <- list(
  Y=df$CdA, N=length(df$CdA),
  POSITION=as.integer(df$Position), P=length(unique(df$Position))
)

options(mc.cores = 2)
fit <- stan("model.stan", data=model_data, iter=50000, warmup=10000)

names(positions) <- c('mu[1]', 'mu[2]', 'mu[3]', 'mu[4]', 'mu[5]')
p <- mcmc_areas(fit,
                pars = c("mu[4]", "mu[1]", "mu[3]", "mu[2]", "mu[5]"),
                prob = 0.95)
p <- p + labs(title="Estimated aerodynamic drag coefficient") +
  scale_y_discrete(labels=positions) +
  xlab("CdA")

cda_annotate <- function (fit, value, i) {
  s <- summary(fit)$summary
  mean_ <- s[value, "mean"]
  lower_ <- s[value, "2.5%"]
  upper_ <- s[value, "97.5%"]
  label = paste('mean=', round(mean_, 2),
                '\n95%CI[', round(lower_, 2), ', ', round(upper_, 2), ']',
                sep='')
  annotate("text", x=mean_ + 0.018, y=i, hjust=0, vjust=-1.4, label=label)
}

p + cda_annotate(fit, 'mu[5]', 5) +
  cda_annotate(fit, 'mu[2]', 4) +
  cda_annotate(fit, 'mu[3]', 3) +
  cda_annotate(fit, 'mu[1]', 2) +
  cda_annotate(fit, 'mu[4]', 1)
ggsave("Figure1.png")  # Estimated CdA per position


diffp <- mcmc_areas(fit, pars=c('diff_legal', 'advantage'), prob=0.95)
diffp <- diffp +
  labs(title="Difference between positions",
  subtitle="The difference between UCI Illegal forearms and UCI ligal aero positions.\nand the difference between UCI legal drop and bracket aero positions.") +
  xlab("Difference in CdA") +
  scale_y_discrete(labels=c('diff_legal'='Bracket - Drop', 'advantage'='Forearms'))
diffp + cda_annotate(fit, 'advantage', 2) +
  cda_annotate(fit, 'diff_legal', 1)
ggsave("Figure2.png")


advantage <- extract(fit)$advantage
paste("H1: UCI-Illegal < UCI-Legal is ", sum(ifelse(advantage < 0, 1, 0)) / length(advantage))
diff_legal <- extract(fit)$diff_legal
paste("H2: Bracket-aero < Drop-aero is ", sum(ifelse(diff_legal < 0, 1, 0)) / length(diff_legal))
