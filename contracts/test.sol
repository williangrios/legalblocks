// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SimpleSmartContract {
    //collection
    struct Version {
        uint firstMint;
        uint version;
    }

    //state variables
    mapping(address => bool) public whitelist;
    mapping(address => Version ) public versionControl;

	function addToWhitelist(address[] memory addresses)  public {
        uint i = 0;
        while (i < addresses.length ){
            whitelist[addresses[i]] = true;
            i++;
        }
    }

    function removeFromWhitelist(address[] memory addresses)  public{
        uint i = 0;
        while (i < addresses.length ){
            delete whitelist[addresses[i]];
            i++;
        }
    }

    function mintNFT() public onlyWhitelisted(msg.sender) returns (string memory) {
		
		Version storage vers = versionControl[msg.sender];
        
		if (vers.firstMint == 0){
			vers.firstMint = block.timestamp;	
			vers.version ++;	
			return "criou primeiro";
		}else{
			//verifying if allowed to mint the next version
			require( block.timestamp >= ( vers.firstMint + (vers.version * 1 minutes)), "Only after one year");

			vers.version ++;	
			return "apenas add";
		}
    }

	modifier onlyWhitelisted (address _addr) {
        require(whitelist[_addr] == true, "You are not whitelisted");
        _;
    }

}
