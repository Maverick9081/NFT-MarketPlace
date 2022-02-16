// SPDX-License-Identifier: GPL-3.0

pragma solidity ^ 0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ERC721.sol";

contract MarketPlace {
    uint private nftId; 
    IERC20 public Token;
    address payable admin;

    constructor(address tokenAddress) {
        Token = IERC20(tokenAddress);
        admin = payable(msg.sender);
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

        market[nftId] = MarketNft(
            nftId,
            nftContractAddress,
            tokenId,
            payable (msg.sender),
            price,
            false
        );  
    }

    function buyNft(address i,uint id) public {
        uint price = market[id].price;
        uint tokenId = market[id].tokenId;

        Token.approve(address(this),100);
        IERC20(i).transfer(admin,50);
    }

}

