let mainAddress = "0xAA019896bbFD00ba44265Fa6fe81aADCB24afc41";
let parseEther = require("ethers").utils.parseEther;
let underlyingAddress = "0x99cdc7ca99e84Bc18Fb0Eb4f42E4409f2Dda2780";

const config = {
    initialExchangeRateMantissa: parseEther('2'),
    liquidationIncentiveMantisa: parseEther('1.08'),
    closeFactorMantisa: parseEther('0.8'),
    compSpeed: parseEther('0'), //0 to not drip
};


const Token = artifacts.require("./Governance/Mara.sol");
const Unitroller = artifacts.require("./Unitroller.sol");
const Comptroller = artifacts.require("./Comptroller.sol");
const WhitePaperInterestRateModel = artifacts.require("./WhitePaperInterestRateModel.sol");
const SimplePriceOracle = artifacts.require("./SimplePriceOracle.sol");
const LErc20Delegate = artifacts.require("./AErc20Delegate.sol");
const LErc20Delegator = artifacts.require("./AErc20Delegator.sol");
const LErc20Immutable = artifacts.require("./AErc20Immutable.sol");
// const Erc20 = artifacts.require("./ERC20.sol");
module.exports = async function (deployer) {
    //step1: 部署代币
    // deployer.deploy(Erc20Token, mainAddress);
    let cTokenAddress = "0x7901974ce90B609202761437f3A8488eBF3cEA76"

    //STEP2: 部署 unitroller
    // deployer.deploy(Unitroller);
    let UnitrollerAddress = "0xD9973756943391E5ed3D31bBfAD06059d400422d";

    /*
    * 部署comptroller修改代码 最后代币地址
    */
    //STEP3: 部署 Comptroller
    deployer.deploy(Comptroller);
    let ComptrollerAddress = "0x3f4F6F66a253f5E11b822E519fde386602A5F1A4";

    //step4: 部署SimplePriceOracle
    // deployer.deploy(SimplePriceOracle, "LCC");
    let SimplePriceOracleAddress = "0xeE859Cdb7845f996c5A03F266D6335BE09e8799f";

    //STEP5：部署WhitePaperInterestRateModel
    // deployer.deploy(WhitePaperInterestRateModel, parseEther('0.02'), parseEther('0.3'))
    let WhitePaperInterestRateModelAddress = "0x2Ef207903CE94A6bcDD31e74B66905c48FA3CC5E";

    //step6: 部署LErc20Delegate
    // deployer.deploy(LErc20Delegate);
    let LErc20DelegateAddress = "0x60DF58E7F2d333a4bf200d4645FC278bC43AAcCe";
    //备注：0xC8D3ec53fc8901C2431c7d14D05d0943e8dFC51f

    /*
    * Important!!!
    * 1.unitroller先执行_setPendingImplementation方法,允许与comptroller地址关联
    * 2.comptroller执行_become方法,关联上unitroller地址
    */

    //STEP7: 部署主市场
    // deployer.deploy(LErc20Delegator, "0x91431bE3d3A17646D5dabea84AB7261edb95839C", UnitrollerAddress, WhitePaperInterestRateModelAddress, parseEther('5'), "LDD", "LDD", 18, mainAddress, "0xC8D3ec53fc8901C2431c7d14D05d0943e8dFC51f", "0x")
    let LErc20DelegatorAddress = "0x8701C49AA6312bd52F5813994fC211B05DA9Bd95";
    //备注：0xC84d43399664007de1bBBA059c410c8C1C89A214

    //STEP8: 部署主市场
    // deployer.deploy(LErc20Immutable, TokenAddress, UnitrollerAddress, WhitePaperInterestRateModelAddress, parseEther('2'), "LCC", "LCC", 18, mainAddress, LErc20DelegateAddress)
    let LErc20ImmutableAddress = "";
};