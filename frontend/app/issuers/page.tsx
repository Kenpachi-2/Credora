"use client";

import { useState } from "react";
import { AdenaSDK } from "@adena-wallet/sdk";

type WalletAccount = { address?: string; account?: { address?: string }; data?: { address?: string }; [key: string]: unknown };
type WalletNetwork = { chainId?: string; chain_id?: string; chainName?: string; name?: string; data?: { chainId?: string; chain_id?: string; chainName?: string; name?: string }; [key: string]: unknown };

function getAddress(account: WalletAccount): string {
  return account.data?.address ?? account.address ?? account.account?.address ?? "";
}

export default function IssuersPage() {
  const [organisation, setOrganisation] = useState("");
  const [wallet, setWallet] = useState("");
  const [network, setNetwork] = useState("");
  const [connected, setConnected] = useState(false);
  const [connecting, setConnecting] = useState(false);
  const [walletError, setWalletError] = useState("");
  const [submitted, setSubmitted] = useState(false);

  async function connectWallet() {
    setConnecting(true);
    setWalletError("");
    try {
      const adena = AdenaSDK.createAdenaWallet();
      await adena.connectWallet();
      const [account, currentNetwork] = await Promise.all([
        adena.getAccount() as unknown as Promise<WalletAccount>,
        adena.getNetwork() as unknown as Promise<WalletNetwork>
      ]);
      const address = getAddress(account);
      if (!address) throw new Error("Adena connected, but no account address was returned. Please unlock Adena and try again.");
      setWallet(address);
      const networkInfo = currentNetwork.data ?? currentNetwork;
      setNetwork(networkInfo.chainId ?? networkInfo.chain_id ?? networkInfo.chainName ?? networkInfo.name ?? "Connected network");
      setConnected(true);
      setSubmitted(false);
    } catch (error) {
      setWalletError(error instanceof Error ? error.message : "Could not connect to Adena. Check that the extension is installed and unlocked.");
    } finally {
      setConnecting(false);
    }
  }

  function submit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSubmitted(true);
  }

  return (
    <main className="standalone-page">
      <a className="standalone-brand" href="/"> <span className="brand-mark">c<span>.</span></span> credora</a>
      <div className="eyebrow">FOR EDUCATION & CERTIFICATION PROVIDERS</div>
      <h1>Become a trusted issuer.</h1>
      <p className="subtitle">A transparent route for organisations to issue verifiable qualifications.</p>
      <section className="feature-panel verify-panel">
        <div className="feature-symbol">▧</div>
        <h2>Issuer registration preview</h2>
        <p>Connect your Adena wallet to identify the organisation's Gno account. Registration is still a preview; no blockchain transaction is submitted.</p>
        <div className="wallet-connect-panel">
          <button className="primary-button" type="button" onClick={connectWallet} disabled={connecting}>
            {connecting ? "Connecting…" : connected ? "Reconnect Adena wallet" : "Connect Adena wallet"} <span>→</span>
          </button>
          {connected && <div className="wallet-connected" role="status">
            <strong>Wallet connected</strong>
            <span>{wallet}</span>
            <small>Network: {network}</small>
          </div>}
          {walletError && <div className="wallet-error" role="alert">{walletError}</div>}
        </div>
        <form onSubmit={submit} className="verify-form">
          <label htmlFor="org-name">Organisation name</label>
          <input id="org-name" value={organisation} onChange={(event) => { setOrganisation(event.target.value); setSubmitted(false); }} placeholder="e.g. Example University" required />
          <label htmlFor="org-wallet">Connected Gno issuer address</label>
          <input id="org-wallet" value={wallet} readOnly placeholder="Connect your Adena wallet above" required />
          <button className="primary-button" type="submit" disabled={!connected || !organisation.trim()}>Preview registration <span>→</span></button>
        </form>
        {submitted && <div className="verification-notice"><strong>Preview only — no request was submitted.</strong><span>{organisation} · {wallet}</span></div>}
      </section>
      <p className="disclaimer">Wallet connection only. No signing or transaction is requested. Issuer registration requires independent organisation checks; a wallet address alone does not prove accreditation.</p>
    </main>
  );
}
