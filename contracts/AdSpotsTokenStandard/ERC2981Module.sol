// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/introspection/ERC165.sol';

import './ERC2981Base.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

abstract contract ERC2981Module is ERC2981Base {
    RoyaltyInfo private _royalties;

    address[] private modules;


    function connect(address[] calldata _c) external {
        modules = _c;
    }


    function setRoyalties(address recipient, uint256 value) external {
        require(value <= 10000, 'ERC2981Royalties: Too high');
        _royalties = RoyaltyInfo(recipient, uint24(value));
    }

    function royaltyInfo(uint256, uint256 value)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        RoyaltyInfo memory royalties = _royalties;
        receiver = royalties.recipient;
        royaltyAmount = (value * royalties.amount) / 10000;
    }
}