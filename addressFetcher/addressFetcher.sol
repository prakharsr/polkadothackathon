// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.8.0;

// A simple beginner level smart contract which returns the address of the owner who deployed the smart contract, the address of the smart contract and the address of the calling entity which calls the public getAddresses function. 

contract addressFetcher {

	address ownerAddress;
	address smartContractAddress;
	uint deployedTime;

    constructor(uint _time) {
		deployedTime = _time;
		ownerAddress = msg.sender;
		smartContractAddress = address(this);
	}
	
	function getAddresses() public view returns(address, address, address) {
		return(ownerAddress, smartContractAddress, msg.sender);
	}
}
