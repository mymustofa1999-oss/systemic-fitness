console.log("=== NEXT.CONFIG.JS LOADED (COMMONJS) ===");
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Prevent stale chunk errors by setting proper cache headers
  async headers() {
    return [
      {
        source: "/_next/static/:path*",
        headers: [
          {
            key: "Cache-Control",
            value: "public, max-age=31536000, immutable",
          },
        ],
      },
    ];
  },
  // Ensure images from API uploads can be loaded
  images: {
    domains: ["images.unsplash.com", "localhost", "api.systemicfitnesshealth.com"],
    remotePatterns: [
      {
        protocol: "http",
        hostname: "localhost",
        port: "8080",
      },
      {
        protocol: "https",
        hostname: "api.systemicfitnesshealth.com",
      },
      {
        protocol: "https",
        hostname: "images.unsplash.com",
      },
    ],
  },
};

module.exports = nextConfig;
