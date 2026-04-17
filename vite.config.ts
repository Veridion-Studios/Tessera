import { defineConfig } from "vite";
import RubyPlugin from "vite-plugin-ruby";
import { svelte } from "@sveltejs/vite-plugin-svelte";
import tailwindcss from "@tailwindcss/vite";
import { resolve } from "node:path";

const entrypointInput = {
  "entrypoints/application.js": resolve("app/frontend/entrypoints/application.js"),
  "entrypoints/application.css": resolve("app/frontend/entrypoints/application.css"),
};

export default defineConfig({
  build: {
    rollupOptions: {
      input: entrypointInput,
    },
    rolldownOptions: {
      input: entrypointInput,
    },
  },
  plugins: [
    RubyPlugin(),
    svelte(),
    tailwindcss(),
  ],
});