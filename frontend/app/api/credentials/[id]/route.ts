import { GNO_NETWORK } from "@/lib/config";
import { parseCredentialValidityResult } from "@/lib/credential-query";

export const dynamic = "force-dynamic";

type AbciQueryResponse = {
  result?: {
    response?: {
      ResponseBase?: {
        Error?: unknown;
        Data?: string;
      };
    };
  };
};

export async function GET(
  _request: Request,
  context: { params: Promise<{ id: string }> },
) {
  const { id } = await context.params;

  if (!id || id.length > 128) {
    return Response.json({ error: "Enter a credential ID of 1–128 characters." }, { status: 400 });
  }

  const expression = `${GNO_NETWORK.realmPath}.IsCredentialValid(${JSON.stringify(id)})`;
  const data = Buffer.from(expression, "utf8").toString("base64");

  try {
    const rpcResponse = await fetch(GNO_NETWORK.rpcUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        jsonrpc: "2.0",
        id: 1,
        method: "abci_query",
        params: { path: "vm/qeval_json", data, prove: false },
      }),
      cache: "no-store",
    });

    if (!rpcResponse.ok) {
      return Response.json({ error: "The Onyx RPC endpoint is unavailable." }, { status: 502 });
    }

    const rpc = (await rpcResponse.json()) as AbciQueryResponse;
    const responseBase = rpc.result?.response?.ResponseBase;

    if (!responseBase) {
      return Response.json({ error: "Onyx returned an unexpected query response." }, { status: 502 });
    }

    if (responseBase.Error) {
      return Response.json(
        {
          status: "realm_not_deployed",
          error: "The Credora registry realm is not deployed at the configured Onyx address yet.",
          chainId: GNO_NETWORK.chainId,
          realmPath: GNO_NETWORK.realmPath,
        },
        { status: 503 },
      );
    }

    if (!responseBase.Data) {
      return Response.json({ error: "The registry returned no credential result." }, { status: 502 });
    }

    const decoded: unknown = JSON.parse(Buffer.from(responseBase.Data, "base64").toString("utf8"));
    let valid: boolean;
    try {
      valid = parseCredentialValidityResult(decoded);
    } catch {
      return Response.json({ error: "The registry returned an unrecognised credential result." }, { status: 502 });
    }

    return Response.json(
      { id, valid, chainId: GNO_NETWORK.chainId, realmPath: GNO_NETWORK.realmPath },
      { headers: { "Cache-Control": "no-store" } },
    );
  } catch {
    return Response.json({ error: "Could not reach or decode the Onyx credential registry." }, { status: 502 });
  }
}
