// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//Owned by FSSonic
contract sncFlash is ERC20, Ownable {
    constructor() ERC20("Sonic USDC", "sncFlash") {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    //is this function necessary?
    function burn(address to, uint256 amount) external onlyOwner {
        _burn(to, amount);
    }
}
