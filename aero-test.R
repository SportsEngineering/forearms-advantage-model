library(rstan)
library(bayesplot)

options(mc.cores = 2)
rstan_options(auto_write = TRUE)

setwd("/Users/oyama/src/github.com/SportsEngineering/bayes-aero-test")
p1 <- c(0.351, 0.329, 0.327)  # ブラケットニュートラル
p2 <- c(0.325, 0.306, 0.321)  # ブラケットエアロ
p3 <- c(0.334, 0.308, 0.333)  # 下ハン・エアロ
p4 <- c(0.366, 0.363, 0.356)  # アップライト
p5 <- c(0.277, 0.281, 0.261)  # 肘置き・エアロ
labels <- c(
  "mu[5]" = "①エアロポジション",
  "mu[2]" = "②ブラケット・エアロ",
  "mu[3]" = "③ドロップ・エアロ", 
  "mu[1]" = "④ブラケット・ニュートラル" ,
  "mu[4]" = "⑤アップライト")
cda <- c(0.351, 0.329, 0.327, 0.325, 0.306, 0.321, 0.334, 0.308, 0.333, 0.366, 0.363, 0.356, 0.277, 0.281, 0.261)
group <- c(1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5)
data <- list(CdA=cda, N=length(cda),
             GROUP=group, M=length(unique(group)))

fit <- stan("model.stan", data=data, iter=50000, seed=1234, warmup=10000)
p <- mcmc_areas(fit,
                pars = c("mu[4]", "mu[1]", "mu[3]", "mu[2]", "mu[5]"),
                prob = 0.95,
                point_est='none')

#p <- p + labs(title="空気抵抗係数(CdA)フィールドテスト結果",
#              subtitle="ポジション5種類をランダム化して15回計測。計測結果を統計処理しポジションごとのCdA推定値を作図。",
#              caption="※ 図中の山の高さは推定値の'ばらつき'と'確率'を表している。")
p <- p + xlab("CdA")

p <- p + scale_y_discrete(labels=labels)
p <- p + theme(text=element_text(family='HiraKakuPro-W3', size=18),
               plot.title=element_text(size=26),
               plot.subtitle=element_text(size=16, margin=margin(t=5, b=10)),
               plot.caption=element_text(size=16, hjust=0, margin=margin(t=15)),
               axis.text.y=element_text(size=16, family='HiraKakuPro-W6', hjust=0)) +
  xlim(c(0.21, 0.42))

p +         
  annotate("text", x=0.27, y=5, hjust=0.4, vjust=-0.2, label="0.27%+-%0.01", parse=TRUE, size=6.5) +
  annotate("text", x=0.32, y=4, hjust=0.6, vjust=-0.2, label="0.32%+-%0.01", parse=TRUE, size=6.5) +
  annotate("text", x=0.33, y=3, hjust=0.7, vjust=-0.2, label="0.33%+-%0.01", parse=T, size=6.5) +
  annotate("text", x=0.34, y=2, hjust=0.7, vjust=-0.2, label="0.34%+-%0.01", parse=T, size=6.5) +
  annotate("text", x=0.36, y=1, hjust=0.4, vjust=-0.2, label="0.36%+-%0.01", parse=T, size=6.5)

#ggsave("aero-test.png")

diffp <- mcmc_areas(fit, pars=c('diff52', 'diff23'), prob=0.95, point_est='none')
diffp + theme(text=element_text(family='HiraKakuPro-W3', size=18),
              +               plot.title=element_text(size=26),
              +               plot.subtitle=element_text(size=16, margin=margin(t=5, b=10)),
              +               plot.caption=element_text(size=16, hjust=0, margin=margin(t=15)),
              +               axis.text.y=element_text(size=16, family='HiraKakuPro-W6', hjust=0)) +
  +     xlab("CdAの差") +
  +     scale_y_discrete(
    +         labels=c('diff52'='①エアロポジション', 'diff23'='②ブラケット- ③ ドロップ') )+
  +     annotate("text", x=-0.013, y=2, vjust=1.2, label="-0.01", size=5.5) +
  +     annotate("text", x=0.029, y=2, vjust=1.2, label="0.03", size=5.5) +
  +     annotate("text", x=0.007, y=2, vjust=-0.6, label="0.01", size=7.5) +
  +     annotate("text", x=0.0298, y=1, vjust=1.2, label="0.03", size=5.5) +
  +     annotate("text", x=0.0678, y=1, vjust=1.2, label="0.07", size=5.5) +
  +     annotate("text", x=0.048, y=1, vjust=-0.6, label="0.05", size=7.5)

diff_legal <- extract(fit)$diff_legal
paste("mu[3] > mu[2] is ", sum(ifelse(diff_legal > 0, 1, 0)) / length(diff_legal))
diff_illegal <- extract(fit)$diff_illegal
paste("mean(mu[2], mu[3]) > mu[1] is ", sum(ifelse(diff_illegal > 0, 1, 0)) / length(diff_illegal))
