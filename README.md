# Sales Data Analysis — Business Transformation Case Study

> A self-practice consulting case study simulating an operating model diagnostic engagement for a confectionery company · End-to-end data audit, insight generation & strategic recommendations

---

## Overview

This project is a **self-initiated practice case** modeled after real-world consulting diagnostics. The scenario: a consulting team is engaged to gain an initial understanding of a confectionery company's **as-is operating model** through its transaction data.

Starting from raw, uncleaned sales data, the analysis covers the full consulting workflow — data quality audit → assumption framework → business insight → actionable recommendations — structured and delivered as a client-facing presentation.

> ⚠️ *All data used in this project is fictional and created solely for practice purposes. No real company data is involved.*

---

## Why This Project Stands Out

- **Consulting-grade framing** — every insight follows the *Understanding → Question to Validate → Quick Initiative* structure, mirroring how management consultants communicate findings to clients
- **Rigorous data audit before analysis** — identified and documented 8+ categories of anomalies across 5 data dimensions before drawing any conclusions, demonstrating professional data skepticism
- **Multi-dimensional business lens** — analysis spans revenue, customer segmentation, product performance, supply chain, geographic distribution, and product returns — not just descriptive stats
- **Actionable output** — each insight section closes with concrete, prioritized quick wins the client can act on immediately
- **Excel forensics** — used `LEN()` function to uncover hidden characters in product codes (visually 11 chars but `LEN()` returns 13), showing attention to non-obvious data quality issues

---

## Project Structure

```
1. Data Context       → Business background and scope
2. Quality Audit      → Anomaly detection across all key fields
3. Key Assumptions    → Documented decision framework for ambiguous data
4. Key Insights       → Business findings across 6 analytical dimensions
```

---

## Data Quality Audit — Key Findings

Conducted a systematic audit across every major field before any analysis:

**Revenue & Pricing**
- `Total Value ≠ Quantity × Price` → integrity discrepancy (rounding errors / hidden discounts)
- Mixed positive/negative values in Total Value due to accounting reversals
- Negative price entries and zero-value records (Quantity = 0, Price = 0)
- Extreme high-value outliers skewing distribution (VIP/Key Account orders)

**Logistics Cost**
- 99% of records have Transportation Cost / Revenue ratio > 98% → fatal systematic error
- Mixed positive/negative cost entries → flagged for Finance Department cross-check

**Categorical Fields**
- Segment field contains typo: `"Third Partty"` (double-t)
- City/Province field contains country names → misclassified export records
- Product codes visually display 11 characters but `LEN()` returns 13 → hidden whitespace/characters

---

## Assumption Framework

All analytical decisions documented transparently before proceeding:

| Issue | Decision |
|-------|----------|
| `Total Value vs. Qty × Price` discrepancy | Prioritize Total Value as the definitive revenue metric |
| Zero-value transactions | Classify as Promotional / Bundle Items |
| Records where both Qty and Price = 0 | Excluded as noise |
| High-value outlier orders | Identified as Key Account / VIP — retained with flag |
| Foreign entries in City/Province field | Reclassified as Export Market data |
| Transportation cost anomaly (ratio > 98%) | Escalated to Finance — excluded from cost analysis |

---

## Key Insights & Results

### 1. Sales Revenue
- Standard Segment revenue shows **strong seasonal volatility** with sharp month-to-month swings
- Growth rate oscillates between significant positive spikes and notable drops, suggesting demand instability
- **Quick win:** Implement seasonal demand forecasting + a structured playbook for high-demand months to optimize inventory and promotions

### 2. Key Customer Base
- **~90% of key customers are recurring** → revenue base is stable and long-term
- Company demonstrates strong retention of its most strategic accounts
- **Quick win:** Apply proven retention strategies to one-off customers to convert them into recurring accounts

### 3. Top Products — Regional Concentration Risk
- Several top products overwhelmingly concentrated in one region (up to **84% regional dependency**)
- Other products have established international footholds in South-East Asia and East Asia
- **Quick win:** Expand regionally-dominant products into underserved regions; scale proven international products further

### 4. Top Products — Revenue & Channel Mix
- Highest revenue combination: **External segment × Trader channel → 28.2% of total revenue**
- Domestic market drives the majority; international markets contribute meaningfully via export channels
- **Quick win:** Double down on the Trader channel; optimize FOB and Third-Party export channels for margin improvement

### 5. Top Products — Supply Chain Risk
- One top product has **sole-supplier dependency** → critical single point of failure in the supply chain
- Other products source from expensive main suppliers despite cheaper qualified alternatives existing
- **Quick win:** Immediately qualify a backup supplier for the sole-sourced product; pilot volume transfer to cheaper manufacturers for cost reduction

### 6. Product Returns
- Two products dominate return **volume** (~6,000 units each) → likely operational/logistics root cause
- One product has a **92.2% return rate** (Returned Value / Sales Value) → near-total commercial failure
- **Quick win:** Immediately investigate and consider halting sales of the 92.2% return-rate product; deploy a quality response team for the high-volume return products

---

## Tools Used

| Tool | Purpose |
|------|---------|
| Excel | Data cleaning, anomaly detection, `LEN()` forensics, pivot analysis, visualization |
| PowerPoint | Client-facing insight presentation |

---

## Skills Demonstrated

`Data Quality Auditing` · `Assumption Documentation` · `Business Insight Generation` · `Revenue Analysis` · `Customer Segmentation` · `Supply Chain Risk Assessment` · `Excel Advanced Functions` · `Consulting Communication`
