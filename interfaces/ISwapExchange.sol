pragma solidity ^0.6.0;
// SPDX-License-Identifier: MIT

interface ISwapExchange {
    function swapExactTokensForTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external;
}