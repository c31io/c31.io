export const prerender = true;

import { loadTranslations } from "../lib";

/** @type {import('@sveltejs/kit').Load} */
export const load = async ({ url }) => {
    const { pathname } = url;

    const initLocale = 'en';

    await loadTranslations(initLocale, pathname);

    return {};
}
