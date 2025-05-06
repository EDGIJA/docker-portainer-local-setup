# 🚧 TROUBLESHOOTING & SETUP NOTES

This document captures real issues encountered during development and setup of this project, along with their solutions.

---

## ❌ Problem 1: GitHub Push Failed - Password Authentication Removed

### **Symptoms:**

```
Username for 'https://github.com': <username>
Password for 'https://<username>@github.com':
remote: Support for password authentication was removed...
fatal: Authentication failed
```

### **Cause:**

GitHub removed password-based authentication for HTTPS repositories.

### ✅ **Solution:**

Switch to SSH:

```bash
git remote set-url origin git@github.com:EDGIJA/docker-portainer-local-setup.git
```

Then test:

```bash
ssh -T git@github.com
```

---

## ❌ Problem 2: "Repository Not Found" When Using SSH

### **Symptoms:**

```
ERROR: Repository not found.
fatal: Could not read from remote repository.
```

### **Cause:**

The SSH URL pointed to a repository name that didn't match the actual one on GitHub.

### ✅ **Solution:**

Double-check the repo name in GitHub and correct the remote:

```bash
git remote set-url origin git@github.com:<username>/docker-portainer-local-setup.git
```

---

## ❌ Problem 3: Nothing Pushed - "src refspec main does not match any"

### **Symptoms:**

```
fatal: src refspec main does not match any
```

### **Cause:**

No commit had been made yet, and the branch `main` didn't exist locally.

### ✅ **Solution:**

Make the initial commit before pushing:

```bash
git add .
git commit -m "Initial commit"
git branch -m main
```

Then push:

```bash
git push -u origin main
```

---

## ❌ Problem 4: Pushed from the Wrong Folder

### **Symptoms:**

Git tried to push unrelated files (e.g. user home files, videos, etc.)

### **Cause:**

The repository was initialized in the user's home folder instead of the project directory.

### ✅ **Solution:**

Always initialize Git from the correct folder:

```bash
cd ~/Documents/Development/Repos\ -\ opensource/linux-docker-portainer-local-setup
git init
```

Avoid using Git in `~/` directly unless intentional.

---

## 🧠 Tip: Configure `main` as Default Branch Name Globally

```bash
git config --global init.defaultBranch main
```

So future `git init` commands default to `main` instead of `master`.

---

## ✅ Confirming Success

After solving the above:

```bash
git push -u origin main
```

You should see:

```
Writing objects: 100%...
To github.com:<username>/docker-portainer-local-setup.git
 * [new branch]      main -> main
```

Happy containerizing! 🐳
