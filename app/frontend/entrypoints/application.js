import "./application.css";

const debounce = (fn, delay = 250) => {
	let timeoutId;
	return (...args) => {
		clearTimeout(timeoutId);
		timeoutId = setTimeout(() => fn(...args), delay);
	};
};

const renderRepoResults = (container, repos, onSelect) => {
	if (!repos.length) {
		container.innerHTML = '<div class="px-3 py-2 text-xs text-zinc-500">No matching repositories</div>';
		container.classList.remove("hidden");
		return;
	}

	container.innerHTML = repos
		.map(
			(repo) => `
				<button type="button" class="w-full text-left px-3 py-2 border-b border-white/5 last:border-b-0 hover:bg-white/5 transition-colors" data-repo-url="${repo.html_url}" data-repo-name="${repo.full_name}">
					<div class="text-sm text-white">${repo.full_name}</div>
					<div class="text-xs text-zinc-500">${repo.private ? "Private" : "Public"}</div>
				</button>
			`
		)
		.join("");

	container.classList.remove("hidden");
	container.querySelectorAll("[data-repo-url]").forEach((button) => {
		button.addEventListener("click", () => {
			onSelect(button.dataset.repoName, button.dataset.repoUrl);
			container.classList.add("hidden");
		});
	});
};

document.addEventListener("DOMContentLoaded", () => {
	document.querySelectorAll("[data-github-repo-picker]").forEach((picker) => {
		const source = picker.dataset.githubRepoSource;
		const input = picker.querySelector('[data-github-repo-picker-target="input"]');
		const valueInput = picker.querySelector('[data-github-repo-picker-target="value"]');
		const results = picker.querySelector('[data-github-repo-picker-target="results"]');

		if (!source || !input || !valueInput || !results) return;

		const search = debounce(async (query) => {
			if (!query.trim()) {
				results.classList.add("hidden");
				results.innerHTML = "";
				valueInput.value = "";
				return;
			}

			const response = await fetch(`${source}?q=${encodeURIComponent(query)}`, {
				headers: { Accept: "application/json" }
			});

			if (!response.ok) {
				results.classList.add("hidden");
				return;
			}

			const repos = await response.json();
			renderRepoResults(results, repos, (fullName, url) => {
				input.value = fullName;
				valueInput.value = url;
			});
		}, 250);

		input.addEventListener("input", (event) => {
			search(event.target.value);
		});

		document.addEventListener("click", (event) => {
			if (!picker.contains(event.target)) {
				results.classList.add("hidden");
			}
		});
	});
});