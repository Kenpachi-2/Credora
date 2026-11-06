# Credora frontend

Next.js App Router + TypeScript interface prototype.

## Run locally

Run the frontend unit tests with `npm test` after installing dependencies.

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
- Issuer registration preview at `/issuers`
- Credential verification preview at `/verify`
- Explicit Onyx testnet and intended realm-path configuration

## Important limitations

This is a UI prototype. The sample credentials and status labels are hard-coded demo data. The wallet button does not connect a wallet, the sample share URL is not a real verifier, and no transactions are sent to Gno. Do not enter real personal information.

The intended realm path is `gno.land/r/g1vfxnumezmdrtf3l2rncqe7p2ag2cksfcfjc4m0/credentials`, derived from the public Gno address supplied by the project owner. It is configured in `frontend/lib/config.ts` and `.env.example`. It is only a planned address: the realm must be compiled, tested, and deployed to Onyx before that path resolves. The contract's `gnomod.toml` module and the deployment transaction's `-pkgpath` must use exactly the same path.

To override the path locally, copy `.env.example` to `.env.local` and edit the value if needed. No wallet secret or private key belongs in an environment file.
