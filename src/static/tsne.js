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

// Use the global variables
// function fetchData() {
//   return Promise.resolve(tsne_data_json);
// }

function fetchData() {
  return Promise.all([
    Promise.resolve(tsne_data_json),
    Promise.resolve(cluster_info_json),
    Promise.resolve(gsea_results_json),
  ]);
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

// function generateSidePanel(point) {
//   const sidePanel = document.getElementById("side-panel");

//   // Get the cluster info for the point
//   const clusterInfo = cluster_info_json[point.cluster][0];
//   let cellInfo = null;

//   for (const cluster in integrated_tsne_gsea_json) {
//     const cell = integrated_tsne_gsea_json[cluster].find(
//       (cell) => cell.cell_id === point.cell_id
//     );
//     if (cell) {
//       cellInfo = cell;
//       break;
//     }
//   }

//   console.log(cellInfo);

//   // Create the HTML content for the side panel
//   const content = `
//     <h2>Cluster Info</h2>
//     <p><strong>Top Pathways:</strong></p>
//     <ul class='list-disc list-inside'>
//       ${clusterInfo.top_pathways
//         .map((pathway) => `<li class='ml-2'>${pathway}</li>`)
//         .join("")}
//     </ul>
//     <hr />
//     <h2>Point Info</h2>
//     <p><strong>Top Pathways:</strong></p>
//     <ul class='list-disc list-inside'>
//     ${cellInfo.top_pathways
//       .map((pathway) => `<li class='ml-2'>${pathway}</li>`)
//       .join("")}
//     </ul>

//   `;

//   // Set the content of the side panel
//   sidePanel.innerHTML = content;
// }

function generateGseaInfo(pathway) {
  const gseaPanel = document.getElementById("gsea-info-panel");

  const gseaInfo = gsea_results_json.find(
    (result) => result.pathway === pathway
  );

  const content = `
    <h2>GSEA Info</h2>
    <p><strong>Pathway:</strong> ${gseaInfo.pathway}</p>
    <p><strong>P Value:</strong> ${gseaInfo.pval}</p>
    <p><strong>Leading Edge:</strong></p>
    <ul class='list-disc list-inside'>
      ${gseaInfo.leadingEdge
        .map((gene) => `<li class='ml-2'>${gene}</li>`)
        .join("")}
    </ul>
  `;

  gseaPanel.innerHTML = content;
}

function generateClusterInfo(point) {
  // Clear the gsae info panel
  const gseaPanelInfo = document.getElementById("gsea-info-panel");
  gseaPanelInfo.innerHTML = "";

  const clusterPanelInfo = document.getElementById("cluster-info-panel");

  // Get the cluster info for the point
  const clusterInfo = cluster_info_json[point.cluster][0];

  // Create the HTML content for the side panel
  const content = `
    <h2>Cluster Info</h2>
    <p><strong>Top Pathways:</strong></p>
    <ul class='list-disc list-inside'>
      ${clusterInfo.top_pathways
        .map(
          (pathway) => `<li class='ml-2'>${pathway} 
        <button class="bg-slate-100 border p-1" onClick="generateGseaInfo('${pathway}')">
          View Details
        </button>
        </li>`
        )
        .join("")}
    </ul>
  `;

  // Set the content of the side panel
  clusterPanelInfo.innerHTML = content;
}

// Draw data points on the SVG
function drawDataPoints(svg, data, X, Y) {
  const radius = 3;

  data.forEach((point, i) => {
    const circle = svg
      .append("circle")
      .attr("id", `circle-${i}`)
      .attr("class", `cursor-pointer cluster-${point.cluster} data-point`)
      .attr("cx", X(point.tSNE_1))
      .attr("cy", Y(point.tSNE_2))
      .attr("r", radius)
      .attr("fill", BASE_COLORS[parseInt(point.cluster)])
      .attr("stroke", "black")
      .attr("stroke-width", 0.5);

    circle.on("click", () => console.log(point));
    circle.on("mouseover", () => {
      // Gray out all points
      d3.selectAll(".data-point").transition().attr("fill", "ghostwhite");

      // Highlight the selected cluster
      d3.selectAll(`.cluster-${point.cluster}`)
        .transition()
        .attr("fill", BASE_COLORS[parseInt(point.cluster)]);

      // Highlight the cluster points
      d3.selectAll(`.cluster-${point.cluster}`)
        .transition()
        .attr("r", radius + 2);
    });

    circle.on("click", () => {
      console.log(point);

      // Fill the side panel with the data
      generateClusterInfo(point);
    });

    circle.on("mouseout", () => {
      // Reset the color of all points
      for (let i = 0; i < BASE_COLORS.length; i++) {
        d3.selectAll(`.cluster-${i}`).transition().attr("fill", BASE_COLORS[i]);
      }

      d3.selectAll(`.cluster-${point.cluster}`).transition().attr("r", radius);
    });
  });
}

// Draw centroids on the SVG
function drawCentroids(svg, clusterInfo, X, Y) {
  Object.keys(clusterInfo).forEach((cluster) => {
    const info = clusterInfo[cluster][0];

    // Create an x for the center point
    svg
      .append("line")
      .attr("x1", X(info.centroid_x) - 5)
      .attr("y1", Y(info.centroid_y) - 5)
      .attr("x2", X(info.centroid_x) + 5)
      .attr("y2", Y(info.centroid_y) + 5)
      .attr("stroke", "black")
      .attr("stroke-width", 2)
      .attr("stroke", BASE_COLORS[parseInt(cluster)]);

    svg
      .append("line")
      .attr("x1", X(info.centroid_x) + 5)
      .attr("y1", Y(info.centroid_y) - 5)
      .attr("x2", X(info.centroid_x) - 5)
      .attr("y2", Y(info.centroid_y) + 5)
      .attr("stroke", "black")
      .attr("stroke-width", 2)
      .attr("stroke", BASE_COLORS[parseInt(cluster)]);

    // centroid.on("click", () => console.log(info));
  });
}

// Main function to draw the SVG chart
function drawSVG(data, clusterInfo) {
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
  drawCentroids(svg, clusterInfo, scales.X, scales.Y);
}

// Main execution function
async function main() {
  try {
    const data = await fetchData();
    if (!data || data.length === 0) {
      throw new Error("No data received or empty data set");
    }
    drawSVG(data[0], data[1]);
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
