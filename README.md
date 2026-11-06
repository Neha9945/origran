# ORIGRAN SPICES — Complete Website Starter

A premium, responsive storefront and admin prototype with a cloud-backend integration path.

## What is included

- Premium responsive storefront: home, retail shop, wholesale, about and contact
- Product catalogue with pack size, retail price, wholesale price, MOQ and stock
- Persistent browser-demo cart, quantity controls and coupon application
- Retail and wholesale account application flows
- Demo checkout and order records
- Admin dashboard: products, offers, orders, customers, wholesale approvals and inventory
- Supabase SQL schema with Row Level Security policies
- Razorpay payment integration outline and secure server-side payment verification function
- Draft FAQ, shipping, returns, privacy and terms pages

## Important: demo mode vs live business mode

The website runs immediately in **demo mode** when Supabase settings are blank. Demo products, cart, customers, coupons and orders are stored in the current browser's local storage. This is useful for previewing the layout and admin interactions, but it is **not** a shared database, secure authentication, or a live payment system.

For a real business launch, configure Supabase and Razorpay as described below. Do not accept real customer orders or payments until the backend, RLS policies, merchant account and order workflow have been tested.

## Preview locally

1. Install Node.js 20+.
2. Open a terminal in this folder.
3. Run `npx serve .` (or use VS Code Live Server).
4. Open the local address shown by the server.

The Supabase JS client is loaded from jsDelivr as an ES module. A local web server is required; opening `index.html` directly as a file may block module imports.

## Publish a visual preview

You can upload these files to a GitHub repository and enable GitHub Pages. This publishes the demo storefront only. GitHub Pages is static hosting and does not run private server code or payment verification. For production, use a backend host / Supabase Edge Functions and configure your own domain.

## Connect Supabase (production foundation)

1. Create a Supabase project owned by the business email.
2. In Supabase SQL Editor, run `supabase/schema.sql`.
3. Copy the Project URL and anon/publishable key into `config.js`.
4. Enable email/password authentication in Supabase Auth.
5. Configure Storage bucket `product-images` as private or public according to your chosen image delivery model.
6. Create the first admin account using Supabase Auth. Then, in SQL Editor, set that user's profile role to `admin`:

   ```sql
   update public.profiles set role = 'admin'
   where id = (select id from auth.users where email = 'YOUR_ADMIN_EMAIL');
   ```

7. Add production products and prices in the database. Replace demo product reads/writes with the Supabase data operations in your production integration pass. The current UI demonstrates the workflows and contains the Supabase auth and order-insert starting points; not every admin CRUD action is yet wired to cloud tables.
8. Review all Row Level Security policies with a developer before going live.

## Razorpay (real payments)

- Create a Razorpay merchant account in the business owner's name and complete KYC.
- Keep `RAZORPAY_KEY_ID` and `RAZORPAY_KEY_SECRET` only in server-side / Supabase Edge Function secrets. Never put the secret in `config.js`, HTML, JavaScript, GitHub or chat.
- Deploy the Edge Function in `supabase/functions/razorpay-order/` and configure the secrets.
- Add a separate payment verification function and webhook before marking any order as paid.
- Test successful, failed, cancelled and duplicate payment callbacks in Razorpay test mode before enabling live mode.

The included edge function is a starting point for creating a Razorpay order. It is not a substitute for a complete payment verification and webhook implementation.

## Demo admin

- Email: `admin@origran.demo`
- Password: `origran-demo-2026`

This is a **public demo credential**, not secure. Do not use it for a live site. Configure a real Supabase admin account and remove demo admin login before production.

## Before launch — business details to confirm

- Final legal business name, registered address and customer-support phone/email
- Whether ORIGRAN is the final consumer-facing brand
- Actual product list, origin, ingredients, net weight, FSSAI/licensing and label declarations
- Actual retail and wholesale prices, GST treatment, MOQ and shipping charges
- Product photography and approved brand story
- Return/refund, shipping, privacy and terms policies
- FSSAI and other applicable registrations / labelling requirements for packaged food
- Domain, hosting, database and payment gateway ownership under the business

## Architecture recommendation

- Frontend: this responsive HTML/CSS/JavaScript starter (can be migrated to Next.js later)
- Database + authentication: Supabase Postgres and Supabase Auth
- Product images: Supabase Storage
- Payments: Razorpay Checkout with server-side order creation, signature verification and webhooks
- Hosting: Vercel / Netlify for frontend; Supabase for database and Edge Functions
- Domain: registered in the business owner's account

The business should own the domain registrar, hosting, Supabase organization/project, Razorpay merchant account, email service and analytics accounts. Give Sinu and developers delegated access rather than making them the sole owners.
