# Credora

**A Gno-native credential wallet and verification protocol.**

Credora aims to make qualifications easier to manage, harder to forge, and simpler to verify. Individuals will be able to collect and selectively share credentials; approved institutions will issue them; employers and other relying parties will verify their authenticity and current status.

> **Status: early development.** This repository is a starting point, not an audited protocol or a production-ready credential system. Do not use it for real personal data or high-stakes credential decisions.

## Design principles

- **Privacy by design:** never put names, email addresses, certificate files, dates of birth, or other personal data on-chain.
- **Issuer accountability:** credentials are only meaningful when the issuer is authenticated and authorised.
- **User control:** individuals decide which credentials to share and with whom.
- **Verifiability:** a verifier can check issuer authorisation, document integrity, and revocation/expiry status.
- **Open standards:** design toward W3C Verifiable Credentials and interoperable credential formats.

## Repository layout

```text
contracts/credentials/   Gno credential registry realm and tests
frontend/                Next.js + TypeScript UI prototype
docs/                    Architecture, threat model, and roadmap
```

## Development status

| Area | Status |
|---|---|
| Gno realm skeleton | Initial implementation; not audited |
| Issuer requests and admin approval | Initial implementation |
| Credential issuance and revocation | Initial implementation |
| Automated contract tests | Initial tests; expand before deployment |
| Frontend UI | Initial dashboard, issuer, and verification previews |
| Wallet connection and live Gno reads/writes | Not connected |
| Encrypted document storage | Not started |
| Independent security review | Not started |

## Frontend

The Next.js + TypeScript UI prototype lives in `frontend/`. It uses clearly labelled sample data; wallet connection, live Gno reads/writes, encrypted storage, and real verification are not wired up yet.

```sh
cd frontend
npm install
npm run dev
```

See [frontend/README.md](frontend/README.md) for configuration and limitations. The frontend follows the current [Next.js App Router installation guidance](https://nextjs.org/docs/app/getting-started/installation).

## Gno development

Install the Gno toolchain by following the [official installation guide](https://docs.gno.land/builders/getting-started/).

From the contract directory:

```sh
gno fmt ./...
gno lint ./...
gno test ./...
```

The realm is configured for the address-based path:

```text
gno.land/r/g1vfxnumezmdrtf3l2rncqe7p2ag2cksfcfjc4m0/credentials
```

This uses the public Gno address supplied by the project owner. Gno grants each account an address-based namespace, and only that account can deploy under it. The final path segment, `credentials`, matches the source package declaration `package credentials`. The path in `gnomod.toml` must exactly match the `-pkgpath` passed to the deployment transaction. This is an intended path, not a deployed realm yet. See the [official Gno getting-started guide](https://docs.gno.land/builders/getting-started/) and [package configuration reference](https://docs.gno.land/resources/configuring-gno-projects/).

## Network

The initial target is the Gno Onyx testnet (`onyx-1`). Contract deployment is intentionally not part of this first repository commit. Confirm the current RPC, chain ID, faucet, and deployment instructions against the [official Gno documentation](https://docs.gno.land/) immediately before deploying.

## Security

Read [docs/SECURITY.md](docs/SECURITY.md) before running or deploying anything. The contract is experimental and has not been audited.

## Contributing

Issues and pull requests are welcome. Please do not submit real certificates, personal data, private keys, seed phrases, or production credentials to this repository.

## License

MIT. See [LICENSE](LICENSE).
