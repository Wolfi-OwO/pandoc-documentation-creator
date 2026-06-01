#!/usr/bin/env python3
"""
Pandoc filter to render diagrams using Kroki service
Supports: mermaid, graphviz, plantuml, and many others
"""
import os
import sys
import json
import hashlib
import base64
import urllib.request
import urllib.error
from pathlib import Path

# Kroki service URL (can be overridden with KROKI_URL environment variable)
KROKI_URL = os.environ.get('KROKI_URL', 'https://kroki.io')

# Output directory for generated images
OUTPUT_DIR = Path('kroki-images')
SIZING_ATTRIBUTES = {'width', 'height', 'max-width', 'max_width', 'maxwidth', 'maxWidth'}

def create_image(code, diagram_type, output_format='png'):
    """Generate diagram using Kroki service"""
    # Create output directory if it doesn't exist
    OUTPUT_DIR.mkdir(exist_ok=True)
    
    # Generate filename based on content hash
    content_hash = hashlib.sha256(code.encode()).hexdigest()
    filename = f"{content_hash}.{output_format}"
    filepath = OUTPUT_DIR / filename
    
    # Return cached image if it exists
    if filepath.exists():
        return str(filepath)
    
    # Build Kroki URL for POST request
    url = f"{KROKI_URL}/{diagram_type}/{output_format}"
    
    try:
        # Create POST request with diagram code in body
        data = code.encode('utf-8')
        req = urllib.request.Request(
            url,
            data=data,
            headers={
                'Content-Type': 'text/plain',
                'User-Agent': 'pandoc-kroki-filter/1.0'
            },
            method='POST'
        )
        
        # Download image from Kroki
        with urllib.request.urlopen(req, timeout=30) as response:
            image_data = response.read()
        
        # Save image
        with open(filepath, 'wb') as f:
            f.write(image_data)
        
        print(f"Created image {filepath}", file=sys.stderr)
        return str(filepath)
    
    except urllib.error.HTTPError as e:
        print(f"Error generating {diagram_type} diagram (HTTP {e.code}): {e.reason}", file=sys.stderr)
        if e.code == 400:
            print(f"Diagram code may be invalid", file=sys.stderr)
        return None
    except urllib.error.URLError as e:
        print(f"Error connecting to Kroki service: {e}", file=sys.stderr)
        return None

def process_code_block(block):
    """Process code blocks with diagram types"""
    if not isinstance(block, dict) or 't' not in block:
        return None
    
    if block['t'] != 'CodeBlock':
        return None
    
    attrs, code = block['c']
    ident, classes, keyvals = attrs
    
    # Check if this is a supported diagram type
    diagram_types = {'mermaid', 'plantuml', 'graphviz', 'dot', 'ditaa', 'erd', 'nomnoml', 'svgbob'}
    diagram_type = None
    
    for cls in classes:
        if cls.lower() in diagram_types:
            diagram_type = cls.lower()
            break
    
    if not diagram_type:
        return None
    
    # Generate image
    image_path = create_image(code, diagram_type)
    
    if not image_path:
        # Return original code block if generation failed
        return block
    
    # Default to full text width unless the author specified sizing
    if not any(k in SIZING_ATTRIBUTES for k, _ in keyvals):
        keyvals = keyvals + [('width', '100%')]

    # Return image element
    return {
        't': 'Para',
        'c': [{
            't': 'Image',
            'c': [
                [ident, classes, keyvals],  # attrs
                [],  # caption
                [image_path, '']  # target
            ]
        }]
    }

def walk(item):
    """Recursively walk and process document tree"""
    if isinstance(item, dict):
        result = process_code_block(item)
        if result:
            return result
        
        return {k: walk(v) for k, v in item.items()}
    
    elif isinstance(item, list):
        return [walk(x) for x in item]
    
    else:
        return item

if __name__ == '__main__':
    # Read JSON from stdin
    doc = json.load(sys.stdin)
    
    # Process document
    doc = walk(doc)
    
    # Write JSON to stdout
    json.dump(doc, sys.stdout)
