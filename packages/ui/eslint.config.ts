import { defineConfig } from "eslint/config";

import { baseConfig } from "@mainty/eslint-config/base";
import { reactConfig } from "@mainty/eslint-config/react";

export default defineConfig(
  {
    ignores: ["dist/**"],
  },
  baseConfig,
  reactConfig,
);

