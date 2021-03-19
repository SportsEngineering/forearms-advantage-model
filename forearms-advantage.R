library(rstan)
library(bayesplot)
library(bridgesampling)


df <- read.csv("data.csv", stringsAsFactors=FALSE)
positions <- c("Neutral", "Bracket-aero", "Drop-aero", "Upright", "Forearms")
df$Position <- factor(df$Position, levels=positions)
model_data <- list(
  y=df$CdA, N=length(df$CdA),
  position=as.integer(df$Position), P=length(unique(df$Position))
)

options(mc.cores = parallel::detectCores())
# separate mean and variance for each position model
fit0 <- stan("model0.stan", data=model_data, seed=1, iter=10000, warmup=1000, chains=4,
             control=list(adapt_delta=0.98))
# common variance model
fit1 <- stan("model1.stan", data=model_data, seed=1, iter=10000, warmup=1000, chains=4)
# Hierarchical model of riders averages and position-specific effects
fit2 <- stan("model2.stan", data=model_data, seed=1, iter=10000, warmup=1000, chains=4,
             control=list(adapt_delta=0.95))

h0 <- bridge_sampler(fit0, silent=TRUE)
h1 <- bridge_sampler(fit1, silent=TRUE)
h2 <- bridge_sampler(fit2, silent=TRUE)


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

names(positions) <- c('cda_neutral', 'cda_bracket_aero', 'cda_drop_aero', 'cda_upright', 'cda_forearms')
p <- mcmc_areas(fit2,
                pars=c('cda_upright', 'cda_neutral', 'cda_drop_aero', 'cda_bracket_aero', 'cda_forearms'),
                prob = 0.95) +
  labs(title="Estimated aerodynamic drag coefficient") +
  scale_y_discrete(labels=positions) +
  xlab("CdA")



p <- p + cda_annotate(fit2, 'cda_forearms', 5) +
  cda_annotate(fit2, 'cda_bracket_aero', 4) +
  cda_annotate(fit2, 'cda_drop_aero', 3) +
  cda_annotate(fit2, 'cda_neutral', 2) +
  cda_annotate(fit2, 'cda_upright', 1)
plot(p)
ggsave("figure1.png")  # Estimated CdA per position


diffp <- mcmc_areas(fit2, pars=c('advantage_drop_aero', 'advantage_forearms'), prob=0.95)
diffp <- diffp +
  labs(title="Aerodynamic advantage of Forearms-on-bars aero position",
       subtitle="The advantage of the UCI-illegal 'Forearms' position is compared with\nthe 'Bracket-aero'. and compare with UCI legal 'Drop-aero' position.") +
  xlab("CdA difference from 'Bracket-aero'") +
  scale_y_discrete(labels=c(
    'advantage_drop_aero'='Drop-aero',
    'advantage_forearms'='Forearms'))
x_illegal = summary(fit2)$summary['advantage_forearms', 'mean']
x_legal = summary(fit2)$summary['advantage_drop_aero', 'mean']
diffp <- diffp + cda_annotate(fit2, 'advantage_forearms', 2) +
  cda_annotate(fit2, 'advantage_drop_aero', 1) +

  annotate("segment", x=0, y=1.95, xend=x_illegal, yend=1.95,
           size=0.5, arrow=arrow(length=unit(0.015, 'npc'))) +
  annotate("text", x=x_illegal + 0.005, y=1.95, hjust="left", label="'Forearms' is faster") +

  annotate("segment", x=0, y=0.95, xend=x_legal, yend=0.95,
           size=0.5, arrow=arrow(length=unit(0.015, 'npc'))) +
  annotate("text", x=x_legal - 0.005, y=0.95, hjust="right", label="'Drop-aero' may be slower?")

plot(diffp)
ggsave("figure2.png")


print(fit0, digits_summary = 3)
print(fit1, digits_summary = 3)
print(fit2, digits_summary = 3)
bayes_factor(h1, h0)
bayes_factor(h2, h0)
bayes_factor(h2, h1)

advantage_drop_aero <- extract(fit2)$advantage_drop_aero
advantage_forearms <- extract(fit2)$advantage_forearms
paste("H1: Advantage Bracket-aero > 0:",
      round(sum(advantage_drop_aero > 0) / length(advantage_drop_aero), 3))
paste("H2: Advantage Forearms > 0:",
      round(sum(advantage_forearms > 0) / length(advantage_forearms), 3))

TukeyHSD(aov(df$CdA ~ df$Position))