<script>
  import "../app.css";
  import { setLocale, locale, otherLocale, localeLabel, t } from "$lib";
</script>

<h1 class="text-3xl py-2 grid place-items-center select-none">c31.io</h1>

<nav class="select-none grid place-items-center my-4">
  <div class="[&>*]:px-2 border-y">
    <a href="/">{$t('common.home')}</a>
    <a href="/projects">{$t('common.projects')}</a>
    <a href="/about">{$t('common.about')}</a>
    <button class="text-gray-400"
      onclick={() => {
        const next = otherLocale(locale.get());
        setLocale(next);
        localStorage.setItem('locale', next);
      }}
    >{localeLabel[$locale] ?? $locale}</button>
  </div>
</nav>

<slot />
