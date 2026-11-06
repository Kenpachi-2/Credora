# Credora frontend

Next.js App Router + TypeScript interface prototype.

## Run locally

Requirements: Node.js 20.9 or later.

```sh
cd frontend
npm install
npm run dev
```

Open http://localhost:3000.

## Current scope

- Responsive holder dashboard
- Sample credential list, search, and status filters
- Local-only demo credential creation
- Share/verify explainer and sample link
- Issuer directory placeholder
- Explicit Onyx testnet configuration placeholder

## Important limitations

This is a UI prototype. The sample credentials and status labels are hard-coded demo data. The wallet button does not connect a wallet, the sample share URL is not a real verifier, and no transactions are sent to Gno. Do not enter real personal information.

Before connecting a wallet, confirm the current network configuration and implement supported Gno wallet/client integration. Configure the deployed realm path with `NEXT_PUBLIC_CREDORA_REALM_PATH`. The contract package path must be the exact path at which the realm was deployed.

```sh
NEXT_PUBLIC_CREDORA_REALM_PATH=gno.land/r/<your-namespace>/credentials npm run dev
```
