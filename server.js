"use strict";

const Hapi = require("@hapi/hapi");
const {
  levantPlan,
  levantDeploy,
  deployEtlTestBuild,
  deployPOCTestBuild,
} = require("./source/deployer_service");

const routes = [
  {
    method: "GET",
    path: "/",
    handler: (req, res) => {
      return "<h2> 🤫 \n Nomad Levant Deployer Service <h2>";
    },
  },
  {
    method: "GET",
    path: "/levant/deploy",
    handler: (req, res) => {
      levantDeploy(req.query.branch, "etl.nomad");
      return "Deploying " + req.query.branch;
    },
  },
  {
    method: "GET",
    path: "/levant/plan",
    handler: (req, res) => {
      return levantPlan(req.query.branch, "etl.nomad");
    },
  },
  {
    method: "GET",
    path: "/etl",
    handler: async (req, res) => {
      deployEtlTestBuild(req.query.branch);
      return req.query.branch + " ETL nginx config created.";
    },
  },
  {
    method: "GET",
    path: "/poc",
    handler: async (req, res) => {
      deployPOCTestBuild(req.query.branch);
      return req.query.branch + " POC nginx config created.";
    },
  },
  {
    method: "POST",
    path: "/sync/importmap",
    handler: async (req, res) => {
      return syncImportMaps(req.query.prefix, req.query.upstream);
    },
  },
];

const init = async () => {
  const server = Hapi.server({
    port: 3030,
    host: "0.0.0.0",
  });

  //Register custom logging
  server.events.on("response", function (request) {
    console.log(
      "✅  " +
        request.info.remoteAddress +
        ": " +
        request.method.toUpperCase() +
        " " +
        request.path +
        " " +
        request.response.statusCode
    );
  });

  //Register routes
  server.route(routes);

  await server.start();
  console.log("Server running on %s", server.info.uri);
};

process.on("unhandledRejection", (err) => {
  console.log(err);
  process.exit(1);
});

init();
