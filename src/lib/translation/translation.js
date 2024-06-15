import i18n from 'sveltekit-i18n';

const loaders = [];

['en', 'zh'].forEach((l) => {
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
