// Migrations.sol 파일을 가져와서 바이트 코드 추출 후 deploy에 배포
const Migrations = artifacts.require("Migrations");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};
