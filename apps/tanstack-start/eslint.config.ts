import { defineConfig } from "eslint/config";

import { baseConfig, restrictEnvAccess } from "@mainty/eslint-config/base";
import { reactConfig } from "@mainty/eslint-config/react";

export default defineConfig(
  {
    ignores: [".nitro/**", ".output/**", ".tanstack/**"],
  },
  baseConfig,
  reactConfig,
  restrictEnvAccess,
);

