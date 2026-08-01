import os
import re
import urllib.request
import html
import itertools
from collections import Counter
from flask import Flask, request, render_template_string, jsonify

app = Flask(__name__)

# --- ALGORITHMS ---

def find_parikh_matches(text, target_dict):
    matches = []
    window_len = sum(target_dict.values())
    if window_len == 0 or window_len > len(text):
        return matches

    current_counts = Counter(text[:window_len])
    target_counts = Counter(target_dict)

    if current_counts == target_counts:
        matches.append((0, window_len))

    for i in range(1, len(text) - window_len + 1):
        out_char = text[i - 1]
        in_char = text[i + window_len - 1]

        current_counts[out_char] -= 1
        if current_counts[out_char] == 0:
            del current_counts[out_char]
        current_counts[in_char] += 1

        if current_counts == target_counts:
            matches.append((i, i + window_len))

    return matches

def get_permutations_and_mirrors(base_word):
    alphabet = "".join(sorted(set(base_word)))
    variations = set()
    for perm in itertools.permutations(alphabet):
        trans = str.maketrans(alphabet, "".join(perm))
        perm_word = base_word.translate(trans)
        variations.add(perm_word)
        variations.add(perm_word[::-1])
    return variations

def blend_colors(hex_colors):
    if not hex_colors:
        return "transparent"
    n = len(hex_colors)
    r, g, b = 0, 0, 0
    for h in hex_colors:
        h = h.lstrip('#')
        r += int(h[0:2], 16)
        g += int(h[2:4], 16)
        b += int(h[4:6], 16)
    
    r, g, b = r // n, g // n, b // n
    
    # User's refined overlapping color logic
    if n > 1:
        r = int(r * 0.75)
        g = int(g * 0.75)
        b = int(b * 0.75)
        return f"rgba({r}, {g}, {b}, 0.9)"
    
    return f"rgba({r}, {g}, {b}, 0.6)"

# --- WEB APPLICATION ---

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Combinatorics Search Engine</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background-color: #f4f7f6; color: #333; }
        .container { max-width: 2000px; width: 98%; margin: auto; display: flex; gap: 20px; height: 90vh; }
        .sidebar { width: 350px; flex-shrink: 0; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); display: flex; flex-direction: column; overflow-y: auto; overflow-x: hidden; }
        .main-content { flex: 1; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); display: flex; flex-direction: column; min-width: 0; overflow-x: auto; }
        h2 { margin-top: 0; font-size: 1.2rem; color: #2c3e50; }
        label { font-weight: bold; margin-top: 10px; display: block; font-size: 0.9rem; }
        textarea, input[type="text"] { width: 100%; padding: 8px; margin-top: 5px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; font-family: monospace; }
        textarea { height: 120px; resize: vertical; }
        .rule-box { border: 1px solid #e0e0e0; padding: 10px; margin-top: 10px; border-radius: 6px; background: #fafafa; }
        .rule-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px; }
        .remove-btn { background: #ff4d4d; color: white; border: none; border-radius: 3px; cursor: pointer; padding: 2px 8px; font-size: 0.8rem; }
        select, input[type="color"] { margin-top: 5px; padding: 5px; width: 100%; box-sizing: border-box; }
        button.action-btn { background: #3498db; color: white; border: none; padding: 10px; border-radius: 4px; cursor: pointer; font-weight: bold; margin-top: 15px; width: 100%; }
        button.action-btn:hover { background: #2980b9; }
        button.add-btn { background: #2ecc71; margin-top: 10px; }
        button.add-btn:hover { background: #27ae60; }
        #viewer { flex: 1; border: 1px solid #ddd; padding: 15px; border-radius: 4px; overflow: auto; background: #fff; font-family: 'Courier New', Courier, monospace; word-wrap: break-word; word-break: break-all; white-space: pre-wrap; font-size: 14px; line-height: 1.5; resize: horizontal; width: 100%; min-width: 200px; max-width: 5000px; }
        .loading { text-align: center; color: #7f8c8d; font-style: italic; display: none; margin-top: 10px; }
        .length-display { font-size: 0.85rem; color: #555; margin-top: 5px; font-weight: 600; }
    </style>
</head>
<body>
<div class="container">
    <div class="sidebar">
        <h2>Data Source</h2>
        <label>Paste Text or Type URL:</label>
        <textarea id="sourceText" placeholder='e.g., "abcacdcbcdcad..."a19b21 85'></textarea>
        
        <h2 style="margin-top: 20px;">Search Criteria</h2>
        <div id="rulesContainer"></div>
        
        <button class="action-btn add-btn" onclick="addRule()">+ Add Rule</button>
        <button class="action-btn" onclick="runAnalysis()">Run Analysis</button>
        <div class="loading" id="loadingText">Processing...</div>
    </div>
    <div class="main-content">
        <h2>Visualizer</h2>
        <div id="viewer" title="Drag the bottom-right corner to resize this box and align text wrap">Output will appear here...</div>
    </div>
</div>
<script>
    let ruleCount = 0;

    function handleRuleChange(element) {
        updateLength(element);
        
        const ruleBox = element.closest('.rule-box');
        const ruleType = element.value;
        const valueInput = ruleBox.querySelector('.rule-value');
        const colorInput = ruleBox.querySelector('.color-controls');
        
        if (ruleType === 'alt_even' || ruleType === 'alt_odd') {
            valueInput.style.display = 'none';
            colorInput.style.display = 'none';
        } else {
            valueInput.style.display = 'block';
            colorInput.style.display = 'block';
        }
    }

    function updateLength(element) {
        const ruleBox = element.closest('.rule-box');
        const ruleType = ruleBox.querySelector('.rule-type').value;
        const val = ruleBox.querySelector('.rule-value').value.trim();
        const displayElem = ruleBox.querySelector('.length-display');

        if (ruleType === 'alt_even' || ruleType === 'alt_odd') {
            displayElem.innerText = "Length: N/A";
            return;
        }

        if (!val) {
            displayElem.innerText = "Length: 0";
            return;
        }

        if (ruleType === 'regex') {
            let counts = {};
            let cleanVal = val.replace(/[^a-zA-Z]/g, '').toLowerCase();
            for (let c of cleanVal) { counts[c] = (counts[c] || 0) + 1; }
            let parikhStr = Object.keys(counts).sort().map(k => `${k}:${counts[k]}`).join(' ');
            displayElem.innerText = `Length: ${cleanVal.length} | Parikh: [${parikhStr || 'N/A'}]`;
            
        // Dynamic handling for single vs multiple words
        } else if (ruleType === 'perms_mirrors') {
            const words = val.replace(/,/g, ' ').split(/\s+/).filter(w => w.length > 0);
            if (words.length === 1) {
                let cleanVal = words[0].replace(/[^a-zA-Z]/g, '').toLowerCase();
                let counts = {};
                for (let c of cleanVal) { counts[c] = (counts[c] || 0) + 1; }
                let parikhStr = Object.keys(counts).sort().map(k => `${k}:${counts[k]}`).join(' ');
                displayElem.innerText = `Length: ${cleanVal.length} | Parikh: [${parikhStr || 'N/A'}]`;
            } else if (words.length > 1) {
                const lengths = words.map(w => w.length).join(', ');
                displayElem.innerText = `Words: ${words.length} | Lengths: [${lengths}] (Parikh omitted)`;
            }
            
        } else if (ruleType === 'word_list') {
            const words = val.replace(/,/g, ' ').split(/\s+/).filter(w => w.length > 0);
            const lengths = words.map(w => w.length).join(', ');
            displayElem.innerText = `Words: ${words.length} | Lengths: [${lengths}]`;
            
        } else if (ruleType === 'parikh' || ruleType === 'parikh_perms') {
            let sum = 0;
            if (val.includes(':')) {
                const matches = val.match(/\\d+/g);
                if (matches) sum = matches.reduce((acc, curr) => acc + parseInt(curr, 10), 0);
            } else {
                const parts = val.split(/\\s+/);
                if (parts.length > 1) {
                    for (let i = 1; i < parts.length; i++) {
                        let num = parseInt(parts[i], 10);
                        if (!isNaN(num)) sum += num;
                    }
                }
            }
            displayElem.innerText = "Parikh Sum: " + sum;
        }
    }

    function addRule() {
        ruleCount++;
        const colors = ['#ffadad', '#ffd6a5', '#fdffb6', '#caffbf', '#9bf6ff', '#a0c4ff', '#bdb2ff'];
        const randomColor = colors[ruleCount % colors.length];
        const html = `
            <div class="rule-box" id="rule-${ruleCount}">
                <div class="rule-header">
                    <strong>Rule ${ruleCount}</strong>
                    <button class="remove-btn" onclick="document.getElementById('rule-${ruleCount}').remove()">X</button>
                </div>
                <select class="rule-type" onchange="handleRuleChange(this)">
                    <option value="regex">Exact Word / Regex</option>
                    <option value="word_list">Multiple Exact Words (comma separated)</option>
                    <option value="perms_mirrors">Permutations & Mirrors (supports comma separated lists!)</option>
                    <option value="parikh">Parikh Vector (e.g., abcd 9 4 4 4)</option>
                    <option value="parikh_perms">Parikh Vector Permutations</option>
                    <option value="alt_odd">Alternating Letters (Odd: 1st, 3rd, 5th...)</option>
                    <option value="alt_even">Alternating Letters (Even: 2nd, 4th, 6th...)</option>
                </select>
                <input type="text" class="rule-value" placeholder="Enter pattern or vector..." oninput="updateLength(this)">
                
                <div class="length-display">Length: 0</div>

                <div class="color-controls">
                    <div class="autocolor-container" style="margin-top:8px; font-size:0.85rem;">
                        <label style="display:inline; font-weight:normal; cursor:pointer;">
                            <input type="checkbox" class="rule-autocolor" checked> Auto-color distinct instances
                        </label>
                    </div>
                    <div style="margin-top:5px; font-size:0.85rem;">
                        Base Color: <input type="color" class="rule-color" value="${randomColor}" style="vertical-align: middle;">
                    </div>
                </div>
            </div>
        `;
        document.getElementById('rulesContainer').insertAdjacentHTML('beforeend', html);
    }

    async function runAnalysis() {
        const source = document.getElementById('sourceText').value;
        if (!source.trim()) return alert("Please provide some text or a URL.");
        const rules = [];
        document.querySelectorAll('.rule-box').forEach(box => {
            const autoColorCheckbox = box.querySelector('.rule-autocolor');
            rules.push({
                type: box.querySelector('.rule-type').value,
                value: box.querySelector('.rule-value').value.trim(),
                color: box.querySelector('.rule-color').value,
                autoColor: autoColorCheckbox ? autoColorCheckbox.checked : false
            });
        });
        document.getElementById('loadingText').style.display = 'block';
        document.getElementById('viewer').innerHTML = '';
        try {
            const response = await fetch('/analyze', {
                method: 'POST', headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ source: source, rules: rules })
            });
            const data = await response.json();
            if (data.error) document.getElementById('viewer').innerHTML = `<span style="color:red;">Error: ${data.error}</span>`;
            else document.getElementById('viewer').innerHTML = data.html;
        } catch (err) {
            document.getElementById('viewer').innerHTML = `<span style="color:red;">Connection error.</span>`;
        }
        document.getElementById('loadingText').style.display = 'none';
    }
    addRule();
</script>
</body>
</html>
"""

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)

@app.route('/analyze', methods=['POST'])
def analyze():
    data = request.json
    source = data.get('source', '')
    rules = data.get('rules', [])

    if source.startswith('http://') or source.startswith('https://'):
        try:
            req = urllib.request.Request(source, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req) as response:
                html_bytes = response.read()
                html_str = html_bytes.decode('utf-8', errors='ignore')
                text = re.sub(r'<style.*?>.*?</style>', '', html_str, flags=re.IGNORECASE|re.DOTALL)
                text = re.sub(r'<script.*?>.*?</script>', '', text, flags=re.IGNORECASE|re.DOTALL)
                text = re.sub(r'<[^>]+>', ' ', text)
                text = re.sub(r'[^a-zA-Z\n\r\t ]', '', text).lower()
        except Exception as e:
            return jsonify({'error': f"Failed to fetch URL: {str(e)}"}), 400
    else:
        text = source.lower()

    if not text.strip(): return jsonify({'error': "No text to process."}), 400

    match_spans = [] 
    MULTI_PALETTE = ['#ffadad', '#ffd6a5', '#fdffb6', '#caffbf', '#9bf6ff', '#a0c4ff', '#bdb2ff', '#ffc6ff', '#ffb5a7', '#fcd5ce', '#f8ad9d', '#f4978e', '#f08080', '#c1d3fe', '#b6ccfe']
    unique_string_color_map = {}
    multi_color_idx = 0

    PARITY_COLORS = {
        'a': '#ffb3ba',
        'b': '#baffc9',
        'c': '#e6b800',
        'd': '#add8e6' 
    }

    for rule in rules:
        val = rule['value']
        base_color = rule['color']
        auto_color = rule.get('autoColor', False)

        if rule['type'] in ['alt_even', 'alt_odd']:
            target_parity = 0 if rule['type'] == 'alt_odd' else 1
            lines = text.split('\n')
            offset = 0
            for line in lines:
                parity_counter = 0
                for i, char in enumerate(line):
                    actual_idx = offset + i
                    if char.isalpha():
                        if parity_counter % 2 == target_parity:
                            if char in PARITY_COLORS:
                                match_spans.append((actual_idx, actual_idx+1, PARITY_COLORS[char]))
                        parity_counter += 1
                offset += len(line) + 1 
            continue

        if not val: continue

        if rule['type'] == 'word_list':
            try:
                words = [w.strip() for w in val.replace(',', ' ').split() if w.strip()]
                for w in words:
                    if auto_color:
                        if w not in unique_string_color_map:
                            unique_string_color_map[w] = MULTI_PALETTE[multi_color_idx % len(MULTI_PALETTE)]
                            multi_color_idx += 1
                        assigned_color = unique_string_color_map[w]
                    else: assigned_color = base_color
                    for match in re.finditer(f'(?=({re.escape(w)}))', text):
                        match_spans.append((match.start(), match.start() + len(w), assigned_color))
            except Exception: pass

        elif rule['type'] == 'perms_mirrors':
            try:
                words = [w.strip() for w in val.replace(',', ' ').split() if w.strip()]
                for base_word in words:
                    variations = get_permutations_and_mirrors(base_word)
                    for var in variations:
                        if auto_color:
                            if var not in unique_string_color_map:
                                unique_string_color_map[var] = MULTI_PALETTE[multi_color_idx % len(MULTI_PALETTE)]
                                multi_color_idx += 1
                            assigned_color = unique_string_color_map[var]
                        else: assigned_color = base_color
                        for match in re.finditer(f'(?=({re.escape(var)}))', text):
                            match_spans.append((match.start(), match.start() + len(var), assigned_color))
            except Exception: pass

        elif rule['type'] == 'regex':
            try:
                for match in re.finditer(val, text):
                    s, e = match.span()
                    m_text = match.group(0)
                    if auto_color:
                        if m_text not in unique_string_color_map:
                            unique_string_color_map[m_text] = MULTI_PALETTE[multi_color_idx % len(MULTI_PALETTE)]
                            multi_color_idx += 1
                        assigned_color = unique_string_color_map[m_text]
                    else: assigned_color = base_color
                    match_spans.append((s, e, assigned_color))
            except re.error: pass
                
        elif rule['type'] == 'parikh':
            try:
                target_dict = {}
                parts = val.split()
                if len(parts) >= 2:
                    chars = parts[0]
                    counts = parts[1:]
                    if len(chars) == len(counts):
                        for i, char in enumerate(chars): target_dict[char.strip().lower()] = int(counts[i].strip())
                else:
                    for part in val.split(','):
                        k, v = part.split(':')
                        target_dict[k.strip().lower()] = int(v.strip())

                if target_dict:
                    spans = find_parikh_matches(text, target_dict)
                    for s, e in spans:
                        if auto_color:
                            assigned_color = MULTI_PALETTE[multi_color_idx % len(MULTI_PALETTE)]
                            multi_color_idx += 1
                        else: assigned_color = base_color
                        match_spans.append((s, e, assigned_color))
            except Exception: pass

        elif rule['type'] == 'parikh_perms':
            try:
                parts = val.split()
                if len(parts) >= 2:
                    chars = parts[0]
                    counts = [int(c.strip()) for c in parts[1:]]
                    if len(chars) == len(counts):
                        unique_count_perms = set(itertools.permutations(counts))
                        for count_perm in unique_count_perms:
                            target_dict = {chars[i].strip().lower(): count_perm[i] for i in range(len(chars))}
                            spans = find_parikh_matches(text, target_dict)
                            if auto_color:
                                assigned_color = MULTI_PALETTE[multi_color_idx % len(MULTI_PALETTE)]
                                multi_color_idx += 1
                            else: assigned_color = base_color
                            for s, e in spans:
                                match_spans.append((s, e, assigned_color))
            except Exception: pass

    color_map = [[] for _ in range(len(text))]
    for start, end, color in match_spans:
        for i in range(start, end):
            if color not in color_map[i]: color_map[i].append(color)

    chunks = []
    if len(text) > 0:
        current_colors = tuple(color_map[0])
        current_start = 0
        for i in range(1, len(text)):
            if tuple(color_map[i]) != current_colors:
                chunks.append((current_start, i, current_colors))
                current_colors = tuple(color_map[i])
                current_start = i
        chunks.append((current_start, len(text), current_colors))

    html_parts = []
    for start, end, colors in chunks:
        chunk_text = html.escape(text[start:end])
        if colors:
            bg_color = blend_colors(colors)
            html_parts.append(f'<span style="background-color: {bg_color}; font-weight: bold;">{chunk_text}</span>')
        else: html_parts.append(chunk_text)

    return jsonify({'html': "".join(html_parts)})

if __name__ == '__main__':
    print("\n" + "="*50)
    print("Combinatorics Search Engine")
    print("="*50)
    print("Starting local server. Press Ctrl+C to quit.")
    print("Open your web browser to: http://127.0.0.1:5000")
    print("="*50 + "\n")
    app.run(host='127.0.0.1', port=5000, debug=False)