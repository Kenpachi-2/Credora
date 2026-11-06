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
docs/                    Architecture, threat model, and roadmap
```

## Development status

| Area | Status |
|---|---|
| Gno realm skeleton | Initial implementation |
| Issuer requests and admin approval | Initial implementation |
| Credential issuance and revocation | Initial implementation |
| Automated contract tests | Initial tests; expand before deployment |
| Frontend / wallet connection | Not started |
| Encrypted document storage | Not started |
| Independent security review | Not started |

## Gno development

Install the Gno toolchain by following the [official installation guide](https://docs.gno.land/builders/getting-started/).

From the contract directory:

```sh
gno fmt ./...
gno lint ./...
gno test ./...
```

The local module path in `gnomod.toml` is a development placeholder. Before deployment, replace it with a package path in the deployer's registered Gno namespace. A GitHub username is not automatically a Gno namespace.

## Network

The initial target is the Gno Onyx testnet (`onyx-1`). Contract deployment is intentionally not part of this first repository commit. Confirm the current RPC, chain ID, faucet, and deployment instructions against the [official Gno documentation](https://docs.gno.land/) immediately before deploying.

## Security

Read [docs/SECURITY.md](docs/SECURITY.md) before running or deploying anything. The contract is experimental and has not been audited.

## Contributing

Issues and pull requests are welcome. Please do not submit real certificates, personal data, private keys, seed phrases, or production credentials to this repository.

## License

MIT. See [LICENSE](LICENSE).
