// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract ContractTest is Test {
    using stdStorage for StdStorage;

    Utilities internal utils;
    address payable[] internal users;

    address payable public alice;
    // address payable public bob;
    // address payable public charlie;
    // address payable public henry;

    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    function setUp() public {
        utils = new Utilities();
        users = utils.createUsers(5);
        alice = users[0];

        //vm.deal(address(alice), 1_000_000_000 ether);
        //writeTokenBalanceERC20(address(alice), address(DAI), 200 ether);
    }

    function writeTokenBalanceERC20(
        address who,
        address token,
        uint256 amt
    ) internal {
        stdstore
            .target(token)
            .sig(IERC20(token).balanceOf.selector)
            .with_key(who)
            .checked_write(amt);
    }

    //This works! Now I'm able to assign NFTs like ERC20s
    function writeTokenBalance721(
        address who,
        address token,
        uint256 amt
    ) internal {
        stdstore
            .target(token)
            .sig(IERC721(token).balanceOf.selector)
            .with_key(who)
            .checked_write(amt);
    }
}
