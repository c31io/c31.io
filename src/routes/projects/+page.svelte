<script>
	import Project from './Project.svelte';

	const projects = [
		{
			name: 'unbehave',
			links: [
				{ label: 'Home', href: 'https://unbehave.c31.io/' },
				{ label: 'GitHub', href: 'https://github.com/c31io/unbehave' }
			],
			description: 'A behavioral intervention app.'
		},
		{
			name: 'denmi',
			links: [
				{ label: 'Home', href: 'https://denmi.c31.io/' },
				{ label: 'GitHub', href: 'https://github.com/c31io/amnis' }
			],
			description: 'A very dense book serves as a quick review over some subjects.'
		},
		{
			name: 'Amnis',
			links: [{ label: 'GitHub', href: 'https://github.com/c31io/amnis' }],
			description: "Couldn't find a query language for the VOxOV project, so I created a new one."
		},
		{
			name: 'VOxOV',
			links: [{ label: 'GitHub', href: 'https://github.com/vorgv/voxov' }],
			description: `A federated monolithic pay-as-you-go backend-as-a-service cloud-retail project.<br />Not ready for production. Undergoing major refactorization.`
		},
		{
			name: 'ToFON',
			links: [{ label: 'GitHub', href: 'https://github.com/c31io/tofon' }],
			description: `Blender Time-of-Flight Add-on.<br />Much inspired by <a class="italic" href="https://blender.stackexchange.com/a/91760">How to calculate for every ray the total distance it has traveled from camera to emitter</a>.`
		},
		{
			name: 'tect',
			links: [{ label: 'GitHub', href: 'https://github.com/c31io/tect' }],
			description: `A Demo of Electron + TensorFlow.js + MobileNet.<br />Transparent, draggable, resizable, and multi-window.`
		},
		{
			name: 'dotfiles',
			links: [{ label: 'GitHub', href: 'https://github.com/c31io/dotfiles' }],
			description: 'NixOS config files for my machines.'
		}
	];
</script>

{#each projects as project, i}
	<Project {...project} last={i === projects.length - 1} />
{/each}
