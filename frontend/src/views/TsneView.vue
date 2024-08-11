<script setup lang="ts">
import { faker } from '@faker-js/faker'
import { consola } from 'consola'
import * as d3 from 'd3'
import { onMounted, ref } from 'vue'

import tSNE from '@/lib/tsne'

const solution = ref([])

const N = 100
const dimX = 0
const dimY = 1

const width = 800
const height = 800

const tsne = ref<any>(null)
const model = ref<any>(null)

const calculatingDistance = ref(false)

// Generate a 100x3 matrix of random numbers
const responseData = ref<any>([])
const points = ref([[0, 0]])
const categories = ref([
  {
    color: 'red',
    genre: 'category1'
  }
])

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

const euclideanDistance = (a: number[], b: number[]) => {
  let d = 0
  for (let i = 0; i < a.length; i++) {
    let s = a[i] - b[i]
    d += s * s
  }
  return Math.sqrt(d)
}

const init = async () => {
  calculatingDistance.value = true

  const data = await fetch('http://localhost:3001/getData/100')

  points.value = []

  responseData.value = await data.json()
  responseData.value.forEach((element: any) => {
    points.value.push([element.x, element.y])
  })

  generateCategoryColors()

  model.value = new tSNE({
    dim: 2,
    epsilon: 10,
    perplexity: 10
  })

  // points.value = d3.range(N).map(() => [Math.random(), Math.random(), Math.random()])

  const dists = points.value.map((p) => points.value.map((q) => euclideanDistance(p, q)))

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

const generateCategoryColors = () => {
  categories.value = []
  responseData.value.forEach((element: any) => {
    if (!categories.value.find((category) => category.genre === element.genre)) {
      categories.value.push({
        color: faker.color.human(),
        genre: element.genre
      })
    }
  })
}

const getCategoryColor = (category: string) => {
  const categoryIndex = categories.value.findIndex((element) => element.genre === category)
  return categories.value[categoryIndex].color
}

const drawCanvas = () => {
  const container = document.getElementById('chart')
  if (!container) {
    consola.error('Container not found')
    return
  }

  const margin = { bottom: 20, left: 20, right: 20, top: 20 },
    width = 800 - margin.left - margin.right,
    height = 800

  // Clear the container
  container.innerHTML = ''

  const svg = d3
    .select(container)
    .append('svg')
    .attr('width', width)
    .attr('height', height)
    .append('g')
    .attr('transform', `translate(${margin.left}, ${margin.top})`)

  // const svgContainer = d3.select('.svg-demo')

  const xExtent = d3.extent(solution.value, (d) => parseFloat(d[dimX]))
  const yExtent = d3.extent(solution.value, (d) => parseFloat(d[dimY]))

  const X = d3
    .scaleLinear()
    .domain(xExtent)
    .range([20, width - 20])

  const Y = d3
    .scaleLinear()
    .domain(yExtent)
    .range([20, (height * 2) / 3 - 20])

  // Draw circles for all the points in the dataset
  // Add a click event to each circle
  solution.value.forEach((point, i) => {
    svg
      .append('circle')
      .attr('id', `circle-${i}`)
      .attr('class', `cursor-pointer genre-${responseData.value[i].genre}`)
      .attr('cx', X(point[dimX]))
      .attr('cy', Y(point[dimY]))
      .attr('r', 10)
      .attr('stroke', 'black')
      .attr('stroke-width', 1)
      .attr('fill', getCategoryColor(responseData.value[i].genre))
      .on('click', () => {
        consola.info(responseData.value[i])
      })
      // Add a hover event to each circle
      // gently increase the radius of the circle
      .on('mouseover', () => {
        // Increase the radius of all the circles with the same genre
        const genre = responseData.value[i].genre
        d3.selectAll(`.genre-${genre}`).transition().attr('r', 15)
      })
      // gently decrease the radius of the circle
      .on('mouseout', () => {
        // Decrease the radius of all the circles with the same genre
        const genre = responseData.value[i].genre
        d3.selectAll(`.genre-${genre}`).transition().attr('r', 10)
      })
  })
}

// const drawCanvas = () => {
//   const canvas = document.getElementById('tsne') as HTMLCanvasElement
//   if (!canvas) {
//     consola.error('Canvas not found')
//     return
//   }

//   const ctx = canvas.getContext('2d')
//   if (!ctx) {
//     consola.error('Canvas context not found')
//     return
//   }

//   ctx.fillStyle = 'rgba(255,255,255,0.4)'
//   ctx.clearRect(0, 0, canvas.width, canvas.height)

//   const xExtent = d3.extent(solution.value, (d) => parseFloat(d[dimX]))
//   const yExtent = d3.extent(solution.value, (d) => parseFloat(d[dimY]))

//   if (
//     xExtent[0] === undefined ||
//     xExtent[1] === undefined ||
//     yExtent[0] === undefined ||
//     yExtent[1] === undefined
//   ) {
//     consola.error('Invalid extent values')
//     return
//   }

//   const X = d3
//     .scaleLinear()
//     .domain(xExtent)
//     .range([20, canvas.width - 20])

//   const Y = d3
//     .scaleLinear()
//     .domain(yExtent)
//     .range([20, (canvas.width * 2) / 3 - 20])

//   const radius = 150 / Math.sqrt(10 + points.value.length)

//   solution.value.forEach((point, i) => {
//     let k = points.value[i]
//     ctx.beginPath()
//     ctx.arc(X(point[dimX]), Y(point[dimY]), radius, 0, 2 * Math.PI)

//     const h = k[0] * 360
//     const s = 0.3 + 0.5 * k[1]
//     const l = 0.3 + 0.5 * k[2]
//     ctx.fillStyle = `hsl(${h}, ${s * 100}%, ${l * 100}%)`

//     ctx.fill()
//   })
// }

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

    <div id="chart"></div>

    <canvas id="tsne" ref="tsne" height="800" width="800" class="bg-slate-50/20 hidden" />

    <n-divider />

    <n-collapse>
      <n-collapse-item title="categories" name="categories">
        <pre>{{ categories }}</pre>
      </n-collapse-item>

      <n-collapse-item title="responseData" name="responseData">
        <pre>{{ responseData }}</pre>
      </n-collapse-item>

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
