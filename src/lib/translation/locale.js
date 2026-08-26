/** @type {readonly string[]} */
export const supportedLocales = ['en', 'zh'];

export const defaultLocale = supportedLocales[0];

/** @param {string} locale */
export const otherLocale = (locale) =>
  supportedLocales[0] === locale ? supportedLocales[1] : supportedLocales[0];

/** @type {Record<string, string>} */
export const localeLabel = { en: 'en', zh: '中' };
