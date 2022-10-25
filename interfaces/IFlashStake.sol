// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IFlashStake {
    struct StakeStruct {
        address stakerAddress; // Address of staker
        address strategyAddress; // Address of strategy being used
        uint256 stakeStartTs; // Unix timestamp of when stake started
        uint256 stakeDuration; // Time in seconds from start time until stake ends
        uint256 stakedAmount; // The amount of tokens staked
        bool active; // Stake has been removed/unstaked
        uint256 nftId; // NFT id if set
        uint256 fTokensToUser; // How many fERC20 tokens were minted
        uint256 fTokensFee; // How many fERC20 tokens were taken as fee
        uint256 totalFTokenBurned;
        uint256 totalStakedWithdrawn;
    }

    //add stake
    //remove flashStake

    function flashStake(
        address _strategyAddress,
        uint256 _tokenAmount,
        uint256 _stakeDuration,
        uint256 _minimumReceived,
        address _yieldTo,
        bool _mintNFT
    ) external;

    function getStakeInfo(uint256 _id, bool _isNFT)
        external
        view
        returns (StakeStruct memory _stake);
}
