-- Source-backed vintage reference records for Rolex and Omega.
-- All entries are marked community: specifications are cross-checked against
-- specialist archives, auction catalogues, and established watch references,
-- but have not been individually authenticated by the manufacturers.
-- Unknown or disputed fields are intentionally left NULL.

with seed(
  brand_name, model_name, reference_number, variant_name,
  case_diameter_mm, movement, caliber, case_material, crystal,
  production_start, production_end, source_url, verification_status
) as (
  values
    -- Rolex
    ('Rolex', 'Oyster Perpetual', '1500', 'Oyster Perpetual Date',
      34, 'Automatic', '1565 / 1575', 'Stainless steel', 'Acrylic',
      1960, 1980, 'https://rolexopedia.net/wiki/Reference:1500', 'community'),
    ('Rolex', 'Datejust', '1600', 'Datejust smooth bezel',
      36, 'Automatic', '1565 / 1575', 'Stainless steel', 'Acrylic',
      1959, 1977, 'https://www.watchguys.com/pages/rolex-datejust-guide', 'community'),
    ('Rolex', 'Datejust', '1601', 'Datejust fluted bezel',
      36, 'Automatic', '1565 / 1575', 'Stainless steel / white gold bezel', 'Acrylic',
      1959, 1977, 'https://www.watchguys.com/pages/rolex-datejust-guide', 'community'),
    ('Rolex', 'Datejust', '1603', 'Datejust engine-turned bezel',
      36, 'Automatic', '1565 / 1575', 'Stainless steel', 'Acrylic',
      1959, 1977, 'https://www.watchguys.com/pages/rolex-datejust-guide', 'community'),
    ('Rolex', 'Submariner', '5512', 'No-date Submariner chronometer',
      40, 'Automatic', '1530 / 1560 / 1570', 'Stainless steel', 'Acrylic',
      1959, 1980, 'https://www.bobswatches.com/rolex-blog/watch-review/vintage-submariners-reference-5512-5513.html', 'community'),
    ('Rolex', 'Submariner', '5513', 'No-date Submariner non-chronometer',
      40, 'Automatic', '1530 / 1520', 'Stainless steel', 'Acrylic',
      1962, 1989, 'https://www.bobswatches.com/rolex-blog/watch-review/vintage-submariners-reference-5512-5513.html', 'community'),
    ('Rolex', 'Submariner', '1680', 'Submariner Date',
      40, 'Automatic', '1575', 'Stainless steel', 'Acrylic',
      1969, 1980, 'https://rolexopedia.net/wiki/Reference:submariner', 'community'),
    ('Rolex', 'GMT-Master', '1675', 'GMT-Master Pepsi / black bezel variants',
      40, 'Automatic', '1565 / 1575', 'Stainless steel', 'Acrylic',
      1959, 1980, 'https://www.hodinkee.com/articles/rolex-gmt-master-reference-points', 'community'),

    -- Omega Speedmaster
    ('Omega', 'Speedmaster Professional', '105.003', 'Ed White',
      40, 'Manual winding', '321', 'Stainless steel', 'Hesalite',
      1963, 1969, 'https://www.fratellowatches.com/omega-speedmaster-references/', 'community'),
    ('Omega', 'Speedmaster Professional', '105.012', 'Pre-Moon Professional',
      42, 'Manual winding', '321', 'Stainless steel', 'Hesalite',
      1964, 1968, 'https://www.fratellowatches.com/omega-speedmaster-references/', 'community'),
    ('Omega', 'Speedmaster Professional', '145.012', 'Pre-Moon Professional',
      42, 'Manual winding', '321', 'Stainless steel', 'Hesalite',
      1967, 1969, 'https://www.fratellowatches.com/omega-speedmaster-references/', 'community'),
    ('Omega', 'Speedmaster Professional', '145.022', 'Calibre 861 generation',
      42, 'Manual winding', '861', 'Stainless steel', 'Hesalite',
      1968, 1988, 'https://www.fratellowatches.com/omega-speedmaster-references/', 'community'),
    ('Omega', 'Speedmaster Reduced', '3510.61.00', 'Michael Schumacher / red dial',
      39, 'Automatic', '1143', 'Stainless steel', 'Hesalite',
      1996, 2000, 'https://www.chrono24.com/omega/ref-35106100.htm', 'community'),

    -- Omega Seamaster / Constellation
    ('Omega', 'Seamaster 300', '165.014', 'No-date Seamaster 300',
      39, 'Automatic', '552', 'Stainless steel', 'Acrylic',
      1962, 1964, 'https://www.reffile.com/omega/seamaster-300/', 'community'),
    ('Omega', 'Seamaster 300', '165.024', 'No-date Seamaster 300',
      42, 'Automatic', '552', 'Stainless steel', 'Acrylic',
      1963, 1970, 'https://www.reffile.com/omega/seamaster-300/', 'community'),
    ('Omega', 'Seamaster 300', '166.024', 'Date Seamaster 300',
      42, 'Automatic', '565', 'Stainless steel', 'Acrylic',
      1966, 1970, 'https://www.reffile.com/omega/seamaster-300/', 'community'),
    ('Omega', 'Constellation', '168.005', 'Pie Pan dial / dog-leg case',
      null, 'Automatic', '564', 'Stainless steel', 'Acrylic',
      1960, 1967, 'https://www.marcelswatch.com/en/product/vintage-omega-168-005-constellation-pie-pan-1968/', 'community')
)
insert into public.watch_catalog_references (
  model_id, reference_number, variant_name, case_diameter_mm,
  movement, caliber, case_material, crystal, production_start,
  production_end, source_url, verification_status
)
select
  m.id, s.reference_number, s.variant_name, s.case_diameter_mm,
  s.movement, s.caliber, s.case_material, s.crystal, s.production_start,
  s.production_end, s.source_url, s.verification_status
from seed s
join public.watch_catalog_brands b on b.name = s.brand_name
join public.watch_catalog_models m
  on m.brand_id = b.id
 and lower(m.model_name) = lower(s.model_name)
on conflict do nothing;
