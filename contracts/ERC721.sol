// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721 { 
    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;

    string public baseTokenURI;

    constructor(string memory URI) ERC721("SAMURAI", "DOGE") {
        baseTokenURI = URI;
    }

    function mintTo(address recipient)public returns (uint256){
        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        return newItemId;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

}

