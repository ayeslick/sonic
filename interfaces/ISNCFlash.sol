// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface ISNCFlash {
    function mint(address to, uint256 amount) external;

    function burn(address to, uint256 amount) external;
}
