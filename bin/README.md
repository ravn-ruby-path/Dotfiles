# Git Workflow Tools: Bare Clone + Worktrees

Estos scripts implementan un flujo de trabajo moderno de Git basado en **repositorios bare** (sin área de trabajo) y **worktrees** (múltiples directorios de trabajo). Este enfoque es muy eficiente para trabajar con múltiples ramas simultáneamente.

---

## 📚 Conceptos Clave

### ¿Qué es un Repositorio Bare?

Un repositorio bare es un repositorio Git sin directorio de trabajo. Contiene solo los archivos de control de Git (lo que normalmente está en `.git/`). Se usa típicamente en servidores.

```
~/.local/share/git-bare/myrepo/
├── objects/
├── refs/
├── HEAD
└── config
```

**Ventajas:**
- No ocupa espacio duplicado con archivos de trabajo
- Centraliza toda la información de Git
- Perfecto para compartir entre múltiples worktrees

### ¿Qué son Git Worktrees?

Un worktree es un directorio de trabajo conectado a un repositorio Git existente. Permite trabajar en múltiples ramas **simultáneamente** sin cambiar de rama.

```
~/Work/myrepo/
├── main/           ← worktree 1
├── feature/bug-fix/  ← worktree 2
├── feature/new-api/  ← worktree 3
└── .git  ← archivo que apunta al repositorio bare
```

**Ventajas:**
- Trabaja en múltiples ramas al mismo tiempo
- No necesitas hacer `git stash` ni cambiar de rama
- Cada worktree es un directorio independiente
- Git mantiene sincronizado el estado entre ellos

---

## 🔧 Script 1: `git-bare-clone`

### Propósito

Clona un repositorio como bare y crea automáticamente worktrees para **todas** las ramas remotas.

### Ubicaciones por Defecto

| Concepto | Ubicación | Variable de Entorno |
|----------|-----------|-------------------|
| Repositorio Bare | `~/.local/share/git-bare/<repo>` | `$BARE_HOME` |
| Worktrees | `~/Work/<repo>` | `$WORKTREES_HOME` |

### Sintaxis

```bash
git-bare-clone [-h] [-v] [-w <path>] <repository>
```

### Opciones

| Opción | Descripción |
|--------|------------|
| `-h, --help` | Muestra la ayuda |
| `-v, --verbose` | Activa modo debug |
| `-w, --worktrees-dir` | Cambia el directorio base de worktrees |

### Pasos que Realiza

1. ✅ Clona el repositorio como bare
2. ✅ Configura el fetch refspec para traer todas las ramas remotas
3. ✅ Hace fetch de todas las referencias remotas
4. ✅ Crea el directorio de worktrees con archivo `.git` que apunta al bare
5. ✅ Crea un worktree para **cada rama remota** con upstream tracking

### Ejemplos

#### Ejemplo 1: Clonar un repositorio público

```bash
git-bare-clone https://github.com/user/myrepo.git
```

**Resultado:**
- Bare repo en: `~/.local/share/git-bare/myrepo/`
- Worktrees en: `~/Work/myrepo/main/`, `~/Work/myrepo/develop/`, etc.
- Cada worktree seguimiento upstream a `origin/<branch>`

#### Ejemplo 2: Clonar con worktrees en ubicación personalizada

```bash
git-bare-clone -w ~/Projects https://github.com/user/myrepo.git
```

**Resultado:**
- Bare repo en: `~/.local/share/git-bare/myrepo/`
- Worktrees en: `~/Projects/myrepo/main/`, `~/Projects/myrepo/develop/`, etc.

#### Ejemplo 3: Cambiar ubicación de bare y worktrees

```bash
# Definir variables de entorno
export BARE_HOME=~/.cache/git-bare
export WORKTREES_HOME=~/Code

git-bare-clone https://github.com/user/myrepo.git
```

**Resultado:**
- Bare repo en: `~/.cache/git-bare/myrepo/`
- Worktrees en: `~/Code/myrepo/main/`, `~/Code/myrepo/develop/`, etc.

#### Ejemplo 4: Clonar repositorio privado con SSH

```bash
git-bare-clone git@github.com:user/private-repo.git
```

Funciona exactamente igual, requiere que tengas SSH key configurada.

### Flujo de Trabajo Después

```bash
# Ver las ramas disponibles
ls ~/Work/myrepo/

# Entrar a una rama
cd ~/Work/myrepo/main
git status
git log

# Trabajar en otra rama
cd ~/Work/myrepo/develop
git status

# Ambas ramas están sincronizadas con el repositorio bare
```

---

## 🔧 Script 2: `git-create-worktree`

### Propósito

Crea un **nuevo worktree** para una rama específica, con setup de upstream tracking automático.

**⚠️ Nota:** Este script se ejecuta **dentro** de un repositorio bare creado con `git-bare-clone`.

### Sintaxis

```bash
git-create-worktree [-h] [-v] [-r <repo>] [-b <branch>] [-B <base>] [-p <prefix>] [-N] <path>
```

### Opciones

| Opción | Descripción | Por Defecto |
|--------|------------|------------|
| `-h, --help` | Muestra la ayuda | - |
| `-v, --verbose` | Modo debug | - |
| `-r, --repo` | **Ruta del repositorio** (no necesitas estar dentro) | Directorio actual |
| `-b, --branch` | Nombre de rama a crear/usar | `<prefix><path>` |
| `-B, --base` | Rama base para nuevo worktree | `origin/main` |
| `-p, --prefix` | Prefijo para el nombre de rama | `git.user@github` |
| `-N, --no-create-upstream` | Salta la creación de upstream | - |

### Pasos que Realiza

1. ✅ Navega al repositorio especificado (si se proporciona `-r`)
2. ✅ Valida que sea un repositorio Git válido
3. ✅ Crea o adjunta un worktree a una rama existente
4. ✅ Si la rama no existe, la crea desde la rama base
5. ✅ Configura upstream tracking automáticamente
6. ✅ Si la rama no existe en remoto, la pushea

### Usar `-r` para Especificar Repositorio

La opción `-r/--repo` permite usar `git-create-worktree` desde **cualquier directorio** sin necesidad de tener el script en el PATH.

#### Situación: Script No Está en PATH

Antes (necesitabas estar en el directorio):
```bash
cd ~/Work/myrepo
/home/hydenix/Dropbox/ludus/Dotfiles2/dev/bin/git-create-worktree -b "fix/1-base" "1-base"
```

Ahora (puedes estar en cualquier lugar):
```bash
# Desde cualquier directorio
/home/hydenix/Dropbox/ludus/Dotfiles2/dev/bin/git-create-worktree \
  -r ~/Work/myrepo \
  -b "fix/1-base" \
  "1-base"
```

#### Creando un Alias Portátil

Crea un alias en tu `~/.bashrc` o `~/.zshrc`:

```bash
alias gcw="/home/hydenix/Dropbox/ludus/Dotfiles2/dev/bin/git-create-worktree"
```

Luego puedes usarlo desde cualquier lugar:
```bash
# Desde tu home
gcw -r ~/Work/myrepo -b "feature/xyz" "xyz"

# Desde otro proyecto
gcw -r ~/Code/other-project -b "fix/42" "42-fix"

# O desde dentro del repositorio (como siempre)
cd ~/Work/myrepo
gcw -b "feature/xyz" "xyz"
```

#### Patrones de Uso Recomendados

**Patrón 1: Script en PATH (recomendado)**
```bash
# Agregar a ~/.bashrc o ~/.zshrc
export PATH="/home/hydenix/Dropbox/ludus/Dotfiles2/dev/bin:$PATH"

# Uso desde cualquier lugar
cd ~/Work/myrepo
git-create-worktree -b "fix/1-base" "1-base"
```

**Patrón 2: Alias + Opción `-r`**
```bash
# Agregar a ~/.bashrc o ~/.zshrc
alias gcw="/home/hydenix/Dropbox/ludus/Dotfiles2/dev/bin/git-create-worktree"

# Uso desde cualquier lugar
gcw -r ~/Work/myrepo -b "fix/1-base" "1-base"
```

**Patrón 3: Función personalizada con `-r` integrado**
```bash
# Agregar a ~/.bashrc o ~/.zshrc
gcw-cd() {
    local repo_dir="${1:-.}"  # Por defecto el directorio actual
    local branch="${2:-}"
    local worktree="${3:-}"
    
    if [[ -z "$branch" || -z "$worktree" ]]; then
        echo "Usage: gcw-cd <repo-dir> <branch> <worktree-path>"
        return 1
    fi
    
    /home/hydenix/Dropbox/ludus/Dotfiles2/dev/bin/git-create-worktree \
        -r "$repo_dir" \
        -b "$branch" \
        "$worktree"
}

# Uso
gcw-cd ~/Work/myrepo "fix/1-base" "1-base"
```

### Ejemplos

#### Ejemplo 1: Crear worktree simple (desde dentro del repo)

```bash
cd ~/Work/myrepo
git-create-worktree feature/user-auth
```

**Resultado:**
- Crea directorio: `~/Work/myrepo/feature/user-auth/`
- Crea rama: `<github-user>/feature/user-auth` desde `origin/main`
- Configura upstream tracking automáticamente
- Push a `origin/<github-user>/feature/user-auth`

#### Ejemplo 2: Usar `-r` desde cualquier directorio

```bash
# Desde tu home (o cualquier lugar)
/home/hydenix/Dropbox/ludus/Dotfiles2/dev/bin/git-create-worktree \
  -r ~/Work/myrepo \
  -b "fix/issue-1" \
  "1-fix"
```

**Resultado:**
- Navega a `~/Work/myrepo`
- Crea directorio: `~/Work/myrepo/1-fix/`
- Crea rama: `fix/issue-1`
- Configura upstream: `origin/fix/issue-1`

**O con alias:**
```bash
gcw -r ~/Work/myrepo -b "fix/issue-1" "1-fix"
```

#### Ejemplo 3: Especificar rama base diferente (con `-r`)

```bash
# Crear desde rama develop usando -r
/home/hydenix/Dropbox/ludus/Dotfiles2/dev/bin/git-create-worktree \
  -r ~/Work/myrepo \
  -B develop \
  -b "hotfix/critical-bug" \
  "fix-critical"

# O con alias
gcw -r ~/Work/myrepo -B develop -b "hotfix/critical-bug" "fix-critical"
```

**Resultado:**
- Navega a `~/Work/myrepo`
- Crea directorio: `~/Work/myrepo/fix-critical/`
- Crea rama: `hotfix/critical-bug` desde `origin/develop`
- Configura upstream tracking a `origin/hotfix/critical-bug`

#### Ejemplo 4: Usar prefijo personalizado

```bash
cd ~/Work/myrepo
git-create-worktree -p "team/" -b refactor/api refactor-api
```

**Resultado:**
- Crea directorio: `~/Work/myrepo/refactor-api/`
- Crea rama: `team/refactor/api`
- Push a `origin/team/refactor/api`

#### Ejemplo 5: Adjuntar a rama existente

Si la rama ya existe en remoto:

```bash
cd ~/Work/myrepo
git-create-worktree -b feature/existing-work existing
```

**Resultado:**
- Crea directorio: `~/Work/myrepo/existing/`
- Adjunta al worktree existente de `feature/existing-work`
- Configura upstream tracking a `origin/feature/existing-work`

#### Ejemplo 6: Sin upstream tracking (con `-r`)

```bash
/home/hydenix/Dropbox/ludus/Dotfiles2/dev/bin/git-create-worktree \
  -r ~/Work/myrepo \
  -N \
  -b "experimental/idea" \
  "experiment"
```

**Resultado:**
- Navega a `~/Work/myrepo`
- Crea directorio: `~/Work/myrepo/experiment/`
- Crea rama `experimental/idea` pero **no** la pushea ni configura upstream
- Útil para cambios experimentales locales

#### Ejemplo 7: Combinación completa con todas las opciones

```bash
# Desde cualquier lugar, crear feature desde develop con prefijo personalizado
/home/hydenix/Dropbox/ludus/Dotfiles2/dev/bin/git-create-worktree \
  -r ~/Work/myrepo \
  -B develop \
  -p "hydenix/" \
  -b "feature/new-dashboard" \
  "new-dashboard"
```

**Resultado:**
- Navega a `~/Work/myrepo`
- Crea rama: `hydenix/feature/new-dashboard` (con prefijo)
- Base: `origin/develop`
- Directorio: `~/Work/myrepo/new-dashboard/`
- Upstream: `origin/hydenix/feature/new-dashboard`

---

## 🎯 Flujo de Trabajo Completo

### Paso 1: Clonar un Repositorio

```bash
git-bare-clone https://github.com/myorg/myapp.git
```

Te crea automáticamente worktrees para todas las ramas (main, develop, staging, etc.)

### Paso 2: Trabajar en Main

```bash
cd ~/Work/myapp/main
git pull
npm install
npm start
```

### Paso 3: Crear Nueva Feature

Sin salir de main, en otra terminal:

```bash
cd ~/Work/myapp
git-create-worktree -B main -b feature/new-login login-page
```

Ahora tienes:
- `~/Work/myapp/main/` - trabajando aquí
- `~/Work/myapp/login-page/` - trabajando aquí simultáneamente

### Paso 4: Trabajar en Feature

```bash
cd ~/Work/myapp/login-page
git status                    # Ves solo cambios de esta rama
npm start                     # Tu app corre en la nueva rama
# Haz tus cambios
git add .
git commit -m "Add login form"
# Automáticamente pusheado a origin/feature/new-login
```

### Paso 5: Crear Segunda Feature desde Develop

```bash
cd ~/Work/myapp
git-create-worktree -B develop -b feature/notifications notif
```

Ahora tienes 3 worktrees activos:
- `~/Work/myapp/main/` 
- `~/Work/myapp/login-page/`
- `~/Work/myapp/notif/`

Cada uno es independiente, con sus propias dependencias, node_modules, etc.

### Paso 6: Sincronizar Cambios

Todos los worktrees usan el mismo repositorio bare, así que:

```bash
# En main
git fetch          # Trae cambios remotos
git merge origin/feature/new-login

# En notif
git fetch          # Mismo repositorio bare, ves los cambios
git log --oneline  # Ya puedes ver los cambios de login
```

---

## 📋 Comparación: Bare + Worktrees vs Clones Múltiples

### Enfoque Antiguo (Clones Múltiples)

```bash
# Clonas 3 veces - cada clon es independiente
git clone https://github.com/org/repo.git repo-main
git clone https://github.com/org/repo.git repo-feature
git clone https://github.com/org/repo.git repo-develop

# Espacio: ~300MB cada uno = 900MB total
# Cambios de rama: `cd repo-feature && git pull`
# Estás forzado a cambiar de directorio
```

**Problemas:**
- ❌ Mucho espacio duplicado
- ❌ Múltiples copias del historial
- ❌ Necesitas cambiar de directorio
- ❌ Complejo sincronizar cambios

### Nuevo Enfoque (Bare + Worktrees)

```bash
# Un solo bare + múltiples worktrees
git-bare-clone https://github.com/org/repo.git

# Espacio: ~50MB bare + ~50MB cada worktree = 200MB total
# Cambios: no necesitas cambiar rama, solo cambias de directorio
# Ya estás ahí en otra rama diferente
```

**Ventajas:**
- ✅ Menos espacio
- ✅ Un solo historio Git compartido
- ✅ Múltiples ramas activas simultáneamente
- ✅ Sincronización automática

---

## 🎫 Workflow con Issues de GitHub

### Crear un Worktree Basado en un Issue

Un patrón muy común es crear un worktree **directamente desde un issue de GitHub**. El nombre de la rama incluye el número del issue y su descripción.

#### Paso 1: Acceder al Directorio de Worktrees

```bash
# Primero, asegúrate de que el repositorio está clonado con git-bare-clone
cd ~/Work/minimal-installation  # o tu repositorio
```

#### Paso 2: Extraer Información del Issue

Digamos que tienes un issue en GitHub:
- **URL:** `https://github.com/ravn-ruby-path/minimal-installation/issues/1`
- **Título:** `Setup CI/CD Pipeline`
- **Número:** `1`

#### Paso 3: Crear el Worktree para el Issue

**Basado en `main` (por defecto):**
```bash
# Opción 1: Nombre descriptivo simple
git-create-worktree -b "fix/issue-1-setup-cicd" "issue-1"

# Opción 2: Nombre con prefijo personalizado
git-create-worktree -b "ravn/issue-1-setup-cicd" "issue-1"

# Opción 3: Especificar main explícitamente
git-create-worktree -B main -b "issue/1-setup-cicd" "1-setup-cicd"
```

**Basado en `dev` o `develop`:**
```bash
# Crear desde rama dev
git-create-worktree -B dev -b "fix/issue-1-setup-cicd" "issue-1"

# Crear desde rama develop
git-create-worktree -B develop -b "fix/issue-1-setup-cicd" "issue-1"

# Con prefijo personalizado
git-create-worktree -B dev -b "ravn/issue-1-setup-cicd" "issue-1"
```

#### Paso 4: Trabajar en el Worktree

```bash
cd ~/Work/minimal-installation/issue-1
git log --oneline
git status

# Tu rama automáticamente tiene upstream tracking:
git branch -vv
# Output:
# issue/1-setup-cicd  abc1234 [origin/issue/1-setup-cicd] Setup CI/CD Pipeline
```

#### Paso 5: Hacer Push y Crear Pull Request

```bash
# Ya está pusheado! Solo crea el PR en GitHub
# Link: https://github.com/ravn-ruby-path/minimal-installation/pull/new/issue/1-setup-cicd

# O desde la CLI (si tienes gh):
gh pr create --title "Setup CI/CD Pipeline" --body "Fixes #1"
```

### Ejemplos Prácticos por Tipo de Issue

#### Bug Fix (basado en main)

```bash
# Issue: #42 - Fix login redirect after logout
cd ~/Work/myrepo
git-create-worktree -b "fix/42-login-redirect" "42-login"
```

Resultado:
- Rama: `fix/42-login-redirect` (basada en `origin/main`)
- Directorio: `~/Work/myrepo/42-login/`
- Upstream: `origin/fix/42-login-redirect`

#### Bug Fix (basado en dev)

```bash
# Issue: #42 - Fix login redirect after logout
cd ~/Work/myrepo
git-create-worktree -B dev -b "fix/42-login-redirect" "42-login"
```

Resultado:
- Rama: `fix/42-login-redirect` (basada en `origin/dev`)
- Directorio: `~/Work/myrepo/42-login/`
- Upstream: `origin/fix/42-login-redirect`

#### Feature (basado en develop)

```bash
# Issue: #127 - Add dark mode support
cd ~/Work/myrepo
git-create-worktree -B develop -b "feature/127-dark-mode" "127-dark-mode"
```

Resultado:
- Rama basada en: `origin/develop`
- Directorio: `~/Work/myrepo/127-dark-mode/`
- Rama: `feature/127-dark-mode`

#### Feature (basado en dev)

```bash
# Issue: #127 - Add dark mode support
cd ~/Work/myrepo
git-create-worktree -B dev -b "feature/127-dark-mode" "127-dark-mode"
```

Resultado:
- Rama basada en: `origin/dev`
- Directorio: `~/Work/myrepo/127-dark-mode/`
- Rama: `feature/127-dark-mode`

#### Chore/Refactor (basado en dev)

```bash
# Issue: #89 - Refactor authentication module
cd ~/Work/myrepo
git-create-worktree -B dev -b "refactor/89-auth-module" "89-auth"
```

#### Documentación (basado en dev)

```bash
# Issue: #15 - Update API documentation
cd ~/Work/myrepo
git-create-worktree -B dev -b "docs/15-api-docs" "15-api"
```

### Patrón Recomendado: Nomenclatura Consistente

Usa este patrón para todos tus issues:

**Basado en main (por defecto):**
```bash
git-create-worktree -b "<type>/<issue-number>-<slug>" "<issue-number>-<slug>"
```

**Basado en dev/develop:**
```bash
git-create-worktree -B dev -b "<type>/<issue-number>-<slug>" "<issue-number>-<slug>"
git-create-worktree -B develop -b "<type>/<issue-number>-<slug>" "<issue-number>-<slug>"
```

Donde:
- `<type>` = `fix`, `feature`, `refactor`, `docs`, `chore`
- `<issue-number>` = número del issue (ej: `42`)
- `<slug>` = descripción corta con hyphens (ej: `login-redirect`)

**Ejemplos (basado en main):**
```bash
git-create-worktree -b "fix/42-login-redirect" "42-login"
git-create-worktree -b "feature/127-dark-mode" "127-dark"
git-create-worktree -b "refactor/89-auth" "89-auth"
git-create-worktree -b "docs/15-api" "15-docs"
```

**Ejemplos (basado en dev):**
```bash
git-create-worktree -B dev -b "fix/42-login-redirect" "42-login"
git-create-worktree -B dev -b "feature/127-dark-mode" "127-dark"
git-create-worktree -B dev -b "refactor/89-auth" "89-auth"
git-create-worktree -B dev -b "docs/15-api" "15-docs"
```

### Automatizar con Alias

Crea un alias que genere automáticamente el nombre:

```bash
# En ~/.zshrc o ~/.bashrc

# Uso: issue-worktree <issue-number> <slug> [type]
issue-worktree() {
    local issue_num=$1
    local slug=$2
    local type=${3:-fix}  # Por defecto "fix"
    
    if [[ -z "$issue_num" || -z "$slug" ]]; then
        echo "Usage: issue-worktree <number> <slug> [type]"
        echo "Example: issue-worktree 42 login-redirect fix"
        return 1
    fi
    
    git-create-worktree -b "$type/$issue_num-$slug" "$issue_num-$slug"
}
```

Uso:
```bash
cd ~/Work/myrepo
issue-worktree 42 login-redirect fix      # Crea fix/42-login-redirect
issue-worktree 127 dark-mode feature      # Crea feature/127-dark-mode
issue-worktree 89 auth-module refactor    # Crea refactor/89-auth-module
```

---

## � Script 3: `git-issue-worktree`

### Propósito

Vincula automáticamente un issue de GitHub a un nuevo worktree. Combina la funcionalidad de `git-create-worktree` con la obtención de datos del issue, proporcionando contexto y siguientes pasos.

**⚠️ Requisitos:**
- `git-create-worktree` instalado
- GitHub CLI (`gh`) instalado y autenticado
- `jq` instalado (para parsear JSON)

### Sintaxis

```bash
git-issue-worktree [-h] [-v] [-r <repo>] [-B <base>] [-p <prefix>] <issue> <slug>
```

### Opciones

| Opción | Descripción | Por Defecto |
|--------|------------|------------|
| `-h, --help` | Muestra la ayuda | - |
| `-v, --verbose` | Modo debug | - |
| `-r, --repo` | **Ruta de un worktree válido** (ver advertencia) | Directorio actual |
| `-B, --base` | Rama base para nuevo worktree | `origin/main` |
| `-p, --prefix` | Prefijo para el nombre de rama | `git.user@github` |

### ⚠️ Advertencia Crítica: Opción `-r`

**IMPORTANTE:** La opción `-r` en `git-issue-worktree` es **diferente a `git-create-worktree`**:

#### ❌ INCORRECTO (Bare Repository)
```bash
# NO HAGAS ESTO - El bare repo no es un worktree válido
git-issue-worktree -r ~/.local/share/git-bare/fake 1 rfc
# Error: "this operation must be run in a work tree"
```

El bare repository (`~/.local/share/git-bare/<repo>`) no contiene un `.git` válido para trabajar.

#### ✅ CORRECTO (Worktree Válido)
```bash
# SI HAGAS ESTO - Apunta a un worktree existente
git-issue-worktree -r ~/Work/fake/dev 1 rfc
# Funciona correctamente
```

Debes apuntar a un **worktree existente** que contenga:
- Una rama base (como `dev`, `main`, etc.)
- Un `.git` válido para operaciones

#### 📋 Cómo Identificar la Ruta Correcta

**Estructura típica:**
```
~/.local/share/git-bare/repo/          ← Bare repository (NO usar con -r)
~/Work/repo/                           ← Grupo de worktrees
├── dev/                               ← Worktree valido (USAR CON -r)
├── main/                              ← Worktree valido (USAR CON -r)
└── feature-x/                         ← Worktree valido (USAR CON -r)
```

**Validación:**
```bash
# Para verificar si es un worktree válido:
ls ~/Work/repo/dev/.git && echo "✅ Válido" || echo "❌ Inválido"

# Para verificar si es bare repo:
git -C ~/.local/share/git-bare/repo rev-parse --is-bare-repository
# Resultado: true = No usar con -r
```

#### 🔄 Flujo Correcto

```bash
# Paso 1: Clonar el repo con git-bare-clone (crea bare repo + worktrees)
git-bare-clone https://github.com/user/repo.git

# Resultado:
# ~/.local/share/git-bare/repo/    ← Bare repo
# ~/Work/repo/dev/                 ← Worktree valido
# ~/Work/repo/main/                ← Worktree valido

# Paso 2: Usar git-issue-worktree con un worktree existente
git-issue-worktree -r ~/Work/repo/dev 1 rfc
#                          ↑ Worktree existente ✅

# Paso 3: Resultado de la ejecución
# Se crea el nuevo worktree al MISMO NIVEL que dev:
# ~/Work/repo/
# ├── dev/         ← Worktree base
# ├── 1-rfc/       ← Nuevo worktree creado (mismo nivel) ✅
# └── main/
```

#### ⚙️ Cómo Funciona Internamente

Cuando ejecutas `git-issue-worktree -r ~/Work/repo/dev 1 rfc`:

1. **Valida** que `~/Work/repo/dev` es un worktree válido
2. **Detecta** que estás en un worktree (no bare repo)
3. **Encuentra** el directorio padre: `~/Work/repo/`
4. **Navega** a `~/Work/repo/` (donde viven todos los worktrees)
5. **Crea** el nuevo worktree `1-rfc` en ese directorio

Es por eso que el nuevo worktree aparece al mismo nivel que `dev/`, no anidado dentro.


### ¿Qué hace internamente?

1. ✅ Valida dependencias (GitHub CLI, Git, jq, git-create-worktree)
2. ✅ Obtiene información del issue desde GitHub
3. ✅ Crea un nuevo worktree y rama vinculada al issue (todo automático)
4. ✅ Muestra contexto del issue, ubicación del worktree y siguientes pasos

### Ejemplos

git-issue-worktree 1 base-snapshot

#### Ejemplo 1: Crear worktree para issue #1

```bash
# Desde cualquier lugar (dentro o fuera del repo)
git-issue-worktree -r ~/Work/fake/dev 1 base-snapshot
```

**Resultado esperado:**
```
╭──────────────────────────────────────────────╮
│   git-issue-worktree                        │
╰──────────────────────────────────────────────╯

  [1/4] Checking dependencies
  [2/4] Fetching issue #1 from GitHub
  [3/4] Creating worktree
  Branch: hydenix/issue/1-base-snapshot
  Worktree: /home/hydenix/Work/fake/1-base-snapshot
  [4/4] Next Steps

✅ Issue #1 → RFC - Base Snapshot as Foundation
📁 /home/hydenix/Work/fake/1-base-snapshot
🔗 hydenix/issue/1-base-snapshot → origin/hydenix/issue/1-base-snapshot

📝 To start working:
  cd /home/hydenix/Work/fake/1-base-snapshot
  # Make your changes
  git add .
  git commit -m 'Descripción'

🔗 To create a Pull Request:
  gh pr create --title "RFC - Base Snapshot as Foundation" --body "Closes #1"
```

git-issue-worktree -r ~/Work/fake/dev 42 login-fix

#### Ejemplo 2: Crear worktree para otro issue (usando -r)

```bash
git-issue-worktree -r ~/Work/fake/dev 42 login-fix
#                         ↑ Worktree válido
```

**Resultado esperado:**
```
╭──────────────────────────────────────────────╮
│   git-issue-worktree                        │
╰──────────────────────────────────────────────╯

  [1/4] Checking dependencies
  [2/4] Fetching issue #42 from GitHub
  [3/4] Creating worktree
  Branch: hydenix/issue/42-login-fix
  Worktree: /home/hydenix/Work/fake/42-login-fix
  [4/4] Next Steps

✅ Issue #42 → [TÍTULO DEL ISSUE]
📁 /home/hydenix/Work/fake/42-login-fix
🔗 hydenix/issue/42-login-fix → origin/hydenix/issue/42-login-fix

📝 To start working:
  cd /home/hydenix/Work/fake/42-login-fix
  # Make your changes
  git add .
  git commit -m 'Descripción'

🔗 To create a Pull Request:
  gh pr create --title "[TÍTULO DEL ISSUE]" --body "Closes #42"
```

git-issue-worktree -r ~/Work/fake/dev -B develop 127 dark-mode

#### Ejemplo 3: Usando rama base diferente

```bash
git-issue-worktree -r ~/Work/fake/dev -B develop 127 dark-mode
#                         ↑ Worktree válido
```

**Resultado esperado:**
```
╭──────────────────────────────────────────────╮
│   git-issue-worktree                        │
╰──────────────────────────────────────────────╯

  [1/4] Checking dependencies
  [2/4] Fetching issue #127 from GitHub
  [3/4] Creating worktree
   Branch: hydenix/issue/127-dark-mode
   Worktree: /home/hydenix/Work/fake/127-dark-mode
  [4/4] Next Steps

✅ Issue #127 → [TÍTULO DEL ISSUE]
📁 /home/hydenix/Work/fake/127-dark-mode
🔗 hydenix/issue/127-dark-mode → origin/hydenix/issue/127-dark-mode
```

git-issue-worktree -p "team/" 89 refactor

#### Ejemplo 4: Usando prefijo personalizado

```bash
git-issue-worktree -p "team/" 89 refactor
```

**Resultado esperado:**
```
╭──────────────────────────────────────────────╮
│   git-issue-worktree                        │
╰──────────────────────────────────────────────╯

  [1/4] Checking dependencies
  [2/4] Fetching issue #89 from GitHub
  [3/4] Creating worktree
   Branch: team/issue/89-refactor
   Worktree: /home/hydenix/Work/fake/89-refactor
  [4/4] Next Steps

✅ Issue #89 → [TÍTULO DEL ISSUE]
📁 /home/hydenix/Work/fake/89-refactor
🔗 team/issue/89-refactor → origin/team/issue/89-refactor
```

### Comparación: 3 Formas de Crear Worktrees

#### Forma 1: Worktree Manual (Solo Git)

```bash
cd ~/Work/fake
git-create-worktree -B dev -b "rfc/1-base" "1-base"
```

Resultado:
- ✅ Control total
- ❌ No vinculado a issue
- ❌ Sin contexto

#### Forma 2: Worktree + Issue Información (Semi-automatizado)

```bash
git-issue-worktree -r ~/Work/fake 1 base
```

Resultado:
- ✅ Información del issue automática
- ✅ Instrucciones claras
- ✅ Todo en un comando
- ❌ Requiere GitHub CLI

#### Forma 3: Función Personalizada (Workflow Avanzado)

```bash
# Agregar a ~/.bashrc o ~/.zshrc
issue-worktree() {
    local repo="$1" issue="$2" slug="$3"
    git-issue-worktree -r "$repo" "$issue" "$slug" && \
    cd "$repo/$issue-$slug"
}

# Uso
issue-worktree ~/Work/fake 1 base
# Te deja dentro del worktree automáticamente
```

---

## 🔧 Cambios Realizados (v2.0 - 19 Marzo 2026)

### Problemas Corregidos

#### 1. Worktrees Anidados ❌→✅
**Problema:** Cuando usabas `git-issue-worktree -r ~/Work/repo/dev`, los worktrees se creaban **dentro** de `dev/` en lugar de al mismo nivel.

**Causa:** `git-create-worktree` usaba rutas relativas y no navegaba al directorio correcto.

**Solución Implementada:**
- Agregó lógica para detectar si estamos en un worktree o bare repo
- Navega al directorio padre automáticamente
- Usa rutas absolutas para `git worktree add`

**Resultado:**
```bash
# Antes (❌ Incorrecto):
~/Work/repo/dev/1-fix/      ← Anidado dentro de dev

# Ahora (✅ Correcto):
~/Work/repo/1-fix/          ← Mismo nivel que dev/
~/Work/repo/dev/
```

#### 2. Rutas Relativas en Output ❌→✅
**Problema:** Output mostraba rutas incompletas como "1-fix" en lugar de absolutas.

**Solución:** Calcula automáticamente `repo_parent` y construye rutas completas.

**Resultado:**
```
Worktree created at /home/hydenix/Work/repo/1-fix  ✅
cd /home/hydenix/Work/repo/1-fix  ✅
```

#### 3. Ramas que ya Existen en Remoto ❌→✅
**Problema:** No estaba claro qué pasaba si intentabas crear worktree para rama que ya existe.

**Comportamiento Actual:**
- **Primera vez:** "Remote branch not found — pushing to origin"
- **Siguientes veces:** "Remote branch exists — setting upstream" (sin push)

```bash
# Primer intento:
git-issue-worktree -r ~/Work/repo/dev -B dev 1 fix
# Resultado: Pushea y crea PR draft

# Segundo intento (misma rama):
git-issue-worktree -r ~/Work/repo/dev -B dev 1 rfc
# Resultado: Solo configura upstream (no hace push duplicado)
```

### Archivos Modificados

- ✅ `git-create-worktree`: Detección de worktree, navegación a padre, rutas absolutas
- ✅ `git-issue-worktree`: Cálculo correcto de rutas, output mejorado
- ✅ `README.md`: Documentación detallada de flujo interno y estructura

---

## 🎯 Matriz de Decisión: ¿Cuándo Usar Cada Script?

### Decisión Rápida (Diagrama de Flujo)

```
¿Tienes un issue de GitHub? 
    ├─ SI  → ¿Necesitas contexto del issue?
    │         ├─ SI  → git-issue-worktree ✨
    │         └─ NO  → git-create-worktree
    └─ NO  → ¿Es trabajo ad-hoc sin issue?
              ├─ SI  → git-create-worktree
              └─ NO  → git-create-worktree
```

### Tabla Comparativa Completa

| Criterio | `git-create-worktree` | `git-issue-worktree` |
|----------|----------------------|----------------------|
| **Cuándo usar** | Trabajo sin issue, rama ad-hoc | Trabajo vinculado a issue GitHub |
| **Requiere issue** | ❌ No | ✅ Sí (número) |
| **GitHub CLI necesario** | ❌ No | ✅ Sí |
| **Complejidad** | ⭐ Baja | ⭐⭐ Media |
| **Configuración** | `-B, -b, -p, -r` | `-B, -p, -r` + issue |
| **Datos obtenidos** | Solo rama base | Issue: título, estado |
| **Contexto mostrado** | Rama y directorio | Rama + Issue + instrucciones |
| **Casos de uso** | WIP, experimentos, refactoring rápido | Tareas desde issue tracker |
| **Rastreo** | Manual | Automático (issue #N) |
| **Documentación** | Manual en commit | Automática via issue |
| **Tiempo setup** | ~5 segundos | ~10 segundos |

### Matriz de Decisión por Situación

| Situación | Recomendación | Comando |
|-----------|---------------|---------|
| **Trabajar en issue #42** | `git-issue-worktree` | `giw -r ~/Work/repo 42 slug` |
| **Feature sin issue** | `git-create-worktree` | `gcw -b feature/xyz xyz` |
| **Bugfix rápido** | `git-create-worktree` | `gcw -b fix/123 123` |
| **Refactoring** | `git-create-worktree` | `gcw -b refactor/abc abc` |
| **Experimentar** | `git-create-worktree` | `gcw -b experiment/test test` |
| **PR desde issue** | `git-issue-worktree` | `giw -r ~/repo 1 base` |
| **Chore/maintenance** | `git-create-worktree` | `gcw -b chore/deps deps` |
| **RFC con discussion** | `git-issue-worktree` | `giw -r ~/repo 1 snapshot` |

### Guía de Selección Detallada

#### Usar `git-create-worktree` Si:

```
✅ No tienes un issue de GitHub para este trabajo
✅ Es trabajo ad-hoc o experimental
✅ Quieres máximo control sobre la rama
✅ No necesitas contexto de issue
✅ Prefieres nombres de rama personalizados
✅ Es refactoring/chore sin tracking formal
✅ No tienes GitHub CLI instalado
```

**Ejemplos:**
- `gcw -b feature/dark-mode dark` → Feature sin issue
- `gcw -b fix/typo-readme typo` → Bugfix rápido  
- `gcw -b refactor/db-layer db` → Refactoring
- `gcw -b experiment/ai-test ai` → Experimentación

#### Usar `git-issue-worktree` Si:

```
✅ Tienes un issue de GitHub para este trabajo
✅ Quieres rastrabilidad automática
✅ Necesitas contexto del issue al trabajar
✅ Quieres instrucciones claras para PR
✅ Usas issue tracking formalmente
✅ Tienes GitHub CLI instalado y configurado
✅ Quieres workflow más estructurado
```

**Ejemplos:**
- `giw -r ~/repo 42 login` → Issue #42: implementar login
- `giw -r ~/repo 127 dark-mode` → Issue #127: dark mode
- `giw -r ~/repo 1 snapshot` → Issue #1: RFC snapshot
- `giw -r ~/repo 89 refactor` → Issue #89: refactoring

### Escenarios de Decisión

#### Escenario 1: Cliente Reporta Bug (Issue #314)

```
Decisión: ¿Usar git-issue-worktree o git-create-worktree?

Análisis:
  ✅ Hay issue de GitHub (#314)
  ✅ Necesito contexto del problema
  ✅ Voy a hacer PR que cierra el issue
  ✅ Quiero que sea rastreable

RECOMENDACIÓN: git-issue-worktree
  
Comando:
  $ giw -r ~/Work/repo 314 fix
  
Resultado:
  - Worktree: ~/Work/repo/314-fix
  - Rama: hydenix/issue/314-fix
  - Contexto: Título y descripción del issue
  - Instrucciones claras para PR
```

#### Escenario 2: Refactoring Proactivo (Sin Issue)

```
Decisión: ¿Usar git-issue-worktree o git-create-worktree?

Análisis:
  ❌ No hay issue (es proactivo)
  ❌ No necesito contexto de tracking
  ✅ Quiero control total de la rama
  ✅ Voy a decidir el nombre

RECOMENDACIÓN: git-create-worktree
  
Comando:
  $ gcw -b refactor/db-layer db-refactor
  
Resultado:
  - Worktree: ~/Work/repo/db-refactor
  - Rama: hydenix/refactor/db-layer
  - Nombre personalizado
  - Control total
```

#### Escenario 3: RFC con Discussion en Issue #1

```
Decisión: ¿Usar git-issue-worktree o git-create-worktree?

Análisis:
  ✅ Hay issue (#1) con RFC discussion
  ✅ Necesito ver lo que se propone
  ✅ Voy a documentar la implementación
  ✅ PR debe cerrar el issue

RECOMENDACIÓN: git-issue-worktree
  
Comando:
  $ giw -r ~/Work/repo 1 implementation
  
Resultado:
  - Worktree: ~/Work/repo/1-implementation
  - Rama: hydenix/issue/1-implementation
  - Ver RFC en GitHub
  - Instrucciones para PR
```

#### Escenario 4: Experimentación Local

```
Decisión: ¿Usar git-issue-worktree o git-create-worktree?

Análisis:
  ❌ No hay issue (es experimental)
  ❌ No necesito rastrabilidad GitHub
  ✅ Quiero probar algo rápido
  ✅ Podría no convertirse en PR

RECOMENDACIÓN: git-create-worktree
  
Comando:
  $ gcw -b experiment/new-approach newexp
  
Resultado:
  - Worktree: ~/Work/repo/newexp
  - Rama: hydenix/experiment/new-approach
  - Sin contexto de issue
  - Libertad total para experimentar
```

### Checklist de Decisión

Antes de crear un worktree, responde:

```
□ ¿Hay un issue de GitHub para esto?
  └─ SI  → ¿Tienes GitHub CLI instalado?
           └─ SI  → Usa git-issue-worktree ✨
           └─ NO  → Usa git-create-worktree

□ ¿Necesitas rastrabilidad automática?
  └─ SI  → Usa git-issue-worktree ✨
  └─ NO  → Usa git-create-worktree

□ ¿Quieres ver contexto del issue?
  └─ SI  → Usa git-issue-worktree ✨
  └─ NO  → Usa git-create-worktree

□ ¿Es trabajo formal/trackeado?
  └─ SI  → Usa git-issue-worktree ✨
  └─ NO  → Usa git-create-worktree

□ ¿Es experimentación/WIP?
  └─ SI  → Usa git-create-worktree
  └─ NO  → Depende de arriba ↑
```

### Combinación de Ambos (Workflow Avanzado)

En proyectos complejos, puedes usar AMBOS:

```bash
# Primero: crear issue en GitHub
# (Issue #42 se abre automáticamente)

# Luego: crear worktree vinculado al issue
git-issue-worktree 42 feature

# Trabajar y experimentar
cd ~/Work/repo/42-feature
# ... hacer cambios ...

# Si necesitas branch adicional experimental
git-create-worktree -b "exp/idea" "exp-idea"
cd ~/Work/repo/exp-idea
# ... experimentar ...

# Volver al worktree del issue
cd ~/Work/repo/42-feature
# Terminar el trabajo

# Crear PR (vinculado al issue automáticamente)
gh pr create --body "Closes #42"
```

---

## 💡 Tips y Trucos

### Tip 1: Alias de Bash

Agrega esto a tu `.bashrc` o `.zshrc`:

```bash
alias gcb='git-bare-clone'
alias gcw='git-create-worktree'
alias giw='git-issue-worktree'
alias cdwork='cd ~/Work'
```

Uso:
```bash
gcb https://github.com/user/repo.git
cd ~/Work/repo
giw 1 base-snapshot          # Crear y vincular a issue
gcw -b feature/xyz xyz       # Crear worktree manual
```
```bash
gcb https://github.com/user/repo.git
cd ~/Work/repo
gcw -b feature/xyz xyz
```

### Tip 2: Ver Todos tus Worktrees

```bash
cd ~/.local/share/git-bare/<repo>
git worktree list
```

Salida:
```
/home/user/Work/myrepo/main      abc1234 [origin/main]
/home/user/Work/myrepo/develop   def5678 [origin/develop]
/home/user/Work/myrepo/login     ghi9101 [origin/feature/new-login]
```

### Tip 3: Limpiar Worktree

```bash
# Si ya no necesitas el worktree
cd ~/Work/myrepo
git worktree remove login
rm -rf login
```

### Tip 4: Usar Prefijo Automático con GitHub User

El script usa `git config github.user` para el prefijo. Configúralo:

```bash
git config --global github.user "myusername"
```

Luego:
```bash
git-create-worktree feature/xyz xyz
# Crea rama: myusername/feature/xyz automáticamente
```

### Tip 5: Personalizar Variables de Entorno

```bash
# En ~/.bashrc o ~/.zshrc

export BARE_HOME="$HOME/.cache/git-bare"
export WORKTREES_HOME="$HOME/Code"

# O diferente por proyecto
alias work-myrepo='WORKTREES_HOME=$HOME/Projects/myrepo/trees git-bare-clone'
```

---

## ⚙️ Requisitos

- Bash 4.0+
- Git 2.15+
- Nerd Fonts (opcional, para los iconos)

---

## 🔗 Referencias Útiles

- [Git Worktrees Documentation](https://git-scm.com/docs/git-worktree)
- [Git Bare Repositories](https://git-scm.com/book/en/v2/Git-on-the-Server-Getting-Git-on-a-Server)
- [Workflow alternativo: git-worktrees](https://stackoverflow.com/questions/31651146/how-can-i-use-git-worktrees-to-manage-multiple-branches)

---

## 📝 Notas Importantes

1. **Primero** usa `git-bare-clone` para configurar el repositorio
2. **Luego** usa `git-create-worktree` para crear worktrees adicionales
3. **Opcionalmente** usa `git-issue-worktree` para vincular a issues de GitHub
4. Los worktrees comparten el mismo historio (el bare)
5. Los cambios en uno no afectan al otro hasta que hagas push/fetch
6. Cada worktree puede tener sus propias dependencias (node_modules, etc.)
7. Los conflictos se resuelven dentro del worktree como siempre

---

## 📋 Scripts en este Conjunto

| Script | Propósito | Requisitos |
|--------|-----------|-----------|
| `git-bare-clone` | Clona repositorio como bare + crea worktrees | `git` |
| `git-create-worktree` | Crea nuevo worktree con upstream tracking | `git`, `git-bare-clone` |
| `git-issue-worktree` | Vincula issue de GitHub a nuevo worktree | `git`, `gh`, `jq`, `git-create-worktree` |

---

**Creado por:** Mismo autor  
**Última actualización:** Marzo 2026  
**Compatibilidad:** Bash 4.0+, Git 2.15+, GitHub CLI (opcional)
