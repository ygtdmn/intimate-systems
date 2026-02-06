import { execSync } from 'child_process';
import fs from 'fs';

const REVISION_FILE = 'w3name-revision.json';
const CONTENT_DIR = 'ipns_content/';

async function run() {
  let oldCid = null;
  if (fs.existsSync(REVISION_FILE)) {
    try {
      const prev = JSON.parse(fs.readFileSync(REVISION_FILE, 'utf-8'));
      if (prev.value) {
        // Extract CID from "/ipfs/bafy..."
        oldCid = prev.value.replace('/ipfs/', '');
      }
    } catch (e) {
      console.warn('⚠️ Could not parse w3name-revision.json');
    }
  }

  console.log(`🚀 Uploading ${CONTENT_DIR} to Storacha...`);
  // Run storacha up and capture output while printing it to stderr
  const uploadOutput = execSync(`storacha up ${CONTENT_DIR}`, { encoding: 'utf-8' });
  console.log(uploadOutput);

  // Find the last CID in the output (usually the root directory CID)
  const match = uploadOutput.match(/bafy[a-z0-9]+/g);
  if (!match) {
    throw new Error('❌ Failed to find CID in storacha output');
  }
  const newCid = match[match.length - 1];
  console.log(`✅ New CID: ${newCid}`);

  // Only remove if we have an old CID and it's different from the new one
  if (oldCid && oldCid !== newCid) {
    console.log(`🗑️ Removing old content: ${oldCid}`);
    try {
      execSync(`storacha rm ${oldCid}`);
      console.log('✅ Old content removed');
    } catch (e) {
      console.warn('⚠️ Failed to remove old content (it might not exist or already be removed)');
    }
  }

  console.log('🌐 Publishing to IPNS...');
  // Inherit stdio to show the output of the publish script
  execSync(`bun w3name-publish.mjs ${newCid}`, { stdio: 'inherit' });
}

run().catch(err => {
  console.error(err.message);
  process.exit(1);
});
