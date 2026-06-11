# RS Running App v2.0

App de assessoria de corrida — Professor Rui Sanches

## Estrutura
- `/app/login` — Tela de login (professor e alunos)
- `/app/student` — Painel do aluno (treino do dia, semana, evolução, mensalidade, perfil)
- `/app/coach` — Painel do professor (visão geral dos alunos)
- `/app/training` — Montar e publicar treinos semanais
- `/app/financial` — Financeiro e mensalidades

## Passo 1 — Banco de dados (Supabase)

1. Acesse https://supabase.com/dashboard/project/oeszrnprhbcqawrfoybl
2. Clique em **SQL Editor** > **New Query**
3. Cole todo o conteúdo do arquivo `supabase-schema.sql`
4. Clique em **Run**

## Passo 2 — Criar usuário do professor

1. No Supabase, vá em **Authentication** > **Users** > **Add user**
2. E-mail: `sanchesrui64@gmail.com`
3. Senha: escolha uma senha segura
4. Após criar, copie o UUID do usuário
5. No SQL Editor, rode:

```sql
INSERT INTO public.profiles (id, role, name, email, whatsapp)
VALUES ('<UUID_DO_RUI>', 'coach', 'Rui Sanches', 'sanchesrui64@gmail.com', '5519XXXXXXXXX');

INSERT INTO public.workout_templates (coach_id, type, title, description, default_km) VALUES
('<UUID_DO_RUI>', 'rodagem_leve', 'Rodagem leve', 'Ritmo confortável, conversa fácil', 6),
('<UUID_DO_RUI>', 'rodagem_moderada', 'Rodagem moderada', 'Ritmo controlado', 10),
('<UUID_DO_RUI>', 'fartlek', 'Fartlek', '2 min forte / 1 min fraco', 6),
('<UUID_DO_RUI>', 'tiros', '14 × 200m (pausa 45s)', 'Tiros curtos intensos', 5),
('<UUID_DO_RUI>', 'tiros', '10 × 300m (pausa 40s)', 'Tiros médios', 5),
('<UUID_DO_RUI>', 'tiros', '8 × 300m (pausa 50s)', 'Tiros médios', 5),
('<UUID_DO_RUI>', 'tiros', '4×200 + 4×300 + 4×200', 'Pirâmide de tiros', 5),
('<UUID_DO_RUI>', 'longao', 'Longão progressivo', 'Ritmo aumenta a cada km', 28),
('<UUID_DO_RUI>', 'rampa', 'Rampa 30 min', 'Subida contínua', null),
('<UUID_DO_RUI>', 'rampa', 'Rampa 35 min', 'Subida contínua', null),
('<UUID_DO_RUI>', 'regenerativo', 'Regenerativo 5km', 'Bem leve, recuperação ativa', 5);
```

## Passo 3 — Criar alunos

Para cada aluno, criar usuário no Supabase Auth e inserir no profiles:

```sql
-- Após criar cada aluno no Auth, rode para cada um:
INSERT INTO public.profiles (id, role, name, email)
VALUES ('<UUID_DO_ALUNO>', 'student', 'Nome do Aluno', 'email@aluno.com');

INSERT INTO public.students (id, monthly_fee)
VALUES ('<UUID_DO_ALUNO>', 249.00);
```

**Alunos para cadastrar:**
- Ana Júlia — ana.julia.pereira2507@gmail.com
- Carlos — (sem e-mail, pedir)
- Dani Conti — danielaled@bol.com.br
- M. Laura — betmarialaura@gmail.com
- Erika — cfranciscatto@gmail.com ou ecfranciscatto@gmail.com
- Célia — celia_mnascimento@hotmail.com
- Leo — leopb20@hotmail.com
- Claudia — clau_martu2009@hotmail.com
- Eliane — elianegoncalvesbicudo@gmail.com
- Débora — deboramarchesini.dm@gmail.com
- Rafael — Senciattirafael@gmail.com
- Gláucia — glau.rt@hotmail.com
- Tatiane — tatibrug@gmail.com
- Ayane — ayanne_lisiane@hotmail.com

## Passo 4 — Deploy no Vercel

1. Faça upload deste código no GitHub (substituindo o repositório atual)
2. No Vercel, vá em **Settings** > **Environment Variables**
3. Adicione:
   - `NEXT_PUBLIC_SUPABASE_URL` = `https://oeszrnprhbcqawrfoybl.supabase.co`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY` = (sua anon key)
4. Clique em **Redeploy**

## Fluxo de uso

**Professor:**
1. Faz login com seu e-mail
2. Vai em **Treinos** > seleciona o aluno
3. Adiciona treinos da biblioteca ou cria novos
4. Clica em **Publicar**
5. Aluno recebe automaticamente

**Aluno:**
1. Faz login com seu e-mail
2. Vê o treino do dia no painel
3. Clica em **Marcar como concluído**
4. Registra distância, sensação e notas
5. Acumula XP e conquista insígnias
