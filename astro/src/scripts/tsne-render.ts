import * as d3 from "d3";
import { faker } from "@faker-js/faker";
import DATA_JSON from "../data/tsne_data.json";

const dataJson = DATA_JSON;

const baseColors = [
  "#FF0000",
  "#00FF00",
  "#0000FF",
  "#FFFF00",
  "#FF00FF",
  "#00FFFF",
  "#800000",
  "#008000",
  "#000080",
  "#808000",
  "#800080",
  "#008080",
  "#FFA500",
  "#FFC0CB",
  "#A52A2A",
  "#DDA0DD",
  "#20B2AA",
  "#B8860B",
];

const drawSVG = () => {
  const container = document.getElementById("chart");

  if (!container) {
    throw new Error("chart element not found");
  }

  const containerWidth = container.offsetWidth;

  const margin = { bottom: 40, left: 40, right: 40, top: 40 };
  const width = containerWidth - margin.left - margin.right;
  const height = 1000 - margin.top - margin.bottom;

  container.innerHTML = "";

  const svg = d3
    .select(container)
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", `translate(${margin.left}, ${margin.top})`);

  const xExtent = d3.extent(dataJson, (d: any) => d.tSNE_1) as [number, number];
  const yExtent = d3.extent(dataJson, (d: any) => d.tSNE_2) as [number, number];

  const X = d3
    .scaleLinear()
    .domain(xExtent)
    .range([20, width - 20]);

  const Y = d3
    .scaleLinear()
    .domain(yExtent)
    .range([20, height - 20]);

  const radius = 3;

  dataJson.forEach((point: any, i: number) => {
    svg
      .append("circle")
      .attr("id", `circle-${i}`)
      .attr("class", `cursor-pointer cluster-${point.cluster}`)
      .attr("cx", X(point.tSNE_1))
      .attr("cy", Y(point.tSNE_2))
      .attr("r", radius)
      .attr("fill", baseColors[parseInt(point.cluster)])
      .attr("stroke", "black")
      .attr("stroke-width", 0.5)
      .on("click", () => {
        console.log(point);
      })
      .on("mouseover", () => {
        d3.selectAll(`.cluster-${point.cluster}`)
          .transition()
          .attr("r", radius + 2);
      })
      .on("mouseout", () => {
        d3.selectAll(`.cluster-${point.cluster}`)
          .transition()
          .attr("r", radius);
      });
  });
};

// Call the drawSVG function to render the graph
drawSVG();
