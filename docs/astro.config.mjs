// @ts-check
import starlight from '@astrojs/starlight';
import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
  integrations: [
    starlight({
      title: 'Roberto Flores NixOS Dotfiles',
      customCss: [
        // Path to our custom CSS file
        './src/styles/custom.css',
      ],
      components: {
        LanguageSelect: './src/components/LanguageSelect.astro',
      },
      defaultLocale: 'en',
      locales: {
        en: { label: 'English', lang: 'en' },
        es: { label: 'Español', lang: 'es' },
      },
      social: [
        {
          icon: 'github',
          label: 'GitHub',
          href: 'https://github.com/ravn-ruby-path/Dotfiles',
        },
        {
          icon: 'discord',
          label: 'Discord',
          href: 'https://discord.gg/8nWbDC4SnP',
        },
      ],
      sidebar: [
        {
          label: '🚀 Getting Started',
          autogenerate: {directory: 'getting-started'},
        },
        {
          label: '🛠️ Configuring',
          autogenerate: {directory: 'configuring'},
        },
        {
          label: '📙 Man Pages',
          autogenerate: {directory: 'man-pages'},
        },
        {
          label: '🎨 Theming',
          autogenerate: {directory: 'theming'},
        },
        {
          label: '📚 Resources',
          autogenerate: {directory: 'resources'}
        },
        {
          label: '👥 Help',
          autogenerate: {directory: 'help'}
        }
      ],
    }),
  ],
});
