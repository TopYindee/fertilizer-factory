const AdmZip = require('adm-zip');
try {
  const zip = new AdmZip('setupdatawf-blueprint.docx');
  const content = zip.readAsText('word/document.xml');
  const matches = content.match(/<w:t[^>]*>(.*?)<\/w:t>/g);
  if (matches) {
    const text = matches.map(m => m.replace(/<[^>]+>/g, '')).join('\n');
    console.log(text.substring(0, 1500)); // Print first 1500 chars
  }
} catch (e) {
  console.error('Error:', e.message);
}
