# ORIGRAN launch checklist

## Brand and product content
- [ ] Confirm ORIGRAN is the final approved brand name.
- [ ] Confirm business legal name, address, phone and support email.
- [ ] Replace all sample product images with actual product photography.
- [ ] Verify product names, net weights, ingredients, origin and pack variants.
- [ ] Enter actual retail price, wholesale price, MOQ and stock.
- [ ] Confirm whether prices include GST and configure invoices accordingly.

## Operations and compliance
- [ ] Confirm applicable FSSAI registration/licence and food labelling requirements.
- [ ] Confirm GST registration/tax invoice requirements with an accountant.
- [ ] Confirm shipping regions, courier, delivery estimates and shipping rates.
- [ ] Publish reviewed shipping, return/refund, privacy and terms policies.
- [ ] Set up customer support email and WhatsApp number.
- [ ] Decide how wholesale orders, quotations and credit terms are approved.

## Technical
- [ ] Business owns domain registrar and hosting accounts.
- [ ] Business owns Supabase organization and project.
- [ ] Supabase Auth email templates and recovery flow configured.
- [ ] RLS tested using retail, wholesale, unapproved and admin accounts.
- [ ] Product image upload/storage policies configured.
- [ ] Admin-only product, coupon, inventory and order operations tested.
- [ ] Razorpay KYC complete; test-mode payments passed.
- [ ] Server-side payment signature verification and webhook implemented.
- [ ] Payment success/failure/cancel/retry and duplicate webhook handling tested.
- [ ] Order confirmation email/SMS/WhatsApp notifications configured.
- [ ] Backups, logging, analytics and error monitoring configured.
- [ ] Mobile, tablet and desktop testing completed.
- [ ] Final security review completed before accepting live orders.

## Ownership
All critical accounts should be registered to the business owner/business email. Give contractors delegated access. Never share Supabase service-role keys, payment secrets or email-provider API keys in frontend code or public repositories.
