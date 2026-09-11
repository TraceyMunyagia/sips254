create table if not exists likes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade not null,
  cocktail_id uuid references cocktails(id) on delete cascade not null,
  created_at timestamptz default now(),
  unique (user_id, cocktail_id)
);

create table if not exists saves (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade not null,
  cocktail_id uuid references cocktails(id) on delete cascade not null,
  created_at timestamptz default now(),
  unique (user_id, cocktail_id)
);

create table if not exists comments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade not null,
  cocktail_id uuid references cocktails(id) on delete cascade not null,
  content text not null,
  created_at timestamptz default now()
);

create table if not exists follows (
  id uuid primary key default gen_random_uuid(),
  follower_id uuid references profiles(id) on delete cascade not null,
  following_id uuid references profiles(id) on delete cascade not null,
  created_at timestamptz default now(),
  unique (follower_id, following_id),
  constraint no_self_follow check (follower_id != following_id)
);

create index if not exists idx_likes_cocktail on likes(cocktail_id);
create index if not exists idx_saves_cocktail on saves(cocktail_id);
create index if not exists idx_comments_cocktail on comments(cocktail_id);
create index if not exists idx_follows_follower on follows(follower_id);
create index if not exists idx_follows_following on follows(following_id);

alter table likes enable row level security;
alter table saves enable row level security;
alter table comments enable row level security;
alter table follows enable row level security;

create policy "Public read" on likes for select using (true);
create policy "Users manage own likes" on likes for insert with check (auth.uid() = user_id);
create policy "Users remove own likes" on likes for delete using (auth.uid() = user_id);

create policy "Public read" on saves for select using (true);
create policy "Users manage own saves" on saves for insert with check (auth.uid() = user_id);
create policy "Users remove own saves" on saves for delete using (auth.uid() = user_id);

create policy "Public read" on comments for select using (true);
create policy "Users add own comments" on comments for insert with check (auth.uid() = user_id);
create policy "Users delete own comments" on comments for delete using (auth.uid() = user_id);

create policy "Public read" on follows for select using (true);
create policy "Users manage own follows" on follows for insert with check (auth.uid() = follower_id);
create policy "Users remove own follows" on follows for delete using (auth.uid() = follower_id);