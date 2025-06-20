import type { MetaFunction } from "@remix-run/node";

export const meta: MetaFunction = () => {
  return [
    { title: "New Remix App" },
    { name: "description", content: "Welcome to Remix!" },
  ];
};

export default function Index() {
  return (
    <div
      style={{
        display: "flex",
        width: "100%",
        alignItems: "center",
        background: "white",
        flexDirection: "column",
      }}
    >
      <div style={{ height: "100px" }}>It's my website</div>
      <div style={{ width: "500px", margin: "0 auto" }}>
        <div
          dangerouslySetInnerHTML={{
            __html:
              '<form method="POST" action="https://www.liqpay.ua/api/3/checkout" accept-charset="utf-8" >\n<input type="hidden" name="data" value="eyJkZXNjcmlwdGlvbiI6IkNvdXJzZSA5YTUxN2E5ZC1hYTZkLTRhYzgtYTA0Ni03N2JkZWVlNjZhOWEgcGF5bWVudCBmb3IgYzkxMDUyNjMtYTRhZS00ZDg4LWE5MjAtY2Q5OTM1YTZjMGNmIiwiY3VycmVuY3kiOiJVU0QiLCJhY3Rpb24iOiJwYXkiLCJhbW91bnQiOiIxMDAuMCIsInB1YmxpY19rZXkiOiJwdWJsaWNfa2V5Iiwic2VydmVyX3VybCI6Imh0dHA6Ly9sb2NhbGhvc3Q6NDAwMi93ZWJob29rcy9saXFwYXkvdXBkYXRlIiwidmVyc2lvbiI6IjMifQ==" />\n      <input type="hidden" name="signature" value="Dz1WjnsTccRucG06dmju5+nXm08=" />\n <script type="text/javascript" src="https://static.liqpay.ua/libjs/sdk_button.js"></script> \n <sdk-button label="' +
              "LiqPay checkout" +
              '" background="#77CC5D" onClick="submit()"></sdk-button>\n    </form>\n',
          }}
        ></div>
        <div id="liqpay_checkout"></div>
      </div>
    </div>
  );
}
