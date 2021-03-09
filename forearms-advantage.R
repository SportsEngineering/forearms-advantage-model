library(rstan)
library(bayesplot)


df <- read.csv("data.csv", stringsAsFactors=FALSE)
positions <- c("Neutral", "Bracket-aero", "Drop-aero", "Upright", "Forearms")
df$Position <- factor(df$Position, levels=positions)
model_data <- list(
  CdA=df$CdA, N=length(df$CdA),
  Position=as.integer(df$Position), N_Position=length(unique(df$Position))
)
fit <- stan("model.stan", data=model_data, seed=1, iter=150000, warmup=10000, chains=4)

names(positions) <- c('mu[1]', 'mu[2]', 'mu[3]', 'mu[4]', 'mu[5]')
p <- mcmc_areas(fit, pars=c("mu[4]", "mu[1]", "mu[3]", "mu[2]", "mu[5]"), prob = 0.95) +
  labs(title="Estimated aerodynamic drag coefficient") +
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

p <- p + cda_annotate(fit, 'mu[5]', 5) +
  cda_annotate(fit, 'mu[2]', 4) +
  cda_annotate(fit, 'mu[3]', 3) +
  cda_annotate(fit, 'mu[1]', 2) +
  cda_annotate(fit, 'mu[4]', 1)
plot(p)
ggsave("figure1.png")  # Estimated CdA per position


diffp <- mcmc_areas(fit, pars=c('diff_illegal', 'diff_legal'), prob=0.95)
diffp <- diffp +
  labs(title="CdA advantage between positions",
       subtitle="The difference between 'Bracket-aero' and 'Drop-aero' positions.\nand the difference between 'Bracket-aero' and 'Forearms'.") +
  xlab("Advantage in CdA") +
  scale_y_discrete(labels=c(
    'diff_legal'='Bracket-aero - Drop-aero',
    'diff_illegal'='Bracket-aero - Forearms'))
diffp <- diffp + cda_annotate(fit, 'diff_illegal', 1) +
  cda_annotate(fit, 'diff_legal', 2) +
  annotate("segment", x=0, y=0.9, xend=0.048, yend=0.9,
           size=0.5, arrow=arrow(length=unit(0.015, 'npc'))) +
  annotate("text", x=0.048 + 0.005, y=0.9, hjust="left", label="'Forearms' is faster") +
  annotate("segment", x=0, y=1.9, xend=-0.0076, yend=1.9,
           size=0.5, arrow=arrow(length=unit(0.015, 'npc'))) +
  annotate("text", x=-0.0076 - 0.005, y=1.9, hjust="right", label="'Drop-aero' may be slower?")

plot(diffp)
ggsave("figure2.png")


TukeyHSD(aov(df$CdA ~ df$Position))

print(fit)

diff_legal <- extract(fit)$diff_legal
diff_illegal <- extract(fit)$diff_illegal
paste("H1: Bracket-aero > Drop-aero is",
      sum(diff_legal > 0) / length(diff_legal))
paste("H2: Forearms > Bracket-aero is",
      sum(diff_illegal > 0) / length(diff_illegal))
