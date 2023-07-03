// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTWhitelistable is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    mapping(address => bool) public whitelistedAddresses;
    string private _defaultURI;

    event TokenMinted(address indexed owner, uint256 indexed tokenId);
    event UserAdded(address indexed user);

    constructor(string memory defaultTokenURI) ERC721("BRZ Commemorative Update Token", "BRZUP") {
        _defaultURI = defaultTokenURI;
    }

    modifier isWhitelisted() {
        require(whitelistedAddresses[msg.sender], "Whitelist: You need to be whitelisted");
        _;
    }

    function safeMint() public isWhitelisted {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _defaultURI);

        emit TokenMinted(msg.sender, tokenId);
    }

    function addUsers(address[] memory _addressesToWhitelist) public onlyOwner {
        for (uint256 i = 0; i < _addressesToWhitelist.length; i++) {
            address user = _addressesToWhitelist[i];
            if (!whitelistedAddresses[user]) {
                whitelistedAddresses[user] = true;
                emit UserAdded(user);
            }
        }
    }

    function verifyUser(address _whitelistedAddress) public view returns (bool) {
        return whitelistedAddresses[_whitelistedAddress];
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
