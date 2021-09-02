const { exec } = require("child_process");

/**
 * Executes shell command
 * @param {shell command} cmd
 */
const execute = (cmd) => {
  exec(cmd, (error, data, out) => {
    if (error) {
      console.log("error: ", error.message);
    }
    if (out) {
      console.log("output: ", out);
    }
    console.log("data: ", data);
  });
};

/**
 * Invokes etl-test-build shell script
 *
 * Creates location directive for the specified ETL job(branch-name)
 * Modifies nginx configurations and reverse proxy - adds location directive
 * for the created ETL nomad job
 * @param {branch-name} branch
 */
exports.deployEtlTestBuild = (branch) => {
  const target = `${process.env.ROOT_DIR}nginx/conf.d`;
  execute(
    `chmod +x ${process.env.AMPATH_DEVOPS}scripts && sh ${process.env.AMPATH_DEVOPS}scripts/etl-test-build.sh ${branch} ${target}`
  );
};

/**
 * Invokes poc-test-build shell script
 * Modifies nginx configurations to add new test-build url
 * @param {branch-name} branch
 */
exports.deployPOCTestBuild = (branch) => {
  const target = `${process.env.ROOT_DIR}nginx/conf.d`;
  execute(
    `chmod +x ${process.env.AMPATH_DEVOPS}scripts && sh ${process.env.AMPATH_DEVOPS}scripts/poc-test-build.sh ${branch} ${target}`
  );
};

/**
 * Invokes levant-deploy script which;
 * spins up new nomad ETL job
 * @param {branch-name} branch
 */
exports.levantDeploy = (branch) => {
  execute(
    `chmod +x ${process.env.AMPATH_DEVOPS}scripts && sh ${process.env.AMPATH_DEVOPS}scripts/levant-deploy.sh ${branch}`
  );
};

exports.levantPlan = async function levantPlan(branch, job_spec) {
  const name = await exec(getLevantCommand(branch, "plan", job_spec));

  return {
    pid: name.pid,
    connected: name.connected,
    killed: name.killed,
    err: name.stderr,
    in: name.stdin,
    out: name.stdout,
  };
};

/**
 *
 * @param {branch name} branch
 * @param {the command} command plan or deploy
 * @param {nomad job specification template path} job_spec
 * @returns Levant deploy or plan command
 */
const getLevantCommand = (branch, command, job_spec) => {
  return (
    './levant "' +
    command +
    '" -address="' +
    nomadAddress +
    '" -var "job_name=' +
    branch +
    '" templates/"' +
    job_spec +
    '" -vault-token= "' +
    vaultSecret +
    '"'
  );
};
