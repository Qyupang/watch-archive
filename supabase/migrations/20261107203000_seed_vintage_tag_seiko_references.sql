-- Add a curated vintage TAG Heuer / Heuer and Seiko reference set.
-- Sources are linked per record. Entries are community-sourced, not
-- manufacturer-authenticated. Approximate/variant-dependent fields are left
-- blank or described as ranges rather than presented as exact facts.

with model_seed(brand_name, model_name) as (
  values
    ('TAG Heuer', 'Heuer Diver 844'),
    ('TAG Heuer', '1000 Series'),
    ('Seiko', '62MAS'),
    ('Seiko', '6105 Diver'),
    ('Seiko', '6309 Diver'),
    ('Seiko', 'Speed Timer'),
    ('Seiko', '7548 Quartz Diver'),
    ('Seiko', 'SKX Diver')
)
insert into public.watch_catalog_models(brand_id, model_name)
select b.id, s.model_name
from model_seed s
join public.watch_catalog_brands b on b.name = s.brand_name
on conflict do nothing;

with seed(
  brand_name, model_name, reference_number, variant_name,
  case_diameter_mm, movement, caliber, case_material, crystal,
  production_start, production_end, source_url, verification_status
) as (
  values
    -- Heuer / TAG Heuer vintage
    ('TAG Heuer', 'Heuer Diver 844', '844', 'Early automatic diver',
      42, 'Automatic', 'FE 4611A', 'Stainless steel', 'Acrylic',
      1979, 1990, 'https://www.tagheuer.com/int/en/vintage-collection/tag-heuer-1000-series.html', 'community'),
    ('TAG Heuer', '1000 Series', '980.013N', 'Professional 1000 quartz date',
      36, 'Quartz', 'ETA 955.112', 'Stainless steel', null,
      1985, null, 'https://www.dawsonsauctions.co.uk/auction/lot/lot-256---tag-heuer-professional-1000-reference/?lot=96257&sd=1', 'community'),
    ('TAG Heuer', 'Autavia', '1163', 'Chronomatic automatic chronograph',
      42.5, 'Automatic chronograph', 'Calibre 11 / 12', 'Stainless steel', 'Acrylic',
      1969, 1972, 'https://www.tagheuer.com/gb/en/vintage-collection/vintage-heuer-autavia.html', 'community'),
    ('TAG Heuer', 'Carrera', '2447', 'Three-register manual chronograph',
      36, 'Manual-winding chronograph', 'Valjoux 72', 'Stainless steel', 'Acrylic',
      1963, 1970, 'https://www.heuerworld.com/gallery_543406.html', 'community'),

    -- Seiko vintage divers and chronographs
    ('Seiko', '62MAS', '6217-8000', 'First-generation small-crown 62MAS',
      null, 'Automatic', '6217A', 'Stainless steel', 'Acrylic',
      1965, 1965, 'https://www.theseikoguy.com/seiko-62mas/', 'community'),
    ('Seiko', '62MAS', '6217-8001', 'Later large-crown 62MAS',
      null, 'Automatic', '6217A', 'Stainless steel', 'Acrylic',
      1965, 1968, 'https://www.theseikoguy.com/seiko-62mas/', 'community'),
    ('Seiko', '6105 Diver', '6105-8000', 'Early symmetrical-case diver',
      null, 'Automatic', '6105A', 'Stainless steel', 'Acrylic',
      1968, 1970, 'https://makedostudio.com/seiko-divers/reference/6105', 'community'),
    ('Seiko', '6105 Diver', '6105-8110', 'Asymmetric-case diver / Uemura',
      null, 'Automatic', '6105B', 'Stainless steel', 'Acrylic',
      1970, 1977, 'https://makedostudio.com/seiko-divers/reference/6105', 'community'),
    ('Seiko', '6309 Diver', '6309-7040', 'Cushion-case Turtle',
      45, 'Automatic', '6309A', 'Stainless steel', 'Acrylic',
      1976, 1988, 'https://makedostudio.com/seiko-divers/reference/6309', 'community'),
    ('Seiko', 'Speed Timer', '6139-6002', 'Automatic chronograph / Pogue family',
      41, 'Automatic chronograph', '6139B', 'Stainless steel', 'Hardlex',
      1969, 1979, 'https://images2.bonhams.com/original?src=Images%2Flive%2F2021-08%2F20%2FS-26685-0-2.pdf', 'community'),
    ('Seiko', '7548 Quartz Diver', '7548-7000', 'Black-dial quartz diver',
      42.5, 'Quartz', '7548', 'Stainless steel', 'Hardlex',
      1978, 1985, 'https://www.theseikoguy.com/seiko-slim-turtle-7548/', 'community'),
    ('Seiko', 'SKX Diver', '7S26-0020', 'SKX007 / SKX009 family',
      null, 'Automatic', '7S26', 'Stainless steel', 'Hardlex',
      1996, 2019, 'https://www.theseikoguy.com/seiko-skx-divers', 'community'),
    ('Seiko', 'SKX Diver', '7S26-0030', 'SKX013 compact diver',
      38, 'Automatic', '7S26', 'Stainless steel', 'Hardlex',
      1996, 2019, 'https://www.theseikoguy.com/seiko-skx-divers', 'community')
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
