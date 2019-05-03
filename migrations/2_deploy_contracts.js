//const ConvertLib = artifacts.require("ConvertLib");
const Crowdsale = artifacts.require("Crowdsale");
const DiamondBackToken = artifacts.require("DiamondBackToken");

module.exports = function(deployer) {
  deployer.deploy(Crowdsale);
  //deployer.deploy(ConvertLib);
  deployer.link(Crowdsale, DiamondBackToken);
};
