<script>
	/** @type {string} */
	export let name;
	/** @type {Array<{label: string, href: string}>} */
	export let links = [];
	/** @type {string} */
	export let description;
	/** @type {boolean} */
	export let last = false;
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

{#if !last}
	<hr class="flex-col justify-center max-w-md mx-auto my-4" />
{/if}
