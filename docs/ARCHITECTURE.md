# Credora architecture

## Product actors

1. **Credential holder** — controls a wallet and chooses which credentials to present.
2. **Issuing organisation** — an institution authorised by Credora governance to issue credentials.
3. **Verifier** — an employer or other relying party checking a presented credential.
4. **Registry administrator** — approves issuer accounts during the initial testnet phase.

## Initial trust flow

1. An institution submits an issuer registration request.
2. The registry administrator reviews the institution outside the contract and approves its Gno address.
3. The approved issuer creates a credential record for a holder address.
4. The issuer gives the holder the signed/off-chain credential document and its credential ID.
5. The holder shares the document and a verification reference with a verifier.
6. The verifier recomputes the document digest and checks the registry record, issuer status, and credential status.

A registry entry alone does **not** prove that an institution is legitimate. Issuer onboarding and governance are part of the trust model and must be documented and operated transparently.

## On-chain / off-chain boundary

### On-chain (initial design)

- Credential identifier (random, non-identifying)
- Issuer Gno address
- Holder Gno address
- Cryptographic digest of the canonical credential document
- Issuance timestamp
- Optional expiry timestamp
- Revocation state
- Issuer authorisation state

### Off-chain

- Original certificate and attachments
- Holder name and contact details
- Qualification title and detailed claims, unless the holder explicitly chooses to disclose them
- Encrypted storage metadata and access grants

Do not store raw certificate files or personally identifying metadata on-chain. Hashes can still leak information when documents are predictable or low entropy; use a randomised, canonical credential envelope and assess dictionary-attack risks.

## Initial contract scope

The first realm is a deliberately small issuer and credential registry:

- Deployer is the initial registry administrator.
- Institutions request issuer registration.
- Administrator approves or disables issuers.
- Approved issuers issue credentials to holder addresses.
- Only the issuing organisation can revoke its own credentials.
- Verifiers can read a credential and check its current validity.

The initial administrator model is a testnet bootstrap mechanism, not a complete production governance design. Before mainnet, add a secure admin rotation / multisig or governance mechanism, recovery procedures, and an auditable issuer onboarding process.

## Planned application layers

- Next.js + TypeScript web application
- Gno wallet connection and transaction client
- Holder dashboard and credential sharing
- Issuer console
- Public verification page
- Encrypted document storage and access control

The frontend must never treat a client-supplied status as authoritative. Verification must read the canonical on-chain record and compare the presented document digest.
