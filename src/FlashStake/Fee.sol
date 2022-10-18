// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

//Contract that supplies the fee to charge per deposit
contract Fee {
    uint256 constant BASIS_POINTS = 10_000;
    uint256 constant fee = 100; //1%

    //This will eventually be based on demand
    function fees(uint256 amount) external pure returns (uint256) {
        return (amount * fee) / BASIS_POINTS;
    }
}
