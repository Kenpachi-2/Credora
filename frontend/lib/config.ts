/**
 * Network settings are deliberately explicit. Confirm these values against
 * current official Gno network documentation before connecting a wallet or
 * submitting transactions. Never silently fall back to mainnet.
 */
export const GNO_NETWORK = {
  name: "Gno Onyx Testnet",
  chainId: "onyx-1",
  rpcUrl: "https://rpc.onyx.testnets.gno.land:443",
  realmPath: process.env.NEXT_PUBLIC_CREDORA_REALM_PATH ?? ""
} as const;

export const isRealmConfigured = GNO_NETWORK.realmPath.length > 0;
