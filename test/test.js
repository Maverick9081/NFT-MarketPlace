const { expect } = require("chai");
const { ethers } = require("hardhat");
let nft;
let token;
let marketplace;


beforeEach(async function () {
    
    const Token = await ethers.getContractFactory("Token");
    token = await Token.deploy();
    tokenAddress = token.address;

    const NFT = await ethers.getContractFactory("NFT");
    nft = await NFT.deploy("URI");
    nftAddress = nft.address;


    const MarketPlace = await ethers.getContractFactory("MarketPlace");
    marketplace = await MarketPlace.deploy(tokenAddress,nftAddress);
    marketPlaceAddress = marketplace.address;
  });

  describe("MarketPlace",function(){
   
    it("should list a nft and add royalty", async function(){
      
        const [deployer, buyer] = await ethers.getSigners();
        await nft.mintTo(deployer.address);
      

        await marketplace.listNft(nftAddress,5,50);
        await marketplace.setNftRoyalty(1,deployer.address,250);
        const hey = await marketplace.getOwners(1)
     
        expect(hey[0]).to.equal(deployer.address);
    })

    it("should not let list nft if person doesn't own the nft",async function(){
        const [deployer, Add1] = await ethers.getSigners();
        await marketplace.listNft(nftAddress,5,50);
        const hi = await marketplace.onSaleNfts.length;
        console.log(hi);
        expect(hi).to.equal(0);
    })

    it("someone can Buy the nft and the royalties are paid",async function(){
        const [deployer, buyer] = await ethers.getSigners();
        await nft.mintTo(deployer.address);
        await marketplace.listNft(nftAddress,1,500);
        await marketplace.setNftRoyalty(1,deployer.address,250);
        await marketplace.setNftRoyalty(1,buyer.address,250);
        await nft.approve(marketplace.address,1);
        await token.transfer(buyer.address,90000000);
        await token.connect(buyer).approve(marketplace.address,900000);
        await marketplace.connect(buyer).buyNft(1);
        const royaltyAmount = (await marketplace.getBalance(buyer.address)).toString()
        expect(await nft.ownerOf(1)).to.equal(buyer.address);
        expect(royaltyAmount).to.equal('12'); 
    })

  })