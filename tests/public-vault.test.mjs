import test from'node:test';
import assert from'node:assert/strict';
import{readFile}from'node:fs/promises';
import{decrypt,unzip}from'../core.js';

test('public manifest opens the existing catalog without an entry password',async()=>{
 const manifest=JSON.parse(await readFile(new URL('../vault/manifest.json',import.meta.url),'utf8'));
 assert.equal(manifest.version,3);
 assert.equal(typeof manifest.publicKey,'string');
 assert.equal('wrappedKey'in manifest,false);
 const key=await crypto.subtle.importKey('raw',Buffer.from(manifest.publicKey,'base64'),{name:'AES-GCM'},false,['decrypt']);
 const catalog=await unzip(await decrypt(key,await readFile(new URL('../vault/'+manifest.catalog,import.meta.url))));
 assert.ok(Array.isArray(catalog)&&catalog.length>250);
});
