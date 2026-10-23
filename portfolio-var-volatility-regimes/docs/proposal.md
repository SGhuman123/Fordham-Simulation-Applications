---
title: "How Much Could This Portfolio Lose Tomorrow?"
subtitle: "Project proposal: testing Monte Carlo risk forecasts built on past data versus option-market expectations"
author: "Simulation Applications (QFGB-8925), Fordham University — revised portfolio edition"
date: "October 2026"
geometry: margin=2.3cm
fontsize: 11pt
colorlinks: true
---

## At a glance

| | |
|----|----------------|
| **Question** | When a risk model predicts "the worst loss you should expect tomorrow", does it matter whether it learns from *the past* or from *what the market expects next*? Which approach is right more often? |
| **Why it matters** | Banks and fund managers set aside cash, and decide how much risk to take, based on these forecasts. A forecast that is too low leaves them exposed in a crash; one that is too high ties up money for nothing. |
| **Method** | Monte Carlo simulation: generate 10,000 possible "tomorrows" for each portfolio, under five different models, every trading day from 2016 to 2024, then check every forecast against what actually happened. |
| **Data** | Wharton Research Data Services (WRDS): CRSP stock returns and historical S&P 500 membership, the S&P 500 index, plus the Cboe VIX (the market's forward-looking volatility gauge). |
| **Success** | A model "passes" if its predicted bad days happen as often as promised (e.g. 1 day in 100), not more and not less, and if those days don't bunch together. |

## 1. The problem, in plain English

**An everyday analogy.** A weather forecaster who says "there is a 1% chance of a flood tomorrow" should be wrong about 1 day in 100. If floods happen 5 days in 100, the forecast is dangerously optimistic. If they never happen, people are building flood walls they don't need. Either way, you can only tell by keeping score over many days.

Financial risk forecasts work the same way. The most widely used one is **Value-at-Risk (VaR)**: a single number such as *"there is a 99% chance this portfolio will not lose more than 3% tomorrow."* Its companion, **Expected Shortfall (ES)**, answers the follow-up question: *"and on the 1% of days when it does, how bad is the loss on average?"* Banks are required by regulators to calculate these numbers. Asset managers use them to size positions. Both use them to decide how much money to hold back as a safety buffer ("capital").

**The hard part is volatility**, meaning how much prices are likely to swing. There are two very different ways to estimate it:

1. **Look backwards.** Measure how much prices actually moved over the past year (*historical* or *realised* volatility). This is objective, but slow: after a calm year it under-reacts to a sudden crisis, and after a crisis it keeps predicting danger long after markets have calmed down.
2. **Look forwards.** Read the market's own expectation from option prices. Options are contracts that pay off when prices move a lot, so their price reveals how much movement traders expect over the next month (*implied* volatility). For the S&P 500 this is published daily as the **VIX**, often called the "fear index". It reacts instantly to news, but it reflects traders' fears and includes a "fear premium", so it may systematically over-state risk.

**The question this project answers:** *for a realistic stock portfolio, which way of estimating volatility gives the most reliable one-day loss forecast, and how much does the choice change the answer?*

**Why the answer matters.** Suppose a model under-states risk by a third on a $100 million portfolio. A one-in-a-hundred bad day then costs about $1 million more than planned, and that happens precisely in a crisis, when raising cash is hardest. Over-stating risk is costly too: capital held against imaginary risk earns nothing. Regulators formally test banks' VaR models on exactly this "how often were you wrong?" basis (the Basel "traffic light" test), so the evaluation in this project mirrors real practice.

### What changed from the first version of this project

An earlier version (the course submission) compared these approaches for 29 stocks and found that historical volatility gave about **twice** the risk of the option-market view. On review, that gap was mostly a measurement error, not a market insight:

* It compared the volatility of the **whole S&P 500 index** (from the VIX) with the average volatility of **individual stocks**. An index is a blend of 500 stocks whose ups and downs partly cancel out, so it is always calmer than a typical single stock. That is like comparing the average temperature of a country with the temperature of one city and concluding the city is "overheating".
* The sample was the first 30 tickers alphabetically from *today's* S&P 500 list. That quietly excluded companies that had failed or been removed (survivorship bias).
* The forecasts were never checked against what actually happened.

This revised project fixes all three. It compares the VIX with the **index's own** history (index against index), uses the true historical index membership, and scores every forecast against reality.

## 2. Planned methodology

### The idea in one paragraph

Every trading day from 2016 to 2024, for 100 randomly chosen five-stock portfolios, each model will look only at information available the evening before and produce tomorrow's 95% and 99% VaR and ES. It does this by **simulating 10,000 possible versions of tomorrow** and reading off the worst 5% and 1% of outcomes. The next day, we record what the portfolio actually did. Repeating this about 2,260 days × 100 portfolios gives over 200,000 forecast-versus-reality comparisons per model.

### The five competing models

| # | Model | How it estimates tomorrow's volatility | Role |
|-|------|-----------|------|
| 1 | **Historical vol (normal)** | Average size of daily moves over the past year, every day weighted equally | The "textbook" approach; what the first version used |
| 2 | **EWMA vol (normal)** | Same, but recent days count more (RiskMetrics method, decay 0.94) | Industry-standard backward-looking model |
| 3 | **VIX-scaled vol (normal)** | Each stock's past-year volatility × (VIX ÷ the index's own past-year volatility); how stocks move *together* still comes from history | The forward-looking idea, done correctly |
| 4 | **VIX-scaled vol (fat-tailed)** | As model 3, but allowing extreme days to be more common than a bell curve predicts (Student-t shocks) | Tests whether "fat tails" matter |
| 5 | **Historical simulation** | No formula: replays the portfolio's actual returns from the last 250 days | Simplest benchmark; widely used by banks |

### How the simulation works (the core of the project)

For each portfolio and day:

1. **Measure the ingredients.** Each stock's volatility (by the model's rule) and the correlations between stocks (how much they tend to move together, estimated from the past 252 trading days).
2. **Generate random "shocks".** Draw 10,000 sets of random numbers, one per stock per scenario.
3. **Make the shocks move together realistically.** Use a *Cholesky decomposition*, a standard matrix technique that reshapes independent random numbers so that, for example, two tech stocks tend to rise and fall together the way they really do.
4. **Turn shocks into portfolio outcomes.** Convert each scenario into a portfolio gain or loss.
5. **Read off the risk.** Sort the 10,000 outcomes. The 100th-worst is the 99% VaR; the average of the 100 worst is the 99% ES.

> **For the technical reader.** One-day log returns are modelled as $r = L z$ with $\Sigma = L L^\top$, where $\Sigma$ is the model's covariance matrix and $z$ is a vector of independent standard normal draws (model 4 scales $z$ by $\sqrt{(\nu-2)/\chi^2_\nu}$ to give unit-variance multivariate-t shocks; $\nu$ is fitted each year to EWMA-standardised residuals). The VIX models use $\Sigma_{VIX,t} = m_t^2\,\Sigma_{hist,t}$, where $m_t = \text{VIX}_t / \sigma^{index}_{t}$ and $\sigma^{index}_t$ is the S&P 500's realised volatility over the past 252 days; correlations are unchanged. The portfolio's simple return is $\sum_i w_i(e^{r_i}-1)$ with $w_i = 1/5$. Expected drift is set to zero, standard for one-day horizons where drift (~0.03%/day) is negligible next to volatility (1–2%/day). All models share the same random draws each day (*common random numbers*), so differences between models are not simulation noise.

### Making the simulation trustworthy and efficient

Simulation gives an *estimate*, and estimates have error. The project will measure and reduce that error:

* **Convergence study.** Repeat the simulation many times at 1,000 to 1,000,000 paths and show the estimation error shrinking at the theoretical rate (halving the error needs four times the paths).
* **Check against a known answer.** In the bell-curve case a closed-form formula exists, so the simulation must reproduce it.
* **Variance reduction.** Test two classic techniques for getting the same accuracy from fewer paths. *Antithetic variates* pair every scenario with its mirror image. *Importance sampling* deliberately simulates more of the rare bad scenarios we care about, then re-weights them so the answer stays unbiased.

## 3. Connection to Simulation Applications

The project is built on the course's core tools: random number generation; transforming independent draws into correlated ones (Cholesky); Monte Carlo estimation of quantiles and tail expectations; Student-t simulation via normal/chi-square mixtures; convergence analysis and confidence intervals; and variance reduction (antithetic variates, importance sampling). The backtest itself is a large simulation experiment: about 2,260 days × 100 portfolios × 10,000 paths, or over two billion simulated portfolio outcomes per model.

## 4. Data

All market data comes from **Wharton Research Data Services (WRDS)**, the academic and industry standard research database, accessed through Fordham's subscription.

| Dataset (WRDS) | What it provides | Why it is needed |
|-----|--------|--------|
| **CRSP daily stock file** | Daily total returns (including dividends) for every US-listed stock, 2015–2024 | The realised outcomes, and the history behind models 1, 2 and 5 |
| **CRSP S&P 500 constituents** | Exact dates each company entered and left the index | Portfolios are drawn only from stocks that were *actually* in the index at the time, which avoids survivorship bias |
| **CRSP daily index file** | Daily return of the S&P 500 index | The index's own past volatility, the like-for-like partner for the VIX |
| **Cboe VIX** | The VIX, daily | The forward-looking volatility for models 3 and 4 |

**Processing.** Returns are converted to log returns. Days with missing data are excluded for the affected portfolio only, never filled in (filling would invent artificial calm days). Small gaps in the VIX (up to 5 trading days) are carried forward. Each January, 100 portfolios are drawn at random from that day's index members that have a full year of history. 2015 serves only as look-back history.

**Why this is better than free data.** Yahoo Finance offers only today's index list, so companies that later left the index are invisible. CRSP is the standard source in academic finance and industry research. Stock-by-stock implied volatility (OptionMetrics) would be a natural refinement of models 3 and 4, but it is not part of the available WRDS subscription. Under the WRDS licence, raw data is **not** published in the repository; only code and summary results are.

**Synthetic data.** The code also includes a generator of realistic fake data with the same layout, so anyone without a WRDS login can run the entire pipeline and its tests.

## 5. Baselines

The two most common approaches in practice serve as baselines: **historical simulation** (model 5, the most popular method among banks) and **EWMA/RiskMetrics** (model 2, the classic parametric method). The plain historical-volatility model (model 1) represents the first version of this project. The VIX-based models (3 and 4) count as useful only if they beat these baselines.

## 6. Metrics and criteria for success

Every model will be scored on the same 200,000+ forecasts:

| Check | Plain-English meaning | Pass mark |
|----|--------|-------|
| **Breach rate** | How often the actual loss exceeded the VaR forecast | Close to 5% (95% VaR) and 1% (99% VaR) |
| **Kupiec test** | Is the breach rate *statistically* different from the promise? | Rejected for as few portfolio-years as possible (≈5% expected by chance) |
| **Christoffersen test** | Do breaches bunch together (a sign the model reacts too slowly)? | Clustering rejected as rarely as possible |
| **Basel traffic light** | Regulators' zone for 99% VaR: green (≤4 breaches a year), yellow (5–9), red (10+) | Most portfolio-years green |
| **ES ratio** | On breach days, actual average loss ÷ forecast ES | Close to 1.0 |
| **Capital efficiency** | Average size of the VaR forecast | Among models that pass, smaller is better |
| **Quantile loss** | A single score rewarding accuracy *and* penalising over-caution | Lowest wins |

**The project succeeds if** it (a) produces a validated simulation engine whose error behaves as theory predicts; (b) gives a clear, statistically supported ranking of the five models, including *when* each fails (e.g. the COVID crash of 2020 and the 2022 bear market); and (c) quantifies how much the volatility assumption changes required capital. A forward-looking model that matches the baselines' breach accuracy with less capital, or beats their accuracy in crises, would be a meaningful improvement. Because the evaluation is out-of-sample, a negative result (the models perform alike) is also an informative outcome.

## Glossary

* **Volatility**: how much a price typically swings, here per day. A stock with 1.5% daily volatility commonly moves about ±1.5% in a day.
* **Value-at-Risk (VaR), 99%**: a loss level that should be exceeded on only 1 day in 100.
* **Expected Shortfall (ES)**: the average loss on those worst days. It describes how bad bad days get.
* **Implied volatility**: the volatility that makes an option's market price "make sense"; the market's forecast of future swings.
* **VIX**: the implied volatility of the S&P 500 index over the next 30 days, published by Cboe.
* **Correlation**: the degree to which two stocks move together (+1 in lockstep, 0 unrelated).
* **Monte Carlo simulation**: answering a question about uncertainty by simulating thousands of random scenarios and studying the results.
* **Backtest**: checking a model's past forecasts against what actually happened afterwards.
* **Survivorship bias**: the distortion from studying only companies that survived to today.
* **Fat tails**: extreme days happen more often than a bell curve predicts.

## References

* Basel Committee on Banking Supervision (1996). *Supervisory framework for the use of "backtesting" in conjunction with the internal models approach to market risk capital requirements.* Bank for International Settlements.
* Basel Committee on Banking Supervision (2019). *Minimum capital requirements for market risk* (Fundamental Review of the Trading Book). Bank for International Settlements.
* Christoffersen, P. (1998). Evaluating interval forecasts. *International Economic Review*, 39(4), 841–862.
* Glasserman, P. (2004). *Monte Carlo Methods in Financial Engineering.* Springer.
* J.P. Morgan/Reuters (1996). *RiskMetrics — Technical Document* (4th ed.).
* Jorion, P. (2007). *Value at Risk: The New Benchmark for Managing Financial Risk* (3rd ed.). McGraw-Hill.
* Kupiec, P. (1995). Techniques for verifying the accuracy of risk measurement models. *Journal of Derivatives*, 3(2), 73–84.
