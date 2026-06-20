# Sales Data Analysis — Business Transformation Case Study
> Simulated KPMG consulting engagement · Confectionery client · End-to-end data audit, insight generation & strategic recommendations

---

## Overview

This project simulates a real consulting engagement in which KPMG is tasked with gaining an initial understanding of a confectionery client's **as-is operating model**. Starting from raw, uncleaned transaction data, the analysis covers the full consulting workflow: data quality audit → assumption framework → business insight → actionable recommendations — structured and delivered as a client-facing presentation.

---

## Why This Project Stands Out

- **Consulting-grade framing** — every insight follows the *Understanding → Question to Validate → Quick Initiative* structure, mirroring how management consultants communicate findings to clients
- **Rigorous data audit before analysis** — identified and documented 8+ categories of data anomalies across 5 dimensions before drawing any conclusions, demonstrating professional data skepticism
- **Multi-dimensional business lens** — analysis spans revenue, customer segmentation, product performance, supply chain, geographic distribution, and product returns — not just descriptive stats
- **Actionable output** — each insight section closes with concrete, prioritized quick wins the client can act on immediately
- **Excel forensics** — used `LEN()` function to uncover hidden characters in product codes (visually 11 chars but LEN() returns 13), showing attention to non-obvious data quality issues

---

## Project Structure

```
1. Data Context       → Business background and scope
2. Quality Audit      → Anomaly detection across all key fields
3. Key Assumptions    → Documented decision framework for ambiguous data
4. Key Insights       → Business findings across 5 analytical dimensions
```

---

## Data Quality Audit — Key Findings

Conducted a systematic audit across every major field before analysis:

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
- City/Province field contains country names: `"Combodia"`, `"Indonesia"` → misclassified export records
- Product codes visually display 11 characters but `LEN()` returns 13 → hidden whitespace/characters

---

## Assumption Framework

Documented all analytical decisions transparently to ensure reproducibility:

| Issue | Decision |
|-------|----------|
| `Total Value vs. Qty × Price` discrepancy | Prioritize Total Value as definitive revenue metric |
| Zero-value transactions | Classify as Promotional / Bundle Items |
| Records where both Qty and Price = 0 | Excluded as noise |
| High-value outlier orders | Identified as Key Account / VIP — retained with flag |
| Foreign city/province entries | Reclassified as Export Market data |
| Transportation cost anomaly | Escalated to Finance — excluded from cost analysis |

---

## Key Insights & Results

### 1. Sales Revenue
- Standard Segment revenue shows **strong seasonal volatility** with sharp month-to-month swings
- Growth rate oscillates between significant positive spikes and notable negative drops
- **Quick win:** Implement seasonal demand forecasting + high-demand month playbook for inventory and promotions

### 2. Key Customer Base
- **~90% of key customers are recurring** → revenue base is stable and long-term
- Company demonstrates strong retention of its most strategic accounts
- **Quick win:** Apply proven retention strategies to one-off customers to convert them into recurring accounts

### 3. Top Products — Revenue & Regional Distribution
- Products 22, 51, 55 overwhelmingly concentrated in **Miền Nam** (e.g., Product 55: 84% regional dependency)
- Products 28 and 87 have established international footholds in South-East Asia and East Asia
- **Quick win:** Expand southern-dominant products into Central and Northern regions; scale Product 87's international presence

### 4. Top Products — Revenue & Channel Mix
- Highest revenue cell: **External segment × Trader channel → 3,241.1B VND (28.2% of total)**
- Domestic concentration: **Bình Dương (2,407.1B)** and **Hồ Chí Minh (1,911.2B)** drive the majority
- International: Singapore (1,140.0B) and China (453.7B) are key export markets
- **Quick win:** Double down on Trader channel; optimize FOB and Third-Party export channels for margin

### 5. Top Products — Supply Chain Risk
- Product 55 has **sole-supplier dependency** (Manufacturer 7) — critical concentration risk
- Products 22, 51, 87 source from expensive main suppliers despite cheaper alternatives available
- **Quick win:** Qualify a backup supplier for P55 immediately; pilot volume transfer to cheaper manufacturers for P22, P51, P87

### 6. Product Returns
- **Products 55 and 22** dominate return volume (~6,000 units each) — likely operational/logistics issues
- **Product 74: 92.2% return rate** (Returned Value / Sales Value) — near-total commercial failure
- **Quick win:** Immediately investigate and consider halting P74 sales; deploy quality response team for P55 and P22

---

## Tools Used

| Tool | Purpose |
|------|---------|
| Excel | Data cleaning, anomaly detection, `LEN()` forensics, pivot analysis |
| PowerPoint | Client-facing insight presentation |

---

## Deliverable

A structured, client-ready presentation covering the complete analytical workflow — from raw data audit through business insight to prioritized recommendations — formatted for a management consulting audience.
