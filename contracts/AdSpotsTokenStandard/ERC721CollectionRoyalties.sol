//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

import './ERC2981CollectionRoyalties.sol';


contract ERC721WithCollectionRoyalties is
    ERC721,
    ERC2981CollectionRoyalties
{
    uint256 nextTokenId;

    constructor(string memory name_, string memory symbol_)
        ERC721(name_, symbol_)
    {}

    /// @inheritdoc	ERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC2981Base)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }


    function setRoyalties(address recipient, uint256 value) public {
        _setRoyalties(recipient, value);
    }


    function mint(address to) external {
        uint256 tokenId = nextTokenId;
        _safeMint(to, tokenId, '');

        nextTokenId = tokenId + 1;
    }


    function mintBatch(address[] memory recipients) external {
        uint256 tokenId = nextTokenId;
        for (uint256 i; i < recipients.length; i++) {
            _safeMint(recipients[i], tokenId, '');
            tokenId++;
        }

        nextTokenId = tokenId;
    }
}