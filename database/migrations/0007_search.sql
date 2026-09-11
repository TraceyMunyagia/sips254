-- Add generated tsvector columns for full-text search

alter table cocktails add column if not exists search_vector tsvector
  generated always as (
    setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(description, '')), 'B')
  ) stored;

alter table ingredients add column if not exists search_vector tsvector
  generated always as (to_tsvector('english', coalesce(name, ''))) stored;

alter table spirits add column if not exists search_vector tsvector
  generated always as (to_tsvector('english', coalesce(name, ''))) stored;

alter table profiles add column if not exists search_vector tsvector
  generated always as (to_tsvector('english', coalesce(username, ''))) stored;

create index if not exists idx_cocktails_search on cocktails using gin(search_vector);
create index if not exists idx_ingredients_search on ingredients using gin(search_vector);
create index if not exists idx_spirits_search on spirits using gin(search_vector);
create index if not exists idx_profiles_search on profiles using gin(search_vector);

-- Trending helper: cocktails ranked by likes in the last 7 days
create or replace view trending_cocktails as
select c.*, count(l.id) as recent_like_count
from cocktails c
left join likes l on l.cocktail_id = c.id and l.created_at > now() - interval '7 days'
where c.status = 'published'
group by c.id
order by recent_like_count desc, c.created_at desc;