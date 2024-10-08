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

let mode = "tsne";

// Fetch all required data
function fetchData() {
  return Promise.all([
    Promise.resolve(tsne_data),
    Promise.resolve(cluster_info),
    Promise.resolve(gsea_results),
    Promise.resolve(top10_markers),
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

// Generate GSEA info panel content
function generateGseaInfo(pathway) {
  const gseaPanel = document.getElementById("gsea-info-panel");
  const gseaInfo = gsea_results.find((result) => result.pathway === pathway);

  const content = `
    <div class="bg-white shadow-xl rounded-lg p-6">
      <h2 class="text-lg font-semibold mb-2">GSEA Info</h2>
      <p class="mb-2"><strong class="font-semibold">Pathway:</strong> ${
        gseaInfo.pathway
      }</p>
      <p class="mb-2"><strong class="font-semibold">P Value:</strong> ${gseaInfo.pval.toExponential(
        2
      )}</p>
      <p class="mb-2"><strong class="font-semibold">Leading Edge:</strong></p>
      <ul class="list-disc list-inside pl-4">
        ${gseaInfo.leadingEdge
          .map((gene) => `<li class="mb-1">${gene}</li>`)
          .join("")}
      </ul>
    </div>
  `;

  gseaPanel.innerHTML = content;
}

// Generate cluster info panel content
function generateClusterInfo(point) {
  const gseaPanelInfo = document.getElementById("gsea-info-panel");
  gseaPanelInfo.innerHTML = "";

  const clusterPanelInfo = document.getElementById("cluster-info-panel");
  const clusterInfo = cluster_info[point.cluster][0];

  const content = `
    <div class="bg-white shadow-md rounded-lg p-6">
      <h2 class="text-lg font-semibold mb-2 flex gap-2 items-center">
      <span>Cluster Info</span> 
       <div class="h-3 w-3 border" style="background-color: ${
         BASE_COLORS[point.cluster]
       }"></div>
      </h2>
      <p class="mb-2"><strong class="font-semibold">Top Pathways:</strong></p>
      <ul class="list-none pl-0">
        ${clusterInfo.top_pathways
          .map(
            (pathway) => `
          <li class="mb-2">
            <div class="flex items-center justify-between">
              <span class="mr-4 w-64 truncate" title="${pathway}">${pathway}</span>
              <button class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-1 px-2 rounded whitespace-nowrap" 
                      onClick="generateGseaInfo('${pathway}')">
                View Details
              </button>
            </div>
          </li>
        `
          )
          .join("")}
      </ul>
    </div>
  `;

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

    circle.on("mouseover", () => {
      // Highlight the selected cluster
      d3.selectAll(`.cluster-${point.cluster}`).attr("r", radius + 2);
    });

    circle.on("click", () => {
      generateClusterInfo(point);

      const clusterSelect = document.getElementById("top10-markers-select");

      clusterSelect.value = point.cluster;
    });

    circle.on("mouseout", () => {
      d3.selectAll(`.data-point`).attr("r", radius);
    });
  });
}

// Draw centroids on the SVG
function drawCentroids(svg, clusterInfo, X, Y) {
  Object.keys(clusterInfo).forEach((cluster) => {
    const info = clusterInfo[cluster][0];
    const color = BASE_COLORS[parseInt(cluster)];

    // Create an X for the center point
    svg
      .append("line")
      .attr("x1", X(info.centroid_x) - 5)
      .attr("y1", Y(info.centroid_y) - 5)
      .attr("x2", X(info.centroid_x) + 5)
      .attr("y2", Y(info.centroid_y) + 5)
      .attr("stroke", color)
      .attr("stroke-width", 2);

    svg
      .append("line")
      .attr("x1", X(info.centroid_x) + 5)
      .attr("y1", Y(info.centroid_y) - 5)
      .attr("x2", X(info.centroid_x) - 5)
      .attr("y2", Y(info.centroid_y) + 5)
      .attr("stroke", color)
      .attr("stroke-width", 2);
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

function drawTop10MarkersHeatmap(data) {
  const container = document.getElementById("top10-markers-heatmap");

  if (!container) {
    throw new Error("top10-markers-heatmap element not found");
  }

  const clusters = [...new Set(data.map((d) => d.cluster))];
  const genes = [...new Set(data.map((d) => d.gene))];

  // Check which genes appear in more than one cluster
  const geneCounts = genes.reduce((acc, gene) => {
    acc[gene] = data.filter((d) => d.gene === gene).length;
    return acc;
  }, {});

  const filteredGenes = genes.filter((gene) => geneCounts[gene] > 1);

  // Create a 2D array to store the avg_logFC values for each gene in each cluster
  const reshapedData = [];

  for (let i = 0; i < clusters.length; i++) {
    reshapedData.push({
      name: `Cluster ${i}`,
      data: [],
    });
  }

  for (let i = 0; i < filteredGenes.length; i++) {
    const gene = filteredGenes[i];
    const geneData = data.filter((d) => d.gene === gene);

    for (let j = 0; j < clusters.length; j++) {
      const clusterData = geneData.filter((d) => d.cluster === clusters[j]);
      const avgLogFC = d3.mean(clusterData, (d) => d.avg_log2FC);
      reshapedData[j].data.push(avgLogFC || 0.0);
    }
  }

  const options = {
    series: reshapedData,
    chart: {
      type: "heatmap",
      height: 350,
    },
    xaxis: {
      categories: filteredGenes,
      title: {
        text: "Gene",
      },
    },
  };

  var chart = new ApexCharts(container, options);
  chart.render();
}

function drawTop10Markers(data) {
  const container = document.getElementById("top10-markers");
  if (!container) {
    throw new Error("top10-markers element not found");
  }

  drawTop10MarkersHeatmap(data);
}

function drawTop10AverageExpression(cluster) {
  const data = top10_markers;

  const filteredData = data.filter((d) => d.cluster === cluster);

  const container = document.getElementById("top10-markers-avg-expression");

  if (!container) {
    throw new Error("top10-markers-avg-expression element not found");
  }

  container.innerHTML = "";

  const options = {
    series: [
      {
        name: "avg_logFC",
        data: filteredData.map((d) => d.avg_log2FC),
      },
    ],
    chart: {
      type: "bar",
      height: 350,
      width: 600,
    },
    plotOptions: {
      bar: {
        borderRadius: 4,
        borderRadiusApplication: "end",
        horizontal: true,
      },
    },
    xaxis: {
      categories: filteredData.map((d) => d.gene),
      title: {
        text: "avg_logFC",
      },
    },
    yaxis: {
      title: {
        text: "Gene",
      },
    },
    title: {
      text: "Average expression of top marker genes in cluster",
      align: "left",
      size: 10,
    },
  };

  var chart = new ApexCharts(container, options);
  chart.render();
}

// Main execution function
async function main() {
  try {
    const [tsneData, clusterInfo, gseaResults] = await fetchData();
    if (!tsneData || tsneData.length === 0) {
      throw new Error("No data received or empty data set");
    }

    drawSVG(tsneData, clusterInfo);

    const clusterSelect = document.getElementById("top10-markers-select");

    const clusterOptions = Object.keys(clusterInfo).map((cluster) => {
      return `<option value="${cluster}">Cluster ${
        parseInt(cluster) + 1
      }</option>`;
    });

    clusterSelect.innerHTML = clusterOptions.join("");
    clusterSelect.addEventListener("change", (e) => {
      const cluster = e.target.value;
      drawTop10AverageExpression(cluster);
    });

    const modeSwitch = document.getElementById("mode-select");
    const modeSpan = document.getElementById("mode-span");

    modeSwitch.addEventListener("change", (e) => {
      mode = e.target.value;
      if (mode === "tsne") {
        modeSpan.innerHTML = "t-SNE";
        document.getElementById("top10-markers").style.display = "block";

        drawTop10Markers(top10_markers);
        drawTop10AverageExpression("0");
      } else {
        modeSpan.innerHTML = "UMAP";
        document.getElementById("top10-markers").style.display = "none";
      }
    });

    drawTop10Markers(top10_markers);
    drawTop10AverageExpression("0");

    console.log("Visualization completed successfully");
  } catch (error) {
    console.error("An error occurred in main execution:", error);
    document.getElementById("chart").innerHTML = `
      <p class="text-red-500 font-bold">Error: ${error.message}</p>
    `;
  }
}

// Run the main function when the page loads
window.onload = main;
