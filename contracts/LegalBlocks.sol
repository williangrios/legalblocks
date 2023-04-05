//ESTA NOVA VERSAO 04/04/2023

// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract LegalBlocks is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter public tokensMinted;

    //mint price
    struct MintPrice{
        AggregatorV3Interface priceFeed ;
        int decimals;
    }
    
    //state variables
    mapping(address => bool) public whitelisted;
    mapping(address => uint) public versionControl;

    MintPrice private _mintPrice;
    uint public mintPriceInDollar = 500;
    uint public totalSupply = 1000;

    address private royaltyReceiver =
        0x2B51601fD836f86fFC0089e67d4Fbf837Abc4EF0;

    constructor() ERC721("LegalBlocks", "LB") {
        //below mumbai
        _mintPrice = MintPrice(AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada), 8);

        //below ethereum
        //_mintPrice = MintPrice(AggregatorV3Interface(0x7bAC85A8a13A4BcD8abb3eB7d6b4d632c5a57676), 8);
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
    }

    function burnNFT(uint256 tokenId) public onlyOwner {
        _burn(tokenId);
    }

    function Mint() external payable onlyWhitelisted(msg.sender)  {
        //checking total supply
        require(tokensMinted.current() <= totalSupply, "Total supply reached, it is no longer possible to mint.");
        //checking the mint price
        (uint mintPriceInWei) = returnMintPrice();
        mintPriceInWei = mintPriceInWei * 1e16;
        require(mintPriceInWei == msg.value, string(abi.encodePacked("Incorrect value. Actually the value is (wei): ", Strings.toString (mintPriceInWei))));
        //verifying the version that will be minted
        versionControl[msg.sender] ++;
        //incrementing tokenId
        tokensMinted.increment();
        uint currentToken = tokensMinted.current();
        //minting
        _mint(msg.sender, currentToken);
        _setTokenURI(currentToken, returnUri(versionControl[msg.sender]));
        //removing from whitelist
        whitelisted[msg.sender]= false;
        //sending royaltyes        
        sendRoyalty((mintPriceInWei/20));
    }

    function addToWhitelist(address[] memory addresses) external onlyOwner {
        uint i = 0;
        while (i < addresses.length) {
            whitelisted[addresses[i]] = true; 
            i++;
        }
    }

    function removeFromWhitelist(address[] memory addresses) external onlyOwner {
        uint i = 0;
        while (i < addresses.length) {
            delete whitelisted[addresses[i]];
            i++;
        }
    }

    function returnMintPrice()
        public
        view
        returns (uint)
    {
        (, int maticPriceOracle, , , ) = _mintPrice.priceFeed.latestRoundData();
        uint maticPrice =  uint(maticPriceOracle)/1e6;
        uint mint =  (mintPriceInDollar * 1e2) / maticPrice;
        return mint;
    }

    function setMintPriceInDollar(uint newMintPriceInDollar) external onlyOwner {
        mintPriceInDollar = newMintPriceInDollar;
    }

    function setTotalSupply(uint newTotalSupply) external onlyOwner {
        totalSupply = newTotalSupply;
    }

    function returnUri(uint256 tokenId) private pure returns (string memory){
        return string(
            abi.encodePacked("https://ipfs.io/ipfs/QmWPYCrQ1ZMCnSCEuL1p7hrkMM6eS3kbSY2oDuccH3ryVY/metadata", Strings.toString (tokenId), ".json")
        );
    }

    function getContractBalance() external view returns (uint){
        return address(this).balance;
    }

    function withdraw() external onlyOwner {
        // get the amount of Ether stored in this contract
        uint amount = address(this).balance;
        (bool success, ) = payable(owner()).call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    function killContract() external onlyOwner {
        selfdestruct(payable(owner()));
    }

    function sendRoyalty(uint amount) private {
        payable(royaltyReceiver).call{value: amount}("");
    }

    modifier onlyWhitelisted(address _addr) {
        require(whitelisted[_addr] == true, "You are not whitelisted");
        _;
    }
}



    // function returnMintPrice()
    //     public
    //     view
    //     returns (uint maticPriceOracle)
    // {
    //     (, int maticPriceOracle, , , ) = _mintPrice.priceFeed.latestRoundData();
    //     uint res =  uint(maticPriceOracle)/1e2;
    //     uint mint =  mintPriceInDollar / res;
    //     return uint(mint * 1e16);
    // }
