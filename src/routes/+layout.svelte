<script>
    import "../app.css";
    import { t } from "$lib";
</script>

<h1 class="text-3xl py-2 grid place-items-center select-none">c31.io</h1>

<nav class="select-none grid place-items-center my-4">
    <div class="[&>*]:px-2 border-y">
        <a href="/">{$t('common.home')}</a>
        <a href="/blog">{$t('common.blog')}</a>
        <a href="/projects">{$t('common.projects')}</a>
        <a href="/about">{$t('common.about')}</a>
    </div>
</nav>

<slot />
