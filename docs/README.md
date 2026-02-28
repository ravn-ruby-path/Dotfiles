# HyDE site

Visit the [HyDE site](https://hydeproject.pages.dev/)

## 🚀 Project Structure

Inside of your Astro + Starlight project, you'll see the following folders and files:

```
.
├── public/
├── src/
│   ├── assets/
│   ├── content/
│   │   ├── docs/
│   │   └── config.ts
│   └── env.d.ts
├── astro.config.mjs
├── package.json
└── tsconfig.json
```

Starlight looks for `.md` or `.mdx` files in the `src/content/docs/` directory. Each file is exposed as a route based on its file name.

Images can be added to `src/assets/` and embedded in Markdown with a relative link.

Static assets, like favicons, can be placed in the `public/` directory.

## 🧞 Commands

All commands are run from the root of the project, from a terminal:

| Command                   | Action                                           |
| :------------------------ | :----------------------------------------------- |
| `npm install`             | Installs dependencies                            |
| `npm run dev`             | Starts local dev server at `localhost:4321`      |
| `npm run build`           | Build your production site to `./dist/`          |
| `npm run preview`         | Preview your build locally, before deploying     |
| `npm run astro ...`       | Run CLI commands like `astro add`, `astro check` |
| `npm run astro -- --help` | Get help using the Astro CLI                     |


## Translating

Starlight supports internationalization (i18n), allowing you to add new languages to this documentation. This guide will walk you through the process of setting up a new language.

### 1. Understanding the folder structure

As time of writing, our repository looks like this:

```txt
src/content/docs/
├── en/
│   ├── page1.mdx
│   ├── page2.mdx
├── es/
│   ├── page1.mdx
│   ├── page2.mdx
├── de/
│   ├── page1.mdx
│   ├── page2.mdx
├── nl/
│   ├── page1.mdx
│   ├── page2.mdx
# ... You see the picture
```

Language folders (e.g., `de`, `es`, `nl`, `zh`) contain translations of our documentation.

### 2. Create a new language folder

To add a new language, follow these steps:

1. Create a folder using the two-letter language code (ISO 639-1) inside the root directory. For example, to add `French`, create:

```bash 
mkdir -p src/content/docs/fr
```

2. Copy the content from the `src/content/docs/en` directory (certainly the most up-to-date translation) and start translating.
You can do it manually or by some magic one-liner, do as you please, but maintain the same file hierarchy to ensure consistency.

3. Updating Configuration

When adding a new language for the first time, edit `astro.config.mjs` to register the new language: 

```ts
(...)
export default defineConfig({
  integrations: [
    starlight({
      title: 'Roberto Flores NIX Dotfiles',
      defaultLocale: 'en',
      locales: {
        en: { label: 'English', lang: 'en' },
        es: { label: 'Español', lang: 'es' },
        de: { label: 'Deutsch', lang: 'de' },
        nl: { label: 'Nederlands', lang: 'nl' },
        zh: { label: '中文', lang: 'zh' },
        fr: { label: 'Français', lang: 'fr' },  // <=== Adding French
      },
(...)
```

4. More

- Maintain the same filenames and structure as the original content.
- **You do not need to translate everything immediately**—just push the structure and translate progressively. If a translation is missing, Starlight will fall back to the default language and display a notice that the page is not yet translated.

5. Submit your changes

You know the drill, commit on your branch and make a nice PR. ;) Feel free to add more translations over time and refine the content as needed.