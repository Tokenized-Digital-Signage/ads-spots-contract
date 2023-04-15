// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IBunzz.sol";

contract AdsSpotToken is IERC721, ERC721Enumerable, AccessControl, Ownable, IBunzz{
    address private contentsContractAddress;
    mapping(uint256 => uint256) private linkTable;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string private baseTokenURI;
    string private baseContractURI;
    constructor (string memory name, string memory symbol, string memory baseTokenURI_,string memory baseContractURI_) ERC721(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        baseTokenURI = baseTokenURI_;
        baseContractURI = baseContractURI_;
    }

    function connectToOtherContracts(address[] calldata contracts) external override onlyOwner {
        contentsContractAddress = contracts[0];
    }
    
    using Strings for uint256;
    mapping (uint256 => string) private _tokenURIs;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function mint(address to, uint256 _tokenId) external  {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721: must have minter role to mint");

        _mint(to, _tokenId);
    }


    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }


    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

     function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function contractURI() public view returns (string memory) {
        return baseContractURI;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function getContentMetadata(uint256 tokenId) public view returns (string memory) {
        IERC721 contentsContract = IERC721(contentsContractAddress);
        uint256 contentsTokenId = linkTable[tokenId];
        return contentsContract.tokenURI(contentsTokenId);
    }

    function linkAdsSpotToContent(uint256 adsSpotTokenId, uint256 contentTokenId) private {
        IERC721 contentsContract = IERC721(contentsContractAddress);
        require(ownerOf(adsSpotTokenId) == contentsContract.ownerOf(contentTokenId));
        linkTable[adsSpotTokenId] = contentTokenId;
    }
}