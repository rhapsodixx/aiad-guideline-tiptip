# TipTip React / Next.js Stack Conventions

## Base Assumptions
- Node.js LTS and Next.js 14+.
- Default to **App Router** (`app/` directory) unless the repo specifically indicates it is a legacy Pages Router project.
- Strict TypeScript. Ensure `tsconfig.json` strict mode is respected. No `any` types.

## Components & State
- File naming: PascalCase for components (`UserProfile.tsx`), camelCase for utilities (`formatDate.ts`).
- Co-locate tests and styles with the component (e.g., `Button.tsx`, `Button.test.tsx`).
- State Management: Prefer Zustand for global client state and React Query for server state/data fetching.

## API & Integration
- Frontend should call TipTip backend APIs via typed fetch wrappers or React Query hooks.
- Handle loading, error, and success states explicitly.

## Error Handling & UX
- Use React Error Boundaries for catching render errors.
- Display user-friendly toast notifications for operational errors or successful mutations.

## Styling & Performance
- Use Tailwind CSS for all styling.
- Utilize `next/image` for image optimization.
- Implement lazy loading for heavy components not visible on the initial viewport.
- Be conscious of bundle size; import libraries selectively.

## Anti-Patterns to Avoid
- Do not mix Server Components and Client Components incorrectly. Use `"use client"` only at the boundary leaf nodes where interactivity/React hooks are actually needed.
- Avoid legacy `getServerSideProps` or `getStaticProps` in App Router components.
- Do not leak secret environment variables to the client. Only prefix with `NEXT_PUBLIC_` if it is explicitly meant to be visible in the browser.
