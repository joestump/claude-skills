import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import SkillTiles from '@site/src/components/SkillTiles';
import styles from './index.module.css';

export default function Home() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={siteConfig.title}
      description={siteConfig.tagline}>
      <header className={styles.hero}>
        <div className={styles.heroInner}>
          <p className={styles.eyebrow}>CLAUDE-SKILLS</p>
          <h1 className={styles.title}>{siteConfig.tagline}</h1>
          <p className={styles.subtitle}>
            Self-contained instruction packs Claude loads on demand.
            Drop one into <code>~/.claude/skills/</code> and Claude
            picks it up the next session.
          </p>
          <div className={styles.cta}>
            <Link className={styles.primary} to="/docs/getting-started">
              Get started
            </Link>
            <Link
              className={styles.secondary}
              href="https://github.com/joestump/claude-skills">
              GitHub
            </Link>
          </div>
        </div>
      </header>
      <main>
        <section className={styles.tilesSection}>
          <div className={styles.tilesInner}>
            <h2 className={styles.tilesHeader}>Skills</h2>
            <SkillTiles />
          </div>
        </section>
      </main>
    </Layout>
  );
}
