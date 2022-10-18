// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IFee {
    function fees(uint256 amount) external pure returns (uint256);
}
