"use client";

import { useState } from "react";
import Link from "next/link";

export default function VerifyPage() {
  const [credentialId, setCredentialId] = useState("");
  const [submitted, setSubmitted] = useState(false);
  const [checking, setChecking] = useState(false);
  const [valid, setValid] = useState<boolean | null>(null);
  const [verificationError, setVerificationError] = useState("");

  async function submit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSubmitted(true);
    setChecking(true);
    setValid(null);
    setVerificationError("");
    try {
      const response = await fetch(`/api/credentials/${encodeURIComponent(credentialId.trim())}`, { cache: "no-store" });
      const result = await response.json() as { valid?: boolean; error?: string };
      if (!response.ok) throw new Error(result.error ?? "Could not verify this credential.");
      if (typeof result.valid !== "boolean") throw new Error("The registry returned an unexpected response.");
      setValid(result.valid);
    } catch (error) {
      setVerificationError(error instanceof Error ? error.message : "Could not verify this credential.");
    } finally {
      setChecking(false);
    }
  }

  return (
    <main className="standalone-page">
      <Link className="standalone-brand" href="/"> <span className="brand-mark">c<span>.</span></span> credora</Link>
      <div className="eyebrow">CREDENTIAL AUTHENTICITY</div>
      <h1>Verify a credential.</h1>
      <p className="subtitle">Check a credential reference against the Credora registry.</p>
      <section className="feature-panel verify-panel">
        <div className="feature-symbol">✓</div>
        <h2>Enter a credential ID</h2>
        <p>In the connected product, this page will read the issuer, document digest, expiry, and revocation status from Gno. This page queries the configured Credora registry on Gno Onyx. It checks registry status only; it does not inspect or hash the certificate document.</p>
        <form onSubmit={submit} className="verify-form">
          <label htmlFor="credential-id">Credential reference</label>
          <input id="credential-id" value={credentialId} onChange={(event) => { setCredentialId(event.target.value); setSubmitted(false); }} placeholder="e.g. CR-2025-00841" required />
          <button className="primary-button" type="submit" disabled={checking}>{checking ? "Checking Onyx…" : "Check credential"} <span>→</span></button>
        </form>
        {submitted && checking && <div className="verification-notice" role="status"><strong>Checking the Onyx registry…</strong><span>{credentialId.trim()}</span></div>}
        {verificationError && <div className="verification-notice" role="alert"><strong>Verification unavailable</strong><span>{verificationError}</span></div>}
        {valid === true && <div className="verification-notice" role="status"><strong>Registry record is currently valid</strong><span>{credentialId.trim()} is present, not revoked, and not expired according to the configured Credora realm.</span></div>}
        {valid === false && <div className="verification-notice" role="status"><strong>Credential is not valid</strong><span>{credentialId.trim()} may not exist, may be revoked, or may have expired.</span></div>}
      </section>
      <p className="disclaimer">On-chain status is not proof of the document contents or the issuer’s accreditation. Do not rely on this experimental service for high-stakes decisions.</p>
    </main>
  );
}
