// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {IFlashStake} from "../../interfaces/IFlashStake.sol";
import {ISNCFlash} from "../../interfaces/ISNCFlash.sol";

contract FSSonic {

    address private constant FlashStake =
        0x78b2d65dd1d3d9Fb2972d7Ef467261Ca101EC2B9;
    
    // temp hardcoding
    address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address private constant flashUSDCStrat =
        0x6e5eD1A5901E81F6bC008023d766454D831B6617;
    address private constant flashNFT =
        0x3b090839C26fE3b2BdfA2F4CD7F3ab001ccdF73F;
    address private constant USDC_FTokenAddress =
        0x32EA96F6f2985bD38e4dAC3bC08156198Bc2324d;
    uint256 private stakeDuration = 63072000; //2 years
    bool mint = true; //for stake

    address public immutable sncUSDC;
    address public immutable treasury;

    constructor(
        address _sncUSDC,
        address _treasury
    ) {
        sncUSDC = _sncUSDC;
        treasury = _treasury;
        IERC20(USDC).approve(treasury, 0);
        IERC20(USDC).approve(treasury, type(uint256).max);
    }

    //need a way for treasury to redeem a given NFT
    //no fees are taken here
    //fees come from deposit NFT

    struct Deposit {
        uint256 nftId; //this is the stakeId
        address strategyAddress; //determines underlying
        uint256 stakeStartTs; //prevents single block flash loan attacks
        uint256 stakeDuration; //very important. Determines when we can unlock
        uint256 stakedAmount; //most important
        uint256 fTokensToUser; //amount of tokens minted
    }

    mapping(uint256 => Deposit) public deposits;
    

    function _flashStake(uint256 amount, uint256 minimumReceived) internal {}


    function depositToReceiveSONICs(uint256 amount, uint256 minimumReceived)
        external
    {
        address sender = msg.sender;
        uint256 initialAmount = IERC20(USDC).balanceOf(address(this));
        IERC20(USDC).transferFrom(sender, address(this), amount);
        uint256 afterTransfer = IERC20(USDC).balanceOf(address(this));

         uint256 flashStakeAmount = afterTransfer - initialAmount;
        require(flashStakeAmount > 0, "Nothing Transfered");


        //create a local function that mimics flashStake
        //sends yield back in USDC

        //local flashStake 
        //send yield to the customer
        _flashStake(flashStakeAmount, minimumReceived);

    }
}
