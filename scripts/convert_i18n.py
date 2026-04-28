import os
import re
import json

src_dir = '../bw-v3/src/projects/m1/i18n/messages'
dest_dir = 'assets/i18n'

os.makedirs(dest_dir, exist_ok=True)

for file in os.listdir(src_dir):
    if file.endswith('.js') and file != 'index.js':
        with open(os.path.join(src_dir, file), 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Very simple conversion from JS object export to JSON
        # Assuming it's `export default { ... }`
        # Remove export default
        content = re.sub(r'export default\s*', '', content)
        
        # We can't simply parse JS with json.loads because keys might not be quoted
        # So we'll use node to execute and dump it
        
        node_script = f"""
        const fs = require('fs');
        const data = {content};
        fs.writeFileSync('{os.path.join(dest_dir, file.replace(".js", ".json"))}', JSON.stringify(data, null, 2));
        """
        
        with open('temp.js', 'w', encoding='utf-8') as tmp:
            tmp.write(node_script)
            
        os.system('node temp.js')
        os.remove('temp.js')
