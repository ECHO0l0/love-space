import test from 'node:test';import assert from 'node:assert/strict';import{randomBytes,createCipheriv,pbkdf2Sync}from'node:crypto';import{unlockKey,decrypt}from'../core.js';
const password='fixture password only',salt=randomBytes(16),dataKey=randomBytes(32),passwordKey=pbkdf2Sync(password,salt,600000,32,'sha256');
function encrypt(k,bytes){const iv=randomBytes(12),c=createCipheriv('aes-256-gcm',k,iv);return Buffer.concat([iv,c.update(bytes),c.final(),c.getAuthTag()]);}
const manifest={version:2,salt:salt.toString('base64'),wrappedKey:encrypt(passwordKey,dataKey).toString('base64')};
test('new password unwraps the existing data key without rewriting question packages',async()=>{const key=await unlockKey(password,manifest);const result=await decrypt(key,encrypt(dataKey,Buffer.from('existing encrypted question')));assert.equal(new TextDecoder().decode(result),'existing encrypted question');});
test('wrong password and tampered envelope are rejected',async()=>{await assert.rejects(unlockKey('old invalid password',manifest));const bad=Buffer.from(manifest.wrappedKey,'base64');bad[20]^=1;await assert.rejects(unlockKey(password,{...manifest,wrappedKey:bad.toString('base64')}));});
