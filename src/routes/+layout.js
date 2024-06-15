export const prerender = true;

import { browser } from '$app/environment';
import { loadTranslations } from '../lib';

/** @type {import('@sveltejs/kit').Load} */
export const load = async ({ url }) => {
  let initLocale = browser ? localStorage.getItem('locale') : 'en';

  if (browser && !initLocale) {
    initLocale = 'en';
    localStorage.setItem('locale', 'en');
  }

  const { pathname } = url;

  await loadTranslations(initLocale, pathname);

  return {};
}
