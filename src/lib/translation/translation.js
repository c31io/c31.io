import i18n from 'sveltekit-i18n';
import { supportedLocales } from './locale';

/** @type {NonNullable<import('sveltekit-i18n').Config['loaders']>} */
const loaders = [];

supportedLocales.forEach((l) => {
  ['common', 'home'].forEach((k) => {
    loaders.push({
      locale: l,
      key: k,
      loader: async() => (
        await import(`./${l}/${k}.json`)
      ).default,
    });
  })
});

/** @type {import('sveltekit-i18n').Config} */
const config = ({ loaders });

export const { t, setLocale, locale, locales, loading, loadTranslations } = new i18n(config);
