pragma solidity ^0.6.0;
// SPDX-License-Identifier: MIT


interface ICvxRewards{
    function getReward(address _account, bool _claimExtras, bool _stake) external;
}