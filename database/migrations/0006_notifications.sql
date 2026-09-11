create table if not exists notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid references profiles(id) on delete cascade not null,
  actor_id uuid references profiles(id) on delete cascade,
  type text not null check (type in ('like', 'comment', 'follow', 'remix')),
  cocktail_id uuid references cocktails(id) on delete cascade,
  is_read boolean default false,
  created_at timestamptz default now()
);

create index if not exists idx_notifications_recipient on notifications(recipient_id, is_read);

alter table notifications enable row level security;

create policy "Users read own notifications"
  on notifications for select
  using (auth.uid() = recipient_id);

create policy "System can insert notifications"
  on notifications for insert
  with check (true); -- tightened later once triggers/backend own writes

-- Auto-create a notification whenever someone likes a cocktail
create or replace function notify_on_like()
returns trigger as $$
begin
  insert into notifications (recipient_id, actor_id, type, cocktail_id)
  select c.created_by, new.user_id, 'like', new.cocktail_id
  from cocktails c
  where c.id = new.cocktail_id and c.created_by != new.user_id;
  return new;
end;
$$ language plpgsql security definer;

create trigger trg_notify_on_like
  after insert on likes
  for each row execute function notify_on_like();

-- Auto-create a notification whenever someone follows a user
create or replace function notify_on_follow()
returns trigger as $$
begin
  insert into notifications (recipient_id, actor_id, type)
  values (new.following_id, new.follower_id, 'follow');
  return new;
end;
$$ language plpgsql security definer;

create trigger trg_notify_on_follow
  after insert on follows
  for each row execute function notify_on_follow();