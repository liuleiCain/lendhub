pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;

import "../LErc20.sol";
import "../CToken.sol";
import "../PriceOracle.sol";
import "../EIP20Interface.sol";
import "../Governance/LendHub.sol";
import "../SimplePriceOracle.sol";

interface ComptrollerLensInterface {

    function compSpeeds(address) external view returns (uint);

    function compSupplyState(address) external view returns (uint224, uint32);

    function compBorrowState(address) external view returns (uint224, uint32);

    function compSupplierIndex(address, address) external view returns (uint);

    function compBorrowerIndex(address, address) external view returns (uint);

    function markets(address) external view returns (bool, uint);

    function oracle() external view returns (PriceOracle);

    function getAccountLiquidity(address) external view returns (uint, uint, uint);

    function getAssetsIn(address) external view returns (CToken[] memory);

    function claimComp(address) external;

    function compAccrued(address) external view returns (uint);

    function getCompAddress() external view returns (address);
}

contract LendHubLensLHB is ExponentialNoError {
    uint224 public constant compInitialIndex = 1e36;

    struct CTokenLHBData {
        address cToken;
        uint supplyLHBAPY;
        uint borrowLHBAPY;
    }

    struct CompMarketState {
        /// @notice The market's last updated compBorrowIndex or compSupplyIndex
        uint224 index;

        /// @notice The block number the index was last updated at
        uint32 block;
    }

    function cTokenLHBMetadata(CToken cToken) public view returns (CTokenLHBData memory) {
        ComptrollerLensInterface comptroller = ComptrollerLensInterface(address(cToken.comptroller()));
        uint speed = comptroller.compSpeeds(address(cToken));
        SimplePriceOracle priceOracle = SimplePriceOracle(address(comptroller.oracle()));
        uint lhbPrice = priceOracle.assetPrices(comptroller.getCompAddress());
        // 24位小数
        uint exchangeRateCurrent = cToken.exchangeRateStored();
        uint totalPrice = cToken.totalSupply() * exchangeRateCurrent * priceOracle.getUnderlyingPrice(cToken);
        uint supplyAPY = 1000000000000000000 * 1000000 * 10512000 * speed * lhbPrice / totalPrice;
        uint totalBorrowPrice = cToken.totalBorrows() * priceOracle.getUnderlyingPrice(cToken);
        uint borrowLHBAPY = 1000000 * 10512000 * speed * lhbPrice / totalBorrowPrice;

        return CTokenLHBData({
        cToken : address(cToken),
        supplyLHBAPY : supplyAPY,
        borrowLHBAPY : borrowLHBAPY
        });
    }

    function calcLHBAPYs(CToken[] memory cTokens) public view returns (CTokenLHBData[] memory)  {
        uint cTokenCount = cTokens.length;
        CTokenLHBData[] memory res = new CTokenLHBData[](cTokenCount);

        for (uint i = 0; i < cTokenCount; i++) {
            CToken cToken = cTokens[i];
            res[i] = cTokenLHBMetadata(cToken);
        }
        return res;
    }

    function getAccountBorrowAccrued(address account, CToken cToken) internal view returns (uint){
        ComptrollerLensInterface comptroller = ComptrollerLensInterface(address(cToken.comptroller()));
        CTokenInterface cTokenInterface = CTokenInterface(address(cToken));
        uint compBorrowerIndex = 0;
        uint224 borrowStateIndex;

        Exp memory marketBorrowIndex = Exp({mantissa : cToken.borrowIndex()});
        if (compBorrowerIndex == 0) {
            compBorrowerIndex = comptroller.compBorrowerIndex(address(cToken), account);
        }
        (borrowStateIndex,) = comptroller.compBorrowState(address(cToken));
        Double memory borrowIndex = Double({mantissa : borrowStateIndex});
        Double memory borrowerIndex = Double({mantissa : compBorrowerIndex});
        compBorrowerIndex = borrowIndex.mantissa;

        if (borrowerIndex.mantissa > 0) {
            Double memory deltaIndex = sub_(borrowIndex, borrowerIndex);
            uint borrowerAmount = div_(cTokenInterface.borrowBalanceStored(account), marketBorrowIndex);
            uint borrowerDelta = mul_(borrowerAmount, deltaIndex);
            return borrowerDelta;
        }
        return 0;
    }

    function getAccountSupplyAccrued(address account, CToken cToken) internal view returns (uint){
        ComptrollerLensInterface comptroller = ComptrollerLensInterface(address(cToken.comptroller()));
        CTokenInterface cTokenInterface = CTokenInterface(address(cToken));
        uint compSupplierIndex = 0;
        uint224 supplyStateIndex;

        if (compSupplierIndex == 0) {
            compSupplierIndex = comptroller.compSupplierIndex(address(cToken), account);
        }
        (supplyStateIndex,) = comptroller.compSupplyState(address(cToken));
        Double memory supplyIndex = Double({mantissa : supplyStateIndex});
        Double memory supplierIndex = Double({mantissa : compSupplierIndex});
        compSupplierIndex = supplyIndex.mantissa;

        if (supplierIndex.mantissa == 0 && supplyIndex.mantissa > 0) {
            supplierIndex.mantissa = compInitialIndex;
        }

        Double memory deltaIndex = sub_(supplyIndex, supplierIndex);
        uint supplierTokens = cTokenInterface.balanceOf(account);
        uint supplierDelta = mul_(supplierTokens, deltaIndex);
        return supplierDelta;
    }

    function calAccountAccrued(address account, CToken cToken) public view returns (uint){
        uint sum = 0;
        sum = sum + getAccountBorrowAccrued(account, cToken);
        sum = sum + getAccountSupplyAccrued(account, cToken);
        return sum;
    }

    function calcAccountAllAccrued(address account, CToken[] memory cTokens) public view returns (uint){
        uint res = 0;
        for (uint i = 0; i < cTokens.length; i++) {
            CToken cToken = cTokens[i];
            res = res + calAccountAccrued(account, cToken);
        }
        return res;
    }
}
