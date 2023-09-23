<script>
	import { page } from '$app/stores';
</script>

<h1 class="text-2xl py-4 grid place-items-center select-none">
    {$page.error?.message}
</h1>
