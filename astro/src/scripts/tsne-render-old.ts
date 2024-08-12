import * as d3 from "d3";
import tSNE from "./tsne";
import { faker } from "@faker-js/faker";
import DATA_JSON from "../data/tsne_data.json";

const dataJson = DATA_JSON;

const categories = [
  {
    color: "red",
    cluster: "1",
  },
];

const generateCategoryColors = () => {
  // Clear the categories array
  categories.length = 0;

  dataJson.forEach((element: any) => {
    if (!categories.find((category) => category.cluster === element.cluster)) {
      categories.push({
        color: faker.color.human(),
        cluster: element.cluster,
      });
    }
  });
};
generateCategoryColors();

const preData = document.getElementById("pre-data");

if (!preData) {
  throw new Error("pre-data element not found");
}

const points = [[0, 0]];

// Clear the first point
points.pop();

for (const point of dataJson) {
  points.push([point.tSNE_1, point.tSNE_2]);
}

const model = new tSNE({
  dim: 2,
  epsilon: 10,
  perplexity: 10,
});

const euclideanDistance = (a: number[], b: number[]) => {
  let d = 0;
  for (let i = 0; i < a.length; i++) {
    let s = a[i] - b[i];
    d += s * s;
  }
  return Math.sqrt(d);
};

const dists = points.map((a) => points.map((b) => euclideanDistance(a, b)));

model.initDataDist(dists);

let cost = 0;
let costPrev = 0;

const dimX = 0;
const dimY = 1;

let solution: any = [];

const getCategoryColor = (category: string) => {
  const categoryIndex = categories.findIndex(
    (element) => element.cluster === category
  );
  return categories[categoryIndex].color;
};

const drawSVG = () => {
  const container = document.getElementById("chart");

  if (!container) {
    throw new Error("chart element not found");
  }

  const margin = { bottom: 20, left: 20, right: 20, top: 20 };
  const width = 1200 - margin.left - margin.right;
  const height = 800;

  container.innerHTML = "";

  const svg = d3
    .select(container)
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", `translate(${margin.left}, ${margin.top})`);

  const xExtent = d3.extent(solution, (d: any) =>
    parseFloat(d[dimX] as unknown as string)
  ) as [number, number];
  const yExtent = d3.extent(solution, (d: any) =>
    parseFloat(d[dimY] as unknown as string)
  ) as [number, number];

  const X = d3
    .scaleLinear()
    .domain(xExtent)
    .range([20, width - 20]);

  const Y = d3
    .scaleLinear()
    .domain(yExtent)
    .range([20, (height * 2) / 3 - 20]);

  // Draw circles for all the points in the dataset
  // Add a click event to each circle
  solution.forEach((point: any, i: number) => {
    svg
      .append("circle")
      .attr("id", `circle-${i}`)
      .attr("class", `cursor-pointer cluster-${dataJson[i].cluster}`)
      .attr("cx", X(point[dimX]))
      .attr("cy", Y(point[dimY]))
      .attr("r", 2)
      .attr("stroke", "black")
      .attr("stroke-width", 1)
      .attr("fill", "gray")
      // .attr('fill', getCategoryColor(preData[i].genre))
      .on("click", () => {
        console.log(dataJson[i]);
      })
      // Add a hover event to each circle
      // gently increase the radius of the circle
      .on("mouseover", () => {
        // Increase the radius of all the circles with the same genre
        const genre = dataJson[i].cluster;
        d3.selectAll(`.genre-${genre}`).transition().attr("r", 15);
        const color = getCategoryColor(genre);
        d3.selectAll(`.genre-${genre}`).transition().attr("fill", color);
      })
      // gently decrease the radius of the circle
      .on("mouseout", () => {
        // Decrease the radius of all the circles with the same genre
        const genre = dataJson[i].cluster;
        d3.selectAll(`.genre-${genre}`).transition().attr("r", 10);
        d3.selectAll(`.genre-${genre}`).transition().attr("fill", "gray");
      });
  });
};

do {
  cost = costPrev;
  costPrev = cost * 0.9 + 0.1 * model.step();

  solution = model.getSolution();

  drawSVG();
  await new Promise((resolve) => setTimeout(resolve, 0.1));
} while (Math.abs(cost - costPrev) > 1e-4);
