# Onyx issuer-registration audit notes

**Scope:** static review of `contracts/credentials/credentials.gno` and
`contracts/credentials/credentials_test.gno` for the first Onyx testnet
issuer-registration milestone.

**Status:** preliminary review only. The Gno test suite has not been run in
this environment, and this is not an independent security audit.

## Deployment identity

The configured module path is:

```text
gno.land/r/g1vfxnumezmdrtf3l2rncqe7p2ag2cksfcfjc4m0/credentials
```

The public address supplied by the project owner matches the address embedded
in the module path. The path is still an intended deployment target, not proof
that a realm is deployed there.

## Findings

### 1. Administrator is the package deployer

The realm's `init(cur realm)` stores `cur.Previous().Address()` as
`admin`. This is consistent with Gno's package-initialization context: the
previous realm during initialization represents the deployer. The test suite
must prove that the intended wallet is the captured administrator on a fresh
realm deployment.

**Risk:** if the wrong wallet deploys the package, that wallet becomes the
administrator. There is no admin-transfer or recovery function in this initial
contract.

### 2. Admin authorization is caller-based

`requireAdmin` compares `cur.Previous().Address()` to the stored
administrator. This is the relevant authorization check for
`ApproveIssuer` and `DisableIssuer`; tests must exercise both the authorized
and unauthorized caller paths.

### 3. `requireCurrent(cur)` is not an authorization boundary

The helper checks `cur.IsCurrent()`. Current Gno interrealm documentation
describes the `cur realm` parameter of a crossing function as a capability
for the current crossing frame; `cur.IsCurrent()` is therefore true for the
function's own `cur`. It does not authenticate the end user and must not be
counted as an access-control check. Authorization must continue to rely on
`cur.Previous().Address()` and explicit role/state checks.

This helper is redundant in the current crossing-function pattern. Confirm
behavior against the exact pinned Gno toolchain before changing contract code.

### 4. Issuer request validation

`RequestIssuer` rejects an empty string and duplicate requests from the same
address. It does not trim whitespace, so a name consisting only of spaces is
currently accepted. Decide whether to reject whitespace-only names before
deployment. The issuer's address is derived from the caller, not supplied by
the caller, which is the correct identity-binding approach.

### 5. Approval and suspension behavior

`ApproveIssuer` and `DisableIssuer` are administrator-only and reject
unknown issuer addresses. Repeated approval and repeated disabling are
currently idempotent. Decide whether this is intended and lock it down with
tests. Approval is an administrative trust decision; it is not proof of an
institution's legal accreditation.

## Required executable test matrix

Add and run Gno tests against the pinned toolchain before deployment:

| Scenario | Expected result |
|---|---|
| New address requests issuer status | Record exists and is inactive |
| Empty issuer name | Panic / no state change |
| Whitespace-only issuer name | Explicitly decide and test policy |
| Same address requests twice | Second request rejected; first record unchanged |
| Different address requests | Separate inactive record |
| Administrator approves existing request | Issuer becomes active |
| Non-administrator approves request | Rejected; issuer remains inactive |
| Administrator disables active issuer | Issuer becomes inactive |
| Non-administrator disables issuer | Rejected; state unchanged |
| Administrator approves unknown address | Rejected |
| Unapproved issuer issues credential | Rejected |
| Approved issuer issues credential | Accepted |

Implemented in `credentials_test.gno`: request creation and inactive default,
empty-name rejection, duplicate rejection without overwriting the original
record, independent requests by two callers, admin approval, non-admin
approval rejection, unknown-issuer rejection, admin disable, and non-admin
disable rejection. The tests use distinct caller fixtures so shared package
state cannot make the cases order-dependent. They use the documented Gno test
conventions: `testing.SetOriginCaller` to select the simulated signer and
`cross` to invoke realm crossing functions.

**Execution status:** the tests have been authored but have not yet been run.
The current execution environment has Go but no `gno` binary, and it cannot
resolve GitHub to install the pinned toolchain. Do not treat this branch as
passing until `gno fmt ./...`, `gno lint ./...`, and `gno test ./...` have
been run with the project's intended Gno version.

The admin-role tests assign the package-level `admin` fixture directly. They
exercise the authorization guard, but **do not prove that realm initialization
captures the actual package deployer**. That remains a separate filetest or
fresh-realm integration-test requirement. Whitespace-only issuer names are
also currently accepted by the contract and remain an explicit validation gap.

## Deployment gate

Do not deploy until all of the following are true:

- The exact Gno version/toolchain is pinned and recorded.
- `gno fmt ./...`, `gno lint ./...`, and `gno test ./...` pass.
- The issuer/admin tests above are implemented and pass.
- The intended Adena public address is independently rechecked in the wallet.
- The package path in `gnomod.toml` exactly matches the deployment
  transaction's `-pkgpath`.
- Gas and storage deposit are estimated from the actual compiled package.
- The exact transaction is reviewed before the user signs it.

No wallet credentials or transaction data are included in this review.
