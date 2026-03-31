# SatuSatu Techstack Definition

Update this file when the techstack changes — the audit skill reads it at runtime.

## Framework
- **Next.js 16** (App Router)
  - `tencent edgeone` for image optimization https://www.tencentcloud.com/document/product/228/47823
  - `metadata` API for head management
  - Server Components by default
  - Streaming SSR with Suspense

## CDN / Edge
- **Tencent EdgeOne**
  - Edge caching with `s-maxage` / `Cache-Control`
  - Edge functions for dynamic routing
  - Global PoP distribution

## Deployment
- Production environment
