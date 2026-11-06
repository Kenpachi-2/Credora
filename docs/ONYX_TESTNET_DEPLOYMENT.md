# Credora — Onyx testnet deployment plan

**Status: prepared, not deployed.** This document is a deployment checklist. No transaction has been signed or broadcast.

## Target

- Network: Gno Onyx testnet
- Chain ID: `onyx-1`
- RPC: `https://rpc.onyx.testnets.gno.land:443`
- Realm path: `gno.land/r/g1vfxnumezmdrtf3l2rncqe7p2ag2cksfcfjc4m0/credentials`
- Package directory: `contracts/credentials`
- Package module: `gno.land/r/g1vfxnumezmdrtf3l2rncqe7p2ag2cksfcfjc4m0/credentials`

The package module in `gnomod.toml`, the `-pkgpath` passed to `addpkg`, and the final package name `credentials` must match exactly.

## Critical administrator decision

The realm's `init(cur)` function sets `admin = cur.Previous().Address()`. The deploying account therefore becomes the initial registry administrator. The administrator can approve and disable issuers.

The address embedded in the intended path is:

```text
g1vfxnumezmdrtf3l2rncqe7p2ag2cksfcfjc4m0
```

Before proceeding, the maintainer must confirm that:
1. They control the signing wallet for this exact address.
2. They intend this wallet to be the long-term registry administrator.
3. They understand that the current contract has no admin transfer, multisig, or recovery function. Losing this key could permanently prevent issuer administration.

Do not deploy from a different wallet. Address-based namespaces are controlled by their address owner, and a different signer cannot deploy under this path.

## Before any deployment

- Review [SECURITY.md](./SECURITY.md). This contract is experimental and unaudited.
- Confirm the current network details in the [official Gno network list](https://docs.gno.land/resources/gnoland-networks/).
- Use a dedicated Onyx testnet wallet. Never reuse a wallet holding valuable assets.
- Never share or paste a mnemonic, seed phrase, private key, or wallet export into GitHub, chat, or environment variables.
- Confirm the wallet address locally in Adena or `gnokey list`; do not infer it from a key label.
- Fund only that address through the [official Gno Faucet Hub](https://faucet.gno.land/) with the Onyx (`onyx-1`) network selected.
- Check the balance before deployment.

## Simulation only — does not publish the realm

Run from the package directory after installing the official Gno toolchain:

```sh
cd contracts/credentials

gnokey query bank/balances/g1vfxnumezmdrtf3l2rncqe7p2ag2cksfcfjc4m0 \
  -remote https://rpc.onyx.testnets.gno.land:443

gnokey maketx addpkg \
  -pkgpath "gno.land/r/g1vfxnumezmdrtf3l2rncqe7p2ag2cksfcfjc4m0/credentials" \
  -pkgdir . \
  -gas-wanted 20000000 \
  -gas-fee 20000ugnot \
  -chainid onyx-1 \
  -remote https://rpc.onyx.testnets.gno.land:443 \
  -simulate only \
  <YOUR_LOCAL_KEY_NAME>
```

Replace `<YOUR_LOCAL_KEY_NAME>` with the local key alias shown by `gnokey list`. This is a local alias, not a secret. The `-simulate only` flag is essential: it estimates the transaction without broadcasting it.

Review the simulation output:
- Confirm the package path is exactly the target path above.
- Record the suggested gas wanted and gas fee; use the simulation's suggested values, not the example values, for a later transaction.
- Record the storage fee/deposit. Set an explicit `-max-deposit` on the eventual deployment transaction to a maintainer-approved cap based on the simulation.
- Stop if the package path, signer, gas estimate, storage deposit, or any other output is unexpected.

## Broadcast gate

**Do not run an actual `addpkg` transaction until the maintainer has explicitly approved the exact signer address, realm path, gas limit, gas fee, and maximum storage deposit after reviewing the simulation.**

The actual transaction is the same `gnokey maketx addpkg` command with:
- `-simulate only` removed,
- the simulation-derived `-gas-wanted` and `-gas-fee`,
- an explicit approved `-max-deposit <amount>ugnot`.

That command signs and broadcasts a state-changing transaction. No command with broadcasting enabled is run as part of this preparation.

## After an approved deployment

1. Save the transaction hash, block height, package path, signer address, gas used, storage deposit, and deployment date in the release record.
2. Confirm the realm exists using the Onyx RPC and browse it at:
   [https://onyx.testnets.gno.land/r/g1vfxnumezmdrtf3l2rncqe7p2ag2cksfcfjc4m0/credentials](https://onyx.testnets.gno.land/r/g1vfxnumezmdrtf3l2rncqe7p2ag2cksfcfjc4m0/credentials)
3. Query `IsCredentialValid` for a deliberately nonexistent test ID and confirm it returns `false`.
4. Only then update the frontend's live status to reflect that the realm has been deployed.

Deployment alone does not make Credora production-ready. The frontend currently checks registry validity only; document digest comparison, issuer due diligence, holder consent, secure off-chain storage, admin recovery/governance, and independent security review remain outstanding.
