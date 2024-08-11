<script setup lang="ts">
import { RouterView } from 'vue-router'
</script>

<template>
  <n-config-provider :theme="theme" :theme-overrides="themeOverrides">
    <n-dialog-provider>
      <n-message-provider>
        <n-space vertical size="large">
          <router-view v-slot="{ Component }">
            <transition name="fade" appear mode="out-in">
              <component :is="Component" />
            </transition>
          </router-view>
        </n-space>
      </n-message-provider>
    </n-dialog-provider>
  </n-config-provider>
</template>

<style scoped></style>
