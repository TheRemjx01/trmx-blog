import React from 'react';
import type {ReactNode} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import { usePluginData } from '@docusaurus/useGlobalData';

import styles from './index.module.css';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero', styles.heroBanner)}>
      <div className="container">
        <h1 className="hero__title">{siteConfig.title}</h1>
        <p className="hero__subtitle">
          Sharing insights on engineering excellence, architecture patterns, and real-world experiences
        </p>
        <div className={styles.buttons}>
          <Link className="button button--primary button--lg" to="/blog">
            Read Latest Posts
          </Link>
        </div>
      </div>
    </header>
  );
}

function FocusAreas() {
  return (
    <section className={styles.focusAreas}>
      <div className="container">
        <div className={styles.focusGrid}>
          <div className={styles.focusCard}>
            <h2>Engineering Best Practices</h2>
            <ul>
              <li>Clean Code & Design Patterns</li>
              <li>Testing Strategies</li>
              <li>Code Review Guidelines</li>
              <li>Development Workflows</li>
            </ul>
          </div>
          <div className={styles.focusCard}>
            <h2>Architecture Patterns</h2>
            <ul>
              <li>System Design</li>
              <li>Microservices Architecture</li>
              <li>Scalability Patterns</li>
              <li>Cloud-Native Solutions</li>
            </ul>
          </div>
          <div className={styles.focusCard}>
            <h2>Real-world Experience</h2>
            <ul>
              <li>Case Studies</li>
              <li>Problem Solving</li>
              <li>Team Collaboration</li>
              <li>Technical Leadership</li>
            </ul>
          </div>
        </div>
      </div>
    </section>
  );
}

function FeaturedBlogPosts() {
  const blogPluginData = usePluginData('docusaurus-plugin-content-blog') as any;
  const allPosts = blogPluginData?.blogPosts ?? [];
  
  const featuredPosts = allPosts
    .filter(post => post.metadata.frontMatter.featured)
    .slice(0, 3);

  if (featuredPosts.length === 0) {
    return null;
  }

  return (
    <section className={styles.featuredPosts}>
      <div className="container">
        <h2 className={styles.featuredTitle}>Featured Articles</h2>
        <div className={styles.featuredGrid}>
          {featuredPosts.map((post) => (
            <div key={post.metadata.permalink} className={styles.featuredPost}>
              <h3>{post.metadata.title}</h3>
              {post.metadata.description && (
                <p>{post.metadata.description}</p>
              )}
              <Link
                className="button button--secondary"
                to={post.metadata.permalink}>
                Read more
              </Link>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={siteConfig.title}
      description="Engineering best practices, architecture patterns, and real-world experiences">
      <HomepageHeader />
      <main>
        <FocusAreas />
        <FeaturedBlogPosts />
      </main>
    </Layout>
  );
}
