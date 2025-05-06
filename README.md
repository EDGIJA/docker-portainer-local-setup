# 🐳 Portainer Local GUI Launcher (Without Docker Desktop)

This repository contains a minimal and efficient installation for managing Docker on Linux systems (such as Ubuntu) without relying on Docker Desktop.

It includes:

* Clean installation of Docker Engine
* Portainer container with automatic restart
* Script to launch Portainer and open a browser
* System menu integration via `.desktop`
* Auto-run option at login

> Ideal for those looking for control, customization, and lightness.

---

## 📦 Installation

> Recommended to ensure everything works correctly, but if Docker Engine is already installed, it is not a prerequisite.

```bash
chmod +x instalar_docker.sh
./instalar_docker.sh
```

---

## 🐳 Initialize Portainer

```bash
chmod +x ~/portainer_start.sh
./portainer_start.sh
```

Portainer will start locally and be accessible at:

```http
http://localhost:9000
```

---

## 📃 Included Files

```
.
├── instalar_docker.sh              # Docker Engine installation script
├── portainer_start.sh              # Portainer container runner and browser launcher
├── Applications/
│   └── portainer/
│       ├── portainer.desktop       # .desktop launcher file
│       └── portainer-icon.png      # Custom icon (optional)
├── .gitignore                      # Excludes unnecessary files
└── README.md                       # This file
```

---

## 🌟 Optional Enhancements

* Add `portainer.desktop` to `~/.config/autostart/` for GUI launch on login:

```bash
ln -s /absolute/path/to/portainer.desktop ~/.config/autostart/
```

* Make the `.desktop` file discoverable in your system menu:

```bash
ln -s /absolute/path/to/portainer.desktop ~/.local/share/applications/
```

---

## 🌐 License
MIT License — feel free to fork, adapt, and use.
