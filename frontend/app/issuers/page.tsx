"use client";

import { useState } from "react";

export default function IssuersPage() {
  const [organisation, setOrganisation] = useState("");
  const [wallet, setWallet] = useState("");
  const [submitted, setSubmitted] = useState(false);

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
        <p>Institutions will request issuer status using their Gno wallet. A registry administrator reviews the organisation before it can issue credentials.</p>
        <form onSubmit={submit} className="verify-form">
          <label htmlFor="org-name">Organisation name</label>
          <input id="org-name" value={organisation} onChange={(event) => { setOrganisation(event.target.value); setSubmitted(false); }} placeholder="e.g. Example University" required />
          <label htmlFor="org-wallet">Gno issuer address</label>
          <input id="org-wallet" value={wallet} onChange={(event) => { setWallet(event.target.value); setSubmitted(false); }} placeholder="g1..." required />
          <button className="primary-button" type="submit">Preview registration <span>→</span></button>
        </form>
        {submitted && <div className="verification-notice"><strong>Preview only — no request was submitted.</strong><span>{organisation} · {wallet}</span></div>}
      </section>
      <p className="disclaimer">Issuer registration requires independent organisation checks. A wallet address alone does not prove accreditation.</p>
    </main>
  );
}
