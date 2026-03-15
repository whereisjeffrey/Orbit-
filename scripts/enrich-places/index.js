#!/usr/bin/env node
/**
 * Wander Place Enricher
 * ─────────────────────────────────────────────────────────────────────────
 * Reads your seed places (coworking + cafés), queries the Google Places API
 * for each one, and writes a JSON file of enriched data ready to paste into
 * your Swift seed files or upload to Firestore/Supabase.
 *
 * Usage:
 *   GOOGLE_PLACES_KEY=<your_key> node index.js
 *   GOOGLE_PLACES_KEY=<your_key> node index.js --dry-run   (no API calls)
 *
 * Output:
 *   ./output/enriched_places.json   — all enriched data
 *   ./output/swift_patch.txt        — ready-to-paste Swift photoURLs arrays
 *   ./output/missing_fields.json    — fields still needing community data
 *
 * API cost estimate (120 places):
 *   findPlaceFromText  × 120 = ~$2.04
 *   Place Details       × 120 = ~$2.04  (only fields we need, billed per field)
 *   Photo fetches       × 600 = ~$4.20  (5 per place @ $0.007)
 *   ─────────────────────────────────
 *   Total               ≈ $8.28 one-time per city
 */

import fetch from 'node-fetch';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const isDryRun = process.argv.includes('--dry-run');

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — paste your key here or use the env var
// ─────────────────────────────────────────────────────────────────────────────
const API_KEY = process.env.GOOGLE_PLACES_KEY || 'YOUR_API_KEY_HERE';
const MAX_PHOTOS_PER_PLACE = 5;
const DELAY_MS = 300; // polite delay between requests

// ─────────────────────────────────────────────────────────────────────────────
// SEED DATA — your 18 places (cowork + café)
// Copy/update this list whenever you add new seed places.
// ─────────────────────────────────────────────────────────────────────────────
const SEED_PLACES = [
  // ── Coworking ──────────────────────────────────────────────────────────────
  { id: 'homework_condesa',  name: 'Homework Condesa',      city: 'Mexico City', lat: 19.4133, lon: -99.1707, type: 'cowork' },
  { id: 'homework_polanco',  name: 'Homework Polanco',      city: 'Mexico City', lat: 19.4322, lon: -99.1952, type: 'cowork' },
  { id: 'wework_reforma',    name: 'WeWork Paseo de la Reforma 296', city: 'Mexico City', lat: 19.4284, lon: -99.1709, type: 'cowork' },
  { id: 'selina_roma',       name: 'Selina Roma Norte',     city: 'Mexico City', lat: 19.4163, lon: -99.1594, type: 'cowork' },
  { id: 'impact_hub',        name: 'Impact Hub Mexico City',city: 'Mexico City', lat: 19.4168, lon: -99.1631, type: 'cowork' },
  { id: 'zentro_condesa',    name: 'Zentro Coworking',      city: 'Mexico City', lat: 19.4078, lon: -99.1712, type: 'cowork' },
  { id: 'maquinaria_roma',   name: 'La Maquinaria Roma',    city: 'Mexico City', lat: 19.4155, lon: -99.1601, type: 'cowork' },
  { id: 'bordo_juarez',      name: 'Bordo Coworking',       city: 'Mexico City', lat: 19.4271, lon: -99.1658, type: 'cowork' },
  { id: 'crew_polanco',      name: 'Crew Polanco',          city: 'Mexico City', lat: 19.4340, lon: -99.1984, type: 'cowork' },
  { id: 'latitud_condesa',   name: 'Latitud Condesa',       city: 'Mexico City', lat: 19.4121, lon: -99.1732, type: 'cowork' },
  // ── Cafés ─────────────────────────────────────────────────────────────────
  { id: 'cafe_jarocho',      name: 'Café El Jarocho',       city: 'Mexico City', lat: 19.3507, lon: -99.1618, type: 'cafe' },
  { id: 'cafe_avellaneda',   name: 'Café Avellaneda',       city: 'Mexico City', lat: 19.3512, lon: -99.1625, type: 'cafe' },
  { id: 'cafe_once',         name: 'Once Café',             city: 'Mexico City', lat: 19.4167, lon: -99.1612, type: 'cafe' },
  { id: 'cafe_negro',        name: 'Café Negro Roma',       city: 'Mexico City', lat: 19.4178, lon: -99.1598, type: 'cafe' },
  { id: 'cafe_quentin',      name: 'Café Quentin',          city: 'Mexico City', lat: 19.4135, lon: -99.1712, type: 'cafe' },
  { id: 'cafe_buna',         name: 'Buna 42',               city: 'Mexico City', lat: 19.4322, lon: -99.1942, type: 'cafe' },
  { id: 'cafe_almanegra',    name: 'Almanegra Café',        city: 'Mexico City', lat: 19.4268, lon: -99.1632, type: 'cafe' },
  { id: 'cafe_paramo',       name: 'Páramo',                city: 'Mexico City', lat: 19.4121, lon: -99.1573, type: 'cafe' },
];

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

function log(emoji, msg) { console.log(`${emoji}  ${msg}`); }

/**
 * Step 1: Find the place_id given a name + coordinates.
 * Uses "Find Place from Text" endpoint — biased to the lat/lon we provide.
 * Cost: $0.017 per call
 */
async function findPlaceId(place) {
  if (isDryRun) {
    return `FAKE_PLACE_ID_${place.id}`;
  }

  const q = encodeURIComponent(`${place.name}, ${place.city}`);
  const locationBias = `point:${place.lat},${place.lon}`;
  const url = `https://maps.googleapis.com/maps/api/place/findplacefromtext/json`
    + `?input=${q}`
    + `&inputtype=textquery`
    + `&locationbias=${locationBias}`
    + `&fields=place_id,name`
    + `&key=${API_KEY}`;

  const res = await fetch(url);
  const data = await res.json();

  if (data.status !== 'OK' || !data.candidates?.length) {
    log('⚠️', `No match for "${place.name}" — status: ${data.status}`);
    return null;
  }

  const candidate = data.candidates[0];
  log('📍', `Found: "${candidate.name}" → ${candidate.place_id}`);
  return candidate.place_id;
}

/**
 * Step 2: Fetch Place Details.
 * Only requests the fields we actually use to keep cost minimal.
 * Fields requested: name, formatted_address, opening_hours, website, 
 *                   price_level, rating, user_ratings_total, photos,
 *                   formatted_phone_number, serves_coffee, wheelchair_accessible_entrance
 * Cost: billed per field category — these all fall in "Basic" + "Contact" = ~$0.017 total
 */
async function fetchPlaceDetails(placeId, placeName) {
  if (isDryRun) {
    return {
      name: placeName,
      formatted_address: '123 Fake St, Mexico City',
      opening_hours: { weekday_text: ['Monday: 9:00 AM – 9:00 PM', 'Tuesday: 9:00 AM – 9:00 PM'] },
      website: 'https://example.com',
      price_level: 2,
      rating: 4.3,
      user_ratings_total: 128,
      photos: [{ photo_reference: 'FAKE_REF_1' }, { photo_reference: 'FAKE_REF_2' }],
    };
  }

  const fields = [
    'name',
    'formatted_address',
    'opening_hours',
    'website',
    'price_level',
    'rating',
    'user_ratings_total',
    'photos',
    'formatted_phone_number',
    'url',
  ].join(',');

  const url = `https://maps.googleapis.com/maps/api/place/details/json`
    + `?place_id=${placeId}`
    + `&fields=${fields}`
    + `&language=en`
    + `&key=${API_KEY}`;

  const res = await fetch(url);
  const data = await res.json();

  if (data.status !== 'OK') {
    log('⚠️', `Details failed for ${placeId}: ${data.status} — ${data.error_message || ''}`);
    return null;
  }

  return data.result;
}

/**
 * Step 3: Build a photo URL from a photo_reference.
 * This is a direct URL — no download needed. Pass maxwidth for sizing.
 * Cost: $0.007 per photo
 */
function buildPhotoUrl(photoReference, maxWidth = 800) {
  if (isDryRun) return `https://maps.googleapis.com/maps/api/place/photo?FAKE_DRY_RUN_URL`;
  return `https://maps.googleapis.com/maps/api/place/photo`
    + `?maxwidth=${maxWidth}`
    + `&photo_reference=${photoReference}`
    + `&key=${API_KEY}`;
}

/**
 * Parse opening hours into our app's format (e.g. "8am – 10pm · Mon–Sun")
 */
function parseHours(openingHours) {
  if (!openingHours?.weekday_text?.length) return { hoursDisplay: 'See Google Maps', hoursDays: '' };

  // Find earliest open / latest close across all days
  const times = openingHours.weekday_text
    .map(t => t.replace(/^[^:]+:\s*/, '')) // strip "Monday: "
    .filter(t => !t.includes('Closed'));

  // Simplest heuristic: use Monday's hours as the display hours
  const monday = openingHours.weekday_text.find(t => t.startsWith('Monday'));
  const display = monday
    ? monday.replace('Monday: ', '').replace(' AM', 'am').replace(' PM', 'pm')
    : times[0] || 'See Google Maps';

  // Detect open days
  const closedDays = openingHours.weekday_text
    .filter(t => t.includes('Closed'))
    .map(t => t.split(':')[0]);

  const hoursDays = closedDays.length === 0
    ? 'Mon–Sun'
    : closedDays.length === 1 && closedDays[0] === 'Sunday'
    ? 'Mon–Sat'
    : closedDays.length === 2 && closedDays.includes('Saturday') && closedDays.includes('Sunday')
    ? 'Mon–Fri'
    : 'See website';

  return { hoursDisplay: display, hoursDays };
}

/**
 * Map Google price_level (0–4) to our display format
 */
function parsePriceLevel(level) {
  const map = { 0: 'Free', 1: 'Budget', 2: 'Moderate', 3: 'Upscale', 4: 'Premium' };
  return map[level] ?? null;
}

// ─────────────────────────────────────────────────────────────────────────────
// WEBSITE AMENITY SCRAPER
// Fetches the place's own website and scans for amenity keywords.
// This is 100% legal — you're reading their public marketing pages.
// ─────────────────────────────────────────────────────────────────────────────

const AMENITY_SIGNALS = {
  wifi:      ['wifi', 'wi-fi', 'internet', 'wireless', 'fibra', 'banda ancha'],
  coffee:    ['coffee', 'café', 'espresso', 'barista', 'café incluido', 'includes coffee', 'coffee bar'],
  callRooms: ['call booth', 'phone booth', 'sala privada', 'cabina', 'private room', 'sound proof', 'soundproof', 'call room'],
  outlets:   ['outlets', 'power', 'enchufes', 'coriente', 'charging', 'plugs', 'tomas de corriente'],
  late:      ['open late', '10pm', '11pm', '12am', 'midnight', 'noche', 'madrugada'],
};

async function scrapeWebsiteAmenities(websiteUrl) {
  if (!websiteUrl || isDryRun) return {};

  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 8000);
    const res = await fetch(websiteUrl, {
      signal: controller.signal,
      headers: { 'User-Agent': 'Mozilla/5.0 (compatible; WanderBot/1.0; +https://wander.app/bot)' }
    });
    clearTimeout(timeout);

    if (!res.ok) return {};
    const html = await res.text();
    const text = html.toLowerCase().replace(/<[^>]+>/g, ' '); // strip tags

    const found = {};
    for (const [amenity, keywords] of Object.entries(AMENITY_SIGNALS)) {
      const hit = keywords.some(kw => text.includes(kw));
      if (hit) {
        found[amenity] = { detected: true, confidence: 0.70, source: 'website_scrape' };
      }
    }

    return found;
  } catch (e) {
    // Timeout, CORS, redirect loop — just skip
    return {};
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SWIFT PATCH GENERATOR
// Generates Swift code you can paste directly into CoworkSpace.swift / CafeSpace.swift
// ─────────────────────────────────────────────────────────────────────────────

function toSwiftStringArray(urls) {
  if (!urls.length) return '[]';
  const inner = urls.map(u => `"${u}"`).join(', ');
  return `[${inner}]`;
}

function generateSwiftPatch(enriched) {
  const lines = ['// ─── AUTO-GENERATED PHOTO URL PATCHES ───', '// Paste these photoURLs into your seed data', ''];

  for (const p of enriched) {
    if (p.photoURLs?.length) {
      lines.push(`// ${p.name} (${p.id})`);
      lines.push(`photoURLs: ${toSwiftStringArray(p.photoURLs)},`);
      lines.push('');
    }
  }

  return lines.join('\n');
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────────────────────────────────────

async function main() {
  if (API_KEY === 'YOUR_API_KEY_HERE' && !isDryRun) {
    console.error('\n❌  No API key found!');
    console.error('   Set it via:  GOOGLE_PLACES_KEY=AIzaSy... node index.js\n');
    process.exit(1);
  }

  if (isDryRun) {
    log('🧪', 'DRY RUN mode — no real API calls will be made');
  }

  const outputDir = path.join(__dirname, 'output');
  fs.mkdirSync(outputDir, { recursive: true });

  const enriched = [];
  const missing = [];

  log('🚀', `Starting enrichment for ${SEED_PLACES.length} places...\n`);

  for (const place of SEED_PLACES) {
    log('─', `Processing: ${place.name}`);

    // 1. Find place_id
    const placeId = await findPlaceId(place);
    if (!placeId) {
      log('❌', `Skipping "${place.name}" — not found on Google`);
      missing.push({ id: place.id, name: place.name, reason: 'not_found' });
      await sleep(DELAY_MS);
      continue;
    }
    await sleep(DELAY_MS);

    // 2. Get details
    const details = await fetchPlaceDetails(placeId, place.name);
    if (!details) {
      missing.push({ id: place.id, name: place.name, reason: 'details_failed' });
      await sleep(DELAY_MS);
      continue;
    }
    await sleep(DELAY_MS);

    // 3. Build photo URLs (direct Google hosted URLs — no download needed)
    const photoRefs = (details.photos || []).slice(0, MAX_PHOTOS_PER_PLACE);
    const photoURLs = photoRefs.map(p => buildPhotoUrl(p.photo_reference));

    // 4. Parse hours
    const { hoursDisplay, hoursDays } = parseHours(details.opening_hours);

    // 5. Optional: scrape website for amenity signals
    let websiteAmenities = {};
    if (details.website) {
      log('🌐', `  Scraping website: ${details.website}`);
      websiteAmenities = await scrapeWebsiteAmenities(details.website);
      const found = Object.keys(websiteAmenities);
      if (found.length) {
        log('✅', `  Found on website: ${found.join(', ')}`);
      }
      await sleep(DELAY_MS);
    }

    // 6. Assemble enriched record
    const record = {
      id:           place.id,
      type:         place.type,
      name:         details.name || place.name,
      googlePlaceId: placeId,
      googleMapsUrl: details.url || null,
      address:      details.formatted_address || null,
      phone:        details.formatted_phone_number || null,
      website:      details.website || null,
      hoursDisplay,
      hoursDays,
      hoursRaw:     details.opening_hours?.weekday_text || null,
      priceLevel:   details.price_level ?? null,
      priceLevelLabel: parsePriceLevel(details.price_level),
      rating:       details.rating || null,
      ratingCount:  details.user_ratings_total || null,
      photoURLs,
      photoCount:   photoURLs.length,
      websiteAmenities,
      // Fields that still need community input:
      needsCommunity: {
        wifiSpeed:    !websiteAmenities.wifi,
        outletCount:  !websiteAmenities.outlets,
        callRooms:    !websiteAmenities.callRooms && place.type === 'cowork',
        exactPricing: place.type === 'cowork',
        noiseLevel:   place.type === 'cafe',
        timeLimit:    place.type === 'cafe',
      },
      enrichedAt: new Date().toISOString(),
    };

    enriched.push(record);
    log('✅', `  Done — ${photoURLs.length} photos, hours: "${hoursDisplay}"`);

    // Report any fields we couldn't get
    const communityNeeded = Object.entries(record.needsCommunity)
      .filter(([, v]) => v)
      .map(([k]) => k);
    if (communityNeeded.length) {
      log('📋', `  Needs community: ${communityNeeded.join(', ')}`);
    }

    console.log('');
    await sleep(DELAY_MS);
  }

  // ── Write output ────────────────────────────────────────────────────────────

  // 1. Full enriched data
  const enrichedPath = path.join(outputDir, 'enriched_places.json');
  fs.writeFileSync(enrichedPath, JSON.stringify(enriched, null, 2));
  log('📁', `Saved enriched data → ${enrichedPath}`);

  // 2. Swift patch (just the photoURLs)
  const swiftPath = path.join(outputDir, 'swift_patch.txt');
  fs.writeFileSync(swiftPath, generateSwiftPatch(enriched));
  log('🍎', `Saved Swift patch → ${swiftPath}`);

  // 3. Missing fields report
  const missingFieldsPath = path.join(outputDir, 'missing_fields.json');
  const missingFields = enriched.map(p => ({
    id: p.id,
    name: p.name,
    fields: Object.entries(p.needsCommunity).filter(([, v]) => v).map(([k]) => k),
  })).filter(p => p.fields.length > 0);

  fs.writeFileSync(missingFieldsPath, JSON.stringify({ 
    summary: `${missingFields.length} places have fields needing community input`,
    places: missingFields,
    notFound: missing,
  }, null, 2));
  log('📋', `Saved missing fields report → ${missingFieldsPath}`);

  // ── Summary ─────────────────────────────────────────────────────────────────
  console.log('\n');
  log('🎉', `COMPLETE! ${enriched.length}/${SEED_PLACES.length} places enriched`);
  log('📸', `Total photos fetched: ${enriched.reduce((n, p) => n + p.photoCount, 0)}`);
  log('⚠️', `Not found on Google: ${missing.length}`);

  const totalCommunityNeeded = missingFields.reduce((n, p) => n + p.fields.length, 0);
  log('👥', `Fields needing community: ${totalCommunityNeeded} across ${missingFields.length} places`);

  console.log('\n── Next steps ────────────────────────────────────────────────────────');
  console.log('  1. Review output/enriched_places.json');
  console.log('  2. Copy photo URLs from output/swift_patch.txt into your seed data');
  console.log('  3. Review output/missing_fields.json for community prompt targets');
  console.log('─────────────────────────────────────────────────────────────────────\n');
}

main().catch(err => {
  console.error('\n💥 Fatal error:', err);
  process.exit(1);
});
