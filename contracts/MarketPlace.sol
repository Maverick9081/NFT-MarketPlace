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
        address owner;
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
            msg.sender,
            payable(user),
            price,
            false
        );
        NFT.transferFrom(user,address(this),tokenId);
    }

    function buyNft(uint id) public {
        address user = msg.sender;
        
        uint tokenId = market[id].tokenId;

        payement(user,id);
        NFT.transferFrom(address(this),user,tokenId);
        market[id].owner = user;
        market[id].sold = true;

    }

    function payement(address user, uint id) internal {
        uint price = market[id].price;
        address payable seller = market[id].seller;
        uint denominator =1000;
        uint fees = price/(25/denominator);
        Token.transferFrom(user,admin,fees);
        uint amountReceivedBySeller = price -fees;
        Token.transferFrom(user,seller,amountReceivedBySeller);
    }

    function onSaleNfts()public view returns(MarketNft [] memory){
        
        MarketNft[] memory items = new MarketNft[](nftId);

        for(uint i=0; i<=nftId; i++){
            if(market[i].sold == false){
                MarketNft memory nft = market[i];
                items[i] = nft;
            }
        }
        return items;
    }

}