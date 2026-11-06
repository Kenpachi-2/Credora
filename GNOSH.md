# Gnosh AI development guidance

This file gives AI coding agents project-specific context. It is not a substitute for reviewing generated code.

## Project

Credora is a Gno-native credential registry and dApp. The initial network target is Gno Onyx testnet (`onyx-1`).

## Rules

1. Read `README.md`, `docs/ARCHITECTURE.md`, and `docs/SECURITY.md` before making changes.
2. Follow current official Gno documentation; do not assume Solidity, EVM, or ordinary Go behavior maps directly to Gno.
3. Run `gno fmt ./...`, `gno lint ./...`, and `gno test ./...` in the relevant package.
4. Never introduce personal data or certificate contents into on-chain state.
5. Never weaken caller checks, issuer authorisation, or revocation semantics to make a test pass.
6. Add tests for security-sensitive behavior and explain any untested assumptions.
7. Do not deploy, sign transactions, access mainnet, or use real credentials without explicit maintainer approval.
8. Do not commit secrets, seed phrases, private keys, or unencrypted real-world credentials.

## Current contract assumptions

- The realm deployer becomes the initial admin during `init()`.
- Crossing entrypoints validate `cur.IsCurrent()` and authenticate the immediate caller with `cur.Previous().Address()`.
- Issuer approval is a manual trust decision; it does not prove accreditation.
- The contract stores a digest and minimal public metadata only.
- The contract has not been compiled, tested in a pinned local toolchain, or audited yet. Do not describe it as production-ready.

## Before proposing a deployment

Confirm the module path is in the deployer's actual Gno namespace, check the current Onyx chain configuration from official docs, run all tests, and present the exact transaction and expected effects for maintainer review.
