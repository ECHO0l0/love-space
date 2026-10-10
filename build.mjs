import fs from 'node:fs/promises';
import{build}from'esbuild';
await fs.mkdir('vendor',{recursive:true});
await build({stdin:{contents:"export { createClient } from '@supabase/supabase-js';",resolveDir:process.cwd()},bundle:true,format:'esm',platform:'browser',minify:true,outfile:'vendor/supabase.js'});
await build({stdin:{contents:"export { default } from 'morphdom';",resolveDir:process.cwd()},bundle:true,format:'esm',platform:'browser',minify:true,outfile:'vendor/morphdom.js'});
await fs.rm('dist',{recursive:true,force:true});
await fs.mkdir('dist',{recursive:true});
for(const file of ['index.html','app.js','core.js','practice.js','sync.js','product.js','view.js','cloud-fetch.js','sync-model.js','sync-config.js','vendor','style.css','sw.js','icon.svg','icon-192.png','icon-512.png','icon-180.png','manifest.webmanifest','vault']) await fs.cp(file,`dist/${file}`,{recursive:true});
console.log('海行题库 build complete');
