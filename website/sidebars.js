// @ts-check

/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  docsSidebar: [
    'getting-started',
    {
      type: 'category',
      label: 'Skills',
      collapsed: false,
      items: [
        'gemini-mockup',
        'retirement-plan',
        'self-report',
      ],
    },
    'contributing',
  ],
};

export default sidebars;
