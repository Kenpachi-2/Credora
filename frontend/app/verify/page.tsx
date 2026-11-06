"use client";

import { useState } from "react";

export default function VerifyPage() {
  const [credentialId, setCredentialId] = useState("");
  const [submitted, setSubmitted] = useState(false);

  function submit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSubmitted(true);
  }

  return (
    <main className="standalone-page">
      <a className="standalone-brand" href="/"> <span className="brand-mark">c<span>.</span></span> credora</a>
      <div className="eyebrow">CREDENTIAL AUTHENTICITY</div>
      <h1>Verify a credential.</h1>
      <p className="subtitle">Check a credential reference against the Credora registry.</p>
      <section className="feature-panel verify-panel">
        <div className="feature-symbol">✓</div>
        <h2>Enter a credential ID</h2>
        <p>In the connected product, this page will read the issuer, document digest, expiry, and revocation status from Gno. This preview does not query a live chain.</p>
        <form onSubmit={submit} className="verify-form">
          <label htmlFor="credential-id">Credential reference</label>
          <input id="credential-id" value={credentialId} onChange={(event) => { setCredentialId(event.target.value); setSubmitted(false); }} placeholder="e.g. CR-2025-00841" required />
          <button className="primary-button" type="submit">Check credential <span>→</span></button>
        </form>
        {submitted && <div className="verification-notice"><strong>Live verification is not connected yet.</strong><span>{credentialId.trim()} was not checked against Gno. No validity claim is being made.</span></div>}
      </section>
      <p className="disclaimer">Credora prototype · Never rely on this preview for employment, admissions, or other decisions.</p>
    </main>
  );
}
