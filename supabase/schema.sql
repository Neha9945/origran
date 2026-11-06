-- ORIGRAN SPICES database foundation
-- Run in Supabase SQL editor. Review policies with a qualified developer before launch.
create extension if not exists pgcrypto;

create type public.account_type as enum ('retail','wholesale');
create type public.user_role as enum ('customer','admin');
create type public.order_status as enum ('placed','confirmed','processing','dispatched','completed','cancelled');
create type public.payment_status as enum ('pending','paid','failed','refunded');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  account_type public.account_type not null default 'retail',
  business_name text,
  wholesale_status text not null default 'not_requested' check (wholesale_status in ('not_requested','pending','approved','rejected')),
  role public.user_role not null default 'customer',
  created_at timestamptz not null default now()
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  category text not null,
  description text,
  ingredients text,
  origin text,
  net_weight text not null,
  image_url text,
  retail_price numeric(12,2) not null check (retail_price >= 0),
  wholesale_price numeric(12,2) not null check (wholesale_price >= 0),
  wholesale_moq integer not null default 1 check (wholesale_moq > 0),
  stock_quantity integer not null default 0 check (stock_quantity >= 0),
  low_stock_threshold integer not null default 5,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.coupons (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  discount_type text not null check (discount_type in ('percent','flat')),
  discount_value numeric(12,2) not null check (discount_value > 0),
  starts_at timestamptz,
  ends_at timestamptz,
  usage_limit integer,
  used_count integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.profiles(id),
  order_number text unique not null,
  customer_name text not null,
  phone text not null,
  shipping_address jsonb not null,
  account_type public.account_type not null default 'retail',
  subtotal numeric(12,2) not null,
  discount numeric(12,2) not null default 0,
  shipping_fee numeric(12,2) not null default 0,
  total numeric(12,2) not null,
  status public.order_status not null default 'placed',
  payment_status public.payment_status not null default 'pending',
  payment_provider text,
  payment_reference text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id),
  product_name text not null,
  quantity integer not null check (quantity > 0),
  unit_price numeric(12,2) not null,
  line_total numeric(12,2) not null
);

create table public.wholesale_applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  business_name text not null,
  gstin text,
  business_type text,
  expected_monthly_quantity text,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  admin_note text,
  created_at timestamptz not null default now()
);

create table public.inventory_movements (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id),
  quantity_change integer not null,
  reason text not null,
  order_id uuid references public.orders(id),
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create table public.site_settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select exists(select 1 from public.profiles where id = auth.uid() and role = 'admin') $$;

alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.coupons enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.wholesale_applications enable row level security;
alter table public.inventory_movements enable row level security;
alter table public.site_settings enable row level security;

create policy "profile read own or admin" on public.profiles for select using (id = auth.uid() or public.is_admin());
create policy "profile update own or admin" on public.profiles for update using (id = auth.uid() or public.is_admin()) with check (id = auth.uid() or public.is_admin());
create policy "profile insert self" on public.profiles for insert with check (id = auth.uid());

create policy "active products public read" on public.products for select using (is_active = true or public.is_admin());
create policy "admin manage products" on public.products for all using (public.is_admin()) with check (public.is_admin());

create policy "active coupons public read" on public.coupons for select using (is_active = true or public.is_admin());
create policy "admin manage coupons" on public.coupons for all using (public.is_admin()) with check (public.is_admin());

create policy "customer read own orders" on public.orders for select using (customer_id = auth.uid() or public.is_admin());
create policy "customer create own orders" on public.orders for insert with check (customer_id = auth.uid());
create policy "admin update orders" on public.orders for update using (public.is_admin()) with check (public.is_admin());

create policy "read own order items" on public.order_items for select using (
  exists(select 1 from public.orders o where o.id = order_id and (o.customer_id = auth.uid() or public.is_admin()))
);
create policy "create own order items" on public.order_items for insert with check (
  exists(select 1 from public.orders o where o.id = order_id and o.customer_id = auth.uid())
);

create policy "read own wholesale applications" on public.wholesale_applications for select using (user_id = auth.uid() or public.is_admin());
create policy "create own wholesale application" on public.wholesale_applications for insert with check (user_id = auth.uid());
create policy "admin manage wholesale applications" on public.wholesale_applications for update using (public.is_admin()) with check (public.is_admin());

create policy "admin manage inventory movements" on public.inventory_movements for all using (public.is_admin()) with check (public.is_admin());
create policy "admin manage site settings" on public.site_settings for all using (public.is_admin()) with check (public.is_admin());

-- Create profile automatically for each newly registered auth user.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, account_type)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name',''), 'retail')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Add an initial public site configuration row.
insert into public.site_settings(key,value) values
('storefront', '{"brand":"ORIGRAN SPICES","tagline":"Pure Spices. Better Living.","currency":"INR"}'::jsonb)
on conflict (key) do nothing;
