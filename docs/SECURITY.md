# Security and privacy notes

**This is experimental software. It is not audited and must not be used for production credentials.**

## Non-negotiable privacy rules

- Never store certificate PDFs, names, email addresses, dates of birth, student numbers, or other personal information directly on-chain.
- Do not place private storage URLs, encryption keys, access tokens, or secrets in contract state.
- Treat public hashes as potentially linkable data. Hashing is not anonymisation.
- Use explicit holder consent and narrowly scoped sharing when the off-chain credential presentation layer is implemented.
- Do not upload real personal credentials to GitHub issues, pull requests, test fixtures, or public demos.

## Contract security

- Crossing functions must validate the current realm context using `cur.IsCurrent()`.
- Authorise the immediate caller with `cur.Previous().Address()`; do not use the transaction origin as a substitute for caller authentication.
- Check permissions and validate all input before mutating state.
- Use panic/revert semantics for failed state-changing operations; returning an error after mutation does not automatically roll back prior state changes.
- Ensure only an authorised issuer can issue credentials and only the issuer can revoke its own credentials.
- Treat issuer approval as an administrative trust decision, not proof of legal accreditation.
- Add tests for unauthorised callers, duplicate IDs, invalid digests, expiry boundaries, revocation, and admin actions before testnet deployment.

## Credential integrity

The registry stores a digest, not the original document. A future credential format should define canonical serialisation and use a modern cryptographic digest. The verifier must recompute the digest from the exact canonical payload. Do not hash an arbitrary PDF byte stream in one component and a re-serialised JSON object in another.

## Operational security

- Never commit seed phrases, private keys, wallet exports, RPC credentials, or production secrets.
- Use a dedicated testnet wallet with no valuable assets.
- Confirm the target chain ID and RPC endpoint before signing transactions.
- Use a multisig or carefully governed admin process before mainnet.
- Obtain an independent review and run adversarial tests before production deployment.

## Responsible disclosure

Please do not publish exploitable vulnerabilities in public issues. Contact the maintainers privately first and include a clear reproduction and impact assessment.
