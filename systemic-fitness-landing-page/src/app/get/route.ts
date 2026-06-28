import { NextResponse } from "next/server";
import { getWhatsAppUrl } from "@/lib/whatsapp";

export const dynamic = "force-dynamic";

export function GET(req: Request) {
  const acceptLang = req.headers.get("accept-language") || "";
  const locale = acceptLang.toLowerCase().includes("id") ? "id" : "en";
  const target = getWhatsAppUrl(locale);
  return NextResponse.redirect(target, 302);
}

