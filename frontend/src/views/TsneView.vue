<script setup lang="ts">
import { consola } from 'consola'
import * as d3 from 'd3'
import { onMounted, ref } from 'vue'

import tSNE from '@/lib/tsne'

const solution = ref([])

const N = 300
const dimX = 0
const dimY = 1

const tsne = ref<any>(null)
const model = ref<any>(null)

const calculatingDistance = ref(false)

// Generate a 100x3 matrix of random numbers
const points = ref([[0, 0, 0]])

const distanceHSL = (a: number[], b: number[]) => {
  let d = 0,
    s = 0
  let i = 0
  s = Math.sin(Math.PI * (a[i] - b[i]))
  d += s * s
  i = 1
  s = a[i] - b[i]
  d += (s * s) / 2
  i = 2
  s = a[i] - b[i]
  d += (s * s) / 2
  return Math.sqrt(d)
}

const init = async () => {
  calculatingDistance.value = true

  model.value = new tSNE({
    dim: 2,
    epsilon: 10,
    perplexity: 10
  })

  points.value = d3.range(N).map(() => [Math.random(), Math.random(), Math.random()])

  const dists = points.value.map((p) => points.value.map((q) => distanceHSL(p, q)))

  model.value.initDataDist(dists)

  //Compute a solution, one step at a time, and yield the interim solution. We track the solution's cost, and once it's stabilized we stop the simulation
  let cost = 100
  let costPrev = 0

  do {
    cost = costPrev
    costPrev = cost * 0.9 + 0.1 * model.value.step()

    solution.value = model.value.getSolution()

    drawCanvas()
    await new Promise((resolve) => setTimeout(resolve, 0.1))
  } while (Math.abs(cost - costPrev) > 1e-4)

  solution.value = model.value.getSolution()
  drawCanvas()

  calculatingDistance.value = false
}

const drawCanvas = () => {
  const canvas = document.getElementById('tsne') as HTMLCanvasElement
  if (!canvas) {
    consola.error('Canvas not found')
    return
  }

  const ctx = canvas.getContext('2d')
  if (!ctx) {
    consola.error('Canvas context not found')
    return
  }

  ctx.fillStyle = 'rgba(255,255,255,0.4)'
  ctx.clearRect(0, 0, canvas.width, canvas.height)

  const xExtent = d3.extent(solution.value, (d) => parseFloat(d[dimX]))
  const yExtent = d3.extent(solution.value, (d) => parseFloat(d[dimY]))

  if (
    xExtent[0] === undefined ||
    xExtent[1] === undefined ||
    yExtent[0] === undefined ||
    yExtent[1] === undefined
  ) {
    consola.error('Invalid extent values')
    return
  }

  const X = d3
    .scaleLinear()
    .domain(xExtent)
    .range([20, canvas.width - 20])

  const Y = d3
    .scaleLinear()
    .domain(yExtent)
    .range([20, (canvas.width * 2) / 3 - 20])

  const radius = 150 / Math.sqrt(10 + points.value.length)

  solution.value.forEach((point, i) => {
    let k = points.value[i]
    ctx.beginPath()
    ctx.arc(X(point[dimX]), Y(point[dimY]), radius, 0, 2 * Math.PI)

    const h = k[0] * 360
    const s = 0.3 + 0.5 * k[1]
    const l = 0.3 + 0.5 * k[2]
    ctx.fillStyle = `hsl(${h}, ${s * 100}%, ${l * 100}%)`

    ctx.fill()
  })
}

const getClosestSelectedPoints = (event: any) => {
  const canvas = document.getElementById('tsne') as HTMLCanvasElement
  if (!canvas) {
    consola.error('Canvas not found')
    return
  }

  const rect = canvas.getBoundingClientRect()
  const x = event.clientX - rect.left
  const y = event.clientY - rect.top

  const X = d3
    .scaleLinear()
    .domain([20, canvas.width - 20])
    .range(d3.extent(solution.value, (d) => parseFloat(d[dimX])))

  const Y = d3
    .scaleLinear()
    .domain([20, (canvas.width * 2) / 3 - 20])
    .range(d3.extent(solution.value, (d) => parseFloat(d[dimY])))

  const closest = solution.value.reduce(
    (acc, point, i) => {
      const d = Math.sqrt((X(point[dimX]) - x) ** 2 + (Y(point[dimY]) - y) ** 2)
      if (d < acc.d) {
        acc.d = d
        acc.i = i
      }
      return acc
    },
    { d: Infinity, i: -1 }
  )

  consola.info('Closest point:', closest.i, points.value[closest.i])
}

onMounted(() => {
  init()
})
</script>

<template>
  <main>
    T-sne
    <n-divider />

    <n-flex>
      <n-button @click="init" :disabled="calculatingDistance" :loading="calculatingDistance"
        >Load data</n-button
      >
    </n-flex>

    <n-divider />

    <canvas
      id="tsne"
      ref="tsne"
      height="800"
      width="800"
      class="bg-slate-50/20"
      @click="getClosestSelectedPoints($event)"
    />

    <n-divider />

    <n-collapse>
      <n-collapse-item title="points" name="points">
        <pre>{{ points }}</pre>
      </n-collapse-item>

      <n-collapse-item title="model" name="model">
        <pre>{{ model }}</pre>
      </n-collapse-item>

      <n-collapse-item title="solution" name="solution">
        <pre>{{ solution }}</pre>
      </n-collapse-item>
    </n-collapse>

    <n-divider />

    <n-flex>
      <RouterLink to="/">home</RouterLink>

      <RouterLink to="/about">About</RouterLink>
    </n-flex>
  </main>
</template>
