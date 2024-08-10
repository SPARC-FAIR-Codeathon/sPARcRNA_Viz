<script setup lang="ts">
import { RouterLink, RouterView } from 'vue-router'
import HelloWorld from './components/HelloWorld.vue'
</script>

<template>
  <n-config-provider :theme="theme" :theme-overrides="themeOverrides">
    <n-dialog-provider>
      <n-message-provider>
        <n-space vertical size="large">
          <n-layout-content class="view h-[calc(100vh-56px)] py-4 pl-6">
            <router-view v-slot="{ Component }">
              <transition name="fade" appear mode="out-in">
                <component :is="Component" />
              </transition>
            </router-view>
          </n-layout-content>
        </n-space>
      </n-message-provider>
    </n-dialog-provider>
  </n-config-provider>
</template>

<style scoped></style>
