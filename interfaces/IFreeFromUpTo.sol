// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface IFreeFromUpTo {
    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}