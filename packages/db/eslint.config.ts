import { defineConfig } from "eslint/config";

import { baseConfig } from "@mainty/eslint-config/base";

export default defineConfig(
  {
    ignores: ["dist/**"],
  },
  baseConfig,
);

