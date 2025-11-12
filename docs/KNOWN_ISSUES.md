# Known Issues

This document tracks known issues and their workarounds.

## Current Issues

### Issue #1: Windows Path Length Limitations

**Status:** Known limitation  
**Severity:** Low  
**Affected:** Windows users with deeply nested paths

**Description:**
Windows has a 260-character path length limit that can cause issues with Docker volumes.

**Workaround:**
1. Enable long paths in Windows:
   ```powershell
   New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
   ```
2. Restart computer
3. Or move project to a shorter path (e.g., `C:\dev\Z2RWander`)

**Future Fix:**
- Document path length requirements
- Provide path validation script

---

### Issue #2: M1/M2 Mac Performance

**Status:** Known limitation  
**Severity:** Low  
**Affected:** Apple Silicon Macs

**Description:**
Some Docker images may run slower on M1/M2 Macs due to emulation.

**Workaround:**
- Docker Desktop for Mac handles this automatically via Rosetta 2
- Most images now have ARM64 versions

**Future Fix:**
- Use ARM64-specific images where available
- Document performance expectations

---

### Issue #3: Line Ending Warnings on Windows

**Status:** Cosmetic  
**Severity:** Very Low  
**Affected:** Windows users

**Description:**
Git shows warnings about LF/CRLF line endings when committing.

**Workaround:**
```bash
git config --global core.autocrlf true
```

**Future Fix:**
- Add `.gitattributes` file to enforce line endings
- Document in setup guide

---

### Issue #4: Database Reset on Windows

**Status:** Partially fixed  
**Severity:** Low  
**Affected:** Windows users

**Description:**
The `reset-db` command may have issues with volume removal on Windows.

**Workaround:**
```bash
# Manual reset
make down
docker volume rm infrastructure_postgres_data
make dev
make seed
```

**Future Fix:**
- Improve Windows compatibility in Makefile
- Add platform detection

---

### Issue #5: Port Conflicts Not Detected

**Status:** Enhancement needed  
**Severity:** Low  
**Affected:** All platforms

**Description:**
The setup doesn't automatically detect port conflicts before starting.

**Workaround:**
```bash
# Check ports manually
netstat -ano | findstr :3000  # Windows
lsof -i :3000                 # macOS/Linux
```

**Future Fix:**
- Enhance `check-deps` to detect port conflicts
- Provide automatic port selection

---

### Issue #6: Hot Reload Sometimes Fails

**Status:** Intermittent  
**Severity:** Low  
**Affected:** All platforms

**Description:**
Vite hot module replacement may not detect changes in some edge cases.

**Workaround:**
1. Hard refresh browser (Ctrl+Shift+R)
2. Restart frontend: `make restart-frontend`
3. Check file watcher limits (Linux)

**Future Fix:**
- Investigate file watching issues
- Add file watcher configuration

---

### Issue #7: Redis Connection Pooling

**Status:** Design decision  
**Severity:** Low  
**Affected:** High-load scenarios

**Description:**
Redis client uses a single connection, which may be a bottleneck under high load.

**Workaround:**
- Not an issue for local development
- For production, use connection pooling

**Future Fix:**
- Document for production use
- Add connection pooling option

---

### Issue #8: No SSL/HTTPS by Default

**Status:** By design  
**Severity:** Low  
**Affected:** All platforms

**Description:**
Local development uses HTTP, not HTTPS.

**Workaround:**
- Acceptable for local development
- For HTTPS, see Phase 3 SSL support (if implemented)

**Future Fix:**
- Add optional SSL support
- Document security considerations

---

## Resolved Issues

### Issue #9: Docker Compose Version Warning

**Status:** Fixed  
**Resolved:** Removed `version: '3.8'` from docker-compose.yml

---

### Issue #10: npm ci Without package-lock.json

**Status:** Fixed  
**Resolved:** Added conditional check in Dockerfiles to use `npm install` if `package-lock.json` is missing

---

### Issue #11: Cross-Platform Date Commands

**Status:** Fixed  
**Resolved:** Added PowerShell fallback for Windows in Makefile

---

## Reporting Issues

If you encounter an issue not listed here:

1. **Check existing issues:**
   - Search GitHub Issues
   - Check this document

2. **Create a new issue:**
   - Include error messages
   - Steps to reproduce
   - System information (OS, Docker version)
   - Logs (`make logs`)

3. **Provide context:**
   - What were you trying to do?
   - What happened instead?
   - What did you expect?

## Contributing Fixes

If you have a fix for a known issue:

1. **Fork the repository**
2. **Create a branch:** `fix/issue-description`
3. **Make your changes**
4. **Test thoroughly**
5. **Submit a pull request**

Include:
- Description of the fix
- Reference to the issue number
- Test results
- Any breaking changes

