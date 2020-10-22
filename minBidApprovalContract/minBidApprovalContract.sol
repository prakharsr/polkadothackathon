// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.8.0;

// An auction smart contract that starts an auction after some period of time, we can set the time when the auction ends also. Has an approval phase after auction ends, where the auctioneer approves if he accepts and approves the highest bid. Also, has a minimum bid amount.

contract minBidApprovalContract {
    address payable public beneficiary;
    mapping (address => uint) amountPayable;
    uint public auctionStartTime;
    uint public auctionEndTime;
    uint public approvalEndTime;
    bool isApproved;
    uint public maxBid;
    address public maxBidder;
    uint public minApproval;
    uint public getTime;
    address owner;

    constructor(uint _startTime, uint _endTime, uint _approvalEndTime, uint _minApproval, address payable _beneficiary )public {
        beneficiary = _beneficiary;
        owner = msg.sender;
        getTime = block.timestamp;
        auctionStartTime = _startTime*1000 + getTime;
        auctionEndTime = _endTime*1000 + getTime;
        approvalEndTime = _approvalEndTime*1000 + getTime;
        minApproval = _minApproval;
        isApproved = false;
    }

    modifier duringauction(uint time) {
        
        require(time >= auctionStartTime && time <= auctionEndTime && time <= approvalEndTime);
        _;
    }

    modifier approvalWait(uint time) {
        
        require(time > auctionEndTime && time <=approvalEndTime);
        _;
    }
    
    modifier isOwner() {
        require(msg.sender == payable(owner));
        _;
    }
    
    modifier isNotMaxBidder() {
        require(msg.sender != payable(maxBidder));
        _;
    }

    event maxBidRaised(address bidder, uint amount);
    event maxBidApproved(address winner, uint amount);
    
    function timeUntilAuctionEnds() public view duringauction(block.timestamp) returns (uint) {
	    return auctionEndTime - block.timestamp;
    }
    
    function timeUntilApprovalPeriodEnds() public view approvalWait(block.timestamp) returns (uint) {
        return approvalEndTime - block.timestamp;
    }

    function bid() public payable duringauction(block.timestamp){
        require(msg.value > 0 && msg.value > minApproval && msg.value > maxBid);
        if(maxBidder == address(0)) {
            amountPayable[msg.sender] = msg.value;
            maxBidder = msg.sender;
            maxBid = msg.value;
            emit maxBidRaised(msg.sender, msg.value);
        }
        else {
            amountPayable[maxBidder] += maxBid;
            maxBidder = msg.sender;
            maxBid = msg.value;
            emit maxBidRaised(msg.sender, msg.value);
        }
    }

    function withdraw() public isNotMaxBidder returns (bool) {
        uint amount = amountPayable[msg.sender];
        
        if(amount > 0) {
            amountPayable[msg.sender] = 0;
            uint128 castedAmount = uint128(amount);
            if(!msg.sender.send(castedAmount)) {
                amountPayable[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function approval() public approvalWait(block.timestamp) isOwner returns (bool){

        if(maxBid > minApproval && !isApproved) {
            isApproved = true;
            uint128 castedMaxBid = uint128(maxBid);
            if(beneficiary.send(castedMaxBid)) {
                emit maxBidApproved(maxBidder, maxBid);
                return true;
            }
        }
        return false;
    }

}