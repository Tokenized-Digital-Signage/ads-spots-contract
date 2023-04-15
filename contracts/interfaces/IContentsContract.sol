// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IContentsContract {
    function ownerOf(uint256 tokenId) external view returns (address);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}