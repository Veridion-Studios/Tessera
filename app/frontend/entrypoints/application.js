import "./application.css";
import * as Sentry from "@sentry/browser";

const loadPlainChatWidget = () => {
	if (typeof window === "undefined") return;

	const appId = "liveChatApp_01KRJ1BQYX69NT20W54XRSKYSR";
	const scriptSrc = "https://chat.cdn-plain.com/index.js";
	const existingScript = document.querySelector(`script[src="${scriptSrc}"]`);

	const initWidget = () => {
		if (window.Plain && typeof window.Plain.init === "function") {
			window.Plain.init({ appId });
		}
	};

	if (window.Plain?.init) {
		initWidget();
		return;
	}

	if (existingScript) {
		existingScript.addEventListener("load", initWidget, { once: true });
		return;
	}

	const script = document.createElement("script");
	script.async = false;
	script.onload = initWidget;
	script.src = scriptSrc;
	document.head.appendChild(script);
};

Sentry.init({
	dsn: import.meta.env.VITE_SENTRY_DSN || undefined,
	// adjust sampleRate / tracesSampleRate if using performance monitoring
	environment: import.meta.env.MODE,
});

// If the server exposed the current user to the page, set it for the browser SDK
try {
	if (typeof window !== "undefined" && window.__CURRENT_USER) {
		Sentry.setUser(window.__CURRENT_USER);
	}
} catch (e) {
	// ignore
}

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
	loadPlainChatWidget();

	// Expose Sentry on window for inline handlers and templates
	try {
		window.Sentry = Sentry;
	} catch (e) {
		// ignore
	}

	// Modal-based feedback: wire up the global feedback button and modal form
	const fbOpenBtn = document.getElementById("sentry-feedback-btn");
	const fbModal = document.getElementById("sentry-feedback-modal");
	const fbForm = document.getElementById("sentry-feedback-form");
	const fbClose = document.getElementById("sentry-feedback-close");

	function openModal() {
		if (!fbModal) return;
		fbModal.classList.remove("hidden");
		const textarea = fbModal.querySelector("textarea");
		if (textarea) textarea.focus();
	}
	function closeModal() {
		if (!fbModal) return;
		fbModal.classList.add("hidden");
	}

	if (fbOpenBtn) fbOpenBtn.addEventListener("click", (e) => { e.preventDefault(); openModal(); });
	if (fbClose) fbClose.addEventListener("click", (e) => { e.preventDefault(); closeModal(); });
	if (fbModal) fbModal.addEventListener("click", (e) => { if (e.target === fbModal) closeModal(); });

	if (fbForm) {
		fbForm.addEventListener("submit", (e) => {
			e.preventDefault();
			try {
				const form = e.currentTarget;
				const name = form.querySelector('[name="sentry_name"]')?.value || undefined;
				const email = form.querySelector('[name="sentry_email"]')?.value || undefined;
				const message = form.querySelector('[name="sentry_message"]')?.value || "";
				if (!message.trim()) {
					alert("Please enter a message before submitting.");
					return;
				}

				// Use the SDK to send user feedback
				if (window.Sentry && typeof window.Sentry.captureFeedback === "function") {
					window.Sentry.captureFeedback({ name, email, message });
				} else if (typeof Sentry !== "undefined" && typeof Sentry.captureFeedback === "function") {
					Sentry.captureFeedback({ name, email, message });
				}

				// Simple confirmation and close
				alert("Thanks — your feedback was submitted.");
				closeModal();
				form.reset();
			} catch (err) {
				// ignore
			}
		});
	}

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