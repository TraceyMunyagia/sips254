insert into categories (name, description) values
  ('Classic', 'International cocktail classics'),
  ('Kenyan', 'Kenyan-inspired and local cocktails'),
  ('Tropical', 'Fruit-forward, tropical style'),
  ('Mocktail', 'Non-alcoholic'),
  ('Punch', 'Batch/party cocktails')
on conflict (name) do nothing;

insert into glassware (name) values
  ('Coupe'), ('Highball'), ('Rocks Glass'), ('Martini Glass'),
  ('Hurricane Glass'), ('Mason Jar'), ('Punch Bowl')
on conflict (name) do nothing;

insert into preparation_methods (name) values
  ('Shaken'), ('Stirred'), ('Built'), ('Blended'), ('Layered')
on conflict (name) do nothing;

insert into spirits (name, category, is_kenyan) values
  ('Vodka', 'White Spirit', false),
  ('Gin', 'White Spirit', false),
  ('White Rum', 'Rum', false),
  ('Dark Rum', 'Rum', false),
  ('Tequila', 'Agave Spirit', false),
  ('Whisky', 'Whisky', false),
  ('Kenya Cane', 'Local Spirit', true)
on conflict (name) do nothing;

insert into ingredients (name, type, is_kenyan) values
  ('Passion Fruit Juice', 'Juice', true),
  ('Mango Puree', 'Juice', true),
  ('Pineapple Juice', 'Juice', true),
  ('Tamarind Syrup', 'Syrup', true),
  ('Baobab Puree', 'Juice', true),
  ('Hibiscus Syrup', 'Syrup', true),
  ('Coconut Cream', 'Mixer', true),
  ('Ginger Syrup', 'Syrup', true),
  ('Lime Juice', 'Juice', false),
  ('Lemon Juice', 'Juice', false),
  ('Simple Syrup', 'Syrup', false),
  ('Soda Water', 'Mixer', false),
  ('Tonic Water', 'Mixer', false),
  ('Angostura Bitters', 'Bitters', false),
  ('Mint Leaves', 'Garnish', false),
  ('Lime Wheel', 'Garnish', false)
on conflict (name) do nothing;

insert into equipment_alternatives (professional_tool, home_alternative, notes) values
  ('Jigger', 'Measuring spoon/cup', 'A standard shot is roughly 50ml'),
  ('Shaker', 'Clean sealable jar', 'Shake hard for 10-15 seconds'),
  ('Muddler', 'Wooden spoon', 'Press firmly, do not over-crush'),
  ('Bar Spoon', 'Teaspoon', 'For stirring or layering'),
  ('Strainer', 'Fine kitchen sieve', 'Use to catch ice/pulp when pouring')
on conflict (professional_tool) do nothing;