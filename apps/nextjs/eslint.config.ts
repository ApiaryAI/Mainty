import { defineConfig } from "eslint/config";

import { baseConfig, restrictEnvAccess } from "@mainty/eslint-config/base";
import { nextjsConfig } from "@mainty/eslint-config/nextjs";
import { reactConfig } from "@mainty/eslint-config/react";

export default defineConfig(
  {
    ignores: [".next/**"],
  },
  baseConfig,
  reactConfig,
  nextjsConfig,
  restrictEnvAccess,
);

