// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//Owned by FSSonic
contract sncUSDC is ERC20("Sonic USDC", "sncUSDC"), Ownable {

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    //is this function necessary? v2
    function burn(address to, uint256 amount) external onlyOwner {
        _burn(to, amount);
    }
}
