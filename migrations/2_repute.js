const Repute = artifacts.require('./Repute.sol')

module.exports = function(deployer) {
    deployer.deploy(
        Repute
    );
}