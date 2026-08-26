export const prerender = true;

import { browser } from '$app/environment';
import { loadTranslations, supportedLocales, defaultLocale } from '../lib';

/** @type {import('@sveltejs/kit').Load} */
export const load = async ({ url }) => {
  const stored = browser ? localStorage.getItem('locale') : null;
  const initLocale = stored && supportedLocales.includes(stored) ? stored : defaultLocale;

  const { pathname } = url;

  await loadTranslations(initLocale, pathname);

  return {};
}
