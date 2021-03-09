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


diffp <- mcmc_areas(fit, pars=c('diff_drop_aero', 'diff_forearms'), prob=0.95)
diffp <- diffp +
  labs(title="Aerodynamic advantage of Forearms-on-bars aero position",
       subtitle="The advantage of the UCI-illegal 'Forearms' position is compared with\nthe 'Bracket-aero'. and compare with UCI legal 'Drop-aero' position.") +
  xlab("CdA difference from 'Bracket-aero'") +
  scale_y_discrete(labels=c(
    'diff_drop_aero'='Drop-aero',
    'diff_forearms'='Forearms'))
x_illegal = summary(fit)$summary['diff_forearms', 'mean']
x_legal = summary(fit)$summary['diff_drop_aero', 'mean']
diffp <- diffp + cda_annotate(fit, 'diff_forearms', 2) +
  cda_annotate(fit, 'diff_drop_aero', 1) +

  annotate("segment", x=0, y=1.95, xend=x_illegal, yend=1.95,
           size=0.5, arrow=arrow(length=unit(0.015, 'npc'))) +
  annotate("text", x=x_illegal - 0.005, y=1.95, hjust="right", label="'Forearms' is faster") +

  annotate("segment", x=0, y=0.95, xend=x_legal, yend=0.95,
           size=0.5, arrow=arrow(length=unit(0.015, 'npc'))) +
  annotate("text", x=x_legal + 0.005, y=0.95, hjust="left", label="'Drop-aero' may be slower")

plot(diffp)
ggsave("figure2.png")


TukeyHSD(aov(df$CdA ~ df$Position))

print(fit)

diff_drop_aero <- extract(fit)$diff_drop_aero
diff_forearms <- extract(fit)$diff_forearms
paste("H1: Drop-aero - Bracket-aero < 0",
      sum(diff_drop_aero < 0) / length(diff_drop_aero))
paste("H2: Forearms - Bracket-aero < 0",
      sum(diff_forearms < 0) / length(diff_forearms))
