# 🌐 FinSight Web App - Next.js + Tailwind CSS

## 📋 Overview

Dokumentasi lengkap untuk membuat **FinSight Web App** menggunakan Next.js 15 + Tailwind CSS v4.

---

## 🚀 Setup Instructions

### 1. Create Next.js Project

```bash
# Di folder FinSight, buat folder web-app
cd C:\laragon\www\FinSight

# Create Next.js app (pilih opsi berikut):
npx create-next-app@latest web-app

# Saat ditanya, pilih:
✔ Would you like to use TypeScript? … Yes
✔ Would you like to use ESLint? … Yes
✔ Would you like to use Tailwind CSS? … Yes
✔ Would you like your code inside a `src/` directory? … Yes
✔ Would you like to use App Router? … Yes
✔ Would you like to use Turbopack for `next dev`? … Yes
✔ Would you like to customize the import alias? … No
```

### 2. Install Dependencies

```bash
cd web-app

# Install additional packages
npm install @heroicons/react recharts date-fns clsx tailwind-merge
npm install -D @types/node
```

---

## 📁 Project Structure

```
web-app/
├── src/
│   ├── app/
│   │   ├── (auth)/
│   │   │   └── login/
│   │   │       └── page.tsx
│   │   ├── (dashboard)/
│   │   │   ├── layout.tsx
│   │   │   ├── page.tsx              # Dashboard
│   │   │   ├── kasir/
│   │   │   │   └── page.tsx          # POS
│   │   │   ├── produk/
│   │   │   │   └── page.tsx          # Products
│   │   │   ├── stok/
│   │   │   │   └── page.tsx          # Stock
│   │   │   ├── laporan/
│   │   │   │   └── page.tsx          # Reports
│   │   │   ├── staff/
│   │   │   │   └── page.tsx          # Staff
│   │   │   └── pengaturan/
│   │   │       └── page.tsx          # Settings
│   │   ├── layout.tsx
│   │   └── globals.css
│   ├── components/
│   │   ├── ui/
│   │   │   ├── Button.tsx
│   │   │   ├── Card.tsx
│   │   │   ├── Input.tsx
│   │   │   └── Badge.tsx
│   │   ├── dashboard/
│   │   │   ├── SummaryCard.tsx
│   │   │   ├── MenuGrid.tsx
│   │   │   └── Sidebar.tsx
│   │   ├── kasir/
│   │   │   ├── ProductGrid.tsx
│   │   │   ├── Cart.tsx
│   │   │   └── PaymentModal.tsx
│   │   └── shared/
│   │       ├── Header.tsx
│   │       └── Footer.tsx
│   ├── lib/
│   │   ├── utils.ts
│   │   ├── constants.ts
│   │   └── dummy-data.ts
│   └── types/
│       ├── product.ts
│       └── transaction.ts
├── public/
│   └── images/
├── tailwind.config.ts
├── next.config.ts
└── package.json
```

---

## 🎨 Tailwind Configuration

### `tailwind.config.ts`

```typescript
import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        // Primary - Navy Blue
        primary: {
          50: "#f8fafc",
          100: "#f1f5f9",
          200: "#e2e8f0",
          300: "#cbd5e1",
          400: "#94a3b8",
          500: "#64748b",
          600: "#475569",
          700: "#334155",
          800: "#1e293b",
          900: "#0f172a",
          950: "#020617",
        },
        // Secondary - Emerald Green
        secondary: {
          50: "#ecfdf5",
          100: "#d1fae5",
          200: "#a7f3d0",
          300: "#6ee7b7",
          400: "#34d399",
          500: "#10b981",
          600: "#059669",
          700: "#047857",
          800: "#065f46",
          900: "#064e3b",
          950: "#022c22",
        },
        // Accent - Blue
        accent: {
          50: "#eff6ff",
          100: "#dbeafe",
          200: "#bfdbfe",
          300: "#93c5fd",
          400: "#60a5fa",
          500: "#3b82f6",
          600: "#2563eb",
          700: "#1d4ed8",
          800: "#1e40af",
          900: "#1e3a8a",
          950: "#172554",
        },
      },
      fontFamily: {
        sans: ["Inter", "system-ui", "sans-serif"],
      },
      boxShadow: {
        soft: "0 2px 8px rgba(0, 0, 0, 0.05)",
        medium: "0 4px 16px rgba(0, 0, 0, 0.08)",
        large: "0 8px 24px rgba(0, 0, 0, 0.12)",
      },
    },
  },
  plugins: [],
};

export default config;
```

---

## 🎯 Key Components

### 1. Login Page

**File**: `src/app/(auth)/login/page.tsx`

```typescript
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

export default function LoginPage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    // Simulate login
    setTimeout(() => {
      router.push("/");
    }, 1000);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-900 to-primary-800 flex items-center justify-center p-6">
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-20 h-20 bg-white rounded-2xl shadow-large mb-6">
            <svg
              className="w-12 h-12 text-secondary-500"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"
              />
            </svg>
          </div>
          <h1 className="text-4xl font-bold text-white mb-2">FinSight</h1>
          <p className="text-primary-200">Solusi POS & Keuangan UMKM</p>
        </div>

        {/* Login Card */}
        <div className="bg-white rounded-2xl shadow-large p-8">
          <h2 className="text-2xl font-bold text-primary-900 mb-2">
            Selamat Datang
          </h2>
          <p className="text-primary-500 mb-8">Masuk untuk melanjutkan</p>

          <form onSubmit={handleLogin} className="space-y-6">
            {/* Email Input */}
            <div>
              <label className="block text-sm font-medium text-primary-700 mb-2">
                Email
              </label>
              <input
                type="email"
                placeholder="nama@email.com"
                className="w-full px-4 py-3 border border-primary-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-accent-500 focus:border-transparent transition"
                required
              />
            </div>

            {/* Password Input */}
            <div>
              <label className="block text-sm font-medium text-primary-700 mb-2">
                Password
              </label>
              <input
                type="password"
                placeholder="••••••••"
                className="w-full px-4 py-3 border border-primary-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-accent-500 focus:border-transparent transition"
                required
              />
            </div>

            {/* Forgot Password */}
            <div className="text-right">
              <button
                type="button"
                className="text-sm text-accent-600 hover:text-accent-700 font-medium"
              >
                Lupa Password?
              </button>
            </div>

            {/* Login Button */}
            <button
              type="submit"
              disabled={isLoading}
              className="w-full bg-primary-900 text-white py-3 rounded-xl font-semibold hover:bg-primary-800 transition disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isLoading ? "Memproses..." : "Masuk"}
            </button>

            {/* Divider */}
            <div className="relative my-6">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-primary-200"></div>
              </div>
              <div className="relative flex justify-center text-sm">
                <span className="px-4 bg-white text-primary-400">atau</span>
              </div>
            </div>

            {/* Demo Button */}
            <button
              type="button"
              onClick={handleLogin}
              className="w-full border-2 border-primary-200 text-primary-900 py-3 rounded-xl font-semibold hover:bg-primary-50 transition"
            >
              Demo Mode
            </button>
          </form>
        </div>

        {/* Footer */}
        <p className="text-center text-primary-200 text-sm mt-8">
          © 2025 FinSight. All rights reserved.
        </p>
      </div>
    </div>
  );
}
```

---

### 2. Dashboard Layout

**File**: `src/app/(dashboard)/layout.tsx`

```typescript
import Sidebar from "@/components/dashboard/Sidebar";
import Header from "@/components/shared/Header";

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex h-screen bg-primary-50">
      {/* Sidebar - Hidden on mobile */}
      <Sidebar />

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        <Header />

        <main className="flex-1 overflow-y-auto p-6">
          <div className="max-w-7xl mx-auto">{children}</div>
        </main>
      </div>
    </div>
  );
}
```

---

### 3. Summary Card Component

**File**: `src/components/dashboard/SummaryCard.tsx`

```typescript
interface SummaryCardProps {
  title: string;
  value: string;
  icon: React.ReactNode;
  trend?: string;
  color?: "primary" | "secondary" | "accent";
}

export default function SummaryCard({
  title,
  value,
  icon,
  trend,
  color = "secondary",
}: SummaryCardProps) {
  const colorClasses = {
    primary: "bg-primary-100 text-primary-600",
    secondary: "bg-secondary-100 text-secondary-600",
    accent: "bg-accent-100 text-accent-600",
  };

  return (
    <div className="bg-white rounded-2xl p-6 border border-primary-100 shadow-soft hover:shadow-medium transition">
      {/* Icon */}
      <div className={`inline-flex p-3 rounded-xl ${colorClasses[color]} mb-4`}>
        {icon}
      </div>

      {/* Title */}
      <p className="text-sm text-primary-500 font-medium mb-1">{title}</p>

      {/* Value */}
      <p className="text-3xl font-bold text-primary-900 mb-2">{value}</p>

      {/* Trend (optional) */}
      {trend && (
        <div className="flex items-center text-sm text-secondary-600 font-semibold">
          <svg
            className="w-4 h-4 mr-1"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"
            />
          </svg>
          {trend}
        </div>
      )}
    </div>
  );
}
```

---

## 📱 Mobile-First Responsive Design

### Breakpoints

```typescript
// Tailwind default breakpoints
sm: '640px'   // Mobile landscape
md: '768px'   // Tablet
lg: '1024px'  // Desktop
xl: '1280px'  // Large desktop
2xl: '1536px' // Extra large
```

### Mobile Optimization

```tsx
// Example: Responsive grid
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
  {/* Cards */}
</div>

// Example: Hide sidebar on mobile
<aside className="hidden lg:block w-64">
  {/* Sidebar */}
</aside>

// Example: Mobile menu
<button className="lg:hidden">
  {/* Hamburger icon */}
</button>
```

---

## 🎨 Design System

### Colors

- **Primary**: Navy Blue (Slate palette)
- **Secondary**: Emerald Green
- **Accent**: Blue
- **Neutral**: Gray shades

### Typography

- **Font**: Inter (Google Fonts)
- **Sizes**: text-xs to text-4xl
- **Weights**: font-normal, font-medium, font-semibold, font-bold

### Spacing

- **Padding**: p-2, p-4, p-6, p-8
- **Margin**: m-2, m-4, m-6, m-8
- **Gap**: gap-2, gap-4, gap-6, gap-8

### Shadows

- **soft**: Subtle shadow
- **medium**: Medium shadow
- **large**: Large shadow

---

## 🚀 Running the Web App

```bash
# Development
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Lint
npm run lint
```

Access at: `http://localhost:3000`

---

## 📦 Deployment

### Vercel (Recommended)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel
```

### Netlify

```bash
# Build command
npm run build

# Publish directory
.next
```

---

## ✅ Checklist

- [ ] Setup Next.js project
- [ ] Install Tailwind CSS
- [ ] Configure colors & fonts
- [ ] Create layout components
- [ ] Build login page
- [ ] Build dashboard
- [ ] Build POS page
- [ ] Build product management
- [ ] Build stock management
- [ ] Build reports
- [ ] Build staff management
- [ ] Build settings
- [ ] Add responsive design
- [ ] Test on mobile
- [ ] Deploy

---

## 📚 Resources

- [Next.js Docs](https://nextjs.org/docs)
- [Tailwind CSS Docs](https://tailwindcss.com/docs)
- [Heroicons](https://heroicons.com/)
- [Recharts](https://recharts.org/)

---

**Status**: Ready for implementation! 🚀

Ikuti panduan ini untuk membuat web app yang profesional dan mobile-optimized.
