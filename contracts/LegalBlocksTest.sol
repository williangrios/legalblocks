// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Burnable.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

//import "@openzeppelin/contracts/token/erc721/erc721.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/common/ERC2981.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";

contract LegalBlocks is ERC721URIStorage, ERC2981, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //collection
    struct Version{
        uint firstMint;
        uint version;
    }

    //mint price
    struct MintPrice{
        AggregatorV3Interface priceFeed ;
        int decimals;
    }
    
    //state variables
    mapping(address => bool) public whitelist;
    mapping(address => Version) public versionControl;

    MintPrice private _mintPrice;
    uint mintPriceInDollar = 500000000;

    address private royaltyReceiver =
        0x2c3744a7026388a310eEe70AFe8Cf850bAb82411;
    uint96 private _feeNumerator = 100;

    constructor() ERC721("LegalBlocks", "LB") {
        _setDefaultRoyalty(msg.sender, 100);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        _resetTokenRoyalty(tokenId);
    }

    function burnNFT(uint256 tokenId) public onlyOwner {
        _burn(tokenId);
    }

    function _mintNFT(address recipient, uint version) private returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(recipient, newItemId);
        _setTokenURI(newItemId, returnUri(version) );
        return newItemId;
    }

    function mintNFT() public onlyWhitelisted(msg.sender) returns (uint256) {
        //checking the mint price

        //verifying the version that will be minted
        Version storage vers = versionControl[msg.sender];
        if (vers.firstMint == 0) {
            vers.firstMint = block.timestamp;
            vers.version++;
        } else {
            //verifying if allowed to mint the next version
            require(
                block.timestamp >=
                    (vers.firstMint + (vers.version * 2 minutes)),
                "Only after one year"
            );
            vers.version++;
        }
        uint256 tokenId = _mintNFT(msg.sender, vers.version);
        _setTokenRoyalty(tokenId, royaltyReceiver, _feeNumerator);
        return tokenId;
    }

    function addToWhitelist(address[] memory addresses) public onlyOwner {
        uint i = 0;
        while (i < addresses.length) {
            whitelist[addresses[i]] = true;
            i++;
        }
    }

    function removeFromWhitelist(address[] memory addresses) public onlyOwner {
        uint i = 0;
        while (i < addresses.length) {
            delete whitelist[addresses[i]];
            i++;
        }
    }

    function returnMintPrice()
        public
        view
        returns (uint mintPriceInMatic, uint maticPrice)
    {
        (, int maticPriceOracle, , , ) = _mintPrice.priceFeed.latestRoundData();
        maticPrice = uint(maticPriceOracle) / 1e6; //tirando seis casas decimais
        uint value = mintPriceInDollar / maticPrice; // convertendo de volta para int
        value = value / 1e4;
        value = value * 1e6;
        return (value, maticPrice);
    }

    function setMintPriceInDollar(uint newMintPriceInDollar) public onlyOwner {
        mintPriceInDollar = newMintPriceInDollar;
    }

    function returnUri(uint256 tokenId) private pure returns (string memory){
        return string(
            abi.encodePacked("https://gateway.pinata.cloud/ipfs/QmdUpMJNfrDvxsdwdJUoeMDkuYYjVVLENvKXjp2kEkZvkx/metadata", Strings.toString (tokenId), ".json")
        );
    }

    modifier onlyWhitelisted(address _addr) {
        require(whitelist[_addr] == true, "You are not whitelisted");
        _;
    }
}

//0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
//0x909eFCa230d4FAA7A985F953E911003e3a4395b9
//0xc95c906C1A73cd7Ea3BB60aB60ab4eAD50159746
//[0xc95c906C1A73cd7Ea3BB60aB60ab4eAD50159746, 0x909eFCa230d4FAA7A985F953E911003e3a4395b9, 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266]

//link prices
//https://docs.chain.link/data-feeds/price-feeds/addresses/?network=polygon
