const fs = require('fs');
const { execSync } = require('child_process');

// We can extract zip using node's built-in zlib or admire zip if we install adm-zip, or use node to parse zip
// Actually let's install adm-zip temporarily or read it via JS
try {
  execSync('npm install adm-zip --no-save', { stdio: 'inherit' });
  const AdmZip = require('adm-zip');
  const zip = new AdmZip('bom-formula-blueprint.docx');
  const content = zip.readAsText('word/document.xml');
  // Simple regex to extract text inside <w:t>...</w:t>
  const matches = content.match(/<w:t[^>]*>(.*?)<\/w:t>/g);
  if (matches) {
    const text = matches.map(m => m.replace(/<[^>]+>/g, '')).join(' ');
    console.log(text);
  } else {
    console.log('No text found in docx');
  }
} catch (e) {
  console.error('Error:', e.message);
}
