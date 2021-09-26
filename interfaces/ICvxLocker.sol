pragma solidity ^0.6.0;
// SPDX-License-Identifier: MIT


interface ICvxLocker{
    function lock(address _account, uint256 _amount, uint256 _spendRatio) external;
    function getReward(address _account, bool _stake) external;
}