# ☁️ Google Drive Setup — rclone + FUSE

Guía de autorización para nuevas instalaciones.

---

## Prerequisitos

Asegúrate de haber hecho el rebuild con el módulo activo:

```bash
sudo nixos-rebuild switch
```

Esto instala `rclone`, crea `~/GoogleDrive/` y registra el servicio systemd.

---

## Paso 1 — Ejecutar el asistente de auth

```bash
gdrive-auth
```

El script te guía interactivamente. Sigue leyendo solo si prefieres hacerlo manualmente.

---

## Paso 2 — Setup manual (alternativa)

Si el script falla o prefieres control total:

```bash
rclone config
```

Responde a cada prompt así:

| Prompt | Respuesta |
|--------|-----------|
| `No remotes found, make a new one?` | `n` — New remote |
| `name>` | `gdrive` ← **exactamente este nombre** |
| `Storage>` | `drive` (o escribe `17` si muestra número) |
| `client_id>` | *(dejar vacío, Enter)* |
| `client_secret>` | *(dejar vacío, Enter)* |
| `scope>` | `1` — Full access |
| `root_folder_id>` | *(dejar vacío, Enter)* |
| `service_account_file>` | *(dejar vacío, Enter)* |
| `Edit advanced config?` | `n` |
| `Use auto config?` | `y` ← abre el navegador |
| *(navegar y autorizar en el browser)* | — |
| `Configure this as a Shared Drive?` | `n` (salvo que lo necesites) |
| `Keep this "gdrive" remote?` | `y` |
| `Quit config` | `q` |

> ⚠️ El nombre del remote **debe ser `gdrive`**. El servicio systemd está
> configurado con ese nombre hardcoded. Si lo llamas diferente el mount no funciona.

---

## Paso 3 — Activar el servicio

Después del `rclone config` manual, arranca el servicio:

```bash
systemctl --user daemon-reload
systemctl --user enable rclone-gdrive
systemctl --user start rclone-gdrive
```

Verifica que montó correctamente:

```bash
systemctl --user status rclone-gdrive
ls ~/GoogleDrive
```

---

## Comandos útiles del día a día

```bash
# Estado del mount
systemctl --user status rclone-gdrive

# Montar / desmontar manualmente
systemctl --user start  rclone-gdrive
systemctl --user stop   rclone-gdrive

# Ver logs en tiempo real
journalctl --user -u rclone-gdrive -f

# Copiar archivo local → Drive
cp ~/archivo.pdf ~/GoogleDrive/

# Mover carpeta Drive → local
mv ~/GoogleDrive/Fotos ~/Pictures/

# Eliminar archivo en Drive
rm ~/GoogleDrive/viejo.txt

# Sincronizar carpeta local → Drive (solo CLI, sin mount)
rclone sync ~/Documentos gdrive:/Documentos

# Listar archivos en Drive sin mount
rclone ls gdrive:

# Ver cuánto espacio usas
rclone about gdrive:
```

---

## Cache y rendimiento

El servicio usa `--vfs-cache-mode full` con 2 GB de cache local.
Los archivos recién accedidos se guardan en:

```
~/.cache/rclone/vfs/
```

Para limpiar la cache:

```bash
systemctl --user stop rclone-gdrive
rm -rf ~/.cache/rclone/vfs/
systemctl --user start rclone-gdrive
```

---

## Renovar el token (si expira)

Los tokens OAuth de Google expiran eventualmente. Si el mount falla con errores de autenticación:

```bash
rclone config reconnect gdrive:
```

Abre el browser, reautoriza, y el servicio vuelve a funcionar.

---

## Eliminar la configuración

```bash
# Parar y deshabilitar el servicio
systemctl --user stop   rclone-gdrive
systemctl --user disable rclone-gdrive

# Borrar las credenciales
rclone config delete gdrive

# O borrar todo el archivo de config
rm ~/.config/rclone/rclone.conf
```

Para remover el módulo del sistema: elimina `rclone.nix` de
`modules/hm/services/system/` y haz rebuild.
