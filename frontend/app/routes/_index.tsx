// @ts-nocheck
import { useEffect } from "react";
import type { MetaFunction } from "@remix-run/node";

export const meta: MetaFunction = () => {
  return [
    { title: "New Remix App" },
    { name: "description", content: "Welcome to Remix!" },
  ];
};

export default function Index() {
  useEffect(() => {
    if (window.LiqPayCheckoutCallback) return;

    window.LiqPayCheckoutCallback = function () {
      LiqPayCheckout.init({
        data: "eyJhY3Rpb24iOiJwYXkiLCJhbW91bnQiOjUwMSwiY3VycmVuY3kiOiJVU0QiLCJkZXNjcmlwdGlvbiI6Im15IG9yZGVyIiwib3JkZXJfaWQiOjExODgxLCJwdWJsaWNfa2V5Ijoic2FuZGJveF9pNzQzMzc3MDkwNiIsInNlcnZlcl91cmwiOiJodHRwczovLzc1MGQtMTc2LTM3LTE2NS0yNDMubmdyb2stZnJlZS5hcHAvd2ViaG9va3MvbGlxcGF5L3VwZGF0ZSIsInZlcnNpb24iOiIzIn0=",
        signature: "8wktUqxsuiFKypI+CjVUO7cuOPE=",
        embedTo: "#liqpay_checkout",
        language: "en",
        mode: "embed", // embed || popup
      })
        .on("liqpay.callback", function (data) {
          console.log(data.status);
          console.log(data);
        })
        .on("liqpay.ready", function (data) {
          // ready
        })
        .on("liqpay.close", function (data) {
          // close
        });
    };

    const script = document.createElement("script");
    script.src = "https://static.liqpay.ua/libjs/checkout.js";
    script.async = true;
    document.body.appendChild(script);
  }, []);

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
        <div id="liqpay_checkout"></div>
      </div>
    </div>
  );
}
