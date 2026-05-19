// @ts-check
import {themes as prismThemes} from 'prism-react-renderer';

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'claude-skills',
  tagline: 'Personal Claude skills by Joe Stump',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: 'https://joestump.github.io',
  baseUrl: '/claude-skills/',

  organizationName: 'joestump',
  projectName: 'claude-skills',
  deploymentBranch: 'gh-pages',
  trailingSlash: false,

  onBrokenLinks: 'throw',
  markdown: {
    hooks: {
      onBrokenMarkdownLinks: 'warn',
    },
  },

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  plugins: [
    [
      'plugin-content-claude-plugin-skills',
      {
        skillsDirs: ['..'],
      },
    ],
  ],

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: './sidebars.js',
          editUrl: 'https://github.com/joestump/claude-skills/tree/main/website/',
          routeBasePath: 'docs',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      image: 'img/docusaurus-social-card.jpg',
      colorMode: {
        defaultMode: 'light',
        respectPrefersColorScheme: true,
      },
      navbar: {
        title: 'claude-skills',
        logo: {
          alt: 'claude-skills',
          src: 'img/logo.svg',
        },
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'docsSidebar',
            position: 'left',
            label: 'Skills',
          },
          {
            href: 'https://github.com/joestump/claude-skills',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {label: 'Getting started', to: '/docs/getting-started'},
              {label: 'gemini-mockup', to: '/docs/gemini-mockup'},
              {label: 'refresh-miatrix-token', to: '/docs/refresh-miatrix-token'},
              {label: 'retirement-plan', to: '/docs/retirement-plan'},
              {label: 'self-report', to: '/docs/self-report'},
            ],
          },
          {
            title: 'Project',
            items: [
              {label: 'GitHub', href: 'https://github.com/joestump/claude-skills'},
              {label: 'Issues', href: 'https://github.com/joestump/claude-skills/issues'},
              {label: 'Releases', href: 'https://github.com/joestump/claude-skills/releases'},
            ],
          },
        ],
        copyright: `MIT © ${new Date().getFullYear()} Joe Stump.`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
        additionalLanguages: ['bash', 'json', 'yaml'],
      },
    }),
};

export default config;
