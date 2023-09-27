import i18n from 'sveltekit-i18n';

/** @type {import('sveltekit-i18n').Config} */
const config = ({
    loaders: [
        {
            locale: 'en',
            key: 'common',
            loader: async () => (
                await import('./en/common.json')
            ).default,
        },
        {
            locale: 'zh',
            key: 'common',
            loader: async () => (
                await import('./zh/common.json')
            ).default,
        },
        /*
        {
            locale: 'en',
            key: 'home',
            loader: async () => (
                await import('./en/home.json')
            ).default,
        },
        {
            locale: 'zh',
            key: 'home',
            routes: ['/home'],
            loader: async () => (
                await import('./zh/home.json')
            ).default,
        },
        */
    ],
});

export const { t, locale, locales, loading, loadTranslations } = new i18n(config);
