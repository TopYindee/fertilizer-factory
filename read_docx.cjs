const fs = require('fs');
const { execSync } = require('child_process');

try {
  execSync('npm install adm-zip --no-save', { stdio: 'inherit' });
  const AdmZip = require('adm-zip');
  const zip = new AdmZip('bom-formula-blueprint.docx');
  const content = zip.readAsText('word/document.xml');
  const matches = content.match(/<w:t[^>]*>(.*?)<\/w:t>/g);
  if (matches) {
    const text = matches.map(m => m.replace(/<[^>]+>/g, '')).join('\n');
    console.log(text);
  } else {
    console.log('No text found in docx');
  }
} catch (e) {
  console.error('Error:', e.message);
}
