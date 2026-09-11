-- Reference tables first (referenced by cocktails)

create table if not exists categories (
  id uuid primary key default gen_random_uuid(),
  name text unique not null,
  description text
);

create table if not exists glassware (
  id uuid primary key default gen_random_uuid(),
  name text unique not null,
  description text
);

create table if not exists preparation_methods (
  id uuid primary key default gen_random_uuid(),
  name text unique not null,          -- e.g. "Shaken", "Stirred", "Built"
  description text
);

create table if not exists spirits (
  id uuid primary key default gen_random_uuid(),
  name text unique not null,           -- e.g. "Vodka", "Kenya Cane"
  category text,                       -- e.g. "White Spirit", "Rum", "Local Spirit"
  is_kenyan boolean default false
);

create table if not exists ingredients (
  id uuid primary key default gen_random_uuid(),
  name text unique not null,           -- e.g. "Passion Fruit Juice", "Lime"
  type text,                           -- e.g. "Juice", "Syrup", "Garnish", "Mixer"
  is_kenyan boolean default false
);

-- Core cocktails table with structured attributes for AI/recommendation matching

create table if not exists cocktails (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  category_id uuid references categories(id),
  glassware_id uuid references glassware(id),
  preparation_method_id uuid references preparation_methods(id),
  primary_spirit_id uuid references spirits(id),

  -- Structured attributes, 1-10 scale, used for AI matching & filtering
  strength smallint check (strength between 1 and 10),
  sweetness smallint check (sweetness between 1 and 10),
  sourness smallint check (sourness between 1 and 10),
  bitterness smallint check (bitterness between 1 and 10),
  fruitiness smallint check (fruitiness between 1 and 10),
  fizz smallint check (fizz between 1 and 10),
  difficulty smallint check (difficulty between 1 and 10),

  servings integer default 1,
  garnish text,
  instructions text not null,

  is_kenyan_inspired boolean default false,
  is_community_recipe boolean default false,
  status text default 'published' check (status in ('pending', 'published', 'reviewed', 'featured')),

  created_by uuid references profiles(id),
  photo_url text,

  created_at timestamptz default now()
);

-- Junction table: cocktail <-> ingredient with measurements

create table if not exists cocktail_ingredients (
  id uuid primary key default gen_random_uuid(),
  cocktail_id uuid references cocktails(id) on delete cascade not null,
  ingredient_id uuid references ingredients(id),
  spirit_id uuid references spirits(id),      -- nullable; an ingredient row is either a spirit or a plain ingredient
  amount numeric not null,
  unit text not null,                         -- e.g. "ml", "tsp", "dash", "whole"
  is_optional boolean default false,

  constraint one_reference_only check (
    (ingredient_id is not null and spirit_id is null) or
    (ingredient_id is null and spirit_id is not null)
  )
);

-- Home-alternative equipment mapping (professional method -> home substitute)

create table if not exists equipment_alternatives (
  id uuid primary key default gen_random_uuid(),
  professional_tool text unique not null,   -- e.g. "Jigger"
  home_alternative text not null,            -- e.g. "Measuring spoon/cup"
  notes text
);

-- Indexes for common lookups

create index if not exists idx_cocktails_category on cocktails(category_id);
create index if not exists idx_cocktails_kenyan on cocktails(is_kenyan_inspired);
create index if not exists idx_cocktail_ingredients_cocktail on cocktail_ingredients(cocktail_id);
create index if not exists idx_ingredients_name on ingredients(name);
create index if not exists idx_spirits_name on spirits(name);

-- Row level security: knowledge base is publicly readable, writes restricted

alter table categories enable row level security;
alter table glassware enable row level security;
alter table preparation_methods enable row level security;
alter table spirits enable row level security;
alter table ingredients enable row level security;
alter table cocktails enable row level security;
alter table cocktail_ingredients enable row level security;
alter table equipment_alternatives enable row level security;

create policy "Public read access" on categories for select using (true);
create policy "Public read access" on glassware for select using (true);
create policy "Public read access" on preparation_methods for select using (true);
create policy "Public read access" on spirits for select using (true);
create policy "Public read access" on ingredients for select using (true);
create policy "Public read access" on cocktails for select using (status = 'published' or status = 'featured' or created_by = auth.uid());
create policy "Public read access" on cocktail_ingredients for select using (true);
create policy "Public read access" on equipment_alternatives for select using (true);

create policy "Authenticated users can create cocktails" on cocktails
  for insert with check (auth.uid() = created_by);

create policy "Users can update own cocktails" on cocktails
  for update using (auth.uid() = created_by);