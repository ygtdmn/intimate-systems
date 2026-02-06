import * as Name from 'w3name';
import fs from 'fs';

const CID = process.argv[2];
if (!CID) {
  console.error('Usage: bun w3name-publish.mjs <cid>');
  process.exit(1);
}

const KEY_FILE = 'w3name.key';
const REVISION_FILE = 'w3name-revision.json';
const value = '/ipfs/' + CID;

async function run() {
  let name;
  let revision;

  if (fs.existsSync(KEY_FILE)) {
    // Load existing key
    const bytes = await fs.promises.readFile(KEY_FILE);
    name = await Name.from(bytes);
    console.log('loaded existing name:', name.toString());

    // Load previous revision if exists
    if (fs.existsSync(REVISION_FILE)) {
      const prev = JSON.parse(await fs.promises.readFile(REVISION_FILE, 'utf-8'));
      const prevRevision = await Name.resolve(name);
      revision = await Name.increment(prevRevision, value);
      console.log('incrementing revision to:', value);
    } else {
      revision = await Name.v0(name, value);
      console.log('creating initial revision:', value);
    }
  } else {
    // Create new name
    name = await Name.create();
    console.log('created new name:', name.toString());

    // Save key
    await fs.promises.writeFile(KEY_FILE, Buffer.from(name.key.raw));
    console.log('saved key to', KEY_FILE);

    revision = await Name.v0(name, value);
    console.log('creating initial revision:', value);
  }

  await Name.publish(revision, name.key);
  console.log('published!');

  // Save revision metadata
  await fs.promises.writeFile(REVISION_FILE, JSON.stringify({
    name: name.toString(),
    value: value,
    updated: new Date().toISOString()
  }, null, 2));

  console.log('');
  console.log('IPNS name:', name.toString());
  console.log('points to:', value);
  console.log('');
  console.log('Resolve via:');
  console.log('  https://name.web3.storage/name/' + name.toString());
}

run().catch(err => { console.error(err); process.exit(1); });
