# How Much Could This Portfolio Lose Tomorrow?

**Monte Carlo Value-at-Risk with historical vs. VIX-implied volatility, backtested on S&P 500 stocks, 2016–2024.**

Every day, banks and fund managers estimate how much they could lose tomorrow and hold capital against the answer. This project built five Monte Carlo risk models and checked **216,975 daily forecasts per model** against what actually happened. The test covers 900 random five-stock portfolios drawn from the S&P 500 as it stood at the time, using CRSP and Cboe data from Wharton Research Data Services (WRDS).

![How often each model was wrong](results/figures/results_1_breach_rates.png)

## Key findings

* **Forward-looking beats backward-looking where it counts.** Scaling volatility by the VIX (the options market's "fear gauge") gave a 99% VaR that was breached on **0.88%** of days (target 1%). The textbook one-year-history model was breached on **2.24%**, and 26% of its portfolio-years fell in the Basel red zone, against under 1% for the VIX model.
* **Backward-looking models fail at turning points.** The historical model was breached 4–5× too often in 2018, 2020 and 2022 (**34% of days in March 2020**), then too rarely in the calm years after.
* **Accuracy at a modest cost.** The VIX model holds about 10% more capital than the historical model and **11% less than historical simulation** (the most common bank method), while being more accurate than both.
* **The course version's headline was an artefact.** It divided the VIX (an *index*) by the volatility of *single stocks*. Compared like for like, options were pricing **16% more** risk than history on average, not half as much.
* **Efficient simulation.** Importance sampling cut Monte Carlo variance **36×** for VaR and **107×** for ES; antithetic variates gave no gain in the tail, as theory predicts.

## What's here

| | |
|---|---|
| [`notebooks/portfolio_var_backtest.ipynb`](notebooks/portfolio_var_backtest.ipynb) | The whole analysis in one notebook: data download, cleaning, exploration, the Monte Carlo engine built step by step with checks, the backtest, results and simulation diagnostics. Each modelling decision is explained where it is made. |
| [`docs/report.pdf`](docs/report.pdf) ([markdown](docs/report.md)) | Final report, written for a non-technical reader |
| [`docs/proposal.pdf`](docs/proposal.pdf) ([markdown](docs/proposal.md)) | Project proposal |
| [`results/`](results/) | Summary tables (CSV) and all figures |

## Methods

Correlated Monte Carlo simulation (Cholesky decomposition), multivariate Student-t shocks, common random numbers, importance sampling and antithetic variates. Volatility models: equal-weight historical, EWMA (RiskMetrics) and VIX-scaled; plus historical simulation. Backtesting with Kupiec and Christoffersen tests, the Basel traffic light, ES ratios and quantile loss.

## Running it

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
jupyter notebook notebooks/portfolio_var_backtest.ipynb
```

* **With WRDS** (CRSP and Cboe subscriptions): leave `DATA_SOURCE = "wrds"`. You'll be asked for your WRDS login once, and the data is cached in `data/`. A full run takes about 10 minutes.
* **Without WRDS:** set `DATA_SOURCE = "synthetic"` to run the whole pipeline on generated data with the same structure (numbers are illustrative only).

Raw WRDS data is licensed and is not included in this repository.

---
*Originally developed for Simulation Applications (QFGB-8925), Fordham University, Spring 2026; rebuilt and extended with WRDS data.*
