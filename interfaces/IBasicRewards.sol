pragma solidity ^0.6.0;
// SPDX-License-Identifier: MIT

interface IBasicRewards{
    function getReward(address _account, bool _claimExtras) external;
    function getReward(address _account) external;
    function stakeFor(address, uint256) external;
}
