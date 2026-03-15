#!/usr/bin/env node
/**
 * Photo Downloader
 * ────────────────────────────────────────────────────────────
 * Reads enriched_places.json and downloads all Google Places
 * photos locally to ./photos/<place_id>/photo_1.jpg, etc.
 *
 * Usage:
 *   node download-photos.js
 *
 * Output:
 *   ./photos/<place_id>/photo_1.jpg
 *   ./photos/<place_id>/photo_2.jpg
 *   ...
 *   ./output/local_photo_map.json  — maps place_id → local paths
 */

import fetch from 'node-fetch';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { pipeline } from 'stream/promises';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }
function log(emoji, msg) { console.log(`${emoji}  ${msg}`); }

async function main() {
    const enrichedPath = path.join(__dirname, 'output', 'enriched_places.json');
    if (!fs.existsSync(enrichedPath)) {
        console.error('❌ No enriched_places.json found. Run the enrichment script first.');
        process.exit(1);
    }

    const places = JSON.parse(fs.readFileSync(enrichedPath, 'utf-8'));
    const photosDir = path.join(__dirname, 'photos');
    fs.mkdirSync(photosDir, { recursive: true });

    const photoMap = {};
    let totalDownloaded = 0;
    let totalSkipped = 0;

    log('🚀', `Downloading photos for ${places.length} places...\n`);

    for (const place of places) {
        if (!place.photoURLs?.length) {
            log('⏭️', `${place.name} — no photos to download`);
            continue;
        }

        const placeDir = path.join(photosDir, place.id);
        fs.mkdirSync(placeDir, { recursive: true });

        photoMap[place.id] = {
            name: place.name,
            photos: [],
        };

        log('📸', `${place.name} — ${place.photoURLs.length} photos`);

        for (let i = 0; i < place.photoURLs.length; i++) {
            const filename = `photo_${i + 1}.jpg`;
            const filePath = path.join(placeDir, filename);
            const relativePath = `photos/${place.id}/${filename}`;

            // Skip if already downloaded
            if (fs.existsSync(filePath)) {
                const stat = fs.statSync(filePath);
                if (stat.size > 1000) { // sanity check — must be >1KB
                    log('  ✅', `  ${filename} — already exists (${(stat.size / 1024).toFixed(0)}KB)`);
                    photoMap[place.id].photos.push(relativePath);
                    totalSkipped++;
                    continue;
                }
            }

            try {
                const res = await fetch(place.photoURLs[i], {
                    redirect: 'follow',
                    headers: {
                        'User-Agent': 'Mozilla/5.0 (compatible; WanderBot/1.0)'
                    }
                });

                if (!res.ok) {
                    log('  ⚠️', `  ${filename} — HTTP ${res.status}`);
                    continue;
                }

                const writeStream = fs.createWriteStream(filePath);
                await pipeline(res.body, writeStream);

                const stat = fs.statSync(filePath);
                log('  📥', `  ${filename} — ${(stat.size / 1024).toFixed(0)}KB`);
                photoMap[place.id].photos.push(relativePath);
                totalDownloaded++;
            } catch (err) {
                log('  ❌', `  ${filename} — ${err.message}`);
            }

            await sleep(200); // polite delay
        }

        console.log('');
    }

    // Save the photo map
    const mapPath = path.join(__dirname, 'output', 'local_photo_map.json');
    fs.writeFileSync(mapPath, JSON.stringify(photoMap, null, 2));

    // Generate Swift-ready local photo paths
    const swiftLocalPath = path.join(__dirname, 'output', 'swift_local_photos.txt');
    const swiftLines = ['// ─── LOCAL PHOTO PATHS ───', '// Use these when serving from your own storage', ''];
    for (const [placeId, data] of Object.entries(photoMap)) {
        if (data.photos.length) {
            swiftLines.push(`// ${data.name} (${placeId})`);
            swiftLines.push(`// Photos: ${data.photos.length}`);
            for (const p of data.photos) {
                swiftLines.push(`//   ${p}`);
            }
            swiftLines.push('');
        }
    }
    fs.writeFileSync(swiftLocalPath, swiftLines.join('\n'));

    console.log('');
    log('🎉', `COMPLETE!`);
    log('📥', `Downloaded: ${totalDownloaded} photos`);
    log('⏭️', `Skipped (already existed): ${totalSkipped}`);
    log('📁', `Photo map: ${mapPath}`);
    log('📁', `Photos directory: ${photosDir}`);

    // Print total size
    let totalBytes = 0;
    for (const [, data] of Object.entries(photoMap)) {
        for (const p of data.photos) {
            const fp = path.join(__dirname, p);
            if (fs.existsSync(fp)) totalBytes += fs.statSync(fp).size;
        }
    }
    log('💾', `Total size: ${(totalBytes / 1024 / 1024).toFixed(1)}MB`);
}

main().catch(err => {
    console.error('\n💥 Fatal error:', err);
    process.exit(1);
});
