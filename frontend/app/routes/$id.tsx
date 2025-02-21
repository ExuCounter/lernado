import type { MetaFunction, LoaderFunctionArgs } from "@remix-run/node";
import { useLoaderData } from "@remix-run/react";

export const meta: MetaFunction = () => {
  return [
    { title: "New Remix App" },
    { name: "description", content: "Welcome to Remix!" },
  ];
};

const API_URL = process.env.API_URL as string;

export async function loader({ params }: LoaderFunctionArgs) {
  const data = await fetch(`${API_URL}/api/dummy/${params.id}`);
  const json = await data.json();

  return json as { message: string };
}

export default function Index() {
  const { message } = useLoaderData<typeof loader>();

  return <>{message}</>;
}
