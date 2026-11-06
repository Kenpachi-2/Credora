/**
 * Network settings are deliberately explicit. Confirm these values against
 * current official Gno network documentation before connecting a wallet or
 * submitting transactions. Never silently fall back to mainnet.
 */
export const GNO_NETWORK = {
  name: "Gno Onyx Testnet",
  chainId: "onyx-1",
  rpcUrl: "https://rpc.onyx.testnets.gno.land:443",
  // Intended path only; it will not resolve until the realm is deployed.
  realmPath: process.env.NEXT_PUBLIC_CREDORA_REALM_PATH ?? "gno.land/r/g1vfxnumezmdrtf3l2rncqe7p2ag2cksfcfjc4m0/credentials"
} as const;

export const isRealmConfigured = GNO_NETWORK.realmPath.length > 0;
