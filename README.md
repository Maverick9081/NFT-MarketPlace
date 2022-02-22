# NFT Market Place Smart Contract
TOKEN_ADDRESS = "0x182AFaD041780295AF93AA1E9682100e5a47d98B"

NFT_CONTRACT_ADDRESS = "0x0892C3b5E2d88C908d4B7A5B70f91Ac949642A18"

MARKET-PLACE_CONTRACT_ADDRESS = "0x58d7276F7c11913fe95eaee3d0b6827BEc602A7b"

This NFT marketPlace smart contract allows the User to list Their NFTs to the MarketPlace and buy other NFts with the custom ERC20 tokens.The User can also set Multuple royalty owners for a single NFT in the marketplace.So Evertime someone buys their nft all the royalty owners receive royalty fees.Instead of paying all the royalty owners up front which is very heavy for gas cost, The royalty owner's fees are stored in the smart contract as their balance. Each owner can withdraw their balance as they want using Lazy evalution. 

