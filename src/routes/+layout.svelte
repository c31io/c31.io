<script>
  import "../app.css";
  import { setLocale, locale, t } from "$lib";
</script>

<h1 class="text-3xl py-2 grid place-items-center select-none">c31.io</h1>

<nav class="select-none grid place-items-center my-4">
  <div class="[&>*]:px-2 border-y">
    <a href="/">{$t('common.home')}</a>
    <a href="/projects">{$t('common.projects')}</a>
    <a href="/about">{$t('common.about')}</a>
    <button class="text-gray-400"
      on:click={() => {
        if (locale.get() === 'en') {
          console.log('here')
          setLocale('zh');
          localStorage.setItem('locale', 'zh');
        } else {
          setLocale('en');
          localStorage.setItem('locale', 'en');
        }
      }}
    >{$locale === 'en' ? 'en' : '中'}</button>
  </div>
</nav>

<slot />
