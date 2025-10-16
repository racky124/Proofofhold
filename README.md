ProofOfHold Smart Contract

Overview
**ProofOfHold** is a Clarity-based smart contract that rewards users for **holding STX tokens** over a fixed period.  
By locking tokens in the contract, users demonstrate long-term commitment and earn rewards proportional to the duration and amount held.  
This creates a transparent, decentralized, and fair incentive structure within the **Stacks blockchain ecosystem**.

---

Features

- **Deposit Functionality** — Users can lock STX for a chosen time duration.  
- **Secure Time-Lock** — STX remains safely locked until the release time is reached.  
- **Reward Distribution** — Users earn rewards based on holding time and token amount.  
- **Proof of Holding** — On-chain data verifies the user's commitment duration.  
- **Admin Configuration** — Contract owner can set reward rates and holding rules.  

---

Technical Details

- **Language:** [Clarity](https://docs.stacks.co/write-smart-contracts/clarity-language)  
- **Framework:** [Clarinet](https://github.com/hirosystems/clarinet)  
- **Contract Name:** `proof-of-hold.clar`  
- **Core Functions:**
  - `deposit` — Lock STX for a specified duration.  
  - `withdraw` — Unlock and claim STX plus rewards after the holding period.  
  - `calculate-reward` — Compute user reward based on locked amount and time held.  
  - `get-holder-info` — Retrieve holder details and reward status.

---

Example Workflow

1. **Deposit:**  
   A user deposits 100 STX with a holding period of 90 days.  
2. **Wait:**  
   Tokens remain locked, proving commitment to the ecosystem.  
3. **Withdraw:**  
   After 90 days, the user withdraws 100 STX + accrued rewards.

---

Testing

Run the following command to verify the contract:

```bash
clarinet check
