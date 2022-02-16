// SPDX-License-Identifier: GPL-3.0

pragma solidity ^ 0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract MarketPlace {
    uint private nftId; 
    IERC20 public Token;
    IERC721 public NFT;
    address payable admin;

    constructor(address tokenAddress,address nftAddress) {
        Token = IERC20(tokenAddress);
        admin = payable(msg.sender);
        NFT = IERC721(nftAddress);
    }

    struct MarketNft {
        uint id;
        address nftContractAddress;
        uint tokenId;
        address payable seller;
        uint price;
        bool sold;
    }

    mapping(uint => MarketNft) private market;

    function listNft(address nftContractAddress,uint tokenId, uint price) public {
        nftId++;
        address user = msg.sender;

        market[nftId] = MarketNft(
            nftId,
            nftContractAddress,
            tokenId,
            payable(user),
            price,
            false
        );
        NFT.transferFrom(user,address(this),tokenId);
    }

    function buyNft(uint id) public {
        address user = msg.sender;
        
        uint tokenId = market[id].tokenId;

        payement(id);
        NFT.transferFrom(address(this),user,tokenId);
    }

    function payement(uint id) internal {
        address user = msg.sender;
        uint price = market[id].price;

        Token.transferFrom(user,admin,price);

    }

}