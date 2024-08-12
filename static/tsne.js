// Constants
const BASE_COLORS = [
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

const MARGIN = { bottom: 40, left: 40, right: 40, top: 40 };
const HEIGHT = 1000 - MARGIN.top - MARGIN.bottom;

// Use the global tsneData variable
function fetchData() {
  return Promise.resolve(tsneData);
}

// Create SVG element and return the selection
function createSVG(container, width, height) {
  return d3
    .select(container)
    .append("svg")
    .attr("width", width + MARGIN.left + MARGIN.right)
    .attr("height", height + MARGIN.top + MARGIN.bottom)
    .append("g")
    .attr("transform", `translate(${MARGIN.left}, ${MARGIN.top})`);
}

// Create scales for X and Y axes
function createScales(data, width, height) {
  const xExtent = d3.extent(data, (d) => d.tSNE_1);
  const yExtent = d3.extent(data, (d) => d.tSNE_2);

  const X = d3
    .scaleLinear()
    .domain(xExtent)
    .range([20, width - 20]);

  const Y = d3
    .scaleLinear()
    .domain(yExtent)
    .range([20, height - 20]);

  return { X, Y };
}

// Draw data points on the SVG
function drawDataPoints(svg, data, X, Y) {
  const radius = 3;

  data.forEach((point, i) => {
    const circle = svg
      .append("circle")
      .attr("id", `circle-${i}`)
      .attr("class", `cursor-pointer cluster-${point.cluster}`)
      .attr("cx", X(point.tSNE_1))
      .attr("cy", Y(point.tSNE_2))
      .attr("r", radius)
      .attr("fill", BASE_COLORS[parseInt(point.cluster)])
      .attr("stroke", "black")
      .attr("stroke-width", 0.5);

    circle.on("click", () => console.log(point));
    circle.on("mouseover", () => highlightCluster(point.cluster, radius + 2));
    circle.on("mouseout", () => highlightCluster(point.cluster, radius));
  });
}

// Highlight or un-highlight clusters
function highlightCluster(cluster, radius) {
  d3.selectAll(`.cluster-${cluster}`).transition().attr("r", radius);
}

// Main function to draw the SVG chart
function drawSVG(data) {
  const container = document.getElementById("chart");
  if (!container) {
    throw new Error("chart element not found");
  }

  container.innerHTML = "";
  const containerWidth = container.offsetWidth;
  const width = containerWidth - MARGIN.left - MARGIN.right;

  const svg = createSVG(container, width, HEIGHT);
  const scales = createScales(data, width, HEIGHT);
  drawDataPoints(svg, data, scales.X, scales.Y);
}

// Main execution function
async function main() {
  try {
    const data = await fetchData();
    if (!data || data.length === 0) {
      throw new Error("No data received or empty data set");
    }
    drawSVG(data);
    console.log("Visualization completed successfully");
  } catch (error) {
    console.error("An error occurred in main execution:", error);
    document.getElementById(
      "chart"
    ).innerHTML = `<p>Error: ${error.message}</p>`;
  }
}

// Run the main function when the page loads
window.onload = main;
