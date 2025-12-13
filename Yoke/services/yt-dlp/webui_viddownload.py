#!/usr/bin/env python3

# This python file is 100% LLM-generated bc I was lazy today, I'm surprised it even works (kagi assistant gpt-5-mini)

"""
Flask web UI to run a video-download script.

Behavior:
- Writes input textarea to /tmp/viddownload/input.txt
- Starts: [script_path] [-d] -i /tmp/viddownload -o [output_path]
- Live previews:
  - /tmp/viddownload/viddownload.log
  - [output_path]/fail.txt
  - /tmp/viddownload/input.txt
- Persists chosen output path and script path under /tmp/viddownload/
- Single-run protection via /tmp/viddownload/script.pid
- Cancel endpoint sends SIGTERM then SIGKILL if needed
- Process is started detached (preexec_fn=os.setsid) so it won't be tied to the request
- Provides endpoints for status and log retrieval so multiple browsers see the same progress
"""

import os
import subprocess
import threading
import time
import signal
from flask import Flask, request, jsonify, Response, render_template_string

app = Flask(__name__)

TMP_DIR = '/tmp/viddownload'
os.makedirs(TMP_DIR, exist_ok=True)

PID_FILE = os.path.join(TMP_DIR, 'script.pid')
LOG_FILE = os.path.join(TMP_DIR, 'viddownload.log')     # script writes here
INPUT_FILE = os.path.join(TMP_DIR, 'input.txt')
OUTPATH_FILE = os.path.join(TMP_DIR, 'script.outpath')
SCRIPT_PATH_FILE = os.path.join(TMP_DIR, 'script.path')

DEFAULT_OUTPATH = '/mnt/pool1/yt-dlp'
DEFAULT_SCRIPT_PATH = '/run/current-system/sw/bin/viddownload'

# -- Helpers --

def read_file_tail(path, max_bytes=20000):
    """Return the tail of the file (as text). If file doesn't exist, return empty string."""
    try:
        with open(path, 'rb') as f:
            f.seek(0, os.SEEK_END)
            size = f.tell()
            start = max(0, size - max_bytes)
            f.seek(start)
            data = f.read()
            # decode best-effort
            return data.decode('utf-8', errors='replace')
    except FileNotFoundError:
        return ''
    except Exception as e:
        return f'Error reading {path}: {e}'

def write_pid(pid):
    try:
        with open(PID_FILE, 'w') as f:
            f.write(str(pid))
    except Exception:
        pass

def clear_pid_file():
    try:
        if os.path.exists(PID_FILE):
            os.remove(PID_FILE)
    except Exception:
        pass

def get_pid():
    try:
        with open(PID_FILE) as f:
            return int(f.read().strip())
    except Exception:
        return None

def is_pid_running(pid):
    if not pid:
        return False
    try:
        os.kill(pid, 0)
    except OSError:
        return False
    else:
        return True

def is_script_running():
    pid = get_pid()
    if pid and is_pid_running(pid):
        return True
    # stale pid file cleanup
    clear_pid_file()
    return False

def write_outpath(path):
    try:
        with open(OUTPATH_FILE, 'w') as f:
            f.write(str(path))
    except Exception:
        pass

def read_outpath():
    try:
        with open(OUTPATH_FILE) as f:
            return f.read().strip()
    except Exception:
        return None

def write_script_path(path):
    try:
        with open(SCRIPT_PATH_FILE, 'w') as f:
            f.write(str(path))
    except Exception:
        pass

def read_script_path():
    try:
        with open(SCRIPT_PATH_FILE) as f:
            return f.read().strip()
    except Exception:
        return None

# -- HTML UI --

INDEX_HTML = """
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>VidDownload Runner</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    label { display:block; margin-top: 10px; }
    textarea { width: 100%; box-sizing: border-box; font-family: monospace; }
    #log, #fail, #inputPreview { white-space: pre-wrap; background: #111; color: #eee; padding: 8px; height: 200px; overflow: auto; }
    input[type="text"] { width: 80%; }
    button:disabled { opacity: 0.6; }
    .btns { margin-top: 8px; }
  </style>
</head>
<body>
  <h2>VidDownload Runner</h2>

  <label>Script path:
    <input id="scriptpath" type="text" value="{{ script_default }}" />
  </label>

  <label>Output path on server:
    <input id="outpath" type="text" value="{{ out_default }}" />
  </label>

  <label>
    <input id="dryrun" type="checkbox" /> Dry run (pass -d to the script)
  </label>

  <label>Input file contents (will be written to /tmp/viddownload/input.txt):
    <textarea id="input" rows="8" placeholder="Type input here..."></textarea>
  </label>

  <div class="btns">
    <button id="runBtn">Run</button>
    <button id="cancelBtn" disabled>Cancel</button>
    <span id="status" style="margin-left:12px;"></span>
  </div>

  <h3>Live preview: /tmp/viddownload/viddownload.log</h3>
  <div id="log">Loading...</div>

  <h3>Live preview: fail.txt from chosen output path</h3>
  <div id="fail">Loading...</div>

  <h3>Live preview: /tmp/viddownload/input.txt</h3>
  <div id="inputPreview">Loading...</div>

<script>
const runBtn = document.getElementById('runBtn');
const cancelBtn = document.getElementById('cancelBtn');
const outPathEl = document.getElementById('outpath');
const inputEl = document.getElementById('input');
const scriptPathEl = document.getElementById('scriptpath');
const dryrunEl = document.getElementById('dryrun');
const logEl = document.getElementById('log');
const failEl = document.getElementById('fail');
const inputPreviewEl = document.getElementById('inputPreview');
const statusEl = document.getElementById('status');

async function getStatus() {
  try {
    const r = await fetch('/status');
    const j = await r.json();
    const running = j.running;
    runBtn.disabled = running;
    cancelBtn.disabled = !running;
    statusEl.textContent = running ? ('Running (pid '+j.pid+')') : 'Idle';
  } catch (e) {
    statusEl.textContent = 'Status error';
  }
}

async function pollLog() {
  try {
    const r = await fetch('/log');
    const txt = await r.text();
    if (logEl.textContent !== txt) {
      logEl.textContent = txt;
      logEl.scrollTop = logEl.scrollHeight;
    }
  } catch (e) {
    logEl.textContent = 'Error loading log';
  }
}

async function pollFail() {
  try {
    const r = await fetch('/fail');
    const txt = await r.text();
    if (failEl.textContent !== txt) {
      failEl.textContent = txt;
      failEl.scrollTop = failEl.scrollHeight;
    }
  } catch (e) {
    failEl.textContent = 'Error loading fail file';
  }
}

async function pollInputPreview() {
  try {
    const r = await fetch('/input');
    const txt = await r.text();
    if (inputPreviewEl.textContent !== txt) {
      inputPreviewEl.textContent = txt;
      inputPreviewEl.scrollTop = inputPreviewEl.scrollHeight;
    }
  } catch (e) {
    inputPreviewEl.textContent = 'Error loading input file';
  }
}

runBtn.addEventListener('click', async () => {
  runBtn.disabled = true;
  cancelBtn.disabled = true;
  statusEl.textContent = 'Starting...';
  const payload = {
    scriptpath: scriptPathEl.value,
    outpath: outPathEl.value,
    dry: dryrunEl.checked,
    input: inputEl.value
  };
  try {
    const r = await fetch('/start', {
      method: 'POST',
      headers: {'Content-Type':'application/json'},
      body: JSON.stringify(payload)
    });
    if (!r.ok) {
      const err = await r.json();
      alert('Failed to start: ' + (err.error || 'unknown'));
      runBtn.disabled = false;
    }
  } catch (e) {
    alert('Start request failed: ' + e);
    runBtn.disabled = false;
  }
});

cancelBtn.addEventListener('click', async () => {
  cancelBtn.disabled = true;
  statusEl.textContent = 'Cancelling...';
  try {
    const r = await fetch('/cancel', { method: 'POST' });
    if (!r.ok) {
      const err = await r.json();
      alert('Cancel failed: ' + (err.error || 'unknown'));
    } else {
      // success - keep disabled until status poll updates
      const j = await r.json();
      statusEl.textContent = j.message || 'Cancel sent';
    }
  } catch (e) {
    alert('Cancel request failed: ' + e);
  }
});

async function mainLoop() {
  await getStatus();
  await pollLog();
  await pollFail();
  await pollInputPreview();
  setTimeout(mainLoop, 1000);
}

mainLoop();
</script>

</body>
</html>
"""

# -- Routes --

@app.route('/')
def index():
    # fill defaults from saved values if present
    saved_out = read_outpath() or DEFAULT_OUTPATH
    saved_script = read_script_path() or DEFAULT_SCRIPT_PATH
    return render_template_string(INDEX_HTML, out_default=saved_out, script_default=saved_script)

@app.route('/status')
def status():
    pid = get_pid()
    running = is_script_running()
    return jsonify({'running': running, 'pid': pid if running else None})

@app.route('/log')
def get_log():
    return Response(read_file_tail(LOG_FILE), mimetype='text/plain; charset=utf-8')

@app.route('/fail')
def get_fail():
    outpath = read_outpath()
    if not outpath:
        return Response('', mimetype='text/plain; charset=utf-8')
    fail_file = os.path.join(os.path.abspath(outpath), 'fail.txt')
    return Response(read_file_tail(fail_file), mimetype='text/plain; charset=utf-8')

@app.route('/input')
def get_input_preview():
    return Response(read_file_tail(INPUT_FILE), mimetype='text/plain; charset=utf-8')

@app.route('/start', methods=['POST'])
def start():
    if is_script_running():
        return jsonify({'error': 'Script already running'}), 400

    data = request.get_json(force=True)
    scriptpath = data.get('scriptpath') or DEFAULT_SCRIPT_PATH
    outpath = data.get('outpath') or ''
    dry = bool(data.get('dry'))
    input_text = data.get('input') or ''

    # enforce outpath provided
    if not outpath or not outpath.strip():
        return jsonify({'error': 'Output path is required'}), 400
    outpath = os.path.abspath(outpath)
    write_outpath(outpath)

    # store script path
    scriptpath = os.path.abspath(scriptpath)
    write_script_path(scriptpath)

    # ensure script exists and is executable
    if not os.path.isfile(scriptpath) or not os.access(scriptpath, os.X_OK):
        return jsonify({'error': f'{scriptpath} not found or not executable on server'}), 500

    # write input to /tmp/viddownload/input.txt (script reads this directory)
    try:
        with open(INPUT_FILE, 'wb') as f:
            f.write(input_text.encode('utf-8'))
    except Exception as e:
        return jsonify({'error': f'Failed to write input file: {e}'}), 500

    # Build arguments: include -d if dry requested
    args = [scriptpath]
    if dry:
        args.append('-d')
    args.extend(['-i', TMP_DIR, '-o', outpath])

    # Start the script detached. The script is expected to manage LOG_FILE itself.
    try:
        proc = subprocess.Popen(
            args,
            preexec_fn=os.setsid,
            close_fds=True
        )

        write_pid(proc.pid)

        # waiter thread to clear pid file when process ends
        def waiter(p):
            try:
                p.wait()
            except Exception:
                pass
            clear_pid_file()

        t = threading.Thread(target=waiter, args=(proc,), daemon=True)
        t.start()

        return jsonify({'started': True, 'pid': proc.pid})
    except Exception as e:
        return jsonify({'error': f'Failed to start process: {e}'}), 500

@app.route('/cancel', methods=['POST'])
def cancel():
    pid = get_pid()
    if not pid or not is_pid_running(pid):
        clear_pid_file()
        return jsonify({'error': 'No running process to cancel'}), 400

    try:
        pgid = os.getpgid(pid)
    except Exception as e:
        return jsonify({'error': f'Failed to obtain process group: {e}'}), 500

    # Try graceful termination first
    try:
        os.killpg(pgid, signal.SIGTERM)
    except ProcessLookupError:
        # process already gone
        clear_pid_file()
        return jsonify({'message': 'Process already exited'}), 200
    except PermissionError:
        return jsonify({'error': 'Permission denied sending SIGTERM'}), 500
    except Exception as e:
        return jsonify({'error': f'Failed to send SIGTERM: {e}'}), 500

    # Wait briefly and escalate if still alive
    timeout = 3.0
    interval = 0.1
    waited = 0.0
    while waited < timeout:
        time.sleep(interval)
        waited += interval
        if not is_pid_running(pid):
            return jsonify({'message': 'SIGTERM sent, process exited'}), 200

    # escalate to SIGKILL
    try:
        os.killpg(pgid, signal.SIGKILL)
    except ProcessLookupError:
        clear_pid_file()
        return jsonify({'message': 'Process exited after SIGTERM'}), 200
    except PermissionError:
        return jsonify({'error': 'Permission denied sending SIGKILL'}), 500
    except Exception as e:
        return jsonify({'error': f'Failed to send SIGKILL: {e}'}), 500

    return jsonify({'message': 'SIGKILL sent'}), 200


if __name__ == '__main__':
    # Run flask app (for production, use a proper WSGI server) (gunicorn --workers 3 --bind '[::]:9000' --umask 0o007 webui_viddownload:app)
    app.run(host='::', port=5000, threaded=True)
