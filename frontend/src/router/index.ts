import { createRouter, createWebHistory } from 'vue-router'

import TsneView from '@/views/TsneView.vue'

import HomeView from '../views/HomeView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      name: 'home',
      path: '/',
      component: HomeView
    },
    {
      name: 'about',
      path: '/about',
      // route level code-splitting
      // this generates a separate chunk (About.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () => import('../views/AboutView.vue')
    },
    {
      name: 'tsne',
      path: '/tsne',
      component: TsneView
    }
  ]
})

export default router
