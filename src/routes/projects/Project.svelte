<script>
	/** @type {{ name: string, links?: Array<{label: string, href: string}>, description: string, isLast?: boolean }} */
	let { name, links = [], description, isLast = false } = $props();
</script>

<h2 class="text-xl py-2 grid place-items-center select-none">{name}</h2>

<p class="flex-col justify-center text-center px-4 max-w-md mx-auto">
	{#each links as { label, href }, j}
		<a {href} class="underline">{label}</a>
		{#if j < links.length - 1}
			{' '}
		{/if}
	{/each}
</p>

<p class="flex-col justify-center text-center px-4 max-w-md mx-auto">
	{@html description}
</p>

{#if !isLast}
	<hr class="flex-col justify-center max-w-md mx-auto my-4" />
{/if}
