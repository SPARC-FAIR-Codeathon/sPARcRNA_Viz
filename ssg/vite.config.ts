import { UserConfig } from "vite";
import VuePlugin from "@vitejs/plugin-vue";
import ViteIcons, { ViteIconsResolver } from "vite-plugin-icons";
import ViteComponents from "vite-plugin-components";
import WindiCSS from "vite-plugin-windicss";
import Unimport from "unimport/unplugin";
import AutoImport from "unplugin-auto-import/vite";
import { NaiveUiResolver } from "unplugin-vue-components/resolvers";
import Components from "unplugin-vue-components/vite";
import { fileURLToPath, URL } from "node:url";

const config: UserConfig = {
  plugins: [
    VuePlugin(),
    // https://github.com/antfu/vite-plugin-components
    ViteComponents({
      customComponentResolvers: [
        ViteIconsResolver({
          componentPrefix: "",
        }),
      ],
    }),
    // https://github.com/antfu/vite-plugin-icons
    ViteIcons({
      scale: 1.1,
      defaultStyle: "vertical-align: middle;",
    }),
    WindiCSS(),
    Unimport.vite({
      addons: {
        vueTemplate: true,
      },
      dts: "src/unimport.d.ts", // Optional if not using TypeScript
      imports: [
        // {
        //   name: "fetchWithAuth",
        //   from: fileURLToPath(new URL("src/main.ts", import.meta.url)),
        // },
      ],
    }),
    AutoImport({
      dts: "./auto-imports.d.ts",
      imports: [
        "vue",
        "vue-router",
        // custom imports
        {
          "@vueuse/core": [
            "useMouse", // import { useMouse } from '@vueuse/core',
            ["useFetch", "useMyFetch"], // import { useFetch as useMyFetch } from '@vueuse/core',
          ],
          axios: [
            ["default", "axios"], // import { default as axios } from 'axios',
          ],
          "naive-ui": [
            "useDialog",
            "useMessage",
            "useNotification",
            "useLoadingBar",
          ],
          notivue: ["usePush"],
        },
        //type imports
        {
          from: "naive-ui",
          imports: ["FormInst", "FormRules", "SelectOption", "FormItemRule"],
          type: true,
        },
      ],
      include: [
        /\.[tj]sx?$/, // .ts, .tsx, .js, .jsx
        /\.vue$/,
        /\.vue\?vue/, // .vue
        /\.md$/, // .md
      ],
      injectAtEnd: true,
    }),
    Components({
      // resolvers for custom components
      resolvers: [NaiveUiResolver()],
    }),
  ],
  build: {
    minify: false,
  },
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./src", import.meta.url)),
    },
  },
};

export default config;
