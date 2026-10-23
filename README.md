# Fordham Simulation Applications

Projects from **Simulation Applications (QFGB-8925)**, M.S. Quantitative Finance, Fordham University, rebuilt and extended for a portfolio.

| Project | What it does | Methods | Data |
|---|---|---|---|
| [**How much could this portfolio lose tomorrow?**](portfolio-var-volatility-regimes/) | Backtests five Monte Carlo Value-at-Risk models, built on past volatility vs. the VIX, on S&P 500 stock portfolios from 2016 to 2024 | Correlated Monte Carlo (Cholesky), Student-t shocks, importance sampling, Kupiec / Christoffersen / Basel backtests | WRDS: CRSP, Cboe |
