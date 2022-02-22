// SPDX-License-Identifier: GPL-3.0

pragma solidity ^ 0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract MarketPlace {
    uint private nftId; 
    IERC20 public Token;
    IERC721 public NFT;
    address payable admin;
    uint private basefee = 250;

    constructor(address tokenAddress,address nftAddress) {
        Token = IERC20(tokenAddress);
        admin = payable(msg.sender);
        NFT = IERC721(nftAddress);
    }

    struct RoyaltyInfo {
        uint royaltyFraction;
    }

    mapping(uint => RoyaltyInfo) private tokenRoyaltyInfo;
    mapping(uint => address[]) private RoyaltyOwners;

    struct MarketNft {
        uint id;
        address nftContractAddress;
        uint tokenId;
        address creator;
        address payable seller;
        uint price;
        bool sold;
    }

    mapping(uint => MarketNft) private market;

    //Balance of royalties received for an address
    mapping(address => uint)private balances;

    //settinng royalty of NFT to an address
    //only creator can set NFT royalty
    function setNftRoyalty (uint id,address royaltyReceiver,uint feeNumerator) public {
        require(market[id].creator == msg.sender);
        RoyaltyOwners[id].push(royaltyReceiver);
        tokenRoyaltyInfo[id] = RoyaltyInfo(feeNumerator);
    }

    function getOwners(uint id) view public returns(address[] memory){ 
        return RoyaltyOwners[id]; 
    }

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
    }

    function buyNft(uint id) public {
       
        require(market[id].sold ==false);
        address user = msg.sender;
        address seller = market[id].seller;
        uint tokenId = market[id].tokenId;
        uint price = market[id].price;

        pay(price,user);
        NFT.transferFrom(seller,user,tokenId);
        payTheSeller(price,id,seller);
        delegateBalancesToRoyalties(id,price);
        delegateBalanceToAdmin(price);
        market[id].seller = payable(user);
        market[id].sold = true;
    }

    //putting NFT on sale after buying from marketplace

    function putNftOnSale(uint id,uint amount ) public {
        require(market[id].seller == msg.sender);
        market[id].sold = false;
        market[id].price = amount;
    }

    //Reedem balance for the royalties received

    function reddemBalance() public {
        uint amount = balances[msg.sender];
        require(amount > 100);
        Token.transfer(msg.sender,amount);
        balances[msg.sender] -= amount;
    }

    //displays NFTs on sale
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
    
    function getBalance(address account) public view returns(uint){
        return balances[account];
    }


    function getTotalRoyaltyfees(uint salePrice,uint tokenId)internal view returns(uint){
        uint feesNumerator =tokenRoyaltyInfo[tokenId].royaltyFraction;
        uint owners = RoyaltyOwners[tokenId].length;
        uint finalNumerator = feesNumerator * owners;
        return salePrice*finalNumerator/_feeDenominator();
    }
    
    function _feeDenominator() internal pure  virtual returns (uint96) {
        return 10000;
    }

    
    //allocates the Royalty fees to multiple royalty owners
    function delegateBalancesToRoyalties(uint id,uint salePrice) internal{
        uint owners = RoyaltyOwners[id].length;
        uint fees =tokenRoyaltyInfo[id].royaltyFraction;

        for(uint i=0 ; i<owners;i++){
            address receiver = RoyaltyOwners[id][i];
            uint amount = salePrice * fees/_feeDenominator();
            balances[receiver] +=amount;
        }
    }

    function adminFees(uint salePrice) internal view returns(uint){
        uint amount = salePrice*basefee/_feeDenominator();
        return amount;
    }

    function delegateBalanceToAdmin(uint salePrice) internal {
        uint amount = adminFees(salePrice);
        balances[admin] +=amount;
    }

    function payTheSeller(uint salePrice,uint id,address seller) internal {
        uint amount = salePrice-adminFees(salePrice)-getTotalRoyaltyfees(salePrice,id);
        Token.transfer(seller,amount);
    }

    //token payment from user to contract
    function pay(uint price,address user) internal{
        Token.transferFrom(user,address(this),price);
    }
}
   