import Link from '@docusaurus/Link';
import styles from './styles.module.css';

const SKILLS = [
  {
    name: 'retirement-plan',
    href: '/docs/retirement-plan',
    summary:
      'Generates a high-fidelity, durable retirement-plan.html artifact from a Claude Project’s financial documents and lifestyle assumptions.',
    triggers: [
      'Project name suggests retirement focus',
      '/retirement-plan',
      'New financial documents uploaded',
      'Stale plan (>3 months old)',
    ],
  },
  {
    name: 'self-report',
    href: '/docs/self-report',
    summary:
      'Files GitHub issues against this repo when another skill hits friction during a run. Single owner of the filing path so other skills don’t reimplement it.',
    triggers: [
      'Invoked by another skill on threshold trip',
      '/self-report',
    ],
  },
];

export default function SkillTiles() {
  return (
    <div className={styles.grid}>
      {SKILLS.map((skill) => (
        <Link key={skill.name} to={skill.href} className={styles.tile}>
          <div className={styles.tileHeader}>
            <span className={styles.tileLabel}>SKILL</span>
            <h3 className={styles.tileName}>{skill.name}</h3>
          </div>
          <p className={styles.tileSummary}>{skill.summary}</p>
          <div className={styles.triggers}>
            <span className={styles.triggersLabel}>TRIGGERS</span>
            <ul className={styles.triggerList}>
              {skill.triggers.map((t) => (
                <li key={t}>{t}</li>
              ))}
            </ul>
          </div>
          <div className={styles.tileCta}>
            <span>Read the guide →</span>
          </div>
        </Link>
      ))}
    </div>
  );
}
