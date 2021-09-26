# Convex claim and lock zap contract

Modified and stripped down versions of the Convex <a href="https://etherscan.io/address/0x8cb38a75ecd8572af23a8d086e9bda96ca521889#code">claim and stake all zap contract</a>.

Unlike the currently available contract both versions will:
- Lock your claimed CVX rewards instead of staking them
- Sweep your current wallet balance of CVX, CRV & CVXCRV and stake/lock accordingly.

The lite contract `ClaimLockZapLite` does not claim rewards from LP and is cheaper to deploy.
