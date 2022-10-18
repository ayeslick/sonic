// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {IFee} from "../../interfaces/IFee.sol";
import {IFlashStake} from "../../interfaces/IFlashStake.sol";
import {ISNCFlash} from "../../interfaces/ISNCFlash.sol";

contract FSSonic {
    address private constant FlashStake =
        0x78b2d65dd1d3d9Fb2972d7Ef467261Ca101EC2B9;
    address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address private constant flashUSDCStrat =
        0x6e5eD1A5901E81F6bC008023d766454D831B6617;
    address private constant flashNFT =
        0x3b090839C26fE3b2BdfA2F4CD7F3ab001ccdF73F;
    // address private constant USDC_FTokenAddress =
    //     0x32EA96F6f2985bD38e4dAC3bC08156198Bc2324d;
    uint256 private stakeDuration = 63072000; //2 years
    bool mint = true;

    address public immutable feeAddress;
    address public immutable sncFlash;
    address public immutable treasury;

    constructor(
        address _feeAddress,
        address _sncFlash,
        address _treasury
    ) {
        feeAddress = _feeAddress;
        sncFlash = _sncFlash;
        treasury = _treasury;
    }

    struct Deposit {
        uint256 nftId; //this is the stakeId
        address strategyAddress; //determines underlying
        // uint256 stakeStartTs; //prevents single block flash loan attacks
        uint256 stakeDuration; //very important. Determines when we can unlock
        uint256 stakedAmount; //most important
        //uint256 fTokensToUser; //amount of tokens minted
    }

    mapping(uint256 => Deposit) public deposits;

    //Customers will have to transfer their FlashNFTs here instead
    //We will know the stakeId because it matches their NFTID
    //make sure to save this in a struct or mapping
    //use the one view function to gain access to the stake mapping
    //do this after checking that msg.sender is the current owner of FlashNFT

    function depositFlashNFTForsncFlash(uint256 id) external {
        address sender = msg.sender;

        address currentOwner = IERC721(flashNFT).ownerOf(id);
        require(currentOwner == sender, "Not Current Owner");

        //wrap this is a try statement to catch potenital errors - production
        IFlashStake.StakeStruct memory stake = IFlashStake(FlashStake)
            .getStakeInfo(id, true);

        //use errors intead of require
        require(stake.nftId == id, "Mismatched IDs");
        require(stake.active == true, "flashNFT is inactive");
        require(
            stake.totalFTokenBurned == 0 && stake.totalStakedWithdrawn == 0,
            "Cannot use due to previous withdraw"
        );
        require(
            stake.strategyAddress == flashUSDCStrat,
            "Strategy not accepted here"
        );
        require(
            stake.stakeStartTs < block.timestamp,
            "Created in the same block"
        );

        deposits[stake.nftId] = Deposit({
            nftId: stake.nftId,
            strategyAddress: stake.strategyAddress,
            stakeDuration: stake.stakeDuration,
            stakedAmount: stake.stakedAmount
        });

        uint256 stakedAmount = stake.stakedAmount;
        uint256 fee = IFee(feeAddress).fees(stakedAmount); //1% fee
        uint256 mintAmountForTreasury = fee / 2;

        uint256 sendersAmount = stakedAmount - fee;

        //mint to treasury then sender
        ISNCFlash(sncFlash).mint(treasury, mintAmountForTreasury);
        ISNCFlash(sncFlash).mint(sender, sendersAmount);

        //approve then transfer fee & flashNFT from sender to treasury
        IERC20(USDC).approve(treasury, 0);
        IERC20(USDC).approve(treasury, type(uint256).max);

        IERC20(USDC).transferFrom(sender, treasury, fee);
        IERC721(flashNFT).transferFrom(sender, treasury, id);
    }

    //have a function to rescue tokens into the treasury?
    //implement function to accept 721s?

    //
    //cant use this because nftIdMappingsToStakeIds, stakeCount, and stakes
    //are set to private meaning I cannot access them.
    //None of the functions returns the stakeId so I cannot call the one view function
    //because I dont know my stakeId.
    //A solution to finding my stakeIds is real hacky.
    //Just accept FlashNFTs
    // function depositToReceiveSonic(uint256 amount, uint256 minimumReceived)
    //     external
    // {
    //     address sender = msg.sender;
    //     uint256 initialAmount = IERC20(USDC).balanceOf(address(this));
    //     IERC20(USDC).transferFrom(sender, address(this), amount);
    //     uint256 afterTransfer = IERC20(USDC).balanceOf(address(this));

    //     uint256 beforeFees = afterTransfer - initialAmount;
    //     require(beforeFees > 0, "Nothing Transfered");

    //     //fees in USDC
    //     uint256 preStakeFee = IFee(feeAddress).fees(beforeFees); //1% fee

    //     uint256 flashStakeAmount = beforeFees - preStakeFee;

    //     //sends yield back in USDC
    //     IFlashStake(FlashStake).flashStake(
    //         flashUSDCStrat,
    //         flashStakeAmount,
    //         stakeDuration,
    //         minimumReceived,
    //         address(this),
    //         mint
    //     );

    //     uint256 amountRecieved = IERC20(USDC).balanceOf(address(this));

    //     //yield
    //     uint256 senderAmount = flashStakeAmount - amountRecieved; //??

    //     uint256 feeToMint = preStakeFee / 2;

    //     //mint sncFlash fee to protocol
    //     ISNCFlash(sncFlash).mint(treasury, feeToMint);

    //     //mint unlocked liquidity in the form of sncFlash to sender
    //     ISNCFlash(sncFlash).mint(sender, senderAmount);

    //     //transfer fee to protocol
    //     IERC20(USDC).transfer(treasury, preStakeFee);

    //     //transfer upfront yield to sender
    //     IERC20(USDC).transfer(sender, senderAmount); //??
    // }
    //
    //
    //customer can deposit underlying here and recieve upfront yield from
    //FlashStake less our fee and sncFlash less our fee.
    //Sonic holds onto FlashNFT
    //
    //customer can deposit FlashNFT here and receive sncFlash less a larger
    //fee. It cheaper to deposit directly. Sonic holds onto FlashNFT
    //Check if msg.sender is current owner of FlashNFT before sending sncFlash
    //
    //Store information about FlashNFT within struct so that when its mature
    //the protocol can redeem it for underlying
    //
    //Interface for FlashStake
    //Interface for FlashNFT is IERC721
    //should be able to use getStakeInfo to get the startTime
    //so if the startTime is block.timestamp revert
    //track FlashNFTs minted to protocol
    //getStakeInfo may work here
    //charge a deposit fee?
    //take fee, divide it in half mint for half the other half is in USDC
}
