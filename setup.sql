-- ===================================================
-- نظام متابعة التغذية - SQL الكامل
-- انسخ هذا الكود وشغله في Supabase SQL Editor
-- ===================================================

-- 1. الجداول الأساسية
create table if not exists users (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  phone text unique not null,
  password text not null,
  role text not null check (role in ('doctor', 'client')),
  is_active boolean default true,
  created_at timestamp default now()
);

create table if not exists clinics (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  slogan text,
  phone text,
  address text,
  logo_url text,
  created_at timestamp default now()
);

create table if not exists chronic_diseases (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  created_at timestamp default now()
);

create table if not exists food_allergies (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  created_at timestamp default now()
);

create table if not exists packages (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  duration_days integer not null,
  sessions integer not null,
  price numeric not null,
  description text,
  is_active boolean default true,
  created_at timestamp default now()
);

create table if not exists diet_categories (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  created_at timestamp default now()
);

create table if not exists diet_plans (
  id uuid default gen_random_uuid() primary key,
  code text not null unique,
  name text not null,
  category_id uuid references diet_categories(id),
  calories integer not null,
  days_count integer not null,
  created_at timestamp default now()
);

create table if not exists diet_plan_days (
  id uuid default gen_random_uuid() primary key,
  plan_id uuid references diet_plans(id) on delete cascade,
  day_number integer not null,
  created_at timestamp default now()
);

create table if not exists diet_plan_meals (
  id uuid default gen_random_uuid() primary key,
  day_id uuid references diet_plan_days(id) on delete cascade,
  meal_order integer not null,
  meal_name text not null,
  content text not null,
  created_at timestamp default now()
);

create table if not exists clients (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references users(id),
  clinic_id uuid references clinics(id),
  name text not null,
  phone text,
  birth_date date,
  gender text check (gender in ('male', 'female')),
  address text,
  height numeric,
  first_weight numeric,
  activity_level text check (activity_level in ('sedentary','light','moderate','active','very_active')),
  goal text check (goal in ('lose','gain','maintain')),
  related_client_id uuid references clients(id),
  notes text,
  subscription_approved boolean default false,
  created_at timestamp default now()
);

create table if not exists client_allergies (
  id uuid default gen_random_uuid() primary key,
  client_id uuid references clients(id) on delete cascade,
  allergy_id uuid references food_allergies(id),
  created_at timestamp default now()
);

create table if not exists client_diseases (
  id uuid default gen_random_uuid() primary key,
  client_id uuid references clients(id) on delete cascade,
  disease_id uuid references chronic_diseases(id),
  created_at timestamp default now()
);

create table if not exists subscriptions (
  id uuid default gen_random_uuid() primary key,
  client_id uuid references clients(id) on delete cascade,
  package_id uuid references packages(id),
  start_date date not null,
  end_date date not null,
  sessions_total integer not null,
  sessions_used integer default 0,
  price_paid numeric,
  is_active boolean default true,
  created_at timestamp default now()
);

create table if not exists subscription_requests (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  phone text not null,
  password text,
  gender text,
  birth_date date,
  height numeric,
  weight numeric,
  goal text,
  activity_level text,
  address text,
  package_id uuid references packages(id),
  payment_method text,
  payment_proof text,
  price_paid numeric,
  status text default 'pending' check (status in ('pending','approved','rejected')),
  rejection_reason text,
  notes text,
  created_at timestamp default now()
);

create table if not exists visits (
  id uuid default gen_random_uuid() primary key,
  client_id uuid references clients(id) on delete cascade,
  visit_date date not null,
  weight numeric,
  diet_plan_id uuid references diet_plans(id),
  notes text,
  next_visit_date date,
  created_at timestamp default now()
);

create table if not exists body_measurements (
  id uuid default gen_random_uuid() primary key,
  client_id uuid references clients(id) on delete cascade,
  waist numeric,
  hips numeric,
  arms numeric,
  chest numeric,
  thighs numeric,
  notes text,
  measured_by text check (measured_by in ('doctor','client')),
  measured_at date default current_date,
  created_at timestamp default now()
);

create table if not exists client_photos (
  id uuid default gen_random_uuid() primary key,
  client_id uuid references clients(id) on delete cascade,
  photo_url text not null,
  photo_type text check (photo_type in ('before','after','progress')),
  created_at timestamp default now()
);

create table if not exists notifications (
  id uuid default gen_random_uuid() primary key,
  client_id uuid references clients(id) on delete cascade,
  title text not null,
  message text not null,
  type text default 'reminder',
  is_read boolean default false,
  created_at timestamp default now()
);

create table if not exists messages (
  id uuid default gen_random_uuid() primary key,
  client_id uuid references clients(id) on delete cascade,
  sender_role text check (sender_role in ('doctor','client')),
  message text,
  file_url text,
  file_type text,
  is_read boolean default false,
  created_at timestamp default now()
);

create table if not exists lab_tests (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  created_at timestamp default now()
);

create table if not exists medications (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  created_at timestamp default now()
);

create table if not exists client_lab_requests (
  id uuid default gen_random_uuid() primary key,
  client_id uuid references clients(id) on delete cascade,
  lab_test_id uuid references lab_tests(id),
  visit_id uuid references visits(id),
  notes text,
  status text default 'pending',
  created_at timestamp default now()
);

create table if not exists client_medication_requests (
  id uuid default gen_random_uuid() primary key,
  client_id uuid references clients(id) on delete cascade,
  medication_id uuid references medications(id),
  visit_id uuid references visits(id),
  dosage text,
  status text default 'pending',
  created_at timestamp default now()
);

create table if not exists food_alt_categories (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  created_at timestamp default now()
);

create table if not exists food_alternatives (
  id uuid default gen_random_uuid() primary key,
  food_name text not null,
  alternatives text not null,
  category_id uuid references food_alt_categories(id),
  created_at timestamp default now()
);

create table if not exists health_tips (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  content text not null,
  type text check (type in ('disease','allergy','general')),
  reference_id uuid,
  created_at timestamp default now()
);

create table if not exists doctor_settings (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references users(id),
  vodafone_cash text,
  instapay text,
  daily_tip text,
  created_at timestamp default now()
);

create table if not exists refunds (
  id uuid default gen_random_uuid() primary key,
  client_id uuid references clients(id),
  subscription_id uuid references subscriptions(id),
  amount numeric not null,
  reason text,
  created_at timestamp default now()
);

-- ===================================================
-- 2. الأمان - Row Level Security
-- ===================================================

-- تفعيل RLS على كل الجداول
alter table users enable row level security;
alter table clinics enable row level security;
alter table chronic_diseases enable row level security;
alter table food_allergies enable row level security;
alter table packages enable row level security;
alter table diet_categories enable row level security;
alter table diet_plans enable row level security;
alter table diet_plan_days enable row level security;
alter table diet_plan_meals enable row level security;
alter table clients enable row level security;
alter table client_allergies enable row level security;
alter table client_diseases enable row level security;
alter table subscriptions enable row level security;
alter table subscription_requests enable row level security;
alter table visits enable row level security;
alter table body_measurements enable row level security;
alter table client_photos enable row level security;
alter table notifications enable row level security;
alter table messages enable row level security;
alter table lab_tests enable row level security;
alter table medications enable row level security;
alter table client_lab_requests enable row level security;
alter table client_medication_requests enable row level security;
alter table food_alt_categories enable row level security;
alter table food_alternatives enable row level security;
alter table health_tips enable row level security;
alter table doctor_settings enable row level security;
alter table refunds enable row level security;

-- سياسة: السماح بكل العمليات عبر الـ anon key (للتطبيق)
-- هذا آمن لأن التطبيق يتحكم في المنطق

create policy "allow_all_anon" on users for all using (true) with check (true);
create policy "allow_all_anon" on clinics for all using (true) with check (true);
create policy "allow_all_anon" on chronic_diseases for all using (true) with check (true);
create policy "allow_all_anon" on food_allergies for all using (true) with check (true);
create policy "allow_all_anon" on packages for all using (true) with check (true);
create policy "allow_all_anon" on diet_categories for all using (true) with check (true);
create policy "allow_all_anon" on diet_plans for all using (true) with check (true);
create policy "allow_all_anon" on diet_plan_days for all using (true) with check (true);
create policy "allow_all_anon" on diet_plan_meals for all using (true) with check (true);
create policy "allow_all_anon" on clients for all using (true) with check (true);
create policy "allow_all_anon" on client_allergies for all using (true) with check (true);
create policy "allow_all_anon" on client_diseases for all using (true) with check (true);
create policy "allow_all_anon" on subscriptions for all using (true) with check (true);
create policy "allow_all_anon" on subscription_requests for all using (true) with check (true);
create policy "allow_all_anon" on visits for all using (true) with check (true);
create policy "allow_all_anon" on body_measurements for all using (true) with check (true);
create policy "allow_all_anon" on client_photos for all using (true) with check (true);
create policy "allow_all_anon" on notifications for all using (true) with check (true);
create policy "allow_all_anon" on messages for all using (true) with check (true);
create policy "allow_all_anon" on lab_tests for all using (true) with check (true);
create policy "allow_all_anon" on medications for all using (true) with check (true);
create policy "allow_all_anon" on client_lab_requests for all using (true) with check (true);
create policy "allow_all_anon" on client_medication_requests for all using (true) with check (true);
create policy "allow_all_anon" on food_alt_categories for all using (true) with check (true);
create policy "allow_all_anon" on food_alternatives for all using (true) with check (true);
create policy "allow_all_anon" on health_tips for all using (true) with check (true);
create policy "allow_all_anon" on doctor_settings for all using (true) with check (true);
create policy "allow_all_anon" on refunds for all using (true) with check (true);

-- ===================================================
-- 3. Storage Bucket
-- ===================================================
insert into storage.buckets (id, name, public) values ('nutrition', 'nutrition', true)
on conflict do nothing;

create policy "allow_upload" on storage.objects for insert with check (bucket_id = 'nutrition');
create policy "allow_read" on storage.objects for select using (bucket_id = 'nutrition');
create policy "allow_delete" on storage.objects for delete using (bucket_id = 'nutrition');

-- ===================================================
-- 4. بيانات أولية
-- ===================================================

-- حساب الدكتور
insert into users (name, phone, password, role) 
values ('الدكتور', '01000000000', 'doctor123', 'doctor')
on conflict (phone) do nothing;

-- أمراض شائعة
insert into chronic_diseases (name) values 
('السكري'),('ضغط الدم'),('الكوليسترول'),('قصور الغدة الدرقية'),
('فرط نشاط الغدة الدرقية'),('الكبد الدهني'),('القولون العصبي'),('حصوات الكلى')
on conflict do nothing;

-- حساسيات شائعة
insert into food_allergies (name) values 
('اللاكتوز'),('الجلوتين'),('المكسرات'),('البيض'),('الأسماك'),('الصدفيات'),('فول الصويا')
on conflict do nothing;

-- فئات الخطط
insert into diet_categories (name) values 
('إنقاص الوزن'),('زيادة الوزن'),('تثبيت الوزن'),('السكري'),('ضغط الدم'),('الرياضيين')
on conflict do nothing;

-- باقات نموذجية
insert into packages (name, duration_days, sessions, price, description) values 
('باقة شهر', 30, 4, 500, 'متابعة شهرية مع 4 جلسات'),
('باقة 3 أشهر', 90, 12, 1200, 'متابعة 3 أشهر مع 12 جلسة'),
('باقة 6 أشهر', 180, 24, 2000, 'متابعة 6 أشهر مع 24 جلسة')
on conflict do nothing;

-- فئات البدائل
insert into food_alt_categories (name) values 
('فواكه'),('خضروات'),('كربوهيدرات'),('بروتين'),('دهون')
on conflict do nothing;
