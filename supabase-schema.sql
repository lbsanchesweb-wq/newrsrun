-- RS Running — Schema completo
-- Cole este SQL no Supabase > SQL Editor > New Query

-- Extensões
create extension if not exists "uuid-ossp";

-- Profiles (professor e alunos)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  role text not null check (role in ('coach', 'student')),
  name text not null,
  email text not null,
  avatar_url text,
  whatsapp text,
  bio text,
  created_at timestamptz default now()
);

-- Alunos (dados extras)
create table public.students (
  id uuid references public.profiles(id) on delete cascade primary key,
  goal text,
  next_race text,
  total_km numeric default 0,
  total_workouts integer default 0,
  streak_days integer default 0,
  xp integer default 0,
  monthly_fee numeric default 0,
  pix_key text,
  created_at timestamptz default now()
);

-- Biblioteca de treinos do professor
create table public.workout_templates (
  id uuid default uuid_generate_v4() primary key,
  coach_id uuid references public.profiles(id) on delete cascade,
  type text not null check (type in ('rodagem_leve','rodagem_moderada','fartlek','tiros','longao','rampa','regenerativo','prova')),
  title text not null,
  description text,
  default_km numeric,
  default_duration integer,
  default_pace text,
  notes text,
  created_at timestamptz default now()
);

-- Semanas de treino
create table public.weeks (
  id uuid default uuid_generate_v4() primary key,
  student_id uuid references public.profiles(id) on delete cascade,
  coach_id uuid references public.profiles(id),
  label text not null,
  date_start date not null,
  date_end date not null,
  status text default 'draft' check (status in ('draft','published')),
  notes text,
  created_at timestamptz default now()
);

-- Treinos individuais da semana
create table public.workouts (
  id uuid default uuid_generate_v4() primary key,
  week_id uuid references public.weeks(id) on delete cascade,
  student_id uuid references public.profiles(id) on delete cascade,
  template_id uuid references public.workout_templates(id),
  type text not null,
  title text not null,
  description text,
  planned_km numeric,
  planned_duration integer,
  planned_pace text,
  suggested_day text,
  order_num integer default 1,
  status text default 'pending' check (status in ('pending','done','skipped')),
  done_at timestamptz,
  actual_km numeric,
  actual_duration integer,
  actual_pace text,
  feeling text check (feeling in ('facil','ok','dificil','muito_dificil')),
  notes text,
  created_at timestamptz default now()
);

-- Mensalidades
create table public.payments (
  id uuid default uuid_generate_v4() primary key,
  student_id uuid references public.profiles(id) on delete cascade,
  coach_id uuid references public.profiles(id),
  month text not null,
  amount numeric not null,
  due_date date,
  status text default 'pending' check (status in ('pending','paid','overdue')),
  paid_at timestamptz,
  pix_key text,
  notes text,
  created_at timestamptz default now()
);

-- Mensagens
create table public.messages (
  id uuid default uuid_generate_v4() primary key,
  from_id uuid references public.profiles(id) on delete cascade,
  to_id uuid references public.profiles(id) on delete cascade,
  content text not null,
  read boolean default false,
  created_at timestamptz default now()
);

-- Insígnias conquistadas
create table public.badges (
  id uuid default uuid_generate_v4() primary key,
  student_id uuid references public.profiles(id) on delete cascade,
  badge_key text not null,
  earned_at timestamptz default now(),
  unique(student_id, badge_key)
);

-- RLS (Row Level Security)
alter table public.profiles enable row level security;
alter table public.students enable row level security;
alter table public.workout_templates enable row level security;
alter table public.weeks enable row level security;
alter table public.workouts enable row level security;
alter table public.payments enable row level security;
alter table public.messages enable row level security;
alter table public.badges enable row level security;

-- Policies: profiles
create policy "Usuário vê próprio perfil" on public.profiles for select using (auth.uid() = id);
create policy "Coach vê todos os perfis" on public.profiles for select using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'coach')
);
create policy "Usuário atualiza próprio perfil" on public.profiles for update using (auth.uid() = id);
create policy "Insert próprio perfil" on public.profiles for insert with check (auth.uid() = id);

-- Policies: students
create policy "Aluno vê próprios dados" on public.students for select using (auth.uid() = id);
create policy "Coach vê todos alunos" on public.students for select using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'coach')
);
create policy "Aluno atualiza próprios dados" on public.students for update using (auth.uid() = id);
create policy "Coach atualiza dados de alunos" on public.students for update using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'coach')
);
create policy "Insert student" on public.students for insert with check (auth.uid() = id);

-- Policies: workout_templates
create policy "Coach gerencia templates" on public.workout_templates for all using (coach_id = auth.uid());
create policy "Aluno vê templates" on public.workout_templates for select using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'student')
);

-- Policies: weeks
create policy "Coach gerencia semanas" on public.weeks for all using (coach_id = auth.uid());
create policy "Aluno vê próprias semanas" on public.weeks for select using (student_id = auth.uid());

-- Policies: workouts
create policy "Coach gerencia treinos" on public.workouts for all using (
  exists (select 1 from public.weeks w where w.id = week_id and w.coach_id = auth.uid())
);
create policy "Aluno vê e atualiza próprios treinos" on public.workouts for select using (student_id = auth.uid());
create policy "Aluno marca treino concluído" on public.workouts for update using (student_id = auth.uid());

-- Policies: payments
create policy "Coach gerencia pagamentos" on public.payments for all using (coach_id = auth.uid());
create policy "Aluno vê próprios pagamentos" on public.payments for select using (student_id = auth.uid());

-- Policies: messages
create policy "Ver mensagens próprias" on public.messages for select using (
  from_id = auth.uid() or to_id = auth.uid()
);
create policy "Enviar mensagem" on public.messages for insert with check (from_id = auth.uid());
create policy "Marcar como lida" on public.messages for update using (to_id = auth.uid());

-- Policies: badges
create policy "Aluno vê próprias insígnias" on public.badges for select using (student_id = auth.uid());
create policy "Coach vê insígnias dos alunos" on public.badges for select using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'coach')
);
create policy "Sistema insere insígnias" on public.badges for insert with check (student_id = auth.uid());

-- Storage bucket para avatares
insert into storage.buckets (id, name, public) values ('avatars', 'avatars', true);
create policy "Avatar público" on storage.objects for select using (bucket_id = 'avatars');
create policy "Upload próprio avatar" on storage.objects for insert with check (
  bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]
);
create policy "Atualizar próprio avatar" on storage.objects for update using (
  bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]
);

-- Dados iniciais: biblioteca de treinos do Rui
-- (rodar após criar o usuário coach com o email sanchesrui64@gmail.com)
-- insert into public.workout_templates (coach_id, type, title, description, default_km) values
-- ('<COACH_UUID>', 'rodagem_leve', 'Rodagem leve', 'Ritmo confortável, conversa fácil', 6),
-- ('<COACH_UUID>', 'rodagem_moderada', 'Rodagem moderada', 'Ritmo controlado, respiração firme', 10),
-- ('<COACH_UUID>', 'fartlek', 'Fartlek', '2 min forte / 1 min fraco', 6),
-- ('<COACH_UUID>', 'tiros', 'Tiros 200m', 'Pausa 45 seg entre tiros', 5),
-- ('<COACH_UUID>', 'tiros', 'Tiros 300m', 'Pausa 40-50 seg entre tiros', 5),
-- ('<COACH_UUID>', 'longao', 'Longão progressivo', 'Ritmo aumenta a cada km', 20),
-- ('<COACH_UUID>', 'rampa', 'Rampa 30 min', 'Subida contínua em ritmo controlado', null),
-- ('<COACH_UUID>', 'regenerativo', 'Regenerativo', 'Bem leve, recuperação ativa', 5);
