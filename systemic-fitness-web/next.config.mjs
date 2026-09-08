/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "standalone",
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
    remotePatterns: [
      {
        protocol: "http",
        hostname: "localhost",
        port: "8080",
        pathname: "/uploads/**",
      },
      {
        protocol: "http",
        hostname: "192.168.12.16",
        port: "8080",
        pathname: "/uploads/**",
      },
      {
        protocol: "https",
        hostname: "systemic-fitness-production.up.railway.app",
        pathname: "/uploads/**",
      },
    ],
  },
  // Proxy requests to the backend API so we don't need to expose port 8080
  async rewrites() {
    // Determine the API URL: prioritize internal Docker network name, fallback to localhost
    const apiUrl = process.env.INTERNAL_API_URL || "http://192.168.12.16:8080";
    return [
      {
        source: "/backend-api/:path*",
        destination: `${apiUrl}/api/:path*`,
      },
      {
        source: "/uploads/:path*",
        destination: `${apiUrl}/uploads/:path*`,
      },
    ];
  },
};

export default nextConfig;
