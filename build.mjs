import fs from 'node:fs/promises';
await fs.mkdir('dist',{recursive:true});
for(const file of ['index.html','app.js','core.js','style.css','sw.js','icon.svg','icon-192.png','icon-512.png','icon-180.png','manifest.webmanifest','vault']) await fs.cp(file,`dist/${file}`,{recursive:true});
console.log('海行题库 build complete');
